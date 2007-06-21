package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;

    /** Camera transform, including perspective distortion */
    public class Projection
    {
        public var view:Matrix3D;
		public var transform:Matrix3D;
        public var focus:Number;
        public var zoom:Number;

        public function Projection(view:View3D, transform:Matrix3D = null)
        {
        	this.transform = transform;
            this.view = Matrix3D.multiply(view.camera.getView(), transform);
            this.focus = view.camera.focus;
            this.zoom = view.camera.zoom;
        }
    }
}
