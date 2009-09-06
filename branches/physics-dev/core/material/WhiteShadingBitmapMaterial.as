package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.geom.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;

    import flash.display.Graphics;
    import flash.display.BitmapData;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.ColorTransform;
    import flash.utils.*;

    import mx.core.BitmapAsset;

    public class WhiteShadingBitmapMaterial extends CenterLightingMaterial implements IUVMaterial
    {
        public var diffuse:BitmapData;
        public var smooth:Boolean = false;
        
        protected var _width:int;
        protected var _height:int;
        protected var _transform:Matrix = new Matrix();
        protected var _normal:Number3D = new Number3D(0,0,0);
        protected var _repeat:Boolean = false;
        protected var _scalex:Boolean = false;
        protected var _scaley:Boolean = false;
        
        public var blackrender:Boolean;
        public var whiterender:Boolean;
        public var whitek:Number = 0.2;

        public function get width():Number
        {
            return _width;
        }

        public function get height():Number
        {
            return _height;
        }
        
        public function get transform():Matrix
        {
            return _transform;
        }
        
        public function get normal():Number3D
        {
            return _normal;
        }
                
        public function get repeat():Boolean
        {
            return _repeat;
        }
        
        public function get scalex():Boolean
        {
            return _scalex;
        }
        
        public function get scaley():Boolean
        {
            return _scaley;
        }
        
        public function WhiteShadingBitmapMaterial(diffuse:BitmapData, init:Object)
        {
            super(init);

            this.diffuse = diffuse;
            _width = diffuse.width;
            _height = diffuse.height;

            init = Init.parse(init);

            smooth = init.getBoolean("smooth", false);
            _transform = init.getObject("transform", new Matrix());
            _normal = init.getNumber3D("normal");
            _repeat = init.getBoolean("repeat", false);
            _scalex = init.getBoolean("scalex", false);
            _scaley = init.getBoolean("scaley", false);
        }

        private var cache:Dictionary = new Dictionary();

        private var step:int = 1;

        public function doubleStepTo(limit:int):void
        {
            if (step < limit)
                step *= 2;
        }

        public override function renderTri(tri:DrawTriangle, session:RenderSession, kar:Number, kag:Number, kab:Number, kdr:Number, kdg:Number, kdb:Number, ksr:Number, ksg:Number, ksb:Number):void
        {
            var mapping:Matrix = tri.texturemapping || tri.transformUV(this);
            var v0:Vertex2D = tri.v0;
            var v1:Vertex2D = tri.v1;
            var v2:Vertex2D = tri.v2;
            var graphics:Graphics = session.graphics;
            var br:Number = (kar + kag + kab + kdr + kdg + kdb + ksr + ksg + ksb) / 3;
            if ((br < 1) && (blackrender || step < 16))
            {
                RenderTriangle.renderBitmap(graphics, diffuse, mapping.a, mapping.b, mapping.c, mapping.d, mapping.tx, mapping.ty, v0.x, v0.y, v1.x, v1.y, v2.x, v2.y, smooth, repeat);
                RenderTriangle.renderColor(graphics, 0x000000, 1 - br, v0.x, v0.y, v1.x, v1.y, v2.x, v2.y);
            }
            else
            if ((br > 1) && (whiterender))
            {
                RenderTriangle.renderBitmap(graphics, diffuse, mapping.a, mapping.b, mapping.c, mapping.d, mapping.tx, mapping.ty, v0.x, v0.y, v1.x, v1.y, v2.x, v2.y, smooth, repeat);
                RenderTriangle.renderColor(graphics, 0xFFFFFF, (br - 1)*whitek, v0.x, v0.y, v1.x, v1.y, v2.x, v2.y);
            }
            else
            {
                var brightness:Number = ladder(br);
                var bitmap:BitmapData = cache[brightness];
                if (bitmap == null)
                {
                    bitmap = diffuse.clone();
                    bitmap.colorTransform(bitmap.rect, new ColorTransform(brightness, brightness, brightness));
                    cache[brightness] = bitmap;
                }
                RenderTriangle.renderBitmap(graphics, bitmap, mapping.a, mapping.b, mapping.c, mapping.d, mapping.tx, mapping.ty, v0.x, v0.y, v1.x, v1.y, v2.x, v2.y, smooth, repeat);
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