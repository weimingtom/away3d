package away3d.core.scene
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.mesh.*;
    
    /** Camera in 3D-space */
    public class Camera3D extends Object3D
    {
        public var zoom:Number;
        public var focus:Number;
    
        public function Camera3D(init:Object = null)
        {
            super(init);

            init = Init.parse(init);

            zoom = init.getNumber("zoom", 10);
            focus = init.getNumber("focus", 100);
            var lookat:Object3D = init.getObject3D("lookat");

            if (lookat != null)
                lookAt(lookat.position);
        }
    
        public function get view():Matrix3D
        {
            return Matrix3D.inverse(Matrix3D.multiply(scene ? world : transform, _flipY));
        }
    
        public function screen(object:Object3D, vertex:Vertex = null):ScreenVertex
        {
            use namespace arcane;

            if (vertex == null)
                vertex = new Vertex(0,0,0);

            return vertex.project(new Projection(Matrix3D.multiply(view, object.world), focus, zoom));
        }
    
        private static var _flipY:Matrix3D = Matrix3D.scaleMatrix(1, -1, 1);
    
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
    }
}
