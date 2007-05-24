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

    public class ColorShadingBitmapMaterial implements ITriangleMaterial
    {
        public var ambient:int;
        public var diffuse:int;
        public var specular:int;
        public var ambient_brightness:Number = 1;
        public var diffuse_brightness:Number = 1;
        public var specular_brightness:Number = 1;

        public var alpha:Number;
        public var smooth:Boolean = false;
        public var draw_normal:Boolean = false;
        public var draw_fall:Boolean = false;
        public var draw_fall_k:Number = 1;
        public var draw_reflect:Boolean = false;
        public var draw_reflect_k:Number = 1;

        public function ColorShadingBitmapMaterial(ambient:int, diffuse:int, specular:int, init:Object = null)
        {
            this.ambient = ambient;
            this.diffuse = diffuse;
            this.specular = specular;

            init = Init.parse(init);

            alpha = init.getNumber("alpha", 20);
        }

        public function renderTriangle(tri:DrawTriangle, session:RenderSession):void
        {
            var s0:Vertex2D = tri.v0;
            var s1:Vertex2D = tri.v1;
            var s2:Vertex2D = tri.v2;
            var projection:Projection = tri.projection;
            var focus:Number = projection.focus;
            var zoom:Number = projection.zoom;

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
            
            var d1x:Number = v1x - v0x;
            var d1y:Number = v1y - v0y;
            var d1z:Number = v1z - v0z;

            var d2x:Number = v2x - v0x;
            var d2y:Number = v2y - v0y;
            var d2z:Number = v2z - v0z;

            var pa:Number = d1y*d2z - d1z*d2y;
            var pb:Number = d1z*d2x - d1x*d2z;
            var pc:Number = d1x*d2y - d1y*d2x;
            var pdd:Number = Math.sqrt(pa*pa + pb*pb + pc*pc);
            pa /= pdd;
            pb /= pdd;
            pc /= pdd;

            var vcx:Number = (v0x + v1x + v2x) / 3;
            var vcy:Number = (v0y + v1y + v2y) / 3;
            var vcz:Number = (v0z + v1z + v2z) / 3;

            var scz:Number = vcz;
            var scx:Number = vcx * zoom * focus / (focus + vcz);
            var scy:Number = vcy * zoom * focus / (focus + vcz);

            var s01z:Number = (v0z + v1z) / 2;
            var s01x:Number = (v0x + v1x) * zoom * focus / (focus + s01z) / 2;
            var s01y:Number = (v0y + v1y) * zoom * focus / (focus + s01z) / 2;
                                                                             
            var s12z:Number = (v1z + v2z) / 2;                                
            var s12x:Number = (v1x + v2x) * zoom * focus / (focus + s12z) / 2;
            var s12y:Number = (v1y + v2y) * zoom * focus / (focus + s12z) / 2;
                                                                             
            var s20z:Number = (v2z + v0z) / 2;
            var s20x:Number = (v2x + v0x) * zoom * focus / (focus + s20z) / 2;
            var s20y:Number = (v2y + v0y) * zoom * focus / (focus + s20z) / 2;

            var kcar:Number = 0;
            var kcag:Number = 0;
            var kcab:Number = 0;
            var kcdr:Number = 0;
            var kcdg:Number = 0;
            var kcdb:Number = 0;
            var kcsr:Number = 0;
            var kcsg:Number = 0;
            var kcsb:Number = 0;

            var k0ar:Number = 0;
            var k0ag:Number = 0;
            var k0ab:Number = 0;
            var k0dr:Number = 0;
            var k0dg:Number = 0;
            var k0db:Number = 0;
            var k0sr:Number = 0;
            var k0sg:Number = 0;
            var k0sb:Number = 0;

            var k1ar:Number = 0;
            var k1ag:Number = 0;
            var k1ab:Number = 0;
            var k1dr:Number = 0;
            var k1dg:Number = 0;
            var k1db:Number = 0;
            var k1sr:Number = 0;
            var k1sg:Number = 0;
            var k1sb:Number = 0;

            var k2ar:Number = 0;
            var k2ag:Number = 0;
            var k2ab:Number = 0;
            var k2dr:Number = 0;
            var k2dg:Number = 0;
            var k2db:Number = 0;
            var k2sr:Number = 0;
            var k2sg:Number = 0;
            var k2sb:Number = 0;

            for each (var source:PointLightSource in lightarray.points)
            {
                var red:Number = source.red;
                var green:Number = source.green;
                var blue:Number = source.blue;

                var dcfx:Number = source.x - vcx;
                var dcfy:Number = source.y - vcy;
                var dcfz:Number = source.z - vcz;
                var dcf:Number = Math.sqrt(dcfx*dcfx + dcfy*dcfy + dcfz*dcfz);
                dcfx /= dcf;
                dcfy /= dcf;
                dcfz /= dcf;
                var fadec:Number = 1 / dcf / dcf;
            
                var d0fx:Number = source.x - v0x;
                var d0fy:Number = source.y - v0y;
                var d0fz:Number = source.z - v0z;
                var d0f:Number = Math.sqrt(d0fx*d0fx + d0fy*d0fy + d0fz*d0fz);
                d0fx /= d0f;
                d0fy /= d0f;
                d0fz /= d0f;
                var fade0:Number = 1 / d0f / d0f;
            
                var d1fx:Number = source.x - v1x;
                var d1fy:Number = source.y - v1y;
                var d1fz:Number = source.z - v1z;
                var d1f:Number = Math.sqrt(d1fx*d1fx + d1fy*d1fy + d1fz*d1fz);
                d1fx /= d1f;
                d1fy /= d1f;
                d1fz /= d1f;
                var fade1:Number = 1 / d1f / d1f;
            
                var d2fx:Number = source.x - v2x;
                var d2fy:Number = source.y - v2y;
                var d2fz:Number = source.z - v2z;
                var d2f:Number = Math.sqrt(d2fx*d2fx + d2fy*d2fy + d2fz*d2fz);
                d2fx /= d2f;
                d2fy /= d2f;
                d2fz /= d2f;
                var fade2:Number = 1 / d2f / d2f;
            
                var ambientc:Number = source.ambient * fadec * ambient_brightness;
                var ambient0:Number = source.ambient * fade0 * ambient_brightness;
                var ambient1:Number = source.ambient * fade1 * ambient_brightness;
                var ambient2:Number = source.ambient * fade2 * ambient_brightness;

                kcar += red * ambientc;
                kcag += green * ambientc;
                kcab += blue * ambientc;
                k0ar += red * ambient0;
                k0ag += green * ambient0;
                k0ab += blue * ambient0;
                k1ar += red * ambient1;
                k1ag += green * ambient1;
                k1ab += blue * ambient1;
                k2ar += red * ambient2;
                k2ag += green * ambient2;
                k2ab += blue * ambient2;

                var nfc:Number = dcfx*pa + dcfy*pb + dcfz*pc;
                if (nfc < 0)
                    nfc = 0;
                var nf0:Number = d0fx*pa + d0fy*pb + d0fz*pc;
                if (nf0 < 0)
                    nf0 = 0;
                var nf1:Number = d1fx*pa + d1fy*pb + d1fz*pc;
                if (nf1 < 0)
                    nf1 = 0;
                var nf2:Number = d2fx*pa + d2fy*pb + d2fz*pc;
                if (nf2 < 0)
                    nf2 = 0;

                var diffusec:Number = source.diffuse * fadec * nfc * diffuse_brightness;
                var diffuse0:Number = source.diffuse * fade0 * nf0 * diffuse_brightness;
                var diffuse1:Number = source.diffuse * fade1 * nf1 * diffuse_brightness;
                var diffuse2:Number = source.diffuse * fade2 * nf2 * diffuse_brightness;

                kcdr += red * diffusec;
                kcdg += green * diffusec;
                kcdb += blue * diffusec;
                k0dr += red * diffuse0;
                k0dg += green * diffuse0;
                k0db += blue * diffuse0;
                k1dr += red * diffuse1;
                k1dg += green * diffuse1;
                k1db += blue * diffuse1;
                k2dr += red * diffuse2;
                k2dg += green * diffuse2;
                k2db += blue * diffuse2;

                var rcfx:Number = dcfx - 2*nfc*pa;
                var rcfy:Number = dcfy - 2*nfc*pb;
                var rcfz:Number = dcfz - 2*nfc*pc;
                if (rcfz < 0)
                    rcfz = 0;
            
                var r0fx:Number = d0fx - 2*nf0*pa;
                var r0fy:Number = d0fy - 2*nf0*pb;
                var r0fz:Number = d0fz - 2*nf0*pc;
                if (r0fz < 0)
                    r0fz = 0;
            
                var r1fx:Number = d1fx - 2*nf1*pa;
                var r1fy:Number = d1fy - 2*nf1*pb;
                var r1fz:Number = d1fz - 2*nf1*pc;
                if (r1fz < 0)
                    r1fz = 0;

                var r2fx:Number = d2fx - 2*nf2*pa;
                var r2fy:Number = d2fy - 2*nf2*pb;
                var r2fz:Number = d2fz - 2*nf2*pc;
                if (r2fz < 0)
                    r2fz = 0;

                var specularc:Number = source.specular * fadec * Math.pow(rcfz, alpha) * specular_brightness;
                var specular0:Number = source.specular * fade0 * Math.pow(r0fz, alpha) * specular_brightness;
                var specular1:Number = source.specular * fade1 * Math.pow(r1fz, alpha) * specular_brightness;
                var specular2:Number = source.specular * fade2 * Math.pow(r2fz, alpha) * specular_brightness;

                kcsr += red * specularc;
                kcsg += green * specularc;
                kcsb += blue * specularc;
                k0sr += red * specular0;
                k0sg += green * specular0;
                k0sb += blue * specular0;
                k1sr += red * specular1;
                k1sg += green * specular1;
                k1sb += blue * specular1;
                k2sr += red * specular2;
                k2sg += green * specular2;
                k2sb += blue * specular2;
            }

            var colorc:int = getColor(kcar, kcag, kcab, kcdr, kcdg, kcdb, kcsr, kcsg, kcsb);
            var color0:int = getColor(k0ar, k0ag, k0ab, k0dr, k0dg, k0db, k0sr, k0sg, k0sb);
            var color1:int = getColor(k1ar, k1ag, k1ab, k1dr, k1dg, k1db, k1sr, k1sg, k1sb);
            var color2:int = getColor(k2ar, k2ag, k2ab, k2dr, k2dg, k2db, k2sr, k2sg, k2sb);

            graphics.lineStyle();
            /*
            graphics.beginGradientFill(GradientType.LINEAR, [color0, color1, color2], [1, 1, 1], [0, 127, 255]);
            graphics.moveTo(v0.x, v0.y);
            graphics.lineTo(v1.x, v1.y);
            graphics.lineTo(v2.x, v2.y);
            graphics.beginFill(color0);
            graphics.moveTo(s0.x, s0.y);
            graphics.lineTo(s01x, s01y);
            graphics.lineTo(scx, scy);
            graphics.lineTo(s20x, s20y);
            */
            var offc:Number = 0.1;
            var m:Matrix;
            m = new Matrix((scx-s0.x)*(1-offc)*10/16384, 
                           (scy-s0.y)*(1-offc)*10/16384, 
                          -(scy-s0.y)*(1-offc)*10/16384, 
                           (scx-s0.x)*(1-offc)*10/16384, 
                           (scx*(1-offc)+s0.x*(1+offc))/2, 
                           (scy*(1-offc)+s0.y*(1+offc))/2);
            graphics.beginGradientFill(GradientType.LINEAR, [color0, colorc], [1, 1], [0, 255], m);
            //graphics.beginGradientFill(GradientType.LINEAR, [0xFFFFFF, 0xFF0000, 0x000000], [1, 1, 1], [0, 127, 255], mat01);
            graphics.moveTo(s0.x, s0.y);
            graphics.lineTo(s01x, s01y);
            graphics.lineTo(scx, scy);
            graphics.lineTo(s20x, s20y);
            graphics.endFill();
            /*
            graphics.lineStyle(2, 0xFF0000);
            graphics.moveTo(s0.x, s0.y);
            graphics.lineTo(scx, scy);
            graphics.moveTo(s0.x, s0.y);
            */

            m = new Matrix((scx-s1.x)*(1-offc)*10/16384, 
                           (scy-s1.y)*(1-offc)*10/16384, 
                          -(scy-s1.y)*(1-offc)*10/16384, 
                           (scx-s1.x)*(1-offc)*10/16384, 
                           (scx*(1-offc)+s1.x*(1+offc))/2, 
                           (scy*(1-offc)+s1.y*(1+offc))/2);
            graphics.beginGradientFill(GradientType.LINEAR, [color1, colorc], [1, 1], [0, 255], m);
            graphics.moveTo(s1.x, s1.y);
            graphics.lineTo(s12x, s12y);
            graphics.lineTo(scx, scy);
            graphics.lineTo(s01x, s01y);
            graphics.endFill();

            m = new Matrix((scx-s2.x)*(1-offc)*10/16384, 
                           (scy-s2.y)*(1-offc)*10/16384, 
                          -(scy-s2.y)*(1-offc)*10/16384, 
                           (scx-s2.x)*(1-offc)*10/16384, 
                           (scx*(1-offc)+s2.x*(1+offc))/2, 
                           (scy*(1-offc)+s2.y*(1+offc))/2);
            graphics.beginGradientFill(GradientType.LINEAR, [color2, colorc], [1, 1], [0, 255], m);
            graphics.moveTo(s2.x, s2.y);
            graphics.lineTo(s20x, s20y);
            graphics.lineTo(scx, scy);
            graphics.lineTo(s12x, s12y);
            graphics.endFill();

//            render(graphics, bitmap, mapping.a, mapping.b, mapping.c, mapping.d, mapping.tx, mapping.ty, v0.x, v0.y, v1.x, v1.y, v2.x, v2.y);

            /*
            if (draw_fall || draw_reflect || draw_normal)
            {
                var cz:Number = c0z;
                var cx:Number = c0x * zoom * focus / (focus + cz);
                var cy:Number = c0y * zoom * focus / (focus + cz);

                if (draw_normal)
                {
                    var ncz:Number = (c0z + 30*pc);
                    var ncx:Number = (c0x + 30*pa) * zoom * focus / (focus + ncz);
                    var ncy:Number = (c0y + 30*pb) * zoom * focus / (focus + ncz);

                    graphics.lineStyle(1, 0x000000, 1);
                    graphics.moveTo(cx, cy);
                    graphics.lineTo(ncx, ncy);
                    graphics.moveTo(cx, cy);
                    graphics.drawCircle(cx, cy, 2);
                }

                if (draw_fall || draw_reflect)
                    for each (source in lightarray.points)
                    {
                        red = source.red;
                        green = source.green;
                        blue = source.blue;
                        var sum:Number = (red + green + blue) / 0xFF;
                        red /= sum;
                        green /= sum;
                        blue /= sum;
                
                        dfx = source.x - c0x;
                        dfy = source.y - c0y;
                        dfz = source.z - c0z;
                        df = Math.sqrt(dfx*dfx + dfy*dfy + dfz*dfz);
                        dfx /= df;
                        dfy /= df;
                        dfz /= df;
                
                        nf = dfx*pa + dfy*pb + dfz*pc;
                        if (nf < 0)
                            continue;
                
                        if (draw_fall)
                        {
                            var ffz:Number = (c0z + 30*dfz*(1-draw_fall_k));
                            var ffx:Number = (c0x + 30*dfx*(1-draw_fall_k)) * zoom * focus / (focus + ffz);
                            var ffy:Number = (c0y + 30*dfy*(1-draw_fall_k)) * zoom * focus / (focus + ffz);

                            var fz:Number = (c0z + 30*dfz);
                            var fx:Number = (c0x + 30*dfx) * zoom * focus / (focus + fz);
                            var fy:Number = (c0y + 30*dfy) * zoom * focus / (focus + fz);

                            graphics.lineStyle(1, int(red)*0x10000 + int(green)*0x100 + int(blue), 1);
                            graphics.moveTo(ffx, ffy);
                            graphics.lineTo(fx, fy);
                            graphics.moveTo(ffx, ffy);
                        }

                        if (draw_reflect)
                        {
                            rfx = dfx - 2*nf*pa;
                            rfy = dfy - 2*nf*pb;
                            rfz = dfz - 2*nf*pc;
                    
                            var rz:Number = (c0z - 30*rfz*draw_reflect_k);
                            var rx:Number = (c0x - 30*rfx*draw_reflect_k) * zoom * focus / (focus + rz);
                            var ry:Number = (c0y - 30*rfy*draw_reflect_k) * zoom * focus / (focus + rz);
                        
                            graphics.lineStyle(1, int(red/2)*0x10000 + int(green/2)*0x100 + int(blue/2), 1);
                            graphics.moveTo(cx, cy);
                            graphics.lineTo(rx, ry);
                            graphics.moveTo(cx, cy);
                        }
                    }
            }
            */
        }

        public function getColor(ar:Number, ag:Number, ab:Number, dr:Number, dg:Number, db:Number, sr:Number, sg:Number, sb:Number):int
        {
            var ac:int = ambient;
            var dc:int = diffuse;
            var sc:int = specular;

            var fr:int = int(((ac & 0xFF0000) * ar + (dc & 0xFF0000) * dr + (sc & 0xFF0000) * sr) >> 16);
            var fg:int = int(((ac & 0x00FF00) * ag + (dc & 0x00FF00) * dg + (sc & 0x00FF00) * sg) >> 8);
            var fb:int = int(((ac & 0x0000FF) * ab + (dc & 0x0000FF) * db + (sc & 0x0000FF) * sb));

            return int(fr*0x10000) + int(fg*0x100) + fb;
        }

        protected function render(graphics:Graphics, bitmap:BitmapData, a:Number, b:Number, c:Number, d:Number, tx:Number, ty:Number, 
            v0x:Number, v0y:Number, v1x:Number, v1y:Number, v2x:Number, v2y:Number):void
        {
            var a2:Number = v1x - v0x;
            var b2:Number = v1y - v0y;
            var c2:Number = v2x - v0x;
            var d2:Number = v2y - v0y;
                                   
            var matrix:Matrix = new Matrix(a*a2 + b*c2, 
                                           a*b2 + b*d2, 
                                           c*a2 + d*c2, 
                                           c*b2 + d*d2,
                                           tx*a2 + ty*c2 + v0x, 
                                           tx*b2 + ty*d2 + v0y);

            graphics.lineStyle();
            graphics.beginBitmapFill(bitmap, matrix, false, smooth);
            graphics.moveTo(v0x, v0y);
            graphics.lineTo(v1x, v1y);
            graphics.lineTo(v2x, v2y);
            graphics.endFill();

        }

        public function get visible():Boolean
        {
            return true;
        }
 
        protected static function num(v:Number):Number
        {
            return Math.round(v*1000)/1000;
        }

        protected static function ladder(v:Number):Number
        {
            return v;
            //return Math.exp(Math.round(Math.log(v)*20)/20);
        }
    }
}
