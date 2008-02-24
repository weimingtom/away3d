package away3d.core.scene
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.mesh.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;
    
    /** Camera in 3D-space */
    public class Camera3D extends Object3D
    {
        public var zoom:Number;
        public var focus:Number;
    	
    	private var _view:Matrix3D = new Matrix3D();
    	
        public function Camera3D(init:Object = null)
        {
            super(init);

            init = Init.parse(init);

            zoom = init.getNumber("zoom", 10);
            focus = init.getNumber("focus", 100);
            var lookat:Number3D = init.getPosition("lookat");
			
			_flipY.syy = -1;
			
            if (lookat != null)
                lookAt(lookat);
        }
    
        public function get view():Matrix3D
        {
        	_view.multiply(sceneTransform, _flipY);
        	_view.inverse(_view);
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
            var camera:Camera3D = camera || new Camera3D();
            super.clone(camera);
            camera.zoom = zoom;
            camera.focus = focus;
            return camera;
        }
    }
}
