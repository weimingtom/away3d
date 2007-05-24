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

    public class CornerLightingMaterial implements ITriangleMaterial
    {
        public var ambient_brightness:Number = 1;
        public var diffuse_brightness:Number = 1;
        public var specular_brightness:Number = 1;

        public var alpha:Number = 20;

        public function CornerLightingMaterial(init:Object = null)
        {
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

            renderTri(tri, graphics, clip,
                kcar, kcag, kcab, kcdr, kcdg, kcdb, kcsr, kcsg, kcsb,
                k0ar, k0ag, k0ab, k0dr, k0dg, k0db, k0sr, k0sg, k0sb,
                k1ar, k1ag, k1ab, k1dr, k1dg, k1db, k1sr, k1sg, k1sb,
                k2ar, k2ag, k2ab, k2dr, k2dg, k2db, k2sr, k2sg, k2sb);
        }

        public function renderTri(tri:DrawTriangle, graphics:Graphics, clip:Clipping, 
            kcar:Number, kcag:Number, kcab:Number, kcdr:Number, kcdg:Number, kcdb:Number, kcsr:Number, kcsg:Number, kcsb:Number,
            k0ar:Number, k0ag:Number, k0ab:Number, k0dr:Number, k0dg:Number, k0db:Number, k0sr:Number, k0sg:Number, k0sb:Number,
            k1ar:Number, k1ag:Number, k1ab:Number, k1dr:Number, k1dg:Number, k1db:Number, k1sr:Number, k1sg:Number, k1sb:Number,
            k2ar:Number, k2ag:Number, k2ab:Number, k2dr:Number, k2dg:Number, k2db:Number, k2sr:Number, k2sg:Number, k2sb:Number):void
        {
            throw new Error("Not implemented");
        }

        public function get visible():Boolean
        {
            throw new Error("Not implemented");
        }

    }
}
