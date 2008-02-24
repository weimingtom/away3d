package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.mesh.UV;
    import away3d.core.mesh.Vertex;
    import away3d.core.scene.*;
    
    import flash.display.*;
    import flash.utils.*;

    /** Filter that splits all intersecting triangles and line segments. */
    public class QuadrantRiddleFilter implements IPrimitiveQuadrantFilter
    {
    	use namespace arcane;
    	
        public var maxdelay:int;
    
        public function QuadrantRiddleFilter(maxdelay:int = 60000)
        {
            this.maxdelay = maxdelay;
        }
    	
    	internal var start:int;
        internal var check:int;
        
        internal var primitives:Array;
        internal var pri:DrawPrimitive;
        internal var turn:int;
        internal var leftover:Array;
        
        internal var rivals:Array;
        internal var rival:DrawPrimitive;
        
        internal var parts:Array;
        internal var part:DrawPrimitive;
        internal var subst:Array;
        internal var focus:Number;
        
        public function filter(tree:PrimitiveQuadrantTree, scene:Scene3D, camera:Camera3D, container:Sprite, clip:Clipping):void
        {
            start = getTimer();
            check = 0;
    		focus = camera.focus;
    		
            primitives = tree.list();
            turn = 0;
            
            while (primitives.length > 0)
            {
                var leftover:Array = new Array();
                for each (pri in primitives)
                {
                    
                    check++;
                    if (check == 10)
                        if (getTimer() - start > maxdelay)
                            return;
                        else
                            check = 0;
                    
                    rivals = tree.get(pri, pri.source);
                    for each (rival in rivals)
                    {
                        if (rival == pri)
                            continue;
                        
                        if (rival.minZ >= pri.maxZ)
                            continue;
                        if (rival.maxZ <= pri.minZ)
                            continue;
                        
                        parts = riddle(pri, rival);
                        
                        if (parts == null)
                            continue;
    
                        tree.remove(pri);
                        for each (part in parts)
                        {
                            leftover.push(part);
                            tree.push(part);
                        }
                        break;
                    }
                }
                primitives = leftover;
                turn += 1;
                if (turn == 40)
                    break;
            }
        }
    	
    	public function riddle(q:DrawPrimitive, w:DrawPrimitive):Array
        {
            if (q is DrawTriangle)
            { 
                if (w is DrawTriangle)
                    return riddleTT(q as DrawTriangle, w as DrawTriangle);
                if (w is DrawSegment)
                    return riddleTS(q as DrawTriangle, w as DrawSegment);
            }
            else
            if (q is DrawSegment)
            {
                if (w is DrawTriangle)
                    return riddleTS(w as DrawTriangle, q as DrawSegment);
            }
            return [];
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
            
        public final function riddleTT(q:DrawTriangle, w:DrawTriangle):Array
        {
        	//return if triangle area below 10 or if actual rival triangles do not overlap
            if (q.area < 10 || w.area < 10 || !overlap(q, w))
                return null;
			
			//deperspective rival v0 
            av0z = w.v0.z;
            av0p = 1 + av0z / focus;
            av0x = w.v0.x * av0p;
            av0y = w.v0.y * av0p;
			
			//deperspective rival v1
            av1z = w.v1.z;
            av1p = 1 + av1z / focus;
            av1x = w.v1.x * av1p;
            av1y = w.v1.y * av1p;
			
			//deperspective rival v2
            av2z = w.v2.z;
            av2p = 1 + av2z / focus;
            av2x = w.v2.x * av2p;
            av2y = w.v2.y * av2p;
			
			//calculate rival face normal
            ad1x = av1x - av0x;
            ad1y = av1y - av0y;
            ad1z = av1z - av0z;

            ad2x = av2x - av0x;
            ad2y = av2y - av0y;
            ad2z = av2z - av0z;

            apa = ad1y*ad2z - ad1z*ad2y;
            apb = ad1z*ad2x - ad1x*ad2z;
            apc = ad1x*ad2y - ad1y*ad2x;
            
            //calculate the dot product of the rival normal and rival v0
            apd = apa*av0x + apb*av0y + apc*av0z;
			
			//return if normal length is less than 1
            if (apa*apa + apb*apb + apc*apc < 1)
                return null;
			
			//deperspective v0
            tv0z = q.v0.z;
            tv0p = 1 + tv0z / focus;
            tv0x = q.v0.x * tv0p;
            tv0y = q.v0.y * tv0p;

			//deperspective v1
            tv1z = q.v1.z;
            tv1p = 1 + tv1z / focus;
            tv1x = q.v1.x * tv1p;
            tv1y = q.v1.y * tv1p;
			
			//deperspective v2
            tv2z = q.v2.z;
            tv2p = 1 + tv2z / focus;
            tv2x = q.v2.x * tv2p;
            tv2y = q.v2.y * tv2p;
            
            //calculate the dot product of v0, v1 and v2 to the rival normal
            sv0 = apa*tv0x + apb*tv0y + apc*tv0z - apd;
            sv1 = apa*tv1x + apb*tv1y + apc*tv1z - apd;
            sv2 = apa*tv2x + apb*tv2y + apc*tv2z - apd;

            if (sv0*sv0 < 0.001)
                sv0 = 0;
            if (sv1*sv1 < 0.001)
                sv1 = 0;
            if (sv2*sv2 < 0.001)
                sv2 = 0;

            if (sv0*sv1 >= -0.01 && sv1*sv2 >= -0.01 && sv2*sv0 >= -0.01)
                return null;
			
			//calulate face normal
            td1x = tv1x - tv0x;
            td1y = tv1y - tv0y;
            td1z = tv1z - tv0z;

            td2x = tv2x - tv0x;
            td2y = tv2y - tv0y;
            td2z = tv2z - tv0z;

            tpa = td1y*td2z - td1z*td2y;
            tpb = td1z*td2x - td1x*td2z;
            tpc = td1x*td2y - td1y*td2x;
            
            //calculate the dot product of the face normal and v0
            tpd = tpa*tv0x + tpb*tv0y + tpc*tv0z;
			
			//return if normal length is less than 1
            if (tpa*tpa + tpb*tpb + tpc*tpc < 1)
                return null;
			
			//calculate the dot product of rival v0, v1 and v2 to the face normal
            sav0 = tpa*av0x + tpb*av0y + tpc*av0z - tpd;
            sav1 = tpa*av1x + tpb*av1y + tpc*av1z - tpd;
            sav2 = tpa*av2x + tpb*av2y + tpc*av2z - tpd;

            if (sav0*sav0 < 0.001)
                sav0 = 0;
            if (sav1*sav1 < 0.001)
                sav1 = 0;
            if (sav2*sav2 < 0.001)
                sav2 = 0;

            if ((sav0*sav1 >= -0.01) && (sav1*sav2 >= -0.01) && (sav2*sav0 >= -0.01))
                return null;

            // TODO: segment cross check - now some extra cuts are made

            tv0 = q.v0.deperspective(focus);
            tv1 = q.v1.deperspective(focus);
            tv2 = q.v2.deperspective(focus);
                
            if (sv1*sv2 >= -1)
            {
                return q.fivepointcut(q.v2,  Vertex.weighted(tv2, tv0, -sv0, sv2).perspective(focus), q.v0, Vertex.weighted(tv0, tv1, sv1, -sv0).perspective(focus), q.v1,
                    q.uv2, UV.weighted(q.uv2, q.uv0, -sv0, sv2), q.uv0, UV.weighted(q.uv0, q.uv1, sv1, -sv0), q.uv1);
            }                                                           
            else                                                        
            if (sv0*sv1 >= -1)                                           
            {
                return q.fivepointcut(q.v1,  Vertex.weighted(tv1, tv2, -sv2, sv1).perspective(focus), q.v2, Vertex.weighted(tv2, tv0, sv0, -sv2).perspective(focus), q.v0,
                    q.uv1, UV.weighted(q.uv1, q.uv2, -sv2, sv1), q.uv2, UV.weighted(q.uv2, q.uv0, sv0, -sv2), q.uv0);
            }                                                           
            else                                                        
            {                                                           
                return q.fivepointcut(q.v0,  Vertex.weighted(tv0, tv1, -sv1, sv0).perspective(focus), q.v1, Vertex.weighted(tv1, tv2, sv2, -sv1).perspective(focus), q.v2,
                    q.uv0, UV.weighted(q.uv0, q.uv1, -sv1, sv0), q.uv1, UV.weighted(q.uv1, q.uv2, sv2, -sv1), q.uv2);
            }

            return null;    
        }
        
        internal var q0x:Number;
        internal var q0y:Number;
        internal var q1x:Number;
        internal var q1y:Number;
        internal var q2x:Number;
        internal var q2y:Number;
        
        internal var w0x:Number;
        internal var w0y:Number;
        internal var w1x:Number;
        internal var w1y:Number;
        internal var w2x:Number;
        internal var w2y:Number;
        
        internal var ql01a:Number;
        internal var ql01b:Number;
        internal var ql01c:Number;
        internal var ql01s:Number;
        internal var ql01w0:Number;
        internal var ql01w1:Number;
        internal var ql01w2:Number;
        
        internal var ql12a:Number;
        internal var ql12b:Number;
        internal var ql12c:Number;
        internal var ql12s:Number;
        internal var ql12w0:Number;
        internal var ql12w1:Number;
        internal var ql12w2:Number;
        
        internal var ql20a:Number;
        internal var ql20b:Number;
        internal var ql20c:Number;
        internal var ql20s:Number;
        internal var ql20w0:Number;
        internal var ql20w1:Number;
        internal var ql20w2:Number;
		
        internal var wl01a:Number;
        internal var wl01b:Number;
        internal var wl01c:Number;
        internal var wl01s:Number;
        internal var wl01q0:Number;
        internal var wl01q1:Number;
        internal var wl01q2:Number;
		
        internal var wl12a:Number;
        internal var wl12b:Number;
        internal var wl12c:Number;
        internal var wl12s:Number;
        internal var wl12q0:Number;
        internal var wl12q1:Number;
        internal var wl12q2:Number;
		
        internal var wl20a:Number;
        internal var wl20b:Number;
        internal var wl20c:Number;
        internal var wl20s:Number;
        internal var wl20q0:Number;
        internal var wl20q1:Number;
        internal var wl20q2:Number;
            
        public function overlap(q:DrawTriangle, w:DrawTriangle):Boolean
        {
        
            q0x = q.v0.x;
            q0y = q.v0.y;
            q1x = q.v1.x;
            q1y = q.v1.y;
            q2x = q.v2.x;
            q2y = q.v2.y;
        
            w0x = w.v0.x;
            w0y = w.v0.y;
            w1x = w.v1.x;
            w1y = w.v1.y;
            w2x = w.v2.x;
            w2y = w.v2.y;
        
            ql01a = q1y - q0y;
            ql01b = q0x - q1x;
            ql01c = -(ql01b*q0y + ql01a*q0x);
            ql01s = ql01a*q2x + ql01b*q2y + ql01c;
            ql01w0 = (ql01a*w0x + ql01b*w0y + ql01c) * ql01s;
            ql01w1 = (ql01a*w1x + ql01b*w1y + ql01c) * ql01s;
            ql01w2 = (ql01a*w2x + ql01b*w2y + ql01c) * ql01s;
        
            if ((ql01w0 <= 0.0001) && (ql01w1 <= 0.0001) && (ql01w2 <= 0.0001))
                return false;
        
            ql12a = q2y - q1y;
            ql12b = q1x - q2x;
            ql12c = -(ql12b*q1y + ql12a*q1x);
            ql12s = ql12a*q0x + ql12b*q0y + ql12c;
            ql12w0 = (ql12a*w0x + ql12b*w0y + ql12c) * ql12s;
            ql12w1 = (ql12a*w1x + ql12b*w1y + ql12c) * ql12s;
            ql12w2 = (ql12a*w2x + ql12b*w2y + ql12c) * ql12s;
        
            if ((ql12w0 <= 0.0001) && (ql12w1 <= 0.0001) && (ql12w2 <= 0.0001))
                return false;
        
            ql20a = q0y - q2y;
            ql20b = q2x - q0x;
            ql20c = -(ql20b*q2y + ql20a*q2x);
            ql20s = ql20a*q1x + ql20b*q1y + ql20c;
            ql20w0 = (ql20a*w0x + ql20b*w0y + ql20c) * ql20s;
            ql20w1 = (ql20a*w1x + ql20b*w1y + ql20c) * ql20s;
            ql20w2 = (ql20a*w2x + ql20b*w2y + ql20c) * ql20s;
        
            if ((ql20w0 <= 0.0001) && (ql20w1 <= 0.0001) && (ql20w2 <= 0.0001))
                return false;
        
            wl01a = w1y - w0y;
            wl01b = w0x - w1x;
            wl01c = -(wl01b*w0y + wl01a*w0x);
            wl01s = wl01a*w2x + wl01b*w2y + wl01c;
            wl01q0 = (wl01a*q0x + wl01b*q0y + wl01c) * wl01s;
            wl01q1 = (wl01a*q1x + wl01b*q1y + wl01c) * wl01s;
            wl01q2 = (wl01a*q2x + wl01b*q2y + wl01c) * wl01s;
        
            if ((wl01q0 <= 0.0001) && (wl01q1 <= 0.0001) && (wl01q2 <= 0.0001))
                return false;
        
            wl12a = w2y - w1y;
            wl12b = w1x - w2x;
            wl12c = -(wl12b*w1y + wl12a*w1x);
            wl12s = wl12a*w0x + wl12b*w0y + wl12c;
            wl12q0 = (wl12a*q0x + wl12b*q0y + wl12c) * wl12s;
            wl12q1 = (wl12a*q1x + wl12b*q1y + wl12c) * wl12s;
            wl12q2 = (wl12a*q2x + wl12b*q2y + wl12c) * wl12s;
        
            if ((wl12q0 <= 0.0001) && (wl12q1 <= 0.0001) && (wl12q2 <= 0.0001))
                return false;
        
            wl20a = w0y - w2y;
            wl20b = w2x - w0x;
            wl20c = -(wl20b*w2y + wl20a*w2x);
            wl20s = wl20a*w1x + wl20b*w1y + wl20c;
            wl20q0 = (wl20a*q0x + wl20b*q0y + wl20c) * wl20s;
            wl20q1 = (wl20a*q1x + wl20b*q1y + wl20c) * wl20s;
            wl20q2 = (wl20a*q2x + wl20b*q2y + wl20c) * wl20s;
        
            if ((wl20q0 <= 0.0001) && (wl20q1 <= 0.0001) && (wl20q2 <= 0.0001))
                return false;
            
            return true;
        }

        internal var d:Number;
        internal var k0:Number;
        internal var k1:Number;

        internal var tv01z:Number;
        internal var tv01p:Number;
        internal var tv01x:Number;
        internal var tv01y:Number;
        internal var v01:ScreenVertex = new ScreenVertex();
        
        public function riddleTS(q:DrawTriangle, r:DrawSegment):Array
        {

            av0z = q.v0.z;
            av0p = 1 + av0z / focus;
            av0x = q.v0.x * av0p;
            av0y = q.v0.y * av0p;

            av1z = q.v1.z;
            av1p = 1 + av1z / focus;
            av1x = q.v1.x * av1p;
            av1y = q.v1.y * av1p;

            av2z = q.v2.z;
            av2p = 1 + av2z / focus;
            av2x = q.v2.x * av2p;
            av2y = q.v2.y * av2p;
                                      
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

            tv0z = r.v0.z;
            tv0p = 1 + tv0z / focus;
            tv0x = r.v0.x * tv0p;
            tv0y = r.v0.y * tv0p;

            tv1z = r.v1.z;
            tv1p = 1 + tv1z / focus;
            tv1x = r.v1.x * tv1p;
            tv1y = r.v1.y * tv1p;

            sv0 = apa*tv0x + apb*tv0y + apc*tv0z + apd;
            sv1 = apa*tv1x + apb*tv1y + apc*tv1z + apd;

            if (sv0*sv1 >= 0)                                           
                return null;

            d = sv1 - sv0;
            k0 = sv1 / d;
            k1 = -sv0 / d;

            tv01z = (tv0z*k0 + tv1z*k1);
            tv01p = 1 / (1 + tv01z /  focus);
            tv01x = (tv0x*k0 + tv1x*k1) * tv01p;
            tv01y = (tv0y*k0 + tv1y*k1) * tv01p;

            if (!q.contains(tv01x, tv01y))
                return null;
			
			v01.x = tv01x;
			v01.y = tv01y;
			v01.z = tv01z;
			
			return r.onepointcut(v01);
        }
        
        public function toString():String
        {
            return "QuadrantRiddleFilter" + ((maxdelay == 60000) ? "" : "("+maxdelay+"ms)");
        }
    }

}