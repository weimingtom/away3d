package away3d.materials
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.base.*
    import away3d.core.draw.*;
    import away3d.core.render.*;

    public final class TransparentMaterial implements ITriangleMaterial, ISegmentMaterial
    {
        public static var INSTANCE:TransparentMaterial = new TransparentMaterial();

        public function TransparentMaterial()
        {
        }

        public function renderSegment(seg:DrawSegment):void
        {
        }

        public function renderTriangle(tri:DrawTriangle):void
        {
        }
        
        public function get visible():Boolean
        {
            return false;
        }
 
    }
}
