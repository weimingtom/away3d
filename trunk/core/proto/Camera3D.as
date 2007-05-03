package away3d.core.proto
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    
    // The Camera3D class is the base class for all the cameras that can be placed in a scene.
    // A camera defines the view from which a scene will be rendered. Different camera settings would present a scene from different points of view.
    // 3D cameras simulate still-image, motion picture, or video cameras of the real world. When rendering, the scene is drawn as if you were looking through the camera lens.
    public class Camera3D extends Object3D
    {
        // This value specifies the scale at which the 3D objects are rendered. Higher values magnify the scene, compressing distance. Use it in conjunction with focus.
        public var zoom:Number;
    
        // This value is a positive number representing the distance of the observer from the front clipping plane, which is the closest any object can be to the camera. Use it in conjunction with zoom.
        // Higher focus values tend to magnify distance between objects while allowing greater depth of field, as if the camera had a wider lenses. One result of using a wide angle lens in proximity to the subject is an apparent perspective distortion: parallel lines may appear to converge and with a fisheye lens, straight edges will appear to bend.
        // Different lenses generally require a different camera to subject distance to preserve the size of a subject. Changing the angle of view can indirectly distort perspective, modifying the apparent relative size of the subject and foreground.
        public var focus:Number;
    
        // The Camera3D constructor lets you create cameras for setting up the view from which a scene will be rendered.
        // Its initial position can be specified in the init.
        // @param zoom This value specifies the scale at which the 3D objects are rendered. Higher values magnify the scene, compressing distance. Use it in conjunction with focus.
        // @param focus This value is a positive number representing the distance of the observer from the front clipping plane, which is the closest any object can be to the camera. Use it in conjunction with zoom.
        // @param init An optional object that contains user defined properties with which to populate the newly created Object3D.
        // It includes x, y, z, rotationX, rotationY, rotationZ, scaleX, scaleY scaleZ and a user defined extra object.
        // If extra is not an object, it is ignored. All properties of the extra field are copied into the new instance. The properties specified with extra are publicly available.
        // The following init property is also recognized by the constructor:
        // sort: A Boolean value that determines whether the 3D objects are z-depth sorted between themselves when rendering. The default value is true.
        public function Camera3D(zoom:Number = 3, focus:Number = 500, init:Object = null)
        {
            super(null, init);
    
            if (init == null)
            {
                x = 1000;
                y = 1000;
                z = 1000;
            }

            this.zoom  = zoom;
            this.focus = focus;
        }
    
        public function getView():Matrix3D
        {
            return Matrix3D.inverse(Matrix3D.multiply(transform, _flipY));
        }
    
        static private var _flipY:Matrix3D = Matrix3D.scaleMatrix(1, -1, 1);
    
        // Rotate the camera in its vertical plane.
        // Tilting the camera results in a motion similar to someone nodding their head "yes".
        // @param    angle   Angle to tilt the camera.
        public function tilt(angle:Number):void
        {
            super.pitch(angle);
        }
    
        // Rotate the camera in its horizontal plane.
        // Panning the camera results in a motion similar to someone shaking their head "no".
        // @param    angle   Angle to pan the camera.
        public function pan(angle:Number):void
        {
            super.yaw(angle);
        }
    }
}
