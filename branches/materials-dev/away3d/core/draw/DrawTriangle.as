package away3d.core.draw
{
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.mesh.*;
    import away3d.core.render.*;
    import away3d.core.scene.*;
    
    import flash.display.*;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
	
    /** Triangle drawing primitive */
    public class DrawTriangle extends DrawPrimitive
    {
        use namespace arcane;

        public var v0:ScreenVertex;
        public var v1:ScreenVertex;
        public var v2:ScreenVertex;
        public var uv0:UV;
        public var uv1:UV;
        public var uv2:UV;
        public var area:Number;

        public var face:Face;
		public var object:Mesh;
		
        public var material:ITriangleMaterial;
		public var bitmapMaterial:BitmapData;
		public var bitmapPhong:BitmapData;
		public var bitmapNormal:BitmapData;
		
		public var bitmapRect:Rectangle;
		public var normalRect:Rectangle;
        
        public var texturemapping:Matrix;

        public override function clear():void
        {
            v0 = null;
            v1 = null;
            v2 = null;
            uv0 = null;
            uv1 = null;
            uv2 = null;
            texturemapping = null;
        }

        public override function render(session:RenderSession):void
        {
            material.renderTriangle(this, session);
        }

        public final function maxEdgeSqr():Number
        {
            return Math.max(Math.max(ScreenVertex.distanceSqr(v0, v1),
            							ScreenVertex.distanceSqr(v1, v2)),
            							ScreenVertex.distanceSqr(v2, v0));
        }

        public final function minEdgeSqr():Number
        {
            return Math.min(Math.min(ScreenVertex.distanceSqr(v0, v1),
            							ScreenVertex.distanceSqr(v1, v2)),
            							ScreenVertex.distanceSqr(v2, v0));
        }

        public final function maxDistortSqr(focus:Number):Number
        {
            return Math.max(Math.max(ScreenVertex.distortSqr(v0, v1, focus),
            							ScreenVertex.distortSqr(v1, v2, focus)),
            							ScreenVertex.distortSqr(v2, v0, focus));
        }

        public final function minDistortSqr(focus:Number):Number
        {
            return Math.min(Math.min(ScreenVertex.distortSqr(v0, v1, focus),
            							ScreenVertex.distortSqr(v1, v2, focus)),
            							ScreenVertex.distortSqr(v2, v0, focus));
        }

        public final function acuteAngled():Boolean
        {
            var d01:Number = ScreenVertex.distanceSqr(v0, v1),
            	d12:Number = ScreenVertex.distanceSqr(v1, v2),
            	d20:Number = ScreenVertex.distanceSqr(v2, v0),
            	dd01:Number = d01 * d01,
            	dd12:Number = d12 * d12,
            	dd20:Number = d20 * d20;
            return (dd01 <= dd12 + dd20) && (dd12 <= dd20 + dd01) && (dd20 <= dd01 + dd12);
        }
		
        internal var _u0:Number;
        internal var _u1:Number;
        internal var _u2:Number;
		internal var _v0:Number;
        internal var _v1:Number;
        internal var _v2:Number;
		
        public final function transformUV(material:IUVMaterial):Matrix
        {
            var width:Number = material.width,
            	height:Number = material.height;
            
            if (uv0 == null)
                return new Matrix();
            if (uv1 == null)
                return new Matrix();
            if (uv2 == null)
                return new Matrix();

            _u0 = width * uv0._u,
            _u1 = width * uv1._u,
            _u2 = width * uv2._u,
            _v0 = height * (1 - uv0._v),
            _v1 = height * (1 - uv1._v),
            _v2 = height * (1 - uv2._v);
      
            // Fix perpendicular projections
            if ((_u0 == _u1 && _v0 == _v1) || (_u0 == _u2 && _v0 == _v2))
            {
                _u0 -= (_u0 > 0.05) ? 0.05 : -0.05;
                _v0 -= (_v0 > 0.07) ? 0.07 : -0.07;
            }
    
            if (_u2 == _u1 && _v2 == _v1)
            {
                _u2 -= (_u2 > 0.05) ? 0.04 : -0.04;
                _v2 -= (_v2 > 0.06) ? 0.06 : -0.06;
            }
 
            texturemapping = new Matrix(_u1 - _u0, _v1 - _v0, _u2 - _u0, _v2 - _v0, _u0, _v0);
            texturemapping.invert();
            return texturemapping;
        }
		
		internal var av0z:Number;
        internal var av0p:Number;
        internal var av0x:Number;
        internal var av0y:Number;

        internal var av1z:Number;
        internal var av1p:Number;
        internal var av1x:Number;
        internal var av1y:Number;

        internal var av2z:Number;
        internal var av2p:Number;
        internal var av2x:Number;
        internal var av2y:Number;

        internal var ad1x:Number;
        internal var ad1y:Number;
        internal var ad1z:Number;

        internal var ad2x:Number;
        internal var ad2y:Number;
        internal var ad2z:Number;

        internal var apa:Number;
        internal var apb:Number;
        internal var apc:Number;
        internal var apd:Number;
        
        internal var tv0z:Number;
        internal var tv0p:Number;
        internal var tv0x:Number;
        internal var tv0y:Number;

        internal var tv1z:Number;
        internal var tv1p:Number;
        internal var tv1x:Number;
        internal var tv1y:Number;

        internal var tv2z:Number;
        internal var tv2p:Number;
        internal var tv2x:Number;
        internal var tv2y:Number;

        internal var sv0:Number;
        internal var sv1:Number;
        internal var sv2:Number;
        
        internal var td1x:Number;
        internal var td1y:Number;
        internal var td1z:Number;

        internal var td2x:Number;
        internal var td2y:Number;
        internal var td2z:Number;

        internal var tpa:Number;
        internal var tpb:Number;
        internal var tpc:Number;
        internal var tpd:Number;
        
        internal var sav0:Number;
        internal var sav1:Number;
        internal var sav2:Number;
        
        internal var tv0:Vertex;
        internal var tv1:Vertex;
        internal var tv2:Vertex;
        	
        public override final function riddle(another:DrawTriangle, focus:Number):Array
        {
            if (area < 10)
                return null;

            if (another.area < 10)
                return null;

//            if (another.area < area) // ?? >
//                return null;

            if (another.minZ > maxZ)
                return null;
            if (another.maxZ < minZ)
                return null;

            /*
            if (another.minX > maxX)
                return null;
            if (another.maxX < minX)
                return null;
            if (another.minY > maxY)
                return null;
            if (another.maxY < minY)
                return null;
            */
            
            if (!overlap(this, another))
                return null;

            av0z = another.v0.z;
            av0p = 1 + av0z / focus;
            av0x = another.v0.x * av0p;
            av0y = another.v0.y * av0p;

            av1z = another.v1.z;
            av1p = 1 + av1z / focus;
            av1x = another.v1.x * av1p;
            av1y = another.v1.y * av1p;

            av2z = another.v2.z;
            av2p = 1 + av2z / focus;
            av2x = another.v2.x * av2p;
            av2y = another.v2.y * av2p;

            ad1x = av1x - av0x;
            ad1y = av1y - av0y;
            ad1z = av1z - av0z;

            ad2x = av2x - av0x;
            ad2y = av2y - av0y;
            ad2z = av2z - av0z;

            apa = ad1y*ad2z - ad1z*ad2y;
            apb = ad1z*ad2x - ad1x*ad2z;
            apc = ad1x*ad2y - ad1y*ad2x;
            apd = - (apa*av0x + apb*av0y + apc*av0z);

            if (apa*apa + apb*apb + apc*apc < 1)
                return null;

            tv0z = v0.z;
            tv0p = 1 + tv0z / focus;
            tv0x = v0.x * tv0p;
            tv0y = v0.y * tv0p;

            tv1z = v1.z;
            tv1p = 1 + tv1z / focus;
            tv1x = v1.x * tv1p;
            tv1y = v1.y * tv1p;

            tv2z = v2.z;
            tv2p = 1 + tv2z / focus;
            tv2x = v2.x * tv2p;
            tv2y = v2.y * tv2p;

            sv0 = apa*tv0x + apb*tv0y + apc*tv0z + apd;
            sv1 = apa*tv1x + apb*tv1y + apc*tv1z + apd;
            sv2 = apa*tv2x + apb*tv2y + apc*tv2z + apd;

            if (sv0*sv0 < 0.001)
                sv0 = 0;
            if (sv1*sv1 < 0.001)
                sv1 = 0;
            if (sv2*sv2 < 0.001)
                sv2 = 0;

            if ((sv0*sv1 >= -0.01) && (sv1*sv2 >= -0.01) && (sv2*sv0 >= -0.01))
                return null;

            td1x = tv1x - tv0x;
            td1y = tv1y - tv0y;
            td1z = tv1z - tv0z;

            td2x = tv2x - tv0x;
            td2y = tv2y - tv0y;
            td2z = tv2z - tv0z;

            tpa = td1y*td2z - td1z*td2y;
            tpb = td1z*td2x - td1x*td2z;
            tpc = td1x*td2y - td1y*td2x;
            tpd = - (tpa*tv0x + tpb*tv0y + tpc*tv0z);

            if (tpa*tpa + tpb*tpb + tpc*tpc < 1)
                return null;

            sav0 = tpa*av0x + tpb*av0y + tpc*av0z + tpd;
            sav1 = tpa*av1x + tpb*av1y + tpc*av1z + tpd;
            sav2 = tpa*av2x + tpb*av2y + tpc*av2z + tpd;

            if (sav0*sav0 < 0.001)
                sav0 = 0;
            if (sav1*sav1 < 0.001)
                sav1 = 0;
            if (sav2*sav2 < 0.001)
                sav2 = 0;

            if ((sav0*sav1 >= -0.01) && (sav1*sav2 >= -0.01) && (sav2*sav0 >= -0.01))
                return null;

            // TODO: segment cross check - now some extra cuts are made

            tv0 = v0.deperspective(focus);
            tv1 = v1.deperspective(focus);
            tv2 = v2.deperspective(focus);
                
            if (sv1*sv2 >= -1)
            {
                //var tv20:Vertex = Vertex.weighted(tv2, tv0, -sv0, sv2);
                //var tv01:Vertex = Vertex.weighted(tv0, tv1, sv1, -sv0);

                return fivepointcut(source, material, projection,
                    v2,  Vertex.weighted(tv2, tv0, -sv0, sv2).perspective(focus), v0, Vertex.weighted(tv0, tv1, sv1, -sv0).perspective(focus), v1,
                    uv2, UV.weighted(uv2, uv0, -sv0, sv2), uv0, UV.weighted(uv0, uv1, sv1, -sv0), uv1);
            }                                                           
            else                                                        
            if (sv0*sv1 >= -1)                                           
            {
                return fivepointcut(source, material, projection,
                    v1,  Vertex.weighted(tv1, tv2, -sv2, sv1).perspective(focus), v2, Vertex.weighted(tv2, tv0, sv0, -sv2).perspective(focus), v0,
                    uv1, UV.weighted(uv1, uv2, -sv2, sv1), uv2, UV.weighted(uv2, uv0, sv0, -sv2), uv0);
            }                                                           
            else                                                        
            {                                                           
                return fivepointcut(source, material, projection,
                    v0,  Vertex.weighted(tv0, tv1, -sv1, sv0).perspective(focus), v1, Vertex.weighted(tv1, tv2, sv2, -sv1).perspective(focus), v2,
                    uv0, UV.weighted(uv0, uv1, -sv1, sv0), uv1, UV.weighted(uv1, uv2, sv2, -sv1), uv2);
            }

            return null;    
        }
		
		internal var focus:Number;
		
		internal var ax:Number;
        internal var ay:Number;
        internal var az:Number;
        internal var bx:Number;
        internal var by:Number;
        internal var bz:Number;
        internal var cx:Number;
        internal var cy:Number;
        internal var cz:Number;
		
		internal var azf:Number;
        internal var bzf:Number;
        internal var czf:Number;

        internal var faz:Number;
        internal var fbz:Number;
        internal var fcz:Number;

        internal var axf:Number;
        internal var bxf:Number;
        internal var cxf:Number;
        internal var ayf:Number;
        internal var byf:Number;
        internal var cyf:Number;

        internal var det:Number;
        internal var da:Number;
        internal var db:Number;
        internal var dc:Number;
            	
        public override final function getZ(x:Number, y:Number):Number
        {
            if (projection == null)
                return screenZ;

            focus = projection.focus;
            // v1v:Vector = v1 - v0
            // v2v:Vector = v2 - v0

            // v:Vector = (x,y) - v0

            // *-> v = a*v1v + b*v2v
            // v = (-a-b)*v0 + a*v1 + b*v2 
            // (x,y) = (1-a-b)*v0 + a*v1 + b*v2

            // ---------------------------------

            // (x, y, focus)

            // faz = focus + az
            // fbz = focus + bz
            // fcz = focus + cz

            // x = (ka*ax*faz + kb*bx*fbz + kc*cx*fcz) / (focus + mz)
            // y = (ka*ay*faz + kb*by*fbz + kc*cy*fcz) / (focus + mz)
            // ka+kb+kc = 1;
            // mz = ka*az + kb*bz + kc*cz;
            // ka? kb? kc?

            // x * (focus + ka*az + kb*bz + kc*cz) = (ka*ax*faz + kb*bx*fbz + kc*cx*fcz)
            // y * (focus + ka*az + kb*bz + kc*cz) = (ka*ay*faz + kb*by*fbz + kc*cy*fcz)
            // ka + kb + kc = 1;
            // ka * (ax*faz - x*az) + kb * (bx*fbz - x*bz) + kc * (cx*fcz - x*cz) = x * focus
            // ka * (ay*faz - y*az) + kb * (by*fbz - y*bz) + kc * (cy*fcz - y*cz) = y * focus
            // ka * (1)               + kb * (1)             + kc * (1)             = 1

            // axf = ax*faz - x*az                     ayf = ay*faz - y*az 
            // bxf = bx*fbz - x*bz                     ayf = by*fbz - y*bz 
            // cxf = cx*fcz - x*cz                     ayf = cy*fcz - y*cz 
            // 
            // det = axf*byf - axf*cyf + bxf*cyf - bxf*ayf + cxf*ayf - cxf*byf

            // da = (x*focus)*byf - (x*focus)*cyf + bxf*cyf - bxf*(y*focus) + cxf*(y*focus) - cxf*byf
            // db = axf*(y*focus) - axf*cyf + (x*focus)*cyf - (x*focus)*ayf + cxf*ayf - cxf*(y*focus)
            // dc = axf*byf - axf*(y*focus) + bxf*(y*focus) - bxf*ayf + (x*focus)*ayf - (x*focus)*byf

            // mz = (da*az + db*bz + dc*cz)/det

            ax = v0.x;
            ay = v0.y;
            az = v0.z;
            bx = v1.x;
            by = v1.y;
            bz = v1.z;
            cx = v2.x;
            cy = v2.y;
            cz = v2.z;

            if ((ax == x) && (ay == y))
                return az;

            if ((bx == x) && (by == y))
                return bz;

            if ((cx == x) && (cy == y))
                return cz;

            azf = az / focus;
            bzf = bz / focus;
            czf = cz / focus;

            faz = 1 + azf;
            fbz = 1 + bzf;
            fcz = 1 + czf;

            axf = ax*faz - x*azf;
            bxf = bx*fbz - x*bzf;
            cxf = cx*fcz - x*czf;
            ayf = ay*faz - y*azf;
            byf = by*fbz - y*bzf;
            cyf = cy*fcz - y*czf;

            det = axf*(byf - cyf) + bxf*(cyf - ayf) + cxf*(ayf - byf);
            da = x*(byf - cyf) + bxf*(cyf - y) + cxf*(y - byf);
            db = axf*(y - cyf) + x*(cyf - ayf) + cxf*(ayf - y);
            dc = axf*(byf - y) + bxf*(y - ayf) + x*(ayf - byf);

            return (da*az + db*bz + dc*cz) / det;
        }

        public function getUV(x:Number, y:Number):UV
        {
            if (uv0 == null)
                return null;

            if (uv1 == null)
                return null;

            if (uv2 == null)
                return null;

            var au:Number = uv0._u,
            	av:Number = uv0._v,
            	bu:Number = uv1._u,
            	bv:Number = uv1._v,
            	cu:Number = uv2._u,
            	cv:Number = uv2._v,

            	focus:Number = projection.focus,

            	ax:Number = v0.x,
            	ay:Number = v0.y,
            	az:Number = v0.z,
            	bx:Number = v1.x,
            	by:Number = v1.y,
            	bz:Number = v1.z,
            	cx:Number = v2.x,
            	cy:Number = v2.y,
            	cz:Number = v2.z;

            if ((ax == x) && (ay == y))
                return uv0;

            if ((bx == x) && (by == y))
                return uv1;

            if ((cx == x) && (cy == y))
                return uv2;

            var azf:Number = az / focus,
            	bzf:Number = bz / focus,
            	czf:Number = cz / focus,

            	faz:Number = 1 + azf,
            	fbz:Number = 1 + bzf,
            	fcz:Number = 1 + czf,
                                    
            	axf:Number = ax*faz - x*azf,
            	bxf:Number = bx*fbz - x*bzf,
            	cxf:Number = cx*fcz - x*czf,
            	ayf:Number = ay*faz - y*azf,
            	byf:Number = by*fbz - y*bzf,
            	cyf:Number = cy*fcz - y*czf,

            	det:Number = axf*(byf - cyf) + bxf*(cyf - ayf) + cxf*(ayf - byf),
            	da:Number = x*(byf - cyf) + bxf*(cyf - y) + cxf*(y- byf),
            	db:Number = axf*(y - cyf) + x*(cyf - ayf) + cxf*(ayf - y),
            	dc:Number = axf*(byf - y) + bxf*(y - ayf) + x*(ayf - byf);

            return new UV((da*au + db*bu + dc*cu) / det, (da*av + db*bv + dc*cv) / det);
        }

        public static function fivepointcut(source:Object3D, material:ITriangleMaterial, projection:Projection, v0:ScreenVertex, v01:ScreenVertex, v1:ScreenVertex, v12:ScreenVertex, v2:ScreenVertex, uv0:UV, uv01:UV, uv1:UV, uv12:UV, uv2:UV):Array
        {
            if (ScreenVertex.distanceSqr(v0, v12) < ScreenVertex.distanceSqr(v01, v2))
            {
                return [
                    create(source, material, projection,  v0, v01, v12,  uv0, uv01, uv12),
                    create(source, material, projection, v01,  v1, v12, uv01,  uv1, uv12),
                    create(source, material, projection,  v0, v12 , v2,  uv0, uv12, uv2)];
            }
            else
            {
                return [
                    create(source, material, projection,   v0, v01,  v2,  uv0, uv01, uv2),
                    create(source, material, projection,  v01,  v1, v12, uv01,  uv1, uv12),
                    create(source, material, projection,  v01, v12,  v2, uv01, uv12, uv2)];
            }
        }

        public static function overlap(q:DrawTriangle, w:DrawTriangle):Boolean
        {
            if (q.minX > w.maxX)
                return false;
            if (q.maxX < w.minX)
                return false;
            if (q.minY > w.maxY)
                return false;
            if (q.maxY < w.minY)
                return false;
        
            var q0x:Number = q.v0.x,
            	q0y:Number = q.v0.y,
            	q1x:Number = q.v1.x,
            	q1y:Number = q.v1.y,
            	q2x:Number = q.v2.x,
            	q2y:Number = q.v2.y,
        
            	w0x:Number = w.v0.x,
            	w0y:Number = w.v0.y,
            	w1x:Number = w.v1.x,
            	w1y:Number = w.v1.y,
            	w2x:Number = w.v2.x,
            	w2y:Number = w.v2.y,
        
            	ql01a:Number = q1y - q0y,
            	ql01b:Number = q0x - q1x,
            	ql01c:Number = -(ql01b*q0y + ql01a*q0x),
            	ql01s:Number = ql01a*q2x + ql01b*q2y + ql01c,
            	ql01w0:Number = (ql01a*w0x + ql01b*w0y + ql01c) * ql01s,
            	ql01w1:Number = (ql01a*w1x + ql01b*w1y + ql01c) * ql01s,
            	ql01w2:Number = (ql01a*w2x + ql01b*w2y + ql01c) * ql01s;
        
            if ((ql01w0 <= 0.0001) && (ql01w1 <= 0.0001) && (ql01w2 <= 0.0001))
                return false;
        
            var ql12a:Number = q2y - q1y,
            	ql12b:Number = q1x - q2x,
            	ql12n:Boolean = (ql12a*ql12a + ql12b*ql12b) > 0.0001,
            	ql12c:Number = -(ql12b*q1y + ql12a*q1x),
            	ql12s:Number = ql12a*q0x + ql12b*q0y + ql12c,
            	ql12w0:Number = (ql12a*w0x + ql12b*w0y + ql12c) * ql12s,
            	ql12w1:Number = (ql12a*w1x + ql12b*w1y + ql12c) * ql12s,
            	ql12w2:Number = (ql12a*w2x + ql12b*w2y + ql12c) * ql12s;
        
            if ((ql12w0 <= 0.0001) && (ql12w1 <= 0.0001) && (ql12w2 <= 0.0001))
                return false;
        
            var ql20a:Number = q0y - q2y,
            	ql20b:Number = q2x - q0x,
            	ql20c:Number = -(ql20b*q2y + ql20a*q2x),
            	ql20s:Number = ql20a*q1x + ql20b*q1y + ql20c,
            	ql20w0:Number = (ql20a*w0x + ql20b*w0y + ql20c) * ql20s,
            	ql20w1:Number = (ql20a*w1x + ql20b*w1y + ql20c) * ql20s,
            	ql20w2:Number = (ql20a*w2x + ql20b*w2y + ql20c) * ql20s;
        
            if ((ql20w0 <= 0.0001) && (ql20w1 <= 0.0001) && (ql20w2 <= 0.0001))
                return false;
        
            var wl01a:Number = w1y - w0y,
            	wl01b:Number = w0x - w1x,
            	wl01c:Number = -(wl01b*w0y + wl01a*w0x),
            	wl01s:Number = wl01a*w2x + wl01b*w2y + wl01c,
            	wl01q0:Number = (wl01a*q0x + wl01b*q0y + wl01c) * wl01s,
            	wl01q1:Number = (wl01a*q1x + wl01b*q1y + wl01c) * wl01s,
            	wl01q2:Number = (wl01a*q2x + wl01b*q2y + wl01c) * wl01s;
        
            if ((wl01q0 <= 0.0001) && (wl01q1 <= 0.0001) && (wl01q2 <= 0.0001))
                return false;
        
            var wl12a:Number = w2y - w1y,
            	wl12b:Number = w1x - w2x,
            	wl12c:Number = -(wl12b*w1y + wl12a*w1x),
            	wl12s:Number = wl12a*w0x + wl12b*w0y + wl12c,
            	wl12q0:Number = (wl12a*q0x + wl12b*q0y + wl12c) * wl12s,
            	wl12q1:Number = (wl12a*q1x + wl12b*q1y + wl12c) * wl12s,
            	wl12q2:Number = (wl12a*q2x + wl12b*q2y + wl12c) * wl12s;
        
            if ((wl12q0 <= 0.0001) && (wl12q1 <= 0.0001) && (wl12q2 <= 0.0001))
                return false;
        
            var wl20a:Number = w0y - w2y,
            	wl20b:Number = w2x - w0x,
            	wl20c:Number = -(wl20b*w2y + wl20a*w2x),
            	wl20s:Number = wl20a*w1x + wl20b*w1y + wl20c,
            	wl20q0:Number = (wl20a*q0x + wl20b*q0y + wl20c) * wl20s,
            	wl20q1:Number = (wl20a*q1x + wl20b*q1y + wl20c) * wl20s,
            	wl20q2:Number = (wl20a*q2x + wl20b*q2y + wl20c) * wl20s;
        
            if ((wl20q0 <= 0.0001) && (wl20q1 <= 0.0001) && (wl20q2 <= 0.0001))
                return false;
            
            return true;
        }


        public final function bisect(focus:Number):Array
        {
            var d01:Number = ScreenVertex.distanceSqr(v0, v1),
            	d12:Number = ScreenVertex.distanceSqr(v1, v2),
            	d20:Number = ScreenVertex.distanceSqr(v2, v0);

            if ((d12 >= d01) && (d12 >= d20))
                return bisect12(focus);
            else
            if (d01 >= d20)
                return bisect01(focus);
            else
                return bisect20(focus);
        }

        public final function distortbisect(focus:Number):Array
        {
            var d01:Number = ScreenVertex.distortSqr(v0, v1, focus),
            	d12:Number = ScreenVertex.distortSqr(v1, v2, focus),
            	d20:Number = ScreenVertex.distortSqr(v2, v0, focus);

            if ((d12 >= d01) && (d12 >= d20))
                return bisect12(focus);
            else
            if (d01 >= d20)
                return bisect01(focus);
            else
                return bisect20(focus);
        }

        private final function bisect01(focus:Number):Array
        {
            var v01:ScreenVertex = ScreenVertex.median(v0, v1, focus),
            	uv01:UV = UV.median(uv0, uv1);
            return [
                create(source, material, projection, v2, v0, v01, uv2, uv0, uv01),
                create(source, material, projection, v01, v1, v2, uv01, uv1, uv2) 
            ];
        }

        private final function bisect12(focus:Number):Array
        {
            var v12:ScreenVertex = ScreenVertex.median(v1, v2, focus),
            	uv12:UV = UV.median(uv1, uv2);
            return [
                create(source, material, projection, v0, v1, v12, uv0, uv1, uv12),
                create(source, material, projection, v12, v2, v0, uv12, uv2, uv0) 
            ];
        }

        private final function bisect20(focus:Number):Array
        {
            var v20:ScreenVertex = ScreenVertex.median(v2, v0, focus),
            	uv20:UV = UV.median(uv2, uv0);
            return [
                create(source, material, projection, v1, v2, v20, uv1, uv2, uv20),
                create(source, material, projection, v20, v0, v1, uv20, uv0, uv1) 
            ];                                                
        }
		
		internal var v01:ScreenVertex;
		internal var v12:ScreenVertex;
		internal var v20:ScreenVertex;
		internal var uv01:UV;
		internal var uv12:UV;
		internal var uv20:UV;
		
        public override final function quarter(focus:Number):Array
        {
            if (area < 20)
                return null;

            v01 = ScreenVertex.median(v0, v1, focus),
            v12 = ScreenVertex.median(v1, v2, focus),
            v20 = ScreenVertex.median(v2, v0, focus),
            uv01 = UV.median(uv0, uv1),
            uv12 = UV.median(uv1, uv2),
            uv20 = UV.median(uv2, uv0);

            return [
                create(source, material, projection, v0, v01, v20, uv0, uv01, uv20),
                create(source, material, projection, v1, v12, v01, uv1, uv12, uv01),
                create(source, material, projection, v2, v20, v12, uv2, uv20, uv12),
                create(source, material, projection, v01, v12, v20, uv01, uv12, uv20)
            ];
        }

        public override final function contains(x:Number, y:Number):Boolean
        {   
            if (v0.x*(y - v1.y) + v1.x*(v0.y - y) + x*(v1.y - v0.y) < -0.001)
                return false;

            if (v0.x*(v2.y - y) + x*(v0.y - v2.y) + v2.x*(y - v0.y) < -0.001)
                return false;

            if (x*(v2.y - v1.y) + v1.x*(y - v2.y) + v2.x*(v1.y - y) < -0.001)
                return false;

            return true;
        }

        public final function distanceToCenter(x:Number, y:Number):Number
        {   
            var centerx:Number = (v0.x + v1.x + v2.x) / 3,
            	centery:Number = (v0.y + v1.y + v2.y) / 3;

            return Math.sqrt((centerx-x)*(centerx-x) + (centery-y)*(centery-y));
        }

        public static function create(source:Object3D, material:ITriangleMaterial, projection:Projection,
            v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex, uv0:UV, uv1:UV, uv2:UV):DrawTriangle
        {
            var tri:DrawTriangle = new DrawTriangle();
            tri.source = source;
            tri.material = material;
            tri.projection = projection;
            tri.v0 = v0;
            tri.v1 = v1;
            tri.v2 = v2;
            tri.uv0 = uv0;
            tri.uv1 = uv1;
            tri.uv2 = uv2;
            tri.calc();
            return tri;
        }

        public function calc():void
        {
            minZ = (v0.z > v1.z) ? (v1.z > v2.z ?  v2.z : v1.z) : (v0.z > v2.z ?  v2.z : v0.z);
            maxZ = (v0.z < v1.z) ? (v1.z < v2.z ?  v2.z : v1.z) : (v0.z < v2.z ?  v2.z : v0.z);
            screenZ = (v0.z + v1.z + v2.z) / 3;
            minX = int((v0.x > v1.x) ? (v1.x > v2.x ?  v2.x : v1.x) : (v0.x > v2.x ?  v2.x : v0.x));
            minY = int((v0.y > v1.y) ? (v1.y > v2.y ?  v2.y : v1.y) : (v0.y > v2.y ?  v2.y : v0));
            maxX = int(((v0.x < v1.x) ? (v1.x < v2.x ?  v2.x : v1.x) : (v0.x < v2.x ?  v2.x : v0.x))+1);
            maxY = int(((v0.y < v1.y) ? (v1.y < v2.y ?  v2.y : v1.y) : (v0.y < v2.y ?  v2.y : v0.y))+1);
            area = 0.5 * (v0.x*(v2.y - v1.y) + v1.x*(v0.y - v2.y) + v2.x*(v1.y - v0.y));
        }

        public override function toString():String
        {
            var color:String = "";
            if (material is WireColorMaterial)
            {
                switch ((material as WireColorMaterial).color)
                {
                    case 0x00FF00: color = "green"; break;
                    case 0xFFFF00: color = "yellow"; break;
                    case 0xFF0000: color = "red"; break;
                    case 0x0000FF: color = "blue"; break;
                }
            }
            return "T{"+color+int(area)+" screenZ = " + num(screenZ) + ", minZ = " + num(minZ) + ", maxZ = " + num(maxZ) + " }";
        }

        private static function num(n:Number):Number
        {
            return int(n*1000)/1000;
        }

    }
}
