
package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.mesh.*;
    import away3d.core.render.*;
    import away3d.core.scene.*;
    import away3d.core.utils.*;
    
    import flash.display.*;
    import flash.geom.*;
    import flash.utils.Dictionary;

    /** Basic bitmap texture material */
    public class BitmapMaterial implements ITriangleMaterial, IUVMaterial
    {
    	use namespace arcane;
    	
    	internal var _bitmap:BitmapData;
    	internal var _renderBitmap:BitmapData;
        internal var _faceDictionary:Dictionary = new Dictionary(true);
    	internal var _zeroPoint:Point = new Point(0, 0);
    	
        public var smooth:Boolean;
        public var debug:Boolean;
        public var repeat:Boolean;
        public var precision:Number = 0;
        
        
        public function get width():Number
        {
            return _bitmap.width;
        }

        public function get height():Number
        {
            return _bitmap.height;
        }
        
        public function get bitmap():BitmapData
        {
        	return _bitmap;
        }
        
        public function get faceDictionary():Dictionary
        {
        	return _faceDictionary
        }
        
        internal var faceDictionaryVO:FaceDictionaryVO;
        
        public function clearFaceDictionary():void
        {
        	for each (faceDictionaryVO in _faceDictionary)
        		if (!faceDictionaryVO.dirty)
        			faceDictionaryVO.clear();
        }
        
        public function BitmapMaterial(bitmap:BitmapData, init:Object = null)
        {
            _renderBitmap = _bitmap = bitmap;
            
            init = Init.parse(init);
			
            smooth = init.getBoolean("smooth", false);
            debug = init.getBoolean("debug", false);
            repeat = init.getBoolean("repeat", false);
            precision = init.getNumber("precision", 0);

            precision = precision * precision * 1.4;
            
            createVertexArray();
        }
        
        public function renderMaterial(source:Mesh):void
        {
        }
        
        internal var mapping:Matrix;
        
        public function renderTriangle(tri:DrawTriangle):void
        {
        	mapping = getMapping(tri);
        	
			if (precision) {
				session = tri.source.session;
            	focus = tri.projection.focus;
            	
            	map.a = mapping.a;
	            map.b = mapping.b;
	            map.c = mapping.c;
	            map.d = mapping.d;
	            map.tx = mapping.tx;
	            map.ty = mapping.ty;
	            
	            renderRec(tri.v0, tri.v1, tri.v2, 0);
			} else {
				tri.source.session.renderTriangleBitmap(_renderBitmap, mapping, tri.v0, tri.v1, tri.v2, smooth, repeat);
			}
			
            if (debug)
                tri.source.session.renderTriangleLine(2, 0x0000FF, 1, tri.v0, tri.v1, tri.v2);
        }
		
		public function getMapping(tri:DrawTriangle):Matrix
		{
			return tri.texturemapping || tri.transformUV(this);
		}
		
		internal var shape:Shape = new Shape();
		internal var graphics:Graphics;
		
		public function renderFace(face:Face, bitmapRect:Rectangle):void
		{
			faceDictionaryVO = _faceDictionary[face];
			if (!faceDictionaryVO)
				faceDictionaryVO = _faceDictionary[face.parent] = new FaceDictionaryVO(bitmapRect.width, bitmapRect.height);
					
			mapping = new Matrix();
			mapping.scale(bitmapRect.width/width, bitmapRect.height/height);
			
			faceDictionaryVO.dirty = false;
			
			//draw the bitmap
			if (mapping.a == 1 && mapping.d == 1) {
				//speedier version for non-transformed bitmap
				faceDictionaryVO.bitmap.copyPixels(_bitmap, bitmapRect, _zeroPoint);
			}else {
				graphics = shape.graphics;
				graphics.clear();
				graphics.beginBitmapFill(_bitmap, mapping, repeat, smooth);
				graphics.drawRect(0, 0, bitmapRect.width, bitmapRect.height);
	            graphics.endFill();
				faceDictionaryVO.bitmap.draw(shape);
			}
		}
		
		public function shadeTriangle(tri:DrawTriangle):void
        {
        	//tri.bitmapMaterial = getBitmapReflection(tri, source);
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
        internal var map:Matrix = new Matrix();
        internal var triangle:DrawTriangle = new DrawTriangle();
        
        internal var svArray:Array = new Array();
        
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
            
            if (index >= 100 || (focus == Infinity) || (Math.max(Math.max(ax, bx), cx) - Math.min(Math.min(ax, bx), cx) < 10) || (Math.max(Math.max(ay, by), cy) - Math.min(Math.min(ay, by), cy) < 10))
            {
                /*
                triangle.v0 = a;
                triangle.v1 = b;
                triangle.v2 = c;
                triangle.texturemapping = map;
                */
                session.renderTriangleBitmap(_renderBitmap, map, a, b, c, smooth, repeat);
                if (debug)
                    session.renderTriangleLine(1, 0x00FF00, 1, a, b, c);
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
                session.renderTriangleBitmap(_renderBitmap, map, a, b, c, smooth, repeat);
                if (debug)
                    session.renderTriangleLine(1, 0x00FF00, 1, a, b, c);
                return;
            }

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
        
        public function get visible():Boolean
        {
            return true;
        }
 
    }
}
