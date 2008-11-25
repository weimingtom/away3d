package away3d.cameras
{
    import away3d.arcane;
    import away3d.cameras.lenses.*;
    import away3d.core.base.*;
    import away3d.core.clip.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;
    import away3d.events.CameraEvent;
    
    import flash.utils.*;
    
	use namespace arcane;
	
	/**
	 * Dispatched when the focus or zoom properties of a camera update.
	 * 
	 * @eventType away3d.events.CameraEvent
	 * 
	 * @see #focus
	 * @see #zoom
	 */
	[Event(name="cameraUpdated",type="away3d.events.CameraEvent")]
	
	/**
	 * Basic camera used to resolve a view.
	 * 
	 * @see	away3d.containers.View3D
	 */
    public class Camera3D extends Object3D
    {
    	private var _fovDirty:Boolean;
    	private var _zoomDirty:Boolean;
        private var _aperture:Number = 22;
    	private var _dof:Boolean = false;
        private var _flipY:Matrix3D = new Matrix3D();
        private var _focus:Number;
        private var _zoom:Number;
        private var _lens:AbstractLens;
        private var _fov:Number;
        private var _clipTop:Number;
        private var _clipBottom:Number;
        private var _clipLeft:Number;
        private var _clipRight:Number;
        private var _fovRatio:Number;
    	private var _view:Matrix3D = new Matrix3D();
        private var _screenVertex:ScreenVertex = new ScreenVertex();
        private var _vtActive:Array = new Array();
        private var _vtStore:Array = new Array();
        private var _vt:Matrix3D;
		private var _cameraupdated:CameraEvent;
		private var _x:Number;
		private var _y:Number;
		private var _z:Number;
		private var _sz:Number;
		private var _persp:Number;
		
        private function notifyCameraUpdate():void
        {
            if (!hasEventListener(CameraEvent.CAMERA_UPDATED))
                return;
			
            if (_cameraupdated == null)
                _cameraupdated = new CameraEvent(CameraEvent.CAMERA_UPDATED, this);
                
            dispatchEvent(_cameraupdated);
        }
        
        protected const toRADIANS:Number = Math.PI/180;
		protected const toDEGREES:Number = 180/Math.PI;
		
    	public var invView:Matrix3D = new Matrix3D();
    	
        /**
        * Dictionary of all objects transforms calulated from the camera view for the last render frame
        */
        public var viewTransforms:Dictionary;
        
        public function createViewTransform(node:Object3D):Matrix3D
        {
        	if (_vtStore.length)
        		_vtActive.push(_vt = viewTransforms[node] = _vtStore.pop());
        	else
        		_vtActive.push(_vt = viewTransforms[node] = new Matrix3D());
        	
        	return _vt
        }
        
        public function clearViewTransforms():void
        {
        	viewTransforms = new Dictionary(true);
        	_vtStore = _vtStore.concat(_vtActive);
        	_vtActive = new Array();
        }
        
		/**
		 * Used in <code>DofSprite2D</code>.
		 * 
		 * @see	away3d.sprites.DofSprite2D
		 */
		public function get aperture():Number
		{
			return _aperture;
		}
		
		public function set aperture(value:Number):void
		{
			_aperture = value;
			DofCache.aperture = _aperture;
		}
        
		/**
		 * Used in <code>DofSprite2D</code>.
		 * 
		 * @see	away3d.sprites.DofSprite2D
		 */
		public function get dof():Boolean
		{
			return _dof;
		}
		
		public function set dof(value:Boolean):void
		{
			_dof = value;
			if (_dof)
				enableDof();
			else
				disableDof();
		}		
		/**
		 * A divisor value for the perspective depth of the view.
		 */
		public function get focus():Number
		{
			return _focus;
		}
		
		public function set focus(value:Number):void
		{
			_focus = value;			
			DofCache.focus = _focus;
			notifyCameraUpdate();
		}
		
		/**
		 * Provides an overall scale value to the view
		 */
		public function get zoom():Number
		{
			return _zoom;
		}
		
		public function set zoom(value:Number):void
		{
			_zoom = value;
			notifyCameraUpdate();
		}
		
		/**
		 * Defines a lens object used in vertex projection
		 */
		public function get lens():AbstractLens
		{
			return _lens;
		}
		
		public function set lens(value:AbstractLens):void
		{
			_lens = value;
			
			if (_lens)
				_lens.camera = this;
			
			notifyCameraUpdate();
		}
		
		/**
		 * Defines the field of view of the camera in a vertical direction.
		 */
		public function get fov():Number
		{
			return _fov;
		}
		
		public function set fov(value:Number):void
		{
			_fov = value;
		}
		
		/**
		 * Used in <code>DofSprite2D</code>.
		 * 
		 * @see	away3d.sprites.DofSprite2D
		 */
        public var maxblur:Number = 150;
        
        /**
		 * Used in <code>DofSprite2D</code>.
		 * 
		 * @see	away3d.sprites.DofSprite2D
		 */
        public var doflevels:Number = 16;
    	
		/**
		 * Creates a new <code>Camera3D</code> object.
		 * 
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function Camera3D(init:Object = null)
        {
            super(init);
            
            zoom = ini.getNumber("zoom", 10);
            focus = ini.getNumber("focus", 100);
            lens = ini.getObject("lens", AbstractLens) as AbstractLens;
            aperture = ini.getNumber("aperture", 22);
            maxblur = ini.getNumber("maxblur", 150);
	        doflevels = ini.getNumber("doflevels", 16);
            dof = ini.getBoolean("dof", false);
            
            var lookat:Number3D = ini.getPosition("lookat");
			
			_flipY.syy = -1;
			
            if (lookat)
                lookAt(lookat);
            
            if (!lens)
            	lens = new PerspectiveLens();
        }
        
        /**
		 * Used in <code>DofSprite2D</code>.
		 * 
		 * @see	away3d.sprites.DofSprite2D
		 */
        public function enableDof():void
        {
        	DofCache.doflevels = doflevels;
          	DofCache.aperture = aperture;
        	DofCache.maxblur = maxblur;
        	DofCache.focus = focus;
        	DofCache.resetDof(true);
        }
                
        /**
		 * Used in <code>DofSprite2D</code>
		 * 
		 * @see	away3d.sprites.DofSprite2D
		 */
        public function disableDof():void
        {
        	DofCache.resetDof(false);
        }
        
		/**
		 * Returns the transformation matrix used to resolve the scene to the view.
		 * Used in the <code>ProjectionTraverser</code> class
		 * 
		 * @see	away3d.core.traverse.ProjectionTraverser
		 */
        public function get view():Matrix3D
        {
        	invView.multiply(sceneTransform, _flipY);
        	_view.inverse(invView);
        	return _view;
        }
    	

    	
    	/**
    	 * Returns a <code>ScreenVertex</code> object describing the resolved x and y position of the given <code>Vertex</code> object.
    	 * 
    	 * @param	object	The local object for the Vertex. If none exists, use the <code>Scene3D</code> object.
    	 * @param	vertex	The vertex to be resolved.
    	 * 
    	 * @see	away3d.containers.Scene3D
    	 */
        public function screen(object:Object3D, vertex:Vertex = null):ScreenVertex
        {
            if (vertex == null)
                vertex = new Vertex(0,0,0);
                
			createViewTransform(object).multiply(view, object.sceneTransform);
            lens.project(viewTransforms[object], vertex, _screenVertex);
            
            return _screenVertex
        }
    	        
		/**
		 * Updates the transformation matrix used to resolve the scene to the view.
		 * Used in the <code>BasicRender</code> class
		 * 
		 * @see	away3d.core.render.BasicRender
		 */
        public function update(clip:Clipping):void
        {
        	
        	if (_clipTop != clip.maxY || _clipBottom != clip.minY || _clipLeft != clip.minX || _clipRight != clip.maxX)
        		_fovDirty = true;
        	
        	_clipTop = clip.maxY;
        	_clipBottom = clip.minY;
        	_clipLeft = clip.minX;
        	_clipRight = clip.maxX;
        	
        	if (_fovDirty) {
        		_fovRatio = clip.maxY - clip.minY;
        		_fov = (Math.atan2(_clipTop, _focus*_zoom)*_clipTop/_fovRatio - Math.atan2(_clipBottom, _focus*_zoom)*_clipBottom/_fovRatio)*toDEGREES;
        	}
        	
        	if (_zoomDirty) {
        		_fovRatio = _clipTop - _clipBottom;
        		_zoom = (_clipTop/Math.tan(_fov*toRADIANS*_clipTop/_fovRatio) + _clipBottom/Math.tan(_fov*toRADIANS*_clipBottom/_fovRatio))/_focus;
        	}
        	
        	lens.clip = clip;
        		
        	//lens.updateView(clip, _zoom, _focus, _near, _far, sceneTransform, _flipY);
        }
        
		/**
		 * Rotates the camera in its vertical plane.
		 * 
		 * Tilting the camera results in a motion similar to someone nodding their head "yes".
		 * 
		 * @param	angle	Angle to tilt the camera.
		 */
        public function tilt(angle:Number):void
        {
            super.pitch(angle);
        }
    	
		/**
		 * Rotates the camera in its horizontal plane.
		 * 
		 * Panning the camera results in a motion similar to someone shaking their head "no".
		 * 
		 * @param	angle	Angle to pan the camera.
		 */
        public function pan(angle:Number):void
        {
            super.yaw(angle);
        }
		
		/**
		 * Duplicates the camera's properties to another <code>Camera3D</code> object.
		 * 
		 * @param	object	[optional]	The new object instance into which all properties are copied.
		 * @return						The new object instance with duplicated properties applied.
		 */
        public override function clone(object:Object3D = null):Object3D
        {
            var camera:Camera3D = (object as Camera3D) || new Camera3D();
            super.clone(camera);
            camera.zoom = zoom;
            camera.focus = focus;
            camera.lens = lens;
            return camera;
        }
		
		/**
		 * Default method for adding a cameraUpdated event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnCameraUpdate(listener:Function):void
        {
            addEventListener(CameraEvent.CAMERA_UPDATED, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a cameraUpdated event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnCameraUpdate(listener:Function):void
        {
            removeEventListener(CameraEvent.CAMERA_UPDATED, listener, false);
        }
    }
}
