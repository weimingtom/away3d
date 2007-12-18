package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.mesh.*;
    import away3d.core.render.*;
    import away3d.core.scene.*;
    import away3d.core.utils.*;
    
    import flash.display.Graphics;

    /** Abstract class for materials that calculate lighting for the face's center */
    public class CenterLightingMaterial implements ITriangleMaterial
    {
        public var ambient_brightness:Number = 1;
        public var diffuse_brightness:Number = 1;
        public var specular_brightness:Number = 1;
        public var ak:Number = 20;
        
        public var draw_normal:Boolean = false;
        public var draw_fall:Boolean = false;
        public var draw_fall_k:Number = 1;
        public var draw_reflect:Boolean = false;
        public var draw_reflect_k:Number = 1;

        public function CenterLightingMaterial(init:Object = null)
        {
            init = Init.parse(init);

            ak = init.getNumber("ak", 20);
        }
		
		internal var source:PointLightSource;
        internal var v0:ScreenVertex;
        internal var v1:ScreenVertex;
        internal var v2:ScreenVertex;
        internal var projection:Projection;
        internal var focus:Number;
        internal var zoom:Number;
        
        internal var v0z:Number;
        internal var v0p:Number;
        internal var v0x:Number;
        internal var v0y:Number;
        
        internal var v1z:Number;
        internal var v1p:Number;
        internal var v1x:Number;
        internal var v1y:Number;
        
        internal var v2z:Number;
        internal var v2p:Number;
        internal var v2x:Number;
        internal var v2y:Number;
        
        internal var d1x:Number;
        internal var d1y:Number;
        internal var d1z:Number;
        
        internal var d2x:Number;
        internal var d2y:Number;
        internal var d2z:Number;
        
        internal var pa:Number;
        internal var pb:Number;
        internal var pc:Number;
        internal var pdd:Number;
        
        internal var c0x:Number;
        internal var c0y:Number;
        internal var c0z:Number;
        
        internal var kar:Number;
        internal var kag:Number;
        internal var kab:Number;
        internal var kdr:Number;
        internal var kdg:Number;
        internal var kdb:Number;
        internal var ksr:Number;
        internal var ksg:Number;
        internal var ksb:Number;
        
        internal var red:Number;
        internal var green:Number;
        internal var blue:Number;
        
        internal var dfx:Number;
        internal var dfy:Number;
        internal var dfz:Number;
        internal var df:Number;
        
        internal var fade:Number;
        internal var amb:Number;
        internal var nf:Number;
        
        internal var diff:Number;
        internal var rfx:Number;
        internal var rfy:Number;
        internal var rfz:Number;
        
        internal var spec:Number;
        
        internal var graphics:Graphics;
        
        internal var cz:Number;
        internal var cx:Number;
        internal var cy:Number;
        
        internal var ncz:Number;
        internal var ncx:Number;
        internal var ncy:Number;
        
        internal var sum:Number;
        
        internal var ffz:Number;
        internal var ffx:Number;
        internal var ffy:Number;
        
        internal var fz:Number;
        internal var fx:Number;
        internal var fy:Number;
        
        internal var rz:Number;
        internal var rx:Number;
        internal var ry:Number;
        
        internal var session:RenderSession;
        
        public function renderTriangle(tri:DrawTriangle):void
        {
        	session = tri.source.session;
            v0 = tri.v0;
            v1 = tri.v1;
            v2 = tri.v2;
            projection = tri.projection;
            focus = projection.focus;
            zoom = projection.zoom;

            v0z = v0.z;
            v0p = (1 + v0z / focus) / zoom;
            v0x = v0.x * v0p;
            v0y = v0.y * v0p;

            v1z = v1.z;
            v1p = (1 + v1z / focus) / zoom;
            v1x = v1.x * v1p;
            v1y = v1.y * v1p;

            v2z = v2.z;
            v2p = (1 + v2z / focus) / zoom;
            v2x = v2.x * v2p;
            v2y = v2.y * v2p;
            
            d1x = v1x - v0x;
            d1y = v1y - v0y;
            d1z = v1z - v0z;

            d2x = v2x - v0x;
            d2y = v2y - v0y;
            d2z = v2z - v0z;

            pa = d1y*d2z - d1z*d2y;
            pb = d1z*d2x - d1x*d2z;
            pc = d1x*d2y - d1y*d2x;
            pdd = Math.sqrt(pa*pa + pb*pb + pc*pc);
            
            pa /= pdd;
            pb /= pdd;
            pc /= pdd;

            c0x = (v0x + v1x + v2x) / 3;
            c0y = (v0y + v1y + v2y) / 3;
            c0z = (v0z + v1z + v2z) / 3;

            kar = kag = kab = kdr = kdg = kdb = ksr = ksg = ksb = 0;

            for each (source in session.lightarray.points)
            {
                red = source.red;
                green = source.green;
                blue = source.blue;

                dfx = source.x - c0x;
                dfy = source.y - c0y;
                dfz = source.z - c0z;
                df = Math.sqrt(dfx*dfx + dfy*dfy + dfz*dfz);
                dfx /= df;
                dfy /= df;
                dfz /= df;
                
                fade = 1 / df / df;
                amb = source.ambient * fade * ambient_brightness;
                //amb = source.ambient * ambient_brightness;
                nf = dfx*pa + dfy*pb + dfz*pc;

                kar += red * amb;
                kag += green * amb;
                kab += blue * amb;

                if (nf < 0)
                    continue;

                diff = source.diffuse * fade * nf * diffuse_brightness;
                //diff = source.diffuse * nf * diffuse_brightness;
                rfx = dfx - 2*nf*pa;
                rfy = dfy - 2*nf*pb;
                rfz = dfz - 2*nf*pc;

                kdr += red * diff;
                kdg += green * diff;
                kdb += blue * diff;

                if (rfz < 0)
                    continue;

                spec = source.specular * fade * Math.pow(rfz, ak) * specular_brightness;

                ksr += red * spec;
                ksg += green * spec;
                ksb += blue * spec;
            }

            renderTri(tri, session, kar, kag, kab, kdr, kdg, kdb, ksr, ksg, ksb);

            if (draw_fall || draw_reflect || draw_normal)
            {
                graphics = session.graphics,
                cz = c0z,
                cx = c0x * zoom / (1 + cz / focus),
                cy = c0y * zoom / (1 + cz / focus);
                
                if (draw_normal)
                {
                    ncz = (c0z + 30*pc),
                    ncx = (c0x + 30*pa) * zoom * focus / (focus + ncz),
                    ncy = (c0y + 30*pb) * zoom * focus / (focus + ncz);

                    graphics.lineStyle(1, 0x000000, 1);
                    graphics.moveTo(cx, cy);
                    graphics.lineTo(ncx, ncy);
                    graphics.moveTo(cx, cy);
                    graphics.drawCircle(cx, cy, 2);
                }

                if (draw_fall || draw_reflect)
                    for each (source in session.lightarray.points)
                    {
                        red = source.red;
                        green = source.green;
                        blue = source.blue;
                        sum = (red + green + blue) / 0xFF;
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
                            ffz = (c0z + 30*dfz*(1-draw_fall_k)),
                            ffx = (c0x + 30*dfx*(1-draw_fall_k)) * zoom * focus / (focus + ffz),
                            ffy = (c0y + 30*dfy*(1-draw_fall_k)) * zoom * focus / (focus + ffz),

                            fz = (c0z + 30*dfz),
                            fx = (c0x + 30*dfx) * zoom * focus / (focus + fz),
                            fy = (c0y + 30*dfy) * zoom * focus / (focus + fz);

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
                    
                            rz = (c0z - 30*rfz*draw_reflect_k),
                            rx = (c0x - 30*rfx*draw_reflect_k) * zoom * focus / (focus + rz),
                            ry = (c0y - 30*rfy*draw_reflect_k) * zoom * focus / (focus + rz);
                        
                            graphics.lineStyle(1, int(red*0.5)*0x10000 + int(green*0.5)*0x100 + int(blue*0.5), 1);
                            graphics.moveTo(cx, cy);
                            graphics.lineTo(rx, ry);
                            graphics.moveTo(cx, cy);
                        }
                    }
            }
        }

        public function renderTri(tri:DrawTriangle, session:RenderSession, kar:Number, kag:Number, kab:Number, kdr:Number, kdg:Number, kdb:Number, ksr:Number, ksg:Number, ksb:Number):void
        {
            throw new Error("Not implemented");
        }

		public function shadeTriangle(tri:DrawTriangle):void
        {
        	//tri.bitmapMaterial = getBitmapReflection(tri, source);
        }
        
        public function get visible():Boolean
        {
            throw new Error("Not implemented");
        }
    }
}
