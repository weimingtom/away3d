package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;

    import flash.display.Graphics;
    import flash.display.BitmapData;
    import flash.geom.Matrix;
    import flash.geom.Point;

    import mx.core.BitmapAsset;

    public class BitmapMaterial implements ITriangleMaterial, IUVMaterial
    {
        public var bitmap:BitmapData;
        public var smooth:Boolean;
        public var debug:Boolean;

        public function get width():Number
        {
            return bitmap.width;
        }

        public function get height():Number
        {
            return bitmap.height;
        }

        public function BitmapMaterial(bitmap:BitmapData, smooth:Boolean = false, debug:Boolean = false)
        {
            this.bitmap = bitmap;
            this.smooth = smooth;
            this.debug = debug;
        }

        public static function fromAsset(asset:BitmapAsset, smooth:Boolean = false, debug:Boolean = false):BitmapMaterial
        {
            return new BitmapMaterial(asset.bitmapData, smooth, debug);
        }

        public function renderTriangle(tri:DrawTriangle, graphics:Graphics, clip:Clipping, lightarray:LightArray):void
        {
            var mapping:Matrix = tri.texturemapping || tri.transformUV(this);
            var v0:Vertex2D = tri.v0;
            var v1:Vertex2D = tri.v1;
            var v2:Vertex2D = tri.v2;

            RenderTriangle.renderBitmap(graphics, bitmap, mapping.a, mapping.b, mapping.c, mapping.d, mapping.tx, mapping.ty, v0.x, v0.y, v1.x, v1.y, v2.x, v2.y, smooth);

            if (debug)
            {
                graphics.lineStyle(2, 0x0000FF);
                graphics.moveTo(tri.v0.x, tri.v0.y);
                graphics.lineTo(tri.v1.x, tri.v1.y);
                graphics.lineTo(tri.v2.x, tri.v2.y);
                graphics.lineTo(tri.v0.x, tri.v0.y);
            }
        }

        public function get visible():Boolean
        {
            return true;
        }
 
    }
}
