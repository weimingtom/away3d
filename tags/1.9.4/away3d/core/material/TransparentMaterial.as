package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
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
		
		public function shadeTriangle(tri:DrawTriangle):void
        {
        	//tri.bitmapMaterial = getBitmapReflection(tri, source);
        }
        
        public function get visible():Boolean
        {
            return false;
        }
 
    }
}
