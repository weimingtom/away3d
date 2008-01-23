package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.mesh.Face;
    import away3d.core.mesh.Mesh;
    import away3d.core.render.*;
    import away3d.core.scene.*;
    import away3d.core.utils.*;
    
    import flash.display.*;
    import flash.geom.*;
    import flash.utils.Dictionary;

    /** Basic bitmap texture material */
    public class BitmapMaterial implements ITriangleMaterial, IUVTransformMaterial
    {
    	use namespace arcane;
    	
        internal var _bitmap:BitmapData;
        internal var _transform:Matrix;
        internal var _projectionVector:Number3D;
        
        internal var _N:Number3D = new Number3D();
        internal var _M:Number3D = new Number3D();
        
        internal var UP:Number3D = new Number3D(0, 1, 0);
        internal var RIGHT:Number3D = new Number3D(1, 0, 0);
        
        internal var _zeroPoint:Point = new Point(0, 0);
        internal var _bitmapRect:Rectangle;
        
        internal var _transformDirty:Boolean;
        public var _bitmapDictionary:Dictionary = new Dictionary(true);
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
        
        public function get transform():Matrix
        {
        	return _transform;
        }
        
        public function set transform(val:Matrix):void
        {
        	_transform = val;
        	clearBitmapDictionary()
        }
        
        public function get projectionVector():Number3D
        {
        	return _projectionVector;
        }
        
        public function set projectionVector(val:Number3D):void
        {
        	_projectionVector = val;
        	if (_projectionVector) {
        		_N.cross(_projectionVector, UP);
	            if (!_N.modulo) _N = RIGHT;
	            _M.cross(_N, _projectionVector);
	            _N.cross(_M, _projectionVector);
	            _N.normalize();
	            _M.normalize();
        	}
        	clearBitmapDictionary();
        }
        
        public function get bitmapDictionary():Dictionary
        {
        	return _bitmapDictionary
        }
        
        internal var bitmapDictionaryVO:BitmapDictionaryVO;
        
        public function clearBitmapDictionary():void
        {
        	_transformDirty = true;
        	for each (bitmapDictionaryVO in _bitmapDictionary)
        		if (!bitmapDictionaryVO.dirty)
        			bitmapDictionaryVO.clear();
        }
             
        public function BitmapMaterial(bitmap:BitmapData, init:Object = null)
        {
            _bitmap = bitmap;
            
            init = Init.parse(init);
			
            smooth = init.getBoolean("smooth", false);
            debug = init.getBoolean("debug", false);
            repeat = init.getBoolean("repeat", false);
            transform = init.getObject("transform", Matrix);
            projectionVector = init.getObject("projectionVector", Number3D);
            precision = init.getNumber("precision", 0);

            precision = precision * precision * 1.4;
            
            createVertexArray();
        }
        
        internal var face:Face;
        internal var w:Number;
        internal var h:Number;
        
        public function renderMaterial(source:Mesh, bitmapRect:Rectangle, bitmap:BitmapData):void
        {
        	/*
    		if (_transform) {
				mapping = _transform.clone();
			} else {
				mapping = new Matrix();
			}
        	
        	if (!_bitmapDictionary[source])
        		_bitmapDictionary[source] = bitmap.clone();
        	
        	if (_projectionVector) {
        		w = bitmap.width;
        		h = bitmap.height;
        		for each (face in source.faces) {
        			if (face._dt.texturemapping && !_bitmapDictionary[face]) {
        				_bitmapDictionary[face] = _bitmapDictionary[source];
	        			mapping.concat(face._dt.transformUV(this));
						mapping.concat(face._dt.invtexturemapping);
		        		graphics = shape.graphics;
						graphics.clear();
						graphics.beginBitmapFill(_bitmap, mapping, repeat, smooth);
						graphics.moveTo(face._uv0._u*w, (1 - face._uv0._v)*h);
			            graphics.lineTo(face._uv1._u*w, (1 - face._uv1._v)*h);
			            graphics.lineTo(face._uv2._u*w, (1 - face._uv2._v)*h);
			            graphics.endFill();
			            _bitmapDictionary[source].draw(shape);
			        }
        		}
        	} else {
				mapping.scale(bitmapRect.width/width, bitmapRect.height/height)
				
				if (mapping.a == 1 && mapping.d == 1 && mapping.b == 0 && mapping.c == 0) {
					_bitmapDictionary[source].copyPixels(_bitmap, bitmapRect, _zeroPoint);
				}else {
					
					graphics = shape.graphics;
					graphics.clear();
					graphics.beginBitmapFill(_bitmap, mapping, repeat, smooth);
					graphics.drawRect(0, 0, bitmapRect.width, bitmapRect.height);
		            graphics.endFill();
					_bitmapDictionary[source].draw(shape);
					
				}
        	}*/
        }
        
        internal var mapping:Matrix;
        
        public function renderTriangle(tri:DrawTriangle):void
        {
			if (precision) {
				session = tri.source.session;
            	focus = tri.projection.focus;
            	mapping = getMapping(tri);
            	
            	map.a = mapping.a;
	            map.b = mapping.b;
	            map.c = mapping.c;
	            map.d = mapping.d;
	            map.tx = mapping.tx;
	            map.ty = mapping.ty;
	            
	            renderRec(tri.v0, tri.v1, tri.v2, 0);
			} else {
				tri.source.session.renderTriangleBitmap(_bitmap, getMapping(tri), tri.v0, tri.v1, tri.v2, smooth, repeat);
			}
			
            if (debug)
                tri.source.session.renderTriangleLine(2, 0x0000FF, 1, tri.v0, tri.v1, tri.v2);
        }
		
		public function getMapping(tri:DrawTriangle):Matrix
		{
        	//check local transform or if texturemapping is null
        	if (_transformDirty || !tri.texturemapping) {
        		_transformDirty = false;
        		//use projectUV if projection vector detected
        		if (projectionVector)
        			tri.texturemapping = projectUV(tri);
        		else
        			tri.transformUV(this);
        		if (_transform) {
	        		mapping = _transform.clone();
	        		mapping.concat(tri.texturemapping);
	        		return tri.texturemapping = mapping;
	        	}
        	}
        	return tri.texturemapping;
		}
        
        internal var _u0:Number;
        internal var _u1:Number;
        internal var _u2:Number;
        internal var _v0:Number;
        internal var _v1:Number;
        internal var _v2:Number;
        
        internal var v0x:Number;
        internal var v0y:Number;
        internal var v0z:Number;
        internal var v1x:Number;
        internal var v1y:Number;
        internal var v1z:Number;
        internal var v2x:Number;
        internal var v2y:Number;
        internal var v2z:Number;
        
        internal var t:Matrix;
        
		public final function projectUV(tri:DrawTriangle):Matrix
        {
        	face = tri.face;
        	
    		if (tri.backface) {
	        	v0x = face.v0.x;
	        	v0y = face.v0.y;
	        	v0z = face.v0.z;
	        	v2x = face.v1.x;
	        	v2y = face.v1.y;
	        	v2z = face.v1.z;
	        	v1x = face.v2.x;
	        	v1y = face.v2.y;
	        	v1z = face.v2.z;
	    	} else {
	        	v0x = face.v0.x;
	        	v0y = face.v0.y;
	        	v0z = face.v0.z;
	        	v1x = face.v1.x;
	        	v1y = face.v1.y;
	        	v1z = face.v1.z;
	        	v2x = face.v2.x;
	        	v2y = face.v2.y;
	        	v2z = face.v2.z;
    		}
    		
    		_u0 = v0x*_N.x + v0y*_N.y + v0z*_N.z;
    		_u1 = v1x*_N.x + v1y*_N.y + v1z*_N.z;
    		_u2 = v2x*_N.x + v2y*_N.y + v2z*_N.z;
    		_v0 = v0x*_M.x + v0y*_M.y + v0z*_M.z;
    		_v1 = v1x*_M.x + v1y*_M.y + v1z*_M.z;
    		_v2 = v2x*_M.x + v2y*_M.y + v2z*_M.z;
      
            // Fix perpendicular projections
            if ((_u0 == _u1 && _v0 == _v1) || (_u0 == _u2 && _v0 == _v2))
            {
            	if (_u0 > 0.05)
                	_u0 -= 0.05;
                else
                	_u0 += 0.05;
                	
                if (_v0 > 0.07)           
                	_v0 -= 0.07;
                else
                	_v0 += 0.07;
            }
    
            if (_u2 == _u1 && _v2 == _v1)
            {
            	if (_u2 > 0.04)
                	_u2 -= 0.04;
                else
                	_u2 += 0.04;
                	
                if (_v2 > 0.06)           
                	_v2 -= 0.06;
                else
                	_v2 += 0.06;
            }
            
            t = new Matrix(_u1 - _u0, _v1 - _v0, _u2 - _u0, _v2 - _v0, _u0, _v0);
            t.invert();
            return t;
        }
        
		internal var shape:Shape = new Shape();
		internal var graphics:Graphics;
		internal var bitmapRect:Rectangle;
		
		public function renderFace(face:Face, bitmapRect:Rectangle):void
		{
			//retrieve the transform
			if (_transform)
				mapping = _transform.clone();
			else
				mapping = new Matrix();
			
			//update the transform based on scaling or projection vector
			if (_projectionVector) {
				mapping.concat(projectUV(face._dt));
				mapping.concat(face._dt.invtexturemapping);
				bitmapRect = face._bitmapRect;
			} else {
				mapping.scale(bitmapRect.width/width, bitmapRect.height/height);
			}
			
			//update VO
			bitmapDictionaryVO = _bitmapDictionary[face];
			if (!bitmapDictionaryVO)
				bitmapDictionaryVO = _bitmapDictionary[face] = new BitmapDictionaryVO(bitmapRect.width, bitmapRect.height);	
			else
				bitmapDictionaryVO.dirty = false;
			
			//create source VO for non-projected bitmaps
			if (!_projectionVector)
				_bitmapDictionary[face.parent] = bitmapDictionaryVO;
			
			//draw the bitmap
			if (mapping.a == 1 && mapping.d == 1 && mapping.b == 0 && mapping.c == 0) {
				//speedier version for non-transformed bitmap
				bitmapDictionaryVO.bitmap.copyPixels(_bitmap, bitmapRect, _zeroPoint);
			}else {
				graphics = shape.graphics;
				graphics.clear();
				graphics.beginBitmapFill(_bitmap, mapping, repeat, smooth);
				graphics.drawRect(0, 0, bitmapRect.width, bitmapRect.height);
	            graphics.endFill();
				bitmapDictionaryVO.bitmap.draw(shape);
				
			}
		}
		
		public function transformProjection():void
		{
			
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
                session.renderTriangleBitmap(bitmap, map, a, b, c, smooth, repeat);
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
                session.renderTriangleBitmap(bitmap, map, a, b, c, smooth, repeat);
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
