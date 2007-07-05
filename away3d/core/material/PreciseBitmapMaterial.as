package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;

    import flash.display.Graphics;
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
            var mapping:Matrix = tri.texturemapping || tri.transformUV(this);

            var v0:Vertex2D = tri.v0;
            var v1:Vertex2D = tri.v1;
            var v2:Vertex2D = tri.v2;

            renderRec(session, tri.projection, mapping.a, mapping.b, mapping.c, mapping.d, mapping.tx, mapping.ty, v0.x, v0.y, v0.z, v1.x, v1.y, v1.z, v2.x, v2.y, v2.z);

            if (debug)
            {
                var graphics:Graphics = session.graphics;
                graphics.lineStyle(2, 0xFFFFFF);
                graphics.moveTo(tri.v0.x, tri.v0.y);
                graphics.lineTo(tri.v1.x, tri.v1.y);
                graphics.lineTo(tri.v2.x, tri.v2.y);
                graphics.lineTo(tri.v0.x, tri.v0.y);
            }
        }

        protected function renderRec(session:RenderSession, projection:Projection,
            ta:Number, tb:Number, tc:Number, td:Number, tx:Number, ty:Number, 
            ax:Number, ay:Number, az:Number, bx:Number, by:Number, bz:Number, cx:Number, cy:Number, cz:Number):void
        {
            if (!session.clip.rect(Math.min(ax, Math.min(bx, cx)), Math.min(ay, Math.min(by, cy)), Math.max(ax, Math.max(bx, cx)), Math.max(ay, Math.max(by, cy))))
                return;

            if ((az <= 0) && (bz <= 0) && (cz <= 0))
                return;

            var focus:Number = projection.focus;
            var graphics:Graphics = session.graphics;
            if ((focus == Infinity) || (Math.max(Math.max(ax, bx), cx) - Math.min(Math.min(ax, bx), cx) < 10) || (Math.max(Math.max(ay, by), cy) - Math.min(Math.min(ay, by), cy) < 10))
            {
                RenderTriangle.renderBitmap(graphics, bitmap, ta, tb, tc, td, tx, ty, ax, ay, bx, by, cx, cy, smooth, repeat);
                if (debug)
                {
                    graphics.lineStyle(1, 0x00FF00);
                    graphics.moveTo(ax, ay);
                    graphics.lineTo(bx, by);
                    graphics.lineTo(cx, cy);
                    graphics.lineTo(ax, ay);
                }
                return;
            }

            var faz:Number = focus + az;
            var fbz:Number = focus + bz;
            var fcz:Number = focus + cz;

            var mabz:Number = 2 / (faz + fbz);
            var mbcz:Number = 2 / (fbz + fcz);
            var mcaz:Number = 2 / (fcz + faz);

            var mabx:Number = (ax*faz + bx*fbz)*mabz;
            var maby:Number = (ay*faz + by*fbz)*mabz;
            var mbcx:Number = (bx*fbz + cx*fcz)*mbcz;
            var mbcy:Number = (by*fbz + cy*fcz)*mbcz;
            var mcax:Number = (cx*fcz + ax*faz)*mcaz;
            var mcay:Number = (cy*fcz + ay*faz)*mcaz;

            var dabx:Number = ax + bx - mabx;
            var daby:Number = ay + by - maby;
            var dbcx:Number = bx + cx - mbcx;
            var dbcy:Number = by + cy - mbcy;
            var dcax:Number = cx + ax - mcax;
            var dcay:Number = cy + ay - mcay;
            
            var dsab:Number = (dabx*dabx + daby*daby);
            var dsbc:Number = (dbcx*dbcx + dbcy*dbcy);
            var dsca:Number = (dcax*dcax + dcay*dcay);

            if ((dsab <= precision) && (dsca <= precision) && (dsbc <= precision))
            {
                RenderTriangle.renderBitmap(graphics, bitmap, ta, tb, tc, td, tx, ty, ax, ay, bx, by, cx, cy, smooth, repeat);
                if (debug)
                {
                    graphics.lineStyle(1, 0x0000FF);
                    graphics.moveTo(ax, ay);
                    graphics.lineTo(bx, by);
                    graphics.lineTo(cx, cy);
                    graphics.lineTo(ax, ay);
                }
                return;
            }

            //Debug.trace(num(ta)+" "+num(tb)+" "+num(tc)+" "+num(td)+" "+num(tx)+" "+num(ty));

            if ((dsab > precision) && (dsca > precision) && (dsbc > precision))
            {
                renderRec(session, projection, ta*2, tb*2, tc*2, td*2, tx*2, ty*2,
                    ax, ay, az, mabx/2, maby/2, (az+bz)/2, mcax/2, mcay/2, (cz+az)/2);

                renderRec(session, projection, ta*2, tb*2, tc*2, td*2, tx*2-1, ty*2,
                    mabx/2, maby/2, (az+bz)/2, bx, by, bz, mbcx/2, mbcy/2, (bz+cz)/2);

                renderRec(session, projection, ta*2, tb*2, tc*2, td*2, tx*2, ty*2-1,
                    mcax/2, mcay/2, (cz+az)/2, mbcx/2, mbcy/2, (bz+cz)/2, cx, cy, cz);

                renderRec(session, projection, -ta*2, -tb*2, -tc*2, -td*2, -tx*2+1, -ty*2+1,
                    mbcx/2, mbcy/2, (bz+cz)/2, mcax/2, mcay/2, (cz+az)/2, mabx/2, maby/2, (az+bz)/2);

                return;
            }

            var dmax:Number = Math.max(dsab, Math.max(dsca, dsbc));
            if (dsab == dmax)
            {
                renderRec(session, projection, ta*2, tb*1, tc*2, td*1, tx*2, ty*1,
                    ax, ay, az, mabx/2, maby/2, (az+bz)/2, cx, cy, cz);

                renderRec(session, projection, ta*2+tb, tb*1, 2*tc+td, td*1, tx*2+ty-1, ty*1,
                    mabx/2, maby/2, (az+bz)/2, bx, by, bz, cx, cy, cz);
            
                return;
            }

            if (dsca == dmax)
            {
                renderRec(session, projection, ta*1, tb*2, tc*1, td*2, tx*1, ty*2,
                    ax, ay, az, bx, by, bz, mcax/2, mcay/2, (cz+az)/2);

                renderRec(session, projection, ta*1, tb*2 + ta, tc*1, td*2 + tc, tx, ty*2+tx-1,
                    mcax/2, mcay/2, (cz+az)/2, bx, by, bz, cx, cy, cz);
            
                return;
            }


            renderRec(session, projection, ta-tb, tb*2, tc-td, td*2, tx-ty, ty*2,
                ax, ay, az, bx, by, bz, mbcx/2, mbcy/2, (bz+cz)/2);

            renderRec(session, projection, 2*ta, tb-ta, tc*2, td-tc, 2*tx, ty-tx,
                ax, ay, az, mbcx/2, mbcy/2, (bz+cz)/2, cx, cy, cz);
        }

        private static function num(n:Number):Number
        {
            return int(n*1000)/1000;
        }


    }

}
