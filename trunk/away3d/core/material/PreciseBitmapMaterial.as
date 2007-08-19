package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;

    import flash.display.BitmapData;
    import flash.geom.Matrix;

    import flash.utils.*;

    /** Bitmap material that renders bitmap texture taking into account perspective distortion */
    public class PreciseBitmapMaterial extends BitmapMaterial
    {
        public var precision:Number = 1;

        public function PreciseBitmapMaterial(bitmap:BitmapData, init:Object = null)
        {
            super(bitmap, init);

            init = Init.parse(init);

            precision = init.getNumber("precision", 1);

            precision = precision * precision * 1.4;
        }
        
        public override function renderTriangle(tri:DrawTriangle, session:RenderSession):void
        {
            mapping = tri.texturemapping || tri.transformUV(this);
           	v0 = tri.v0;
            v1 = tri.v1;
            v2 = tri.v2;

            renderRec(session, tri.projection, mapping.a, mapping.b, mapping.c, mapping.d, mapping.tx, mapping.ty, v0.x, v0.y, v0.z, v1.x, v1.y, v1.z, v2.x, v2.y, v2.z);

            if (debug)
                session.renderTriangleLine(2, 0x0000FF, 1, v0.x, v0.y, v1.x, v1.y, v2.x, v2.y);
        }
        
		internal var faz:Number;
        internal var fbz:Number;
        internal var fcz:Number;

        internal var mabz:Number;
        internal var mbcz:Number;
        internal var mcaz:Number;

        internal var mabx:Number;
        internal var maby:Number;
        internal var mbcx:Number;
        internal var mbcy:Number;
        internal var mcax:Number;
        internal var mcay:Number;

        internal var dabx:Number;
        internal var daby:Number;
        internal var dbcx:Number;
        internal var dbcy:Number;
        internal var dcax:Number;
        internal var dcay:Number;
            
        internal var dsab:Number;
        internal var dsbc:Number;
        internal var dsca:Number;
        
        internal var dmax:Number;
        
        protected function renderRec(session:RenderSession, projection:Projection,
            ta:Number, tb:Number, tc:Number, td:Number, tx:Number, ty:Number, 
            ax:Number, ay:Number, az:Number, bx:Number, by:Number, bz:Number, cx:Number, cy:Number, cz:Number):void
        {
            if (!session.clip.rect(Math.min(ax, Math.min(bx, cx)), Math.min(ay, Math.min(by, cy)), Math.max(ax, Math.max(bx, cx)), Math.max(ay, Math.max(by, cy))))
                return;

            if ((az <= 0) && (bz <= 0) && (cz <= 0))
                return;

            var focus:Number = projection.focus;
            if ((focus == Infinity) || (Math.max(Math.max(ax, bx), cx) - Math.min(Math.min(ax, bx), cx) < 10) || (Math.max(Math.max(ay, by), cy) - Math.min(Math.min(ay, by), cy) < 10))
            {
                session.renderTriangleBitmap(bitmap, ta, tb, tc, td, tx, ty, ax, ay, bx, by, cx, cy, smooth, repeat);
                if (debug)
                    session.renderTriangleLine(1, 0x00FF00, 1, ax, ay, bx, by, cx, cy);
                return;
            }

            faz = focus + az;
            fbz = focus + bz;
            fcz = focus + cz;

            mabz = 2 / (faz + fbz);
            mbcz = 2 / (fbz + fcz);
            mcaz = 2 / (fcz + faz);

            mabx = (ax*faz + bx*fbz)*mabz;
            maby = (ay*faz + by*fbz)*mabz;
            mbcx = (bx*fbz + cx*fcz)*mbcz;
            mbcy = (by*fbz + cy*fcz)*mbcz;
            mcax = (cx*fcz + ax*faz)*mcaz;
            mcay = (cy*fcz + ay*faz)*mcaz;

            dabx = ax + bx - mabx;
            daby = ay + by - maby;
            dbcx = bx + cx - mbcx;
            dbcy = by + cy - mbcy;
            dcax = cx + ax - mcax;
            dcay = cy + ay - mcay;
            
            dsab = (dabx*dabx + daby*daby);
            dsbc = (dbcx*dbcx + dbcy*dbcy);
            dsca = (dcax*dcax + dcay*dcay);

            if ((dsab <= precision) && (dsca <= precision) && (dsbc <= precision))
            {
                session.renderTriangleBitmap(bitmap, ta, tb, tc, td, tx, ty, ax, ay, bx, by, cx, cy, smooth, repeat);
                if (debug)
                    session.renderTriangleLine(1, 0x00FF00, 1, ax, ay, bx, by, cx, cy);
                return;
            }

            //Debug.trace(num(ta)+" "+num(tb)+" "+num(tc)+" "+num(td)+" "+num(tx)+" "+num(ty));
			
			var mabx2:Number;
        	var maby2:Number;
        	var mbcx2:Number;
        	var mbcy2:Number;
        	var mcax2:Number;
        	var mcay2:Number;
        	
            if ((dsab > precision) && (dsca > precision) && (dsbc > precision))
            {
            	mabx2 = mabx*0.5;
            	maby2 = maby*0.5;
            	mbcx2 = mbcx*0.5;
            	mbcy2 = mbcy*0.5;
            	mcax2 = mcax*0.5;
            	mcay2 = mcay*0.5;
            	
                renderRec(session, projection, ta*2, tb*2, tc*2, td*2, tx*2, ty*2,
                    ax, ay, az, mabx2, maby2, (az+bz)*0.5, mcax2, mcay2, (cz+az)*0.5);

                renderRec(session, projection, ta*2, tb*2, tc*2, td*2, tx*2-1, ty*2,
                    mabx2, maby2, (az+bz)*0.5, bx, by, bz, mbcx2, mbcy2, (bz+cz)*0.5);

                renderRec(session, projection, ta*2, tb*2, tc*2, td*2, tx*2, ty*2-1,
                    mcax2, mcay2, (cz+az)*0.5, mbcx2, mbcy2, (bz+cz)*0.5, cx, cy, cz);

                renderRec(session, projection, -ta*2, -tb*2, -tc*2, -td*2, -tx*2+1, -ty*2+1,
                    mbcx2, mbcy2, (bz+cz)*0.5, mcax2, mcay2, (cz+az)*0.5, mabx2, maby2, (az+bz)*0.5);

                return;
            }

            dmax = Math.max(dsab, Math.max(dsca, dsbc));
            if (dsab == dmax)
            {
            	mabx2 = mabx*0.5;
            	maby2 = maby*0.5;
            	
                renderRec(session, projection, ta*2, tb*1, tc*2, td*1, tx*2, ty*1,
                    ax, ay, az, mabx2, maby2, (az+bz)*0.5, cx, cy, cz);

                renderRec(session, projection, ta*2+tb, tb*1, 2*tc+td, td*1, tx*2+ty-1, ty*1,
                    mabx2, maby2, (az+bz)*0.5, bx, by, bz, cx, cy, cz);
            
                return;
            }

            if (dsca == dmax)
            {
            	mcax2 = mcax*0.5;
            	mcay2 = mcay*0.5;
            	
                renderRec(session, projection, ta*1, tb*2, tc*1, td*2, tx*1, ty*2,
                    ax, ay, az, bx, by, bz, mcax2, mcay2, (cz+az)*0.5);

                renderRec(session, projection, ta*1, tb*2 + ta, tc*1, td*2 + tc, tx, ty*2+tx-1,
                    mcax2, mcay2, (cz+az)*0.5, bx, by, bz, cx, cy, cz);
            
                return;
            }
			
			mbcx2 = mbcx*0.5;
            mbcy2 = mbcy*0.5;

            renderRec(session, projection, ta-tb, tb*2, tc-td, td*2, tx-ty, ty*2,
                ax, ay, az, bx, by, bz, mbcx2, mbcy2, (bz+cz)*0.5);

            renderRec(session, projection, 2*ta, tb-ta, tc*2, td-tc, 2*tx, ty-tx,
                ax, ay, az, mbcx2, mbcy2, (bz+cz)*0.5, cx, cy, cz);
        }

        private static function num(n:Number):Number
        {
            return int(n*1000)/1000;
        }


    }

}
