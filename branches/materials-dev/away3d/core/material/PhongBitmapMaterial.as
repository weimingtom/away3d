package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;

    import flash.display.*;
    import flash.geom.*;

    /** Basic phong texture material */
    public class PhongBitmapMaterial extends BitmapMaterial
    {
        public var bitmapMaterial:BitmapData;
        
        public function PhongBitmapMaterial(bitmap:BitmapData, init:Object = null)
        {
            super(bitmap, init);

            init = Init.parse(init);
        }
        
        public override function renderTriangle(tri:DrawTriangle, session:RenderSession):void
        {
        	mapping = tri.texturemapping || tri.transformUV(this);
        	
        	bitmapMaterial = tri.face.getBitmapMaterial(tri.material as PhongBitmapMaterial);
			bitmapMaterial.draw(tri.face.getBitmapPhong(), null, null, BlendMode.MULTIPLY);
            session.renderTriangleBitmap(bitmapMaterial, mapping, tri.v0, tri.v1, tri.v2, smooth, repeat);
            //bitmapMaterial.dispose();
			
            if (debug)
                session.renderTriangleLine(2, 0x0000FF, 1, tri.v0, tri.v1, tri.v2);
        }
 
    }
}
