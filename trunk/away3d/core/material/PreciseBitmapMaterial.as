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
            
            createVertexArray();
        }
        
        public function createVertexArray():void
        {
        	var index:Number = 100;
        	while (index--) {
        		svArray.push(new ScreenVertex());
        	}
        }
        
        internal var session:RenderSession;
        internal var focus:Number;
        internal var mapping:Matrix;
        internal var map:Matrix = new Matrix();
        internal var triangle:DrawTriangle = new DrawTriangle();
        
        internal var svArray:Array = new Array();
        
        public override function renderTriangle(tri:DrawTriangle, session:RenderSession):void
        {
        	this.session = session;
        	focus = tri.projection.focus;
        	mapping = tri.texturemapping || tri.transformUV(tri.material as IUVMaterial);
        	map.a = mapping.a;
        	map.b = mapping.b;
        	map.c = mapping.c;
        	map.d = mapping.d;
        	map.tx = mapping.tx;
        	map.ty = mapping.ty;
        	
            renderRec(tri.v0, tri.v1, tri.v2, 0);

            if (debug)
                session.renderTriangleLine(2, 0x0000FF, 1, tri);
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
        
        //internal var a:ScreenVertex;
        //internal var b:ScreenVertex;
        //internal var c:ScreenVertex;
        
        internal var ax:Number;
        internal var ay:Number;
        internal var az:Number;
        internal var bx:Number;
        internal var by:Number;
        internal var bz:Number;
        internal var cx:Number;
        internal var cy:Number;
        internal var cz:Number;
        
        protected function renderRec(a:ScreenVertex, b:ScreenVertex, c:ScreenVertex, index:Number):void
        {
            if (index >= 100)
            	return;
            
        	ax = a.x;
        	ay = a.y;
        	az = a.z;
        	bx = b.x;
        	by = b.y;
        	bz = b.z;
        	cx = c.x;
        	cy = c.y;
        	cz = c.z;
        	
            if (!session.clip.rect(Math.min(ax, Math.min(bx, cx)), Math.min(ay, Math.min(by, cy)), Math.max(ax, Math.max(bx, cx)), Math.max(ay, Math.max(by, cy))))
                return;

            if ((az <= 0) && (bz <= 0) && (cz <= 0))
                return;
			
            if ((focus == Infinity) || (Math.max(Math.max(ax, bx), cx) - Math.min(Math.min(ax, bx), cx) < 10) || (Math.max(Math.max(ay, by), cy) - Math.min(Math.min(ay, by), cy) < 10))
            {
            	triangle.v0 = a;
	    		triangle.v1 = b;
	    		triangle.v2 = c;
	    		triangle.texturemapping = map;
                session.renderTriangleBitmap(bitmap, triangle, smooth, repeat);
                if (debug)
                    session.renderTriangleLine(1, 0x00FF00, 1, triangle);
                return;
            }

            faz = focus + az;
            fbz = focus + bz;
            fcz = focus + cz;

            mabz = 2 / (faz + fbz);
            mbcz = 2 / (fbz + fcz);
            mcaz = 2 / (fcz + faz);

            dabx = ax + bx - (mabx = (ax*faz + bx*fbz)*mabz);
            daby = ay + by - (maby = (ay*faz + by*fbz)*mabz);
            dbcx = bx + cx - (mbcx = (bx*fbz + cx*fcz)*mbcz);
            dbcy = by + cy - (mbcy = (by*fbz + cy*fcz)*mbcz);
            dcax = cx + ax - (mcax = (cx*fcz + ax*faz)*mcaz);
            dcay = cy + ay - (mcay = (cy*fcz + ay*faz)*mcaz);
            
            dsab = (dabx*dabx + daby*daby);
            dsbc = (dbcx*dbcx + dbcy*dbcy);
            dsca = (dcax*dcax + dcay*dcay);

            if ((dsab <= precision) && (dsca <= precision) && (dsbc <= precision))
            {
            	triangle.v0 = a;
	    		triangle.v1 = b;
	    		triangle.v2 = c;
	    		triangle.texturemapping = map;
                session.renderTriangleBitmap(bitmap, triangle, smooth, repeat);
                if (debug)
                    session.renderTriangleLine(1, 0x00FF00, 1,  triangle);
                return;
            }
            
            //Debug.trace(num(ta)+" "+num(tb)+" "+num(tc)+" "+num(td)+" "+num(tx)+" "+num(ty));
			/*
			var map:Matrix;
        	mIndex++;
			if (matrixArray.length < mIndex){
				trace("matrix");
				map = matrixArray[matrixArray.length] = new Matrix(mapping.a, mapping.b, mapping.c, mapping.d, mapping.tx, mapping.ty);
			} else {
				map = matrixArray[mIndex-1];
				map.a = mapping.a;
				map.b = mapping.b;
				map.c = mapping.c;
				map.d = mapping.d;
				map.tx = mapping.tx;
				map.ty = mapping.ty;	
			}
			*/
			var map_a:Number = map.a;
			var map_b:Number = map.b;
			var map_c:Number = map.c;
			var map_d:Number = map.d;
			var map_tx:Number = map.tx;
			var map_ty:Number = map.ty;
        	
        	var sv1:ScreenVertex;
        	var sv2:ScreenVertex;
        	var sv3:ScreenVertex = svArray[index++];
        	sv3.x = mbcx/2;
        	sv3.y = mbcy/2;
        	sv3.z = (bz+cz)/2;
        	
            if ((dsab > precision) && (dsca > precision) && (dsbc > precision))
            {
            	sv1 = svArray[index++];
            	sv1.x = mabx/2;
	        	sv1.y = maby/2;
	        	sv1.z = (az+bz)/2;
	        	
	        	sv2 = svArray[index++];
	        	sv2.x = mcax/2;
		        sv2.y = mcay/2;
		        sv2.z = (cz+az)/2;
	        	
            	map.a = map_a*=2;
            	map.b = map_b*=2;
            	map.c = map_c*=2;
            	map.d = map_d*=2;
            	map.tx = map_tx*=2;
            	map.ty = map_ty*=2;
                renderRec(a, sv1, sv2, index);
	        	
				map.a = map_a;
            	map.b = map_b;
            	map.c = map_c;
            	map.d = map_d;
            	map.tx = map_tx-1;
            	map.ty = map_ty;
                renderRec(sv1, b, sv3, index);
	        	
				map.a = map_a;
            	map.b = map_b;
            	map.c = map_c;
            	map.d = map_d;
            	map.tx = map_tx;
            	map.ty = map_ty-1;
                renderRec(sv2, sv3, c, index);
	        	
				map.a = -map_a;
            	map.b = -map_b;
            	map.c = -map_c;
            	map.d = -map_d;
            	map.tx = 1-map_tx;
            	map.ty = 1-map_ty;
                renderRec(sv3, sv2, sv1, index);
				
                return;
            }

            dmax = Math.max(dsab, Math.max(dsca, dsbc));
            if (dsab == dmax)
            {
            	sv1 = svArray[index++];
            	sv1.x = mabx/2;
	        	sv1.y = maby/2;
	        	sv1.z = (az+bz)/2;
	        	
            	map.a = map_a*=2;
            	map.c = map_c*=2;
            	map.tx = map_tx*=2;
                renderRec(a, sv1, c, index);
	        	
				map.a = map_a + map_b;
            	map.b = map_b;
            	map.c = map_c + map_d;
            	map.d = map_d;
            	map.tx = map_tx + map_ty - 1;
            	map.ty = map_ty;
                renderRec(sv1, b, c, index);
            	
                return;
            }

            if (dsca == dmax)
            {
            	sv2 = svArray[index++];
            	sv2.x = mcax/2;
	        	sv2.y = mcay/2;
	        	sv2.z = (cz+az)/2;
            	
            	map.b = map_b*=2;
            	map.d = map_d*=2;
            	map.ty = map_ty*=2;
                renderRec(a, b, sv2, index);
	        	
				map.a = map_a;
            	map.b = map_b + map_a;
            	map.c = map_c;
            	map.d = map_d + map_c;
            	map.tx = map_tx;
            	map.ty = map_ty + map_tx - 1;
                renderRec(sv2, b, c, index);
            	
                return;
            }
	        	
		    map.a = map_a - map_b;
        	map.b = map_b*2;
        	map.c = map_c - map_d;
        	map.d = map_d*2;
        	map.tx = map_tx - map_ty;
        	map.ty = map_ty*2;
            renderRec(a, b, sv3, index);
	        	
		    map.a = map_a*2;
        	map.b = map_b - map_a;
        	map.c = map_c*2;
        	map.d = map_d - map_c;
        	map.tx = map_tx*2;
        	map.ty = map_ty - map_tx;
            renderRec(a, sv3, c, index);
        }
        /*
		private function getScreenVertex():ScreenVertex
		{
			svIndex++;
        	if (svArray.length < svIndex) 
        		return svArray[svIndex-1] = new ScreenVertex();
        	
        	return svArray[svIndex-1];
		}
        */	
        private static function num(n:Number):Number
        {
            return int(n*1000)/1000;
        }


    }

}
