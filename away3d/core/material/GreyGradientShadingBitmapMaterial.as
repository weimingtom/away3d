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
    import flash.display.GradientType;
    import flash.geom.Matrix;
    import flash.geom.Point;

    import mx.core.BitmapAsset;

    public class GreyGradientShadingBitmapMaterial extends CornerLightingMaterial implements IUVMaterial
    {
        public var diffuse:BitmapData;
        public var smooth:Boolean;

        protected var _width:int;
        protected var _height:int;

        private static var whitewhite:Array = [0xFFFFFF, 0xFFFFFF];
        private static var blackblack:Array = [0, 0];
        private static var zero255:Array = [0, 255];

        public function get width():Number
        {
            return _width;
        }

        public function get height():Number
        {
            return _height;
        }

        public function GreyGradientShadingBitmapMaterial(diffuse:BitmapData, alpha:Number = 10, smooth:Boolean = false)
        {
            super(alpha);

            this.diffuse = diffuse;
            this.smooth = smooth;
            _width = diffuse.width;
            _height = diffuse.height;
        }

        public override function renderTri(tri:DrawTriangle, graphics:Graphics, clip:Clipping, 
            kcar:Number, kcag:Number, kcab:Number, kcdr:Number, kcdg:Number, kcdb:Number, kcsr:Number, kcsg:Number, kcsb:Number,
            k0ar:Number, k0ag:Number, k0ab:Number, k0dr:Number, k0dg:Number, k0db:Number, k0sr:Number, k0sg:Number, k0sb:Number,
            k1ar:Number, k1ag:Number, k1ab:Number, k1dr:Number, k1dg:Number, k1db:Number, k1sr:Number, k1sg:Number, k1sb:Number,
            k2ar:Number, k2ag:Number, k2ab:Number, k2dr:Number, k2dg:Number, k2db:Number, k2sr:Number, k2sg:Number, k2sb:Number):void
        {
            var mapping:Matrix = tri.texturemapping || tri.transformUV(this);
            var s0:Vertex2D = tri.v0;
            var s1:Vertex2D = tri.v1;
            var s2:Vertex2D = tri.v2;
            var s0x:Number = s0.x;
            var s0y:Number = s0.y;
            var s1x:Number = s1.x;
            var s1y:Number = s1.y;
            var s2x:Number = s2.x;
            var s2y:Number = s2.y;

            var br:Number = (kcar + kcag + kcab + kcdr + kcdg + kcdb + kcsr + kcsg + kcsb) / 3;
            var br0:Number = (k0ar + k0ag + k0ab + k0dr + k0dg + k0db + k0sr + k0sg + k0sb) / 3;
            var br1:Number = (k1ar + k1ag + k1ab + k1dr + k1dg + k1db + k1sr + k1sg + k1sb) / 3;
            var br2:Number = (k2ar + k2ag + k2ab + k2dr + k2dg + k2db + k2sr + k2sg + k2sb) / 3;
            RenderTriangle.renderBitmap(graphics, diffuse, mapping.a, mapping.b, mapping.c, mapping.d, mapping.tx, mapping.ty, s0.x, s0.y, s1.x, s1.y, s2.x, s2.y, smooth, repeat);

            /*
            var s0:Vertex2D = tri.v0;
            var s1:Vertex2D = tri.v1;
            var s2:Vertex2D = tri.v2;

            var v0z:Number = s0.z;
            var v0p:Number = (1 + v0z / focus) / zoom;
            var v0x:Number = s0.x * v0p;
            var v0y:Number = s0.y * v0p;

            var v1z:Number = s1.z;
            var v1p:Number = (1 + v1z / focus) / zoom;
            var v1x:Number = s1.x * v1p;
            var v1y:Number = s1.y * v1p;

            var v2z:Number = s2.z;
            var v2p:Number = (1 + v2z / focus) / zoom;
            var v2x:Number = s2.x * v2p;
            var v2y:Number = s2.y * v2p;
            
            var vcx:Number = (v0x + v1x + v2x) / 3;
            var vcy:Number = (v0y + v1y + v2y) / 3;
            var vcz:Number = (v0z + v1z + v2z) / 3;

            var scz:Number = vcz;
            var scx:Number = vcx * zoom * focus / (focus + vcz);
            var scy:Number = vcy * zoom * focus / (focus + vcz);
            */
/*
            br0 = 1;
            br1 = 0;
            br2 = 0.5;
 */
            var maxbr:Number = Math.max(br0, Math.max(br1, br2));
            var minbr:Number = Math.min(br0, Math.min(br1, br2));

            if ((maxbr - minbr < 0.01) || ((maxbr-1)*(minbr-1) < -0.01) || (br1 == br2) || (br0 == br1) || (br2 == br0))
            {
                if (br < 1)
                    RenderTriangle.renderColor(graphics, 0x000000, 1 - br, s0.x, s0.y, s1.x, s1.y, s2.x, s2.y);
                if (br > 1)
                    RenderTriangle.renderColor(graphics, 0xFFFFFF, (br - 1)*0.2, s0.x, s0.y, s1.x, s1.y, s2.x, s2.y);
                return;
            }
///*
            var e01:Number = (s0x - s1x)*(s0x - s1x) + (s0y - s1y)*(s0y - s1y);
            var e12:Number = (s1x - s2x)*(s1x - s2x) + (s1y - s2y)*(s1y - s2y);
            var e20:Number = (s2x - s0x)*(s2x - s0x) + (s2y - s0y)*(s2y - s0y);
            var maxe:Number = Math.max(e01, Math.max(e12, e20));
//*/           
            var m:Matrix;
            if (maxbr <= 1)
            {
                /*
                TODO Full 3-point gradient
                br0 *= 2; br0 -= 1;
                br1 *= 2; br1 -= 1;
                br2 *= 2; br2 -= 1;

                if ((br0 >= br1) && (br0 >= br2))
                {
                    var a:Number = (2*s0x - s1x - s2x) / (2*br0 - br1 - br2);
                    var x:Number = s0x - a*br0;
                    var b:Number = s1x + x - a*br0;
                    var c:Number = (2*s0y - s1y - s2y) / (2*br0 - br1 - br2);
                    var y:Number = s0y - c*br0;
                    var d:Number = s1y + y - c*br0;

                    var m:Matrix = new Matrix(a, b, c, d, x, y);
                    m.scale(10/16384, 10/16384);
                    RenderTriangle.renderBitmap(graphics, diffuse, mapping.a, mapping.b, mapping.c, mapping.d, mapping.tx, mapping.ty, s0.x, s0.y, s1.x, s1.y, s2.x, s2.y, smooth, repeat);
                    graphics.beginGradientFill(GradientType.LINEAR, blackblack, [1, 0], zero255, m);
                    graphics.moveTo(s0.x, s0.y);
                    graphics.lineTo(s1.x, s1.y);
                    graphics.lineTo(s2.x, s2.y);
                    graphics.endFill();
                    return;
                }
                */

//                if (((br0 >= br1) && (br1 >= br2)) || ((br0 <= br1) && (br1 <= br2)))
                if (e20 == maxe)
                {
                    m = new Matrix((s2x-s0.x)*10/16384, 
                                   (s2y-s0.y)*10/16384, 
                                  -(s2y-s0.y)*10/16384, 
                                   (s2x-s0.x)*10/16384, 
                                   (s2x+s0.x)/2, 
                                   (s2y+s0.y)/2);
                    graphics.beginGradientFill(GradientType.LINEAR, blackblack, [1-br0, 1-br2], zero255, m);
                    graphics.moveTo(s0.x, s0.y);
                    graphics.lineTo(s1.x, s1.y);
                    graphics.lineTo(s2.x, s2.y);
                    graphics.endFill();
                    return;
                }
//                if (((br0 >= br2) && (br2 >= br1)) || ((br0 <= br2) && (br2 <= br1)))
                if (e01 == maxe)
                {
                    m = new Matrix((s1x-s0.x)*10/16384, 
                                   (s1y-s0.y)*10/16384, 
                                  -(s1y-s0.y)*10/16384, 
                                   (s1x-s0.x)*10/16384, 
                                   (s1x+s0.x)/2, 
                                   (s1y+s0.y)/2);
                    graphics.beginGradientFill(GradientType.LINEAR, blackblack, [1-br0, 1-br1], zero255, m);
                    graphics.moveTo(s0.x, s0.y);
                    graphics.lineTo(s1.x, s1.y);
                    graphics.lineTo(s2.x, s2.y);
                    graphics.endFill();
                    return;
                }
//                if (((br1 >= br0) && (br0 >= br2)) || ((br1 <= br0) && (br0 <= br2)))
                if (e12 == maxe)
                {
                    m = new Matrix((s2x-s1.x)*10/16384, 
                                   (s2y-s1.y)*10/16384, 
                                  -(s2y-s1.y)*10/16384, 
                                   (s2x-s1.x)*10/16384, 
                                   (s2x+s1.x)/2, 
                                   (s2y+s1.y)/2);
                    graphics.beginGradientFill(GradientType.LINEAR, blackblack, [1-br1, 1-br2], zero255, m);
                    graphics.moveTo(s0.x, s0.y);
                    graphics.lineTo(s1.x, s1.y);
                    graphics.lineTo(s2.x, s2.y);
                    graphics.endFill();
                    return;
                }

            }

            if (maxbr >= 1)
            {
//                if (((br0 >= br1) && (br1 >= br2)) || ((br0 <= br1) && (br1 <= br2)))
                if (e20 == maxe)
                {
                    m = new Matrix((s2x-s0.x)*10/16384, 
                                   (s2y-s0.y)*10/16384, 
                                  -(s2y-s0.y)*10/16384, 
                                   (s2x-s0.x)*10/16384, 
                                   (s2x+s0.x)/2, 
                                   (s2y+s0.y)/2);
                    graphics.beginGradientFill(GradientType.LINEAR, whitewhite, [(br0-1)*0.2, (br2-1)*0.2], zero255, m);
                    graphics.moveTo(s0.x, s0.y);
                    graphics.lineTo(s1.x, s1.y);
                    graphics.lineTo(s2.x, s2.y);
                    graphics.endFill();
                    return;
                }
//                if (((br0 >= br2) && (br2 >= br1)) || ((br0 <= br2) && (br2 <= br1)))
                if (e01 == maxe)
                {
                    m = new Matrix((s1x-s0.x)*10/16384, 
                                   (s1y-s0.y)*10/16384, 
                                  -(s1y-s0.y)*10/16384, 
                                   (s1x-s0.x)*10/16384, 
                                   (s1x+s0.x)/2, 
                                   (s1y+s0.y)/2);
                    graphics.beginGradientFill(GradientType.LINEAR, whitewhite, [(br0-1)*0.2, (br1-1)*0.2], zero255, m);
                    graphics.moveTo(s0.x, s0.y);
                    graphics.lineTo(s1.x, s1.y);
                    graphics.lineTo(s2.x, s2.y);
                    graphics.endFill();
                    return;
                }
//                if (((br1 >= br0) && (br0 >= br2)) || ((br1 <= br0) && (br0 <= br2)))
                if (e12 == maxe)
                {
                    m = new Matrix((s2x-s1.x)*10/16384, 
                                   (s2y-s1.y)*10/16384, 
                                  -(s2y-s1.y)*10/16384, 
                                   (s2x-s1.x)*10/16384, 
                                   (s2x+s1.x)/2, 
                                   (s2y+s1.y)/2);
                    graphics.beginGradientFill(GradientType.LINEAR, whitewhite, [(br1-1)*0.2, (br2-1)*0.2], zero255, m);
                    graphics.moveTo(s0.x, s0.y);
                    graphics.lineTo(s1.x, s1.y);
                    graphics.lineTo(s2.x, s2.y);
                    graphics.endFill();
                    return;
                }

            }
      /*
            if (br < 1)
            {
                RenderTriangle.renderColor(graphics, 0x000000, 1 - br, s0.x, s0.y, s1.x, s1.y, s2.x, s2.y);
                return;
            }
            if (br > 1)
            {
                RenderTriangle.renderColor(graphics, 0xFFFFFF, (br - 1)*0.2, s0.x, s0.y, s1.x, s1.y, s2.x, s2.y);
                return;
            }
      */
        }

        public override function get visible():Boolean
        {
            return true;
        }

        protected static function num(v:Number):Number
        {
            return Math.round(v*1000)/1000;
        }

    }
}
