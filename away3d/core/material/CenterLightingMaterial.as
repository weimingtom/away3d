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

    import mx.core.BitmapAsset;

    public class CenterLightingMaterial implements ITriangleMaterial
    {
        public var ambient_brightness:Number = 1;
        public var diffuse_brightness:Number = 1;
        public var specular_brightness:Number = 1;

        public var alpha:Number;
        public var draw_normal:Boolean = false;
        public var draw_fall:Boolean = false;
        public var draw_fall_k:Number = 1;
        public var draw_reflect:Boolean = false;
        public var draw_reflect_k:Number = 1;

        public function CenterLightingMaterial(alpha:Number = 20)
        {
            this.alpha = alpha;
        }

        public function renderTriangle(tri:DrawTriangle, graphics:Graphics, clip:Clipping, lightarray:LightArray):void
        {
            var v0:Vertex2D = tri.v0;
            var v1:Vertex2D = tri.v1;
            var v2:Vertex2D = tri.v2;
            var projection:Projection = tri.projection;
            var focus:Number = projection.focus;
            var zoom:Number = projection.zoom;

            var v0z:Number = v0.z;
            var v0p:Number = (1 + v0z / focus) / zoom;
            var v0x:Number = v0.x * v0p;
            var v0y:Number = v0.y * v0p;

            var v1z:Number = v1.z;
            var v1p:Number = (1 + v1z / focus) / zoom;
            var v1x:Number = v1.x * v1p;
            var v1y:Number = v1.y * v1p;

            var v2z:Number = v2.z;
            var v2p:Number = (1 + v2z / focus) / zoom;
            var v2x:Number = v2.x * v2p;
            var v2y:Number = v2.y * v2p;
            
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

            var c0x:Number = (v0x + v1x + v2x) / 3;
            var c0y:Number = (v0y + v1y + v2y) / 3;
            var c0z:Number = (v0z + v1z + v2z) / 3;

            var kar:Number = 0;
            var kag:Number = 0;
            var kab:Number = 0;
            var kdr:Number = 0;
            var kdg:Number = 0;
            var kdb:Number = 0;
            var ksr:Number = 0;
            var ksg:Number = 0;
            var ksb:Number = 0;

            for each (var source:PointLightSource in lightarray.points)
            {
                var red:Number = source.red;
                var green:Number = source.green;
                var blue:Number = source.blue;

                var dfx:Number = source.x - c0x;
                var dfy:Number = source.y - c0y;
                var dfz:Number = source.z - c0z;
                var df:Number = Math.sqrt(dfx*dfx + dfy*dfy + dfz*dfz);
                dfx /= df;
                dfy /= df;
                dfz /= df;
                var fade:Number = 1 / df / df;
            
                var ambient:Number = source.ambient * fade * ambient_brightness;

                kar += red * ambient;
                kag += green * ambient;
                kab += blue * ambient;

                var nf:Number = dfx*pa + dfy*pb + dfz*pc;
                if (nf < 0)
                    continue;

                var diffuse:Number = source.diffuse * fade * nf * diffuse_brightness;

                kdr += red * diffuse;
                kdg += green * diffuse;
                kdb += blue * diffuse;

                var rfx:Number = dfx - 2*nf*pa;
                var rfy:Number = dfy - 2*nf*pb;
                var rfz:Number = dfz - 2*nf*pc;
            
                if (rfz < 0)
                    continue;

                var specular:Number = source.specular * fade * Math.pow(rfz, alpha) * specular_brightness;

                ksr += red * specular;
                ksg += green * specular;
                ksb += blue * specular;
            }

            renderTri(tri, graphics, clip, kar, kag, kab, kdr, kdg, kdb, ksr, ksg, ksb);

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
        }

        public function renderTri(tri:DrawTriangle, graphics:Graphics, clip:Clipping, kar:Number, kag:Number, kab:Number, kdr:Number, kdg:Number, kdb:Number, ksr:Number, ksg:Number, ksb:Number):void
        {
            throw new Error("Not implemented");
        }

        public function get visible():Boolean
        {
            throw new Error("Not implemented");
        }
    }
}
