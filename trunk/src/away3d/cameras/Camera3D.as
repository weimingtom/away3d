package away3d.cameras
{
    import away3d.core.*;
    import away3d.core.base.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;
    import away3d.sprites.dof.DofCache;
    
    import flash.utils.getTimer;
    
    /** Camera in 3D-space */
    public class Camera3D extends Object3D
    {
        public var zoom:Number;
        
        
        // Depth of field parameters
        private var _aperture:Number = 22;
        private var _focus:Number;               

		public function set aperture(value:Number):void
		{
			_aperture = value;
			DofCache.aperture = _aperture;
		}
		
		public function get aperture():Number
		{
			return _aperture;			
		}
		
		public function set focus(value:Number):void
		{
			_focus = value;			
			DofCache.focus = _focus;
		}
		
		public function get focus():Number
		{
			return _focus;
		}
		

        public var maxblur:Number = 150;
        public var doflevels:Number = 16;
    	public var usedof:Boolean = false;
    	
    	private var _view:Matrix3D = new Matrix3D();
    	
        public function Camera3D(init:Object = null)
        {
            super(init);

            init = Init.parse(init);
            zoom = (init as Init).getNumber("zoom", 10);
            focus = (init as Init).getNumber("focus", 100);
            usedof = (init as Init).getBoolean("dof", false);
            if(usedof)
            {
	            aperture = (init as Init).getNumber("aperture", 22);
	            maxblur = (init as Init).getNumber("maxblur", 150);
    	        doflevels = (init as Init).getNumber("doflevels", 16);            	
				enableDof();            	
            }
            else
            {
            	disableDof();
            }
            
            var lookat:Number3D = (init as Init).getPosition("lookat");
			
			_flipY.syy = -1;
			
            if (lookat != null)
                lookAt(lookat);
        }
        
        public function enableDof():void
        {
        	DofCache.doflevels = doflevels;
          	DofCache.aperture = aperture;
        	DofCache.maxblur = maxblur;
        	DofCache.focus = focus;
        	DofCache.resetDof(true);
        }
        
        public function disableDof():void
        {
        	DofCache.resetDof(false);
        }
        
        public var invView:Matrix3D = new Matrix3D();
        
        public function get view():Matrix3D
        {
        	_view.multiply(sceneTransform, _flipY);
        	invView.clone(_view);
        	_view.inverse(invView);
        	return _view;
        }
    	
    	internal var screenProjection:Projection = new Projection();
    	
        public function screen(object:Object3D, vertex:Vertex = null):ScreenVertex
        {
            use namespace arcane;

            if (vertex == null)
                vertex = new Vertex(0,0,0);
			object.viewTransform.multiply(view, object.sceneTransform);
			screenProjection.view = object.viewTransform;
			screenProjection.focus = focus;
			screenProjection.zoom = zoom;
			screenProjection.time = getTimer();
            return vertex.project(screenProjection);
        }
    
        private var _flipY:Matrix3D = new Matrix3D();
    
       /**
        * Rotate the camera in its vertical plane.
        * Tilting the camera results in a motion similar to someone nodding their head "yes".
        * @param angle Angle to tilt the camera.
        */
        public function tilt(angle:Number):void
        {
            super.pitch(angle);
        }
    
       /**
        * Rotate the camera in its horizontal plane.
        * Panning the camera results in a motion similar to someone shaking their head "no".
        * @param angle Angle to pan the camera.
        */
        public function pan(angle:Number):void
        {
            super.yaw(angle);
        }

        public override function clone(object:* = null):*
        {
            var camera:Camera3D = object || new Camera3D();
            super.clone(camera);
            camera.zoom = zoom;
            camera.focus = focus;
            return camera;
        }
    }
}
