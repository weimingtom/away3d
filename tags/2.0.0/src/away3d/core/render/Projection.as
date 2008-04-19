package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.math.*;

    /** Camera transform, including perspective distortion */
    public class Projection
    {
        public var view:Matrix3D;
        public var focus:Number;
        public var zoom:Number;
        public var time:int;

        public function Projection()
        {
        }
    }
}
