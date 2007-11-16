package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.mesh.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;

    import flash.display.BitmapData;
    import flash.geom.Matrix;
    import flash.geom.ColorTransform;
    import flash.utils.Dictionary;

    /** Bitmap material that takes average of color lightings as a white lighting */
    public class WhiteShadingBitmapMaterial extends CenterLightingMaterial implements IUVMaterial
    {
        public var diffuse:BitmapData;
        public var smooth:Boolean;
        public var repeat:Boolean;
        
        public var blackrender:Boolean;
        public var whiterender:Boolean;
        public var whitek:Number = 0.2;

        public function get width():Number
        {
            return diffuse.width;
        }

        public function get height():Number
        {
            return diffuse.height;
        }
        
        public function WhiteShadingBitmapMaterial(diffuse:BitmapData, init:Object = null)
        {
            super(init);

            this.diffuse = diffuse;

            init = Init.parse(init);

            smooth = init.getBoolean("smooth", false);
            repeat = init.getBoolean("repeat", false);
        }

        private var cache:Dictionary = new Dictionary();

        private var step:int = 1;

        public function doubleStepTo(limit:int):void
        {
            if (step < limit)
                step *= 2;
        }
		
		internal var mapping:Matrix;
		
		internal var br:Number;
		
        public override function renderTri(tri:DrawTriangle, session:RenderSession, kar:Number, kag:Number, kab:Number, kdr:Number, kdg:Number, kdb:Number, ksr:Number, ksg:Number, ksb:Number):void
        {
            br = (kar + kag + kab + kdr + kdg + kdb + ksr + ksg + ksb) / 3;
            
            mapping = tri.texturemapping || tri.transformUV(this);
            v0 = tri.v0;
            v1 = tri.v1;
            v2 = tri.v2;
            
            if ((br < 1) && (blackrender || ((step < 16) && (!diffuse.transparent))))
            {
                session.renderTriangleBitmap(diffuse, mapping, v0, v1, v2, smooth, repeat);
                session.renderTriangleColor(0x000000, 1 - br, v0, v1, v2);
            }
            else
            if ((br > 1) && (whiterender))
            {
                session.renderTriangleBitmap(diffuse, mapping, v0, v1, v2, smooth, repeat);
                session.renderTriangleColor(0xFFFFFF, (br - 1)*whitek, v0, v1, v2);
            }
            else
            {
                if (step < 64)
                    if (Math.random() < 0.01)
                        doubleStepTo(64);
                var brightness:Number = ladder(br);
                var bitmap:BitmapData = cache[brightness];
                if (bitmap == null)
                {
                    bitmap = diffuse.clone();
                    bitmap.colorTransform(bitmap.rect, new ColorTransform(brightness, brightness, brightness));
                    cache[brightness] = bitmap;
                }
                session.renderTriangleBitmap(bitmap, mapping, v0, v1, v2, smooth, repeat);
            }
        }

        public override function get visible():Boolean
        {
            return true;
        }
 
        protected function ladder(v:Number):Number
        {
            if (v < 1/0xFF)
                return 0;
            if (v > 0xFF)
                v = 0xFF;
            return Math.exp(Math.round(Math.log(v)*step)/step);
        }
    }
}
