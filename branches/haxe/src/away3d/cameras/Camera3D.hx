package away3d.cameras;

    import away3d.arcane;
    import away3d.core.base.*;
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
	/*[Event(name="cameraUpdated",type="away3d.events.CameraEvent")]*/
	
	/**
	 * Basic camera used to resolve a view.
	 * 
	 * @see	away3d.containers.View3D
	 */
    class Camera3D extends Object3D {
        public var aperture(getAperture, setAperture) : Float;
        public var dof(getDof, setDof) : Bool;
        public var focus(getFocus, setFocus) : Float;
        public var fov(getFov, setFov) : Float;
        public var view(getView, null) : Matrix3D
        ;
        public var zoom(getZoom, setZoom) : Float;
        
        var _aperture:Int ;
    	var _dof:Bool ;
        var _flipY:Matrix3D ;
        var _focus:Float;
        var _zoom:Float;
        var _fov:Float;
    	var _view:Matrix3D ;
        var _screenVertex:ScreenVertex ;
        var _vtActive:Array<Dynamic> ;
        var _vtStore:Array<Dynamic> ;
        var _vt:Matrix3D;
		var _cameraupdated:CameraEvent;
		var _x:Float;
		var _y:Float;
		var _z:Float;
		var _sz:Float;
		var _persp:Float;
		
        function notifyCameraUpdate():Void
        {
            if (!hasEventListener(CameraEvent.CAMERA_UPDATED))
                return;
			
            if (_cameraupdated == null)
                _cameraupdated = new CameraEvent(CameraEvent.CAMERA_UPDATED, this);
                
            dispatchEvent(_cameraupdated);
        }
        
    	public var invView:Matrix3D ;
    	
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
        
        public function clearViewTransforms():Void
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
		public function getAperture():Float{
			return _aperture;
		}
		
		public function setAperture(value:Float):Float{
			_aperture = value;
			DofCache.aperture = _aperture;
			return value;
		}
        
		/**
		 * Used in <code>DofSprite2D</code>.
		 * 
		 * @see	away3d.sprites.DofSprite2D
		 */
		public function getDof():Bool{
			return _dof;
		}
		
		public function setDof(value:Bool):Bool{
			_dof = value;
			if (_dof)
				enableDof();
			else
				disableDof();
			return value;
		}		
		/**
		 * A divisor value for the perspective depth of the view.
		 */
		public function getFocus():Float{
			return _focus;
		}
		
		public function setFocus(value:Float):Float{
			_focus = value;			
			DofCache.focus = _focus;
			notifyCameraUpdate();
			return value;
		}
		
		/**
		 * Provides an overall scale value to the view
		 */
		public function getZoom():Float{
			return _zoom;
		}
		
		public function setZoom(value:Float):Float{
			_zoom = value;
			notifyCameraUpdate();
			return value;
		}
		
		/**
		 * Defines the field of view of the camera in a vertical direction.
		 */
		public function getFov():Float{
			return _fov;
		}
		
		public function setFov(value:Float):Float{
			_fov = value;
			return value;
		}
		
		/**
		 * Used in <code>DofSprite2D</code>.
		 * 
		 * @see	away3d.sprites.DofSprite2D
		 */
        public var maxblur:Int ;
        
        /**
		 * Used in <code>DofSprite2D</code>.
		 * 
		 * @see	away3d.sprites.DofSprite2D
		 */
        public var doflevels:Int ;
    	
		/**
		 * Creates a new <code>Camera3D</code> object.
		 * 
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function new(?init:Dynamic = null)
        {
            
            _aperture = 22;
            _dof = false;
            _flipY = new Matrix3D();
            _view = new Matrix3D();
            _screenVertex = new ScreenVertex();
            _vtActive = new Array();
            _vtStore = new Array();
            invView = new Matrix3D();
            maxblur = 150;
            doflevels = 16;
            super(init);
            
            zoom = ini.getNumber("zoom", 10);
            focus = ini.getNumber("focus", 100);
            aperture = ini.getNumber("aperture", 22);
            maxblur = ini.getNumber("maxblur", 150);
	        doflevels = ini.getNumber("doflevels", 16);
            dof = ini.getBoolean("dof", false);
            
            var lookat:Number3D = ini.getPosition("lookat");
			
			_flipY.syy = -1;
			
            if (lookat != null)
                lookAt(lookat);
        }
        
        /**
		 * Used in <code>DofSprite2D</code>.
		 * 
		 * @see	away3d.sprites.DofSprite2D
		 */
        public function enableDof():Void
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
        public function disableDof():Void
        {
        	DofCache.resetDof(false);
        }
        
		/**
		 * Returns the transformation matrix used to resolve the scene to the view.
		 * Used in the <code>ProjectionTraverser</code> class
		 * 
		 * @see	away3d.core.traverse.ProjectionTraverser
		 */
        public function getView():Matrix3D
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
        public function screen(object:Object3D, ?vertex:Vertex = null):ScreenVertex
        {
            if (vertex == null)
                vertex = new Vertex(0,0,0);
                
			createViewTransform(object).multiply(view, object.sceneTransform);
            project(viewTransforms[object], vertex, _screenVertex);
            
            return _screenVertex
        }
        
       /**
        * Projects the vertex to the screen space of the view.
        */
        public function project(viewTransform:Matrix3D, vertex:Vertex, screenvertex:ScreenVertex):Void
        {
        	_x = vertex.x;
        	_y = vertex.y;
        	_z = vertex.z;
        	
            _sz = _x * viewTransform.szx + _y * viewTransform.szy + _z * viewTransform.szz + viewTransform.tz;
    		/*/
    		//modified
    		var wx:Number = x * view.sxx + y * view.sxy + z * view.sxz + view.tx;
    		var wy:Number = x * view.syx + y * view.syy + z * view.syz + view.ty;
    		var wz:Number = x * view.szx + y * view.szy + z * view.szz + view.tz;
			var wx2:Number = Math.pow(wx, 2);
			var wy2:Number = Math.pow(wy, 2);
    		var c:Number = Math.sqrt(wx2 + wy2 + wz*wz);
			var c2:Number = (wx2 + wy2);
			persp = c2? projection.focus*(c - wz)/c2 : 0;
			sz = (c != 0 && wz != -c)? c*Math.sqrt(0.5 + 0.5*wz/c) : 0;
			//*/
    		//end modified
    		
            if (isNaN(_sz))
                throw new Error("isNaN(sz)");
            
            if (_sz*2 <= -focus) {
                screenvertex.visible = false;
                return;
            } else {
                screenvertex.visible = true;
            }

         	_persp = zoom / (1 + _sz / focus);

            screenvertex.x = (_x * viewTransform.sxx + _y * viewTransform.sxy + _z * viewTransform.sxz + viewTransform.tx) * _persp;
            screenvertex.y = (_x * viewTransform.syx + _y * viewTransform.syy + _z * viewTransform.syz + viewTransform.ty) * _persp;
            screenvertex.z = _sz;
            /*
            projected.x = wx * persp;
            projected.y = wy * persp;
			*/
        }
    	
		/**
		 * Rotates the camera in its vertical plane.
		 * 
		 * Tilting the camera results in a motion similar to someone nodding their head "yes".
		 * 
		 * @param	angle	Angle to tilt the camera.
		 */
        public function tilt(angle:Float):Void
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
        public function pan(angle:Float):Void
        {
            super.yaw(angle);
        }
		
		/**
		 * Duplicates the camera's properties to another <code>Camera3D</code> object.
		 * 
		 * @param	object	[optional]	The new object instance into which all properties are copied.
		 * @return						The new object instance with duplicated properties applied.
		 */
        public override function clone(?object:Object3D = null):Object3D
        {
            var camera:Camera3D = (cast( object, Camera3D)) || new Camera3D();
            super.clone(camera);
            camera.zoom = zoom;
            camera.focus = focus;
            return camera;
        }
		
		/**
		 * Default method for adding a cameraUpdated event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnCameraUpdate(listener:Dynamic):Void
        {
            addEventListener(CameraEvent.CAMERA_UPDATED, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a cameraUpdated event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnCameraUpdate(listener:Dynamic):Void
        {
            removeEventListener(CameraEvent.CAMERA_UPDATED, listener, false);
        }
    }
