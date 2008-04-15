package away3d.materials
{
    import away3d.containers.*;
    import away3d.core.*;
    import away3d.core.base.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;
    
    import flash.display.*;
    import flash.geom.*;
    import flash.utils.Dictionary;

    /** Basic bitmap texture material */
    public class BitmapMaterial implements ITriangleMaterial, IUVMaterial, ILayerMaterial, IUpdatingMaterial
    {
    	use namespace arcane;
    	
    	internal var _bitmap:BitmapData;
    	internal var _renderBitmap:BitmapData;
        internal var _faceDictionary:Dictionary = new Dictionary(true);
        internal var _blendMode:String;
    	internal var _zeroPoint:Point = new Point(0, 0);
        internal var _precision:Number;
        internal var _shapeDictionary:Dictionary = new Dictionary(true);
    	internal var _shape:Shape;
        public var smooth:Boolean;
        public var debug:Boolean;
        public var repeat:Boolean;
        
        public function set precision(val:Number):void
        {
        	_precision = val*val*1.4;
        }
        
        public function get precision():Number
        {
        	return _precision;
        }
        
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
        
        internal var _faceVO:FaceVO;
        
        public function updateMaterial(source:Object3D, view:View3D):void
        {
        	clearShapeDictionary();
        }
        
        public function clearShapeDictionary():void
        {
        	for each (_shape in _shapeDictionary)
	        	_shape.graphics.clear();
        }
        
        public function clearFaceDictionary():void
        {
        	for each (_faceVO in _faceDictionary) {
        		if (!_faceVO.cleared)
        			_faceVO.clear();
        		_faceVO.invalidated = true;
        	}
        }
        
        public function set blendMode(val:String):void
        {
        	_blendMode = val;
        }
        
        public function get blendMode():String
        {
        	return _blendMode;
        }
        
        public function BitmapMaterial(bitmap:BitmapData, init:Object = null)
        {
            _renderBitmap = _bitmap = bitmap;
            
            init = Init.parse(init);
			
            smooth = init.getBoolean("smooth", false);
            debug = init.getBoolean("debug", false);
            repeat = init.getBoolean("repeat", false);
            precision = init.getNumber("precision", 0);
            _blendMode = init.getString("blendMode", BlendMode.NORMAL);
            
            createVertexArray();
        }
        
        public function renderLayer(tri:DrawTriangle, layer:Sprite):void
        {
        	if (!blendMode || blendMode == BlendMode.NORMAL) {
        		_graphics = layer.graphics;
        	} else {
	        	if (tri.source.ownCanvas) {
	        		//check to see if source shape exists
		    		if (!(_shape = _shapeDictionary[tri.source]))
		    			layer.addChild(_shape = _shapeDictionary[tri.source] = new Shape());
	        	} else {
		        	//check to see if face shape exists
		    		if (!(_shape = _shapeDictionary[tri.face]))
		    			layer.addChild(_shape = _shapeDictionary[tri.face] = new Shape());
	        	}
	    		_shape.blendMode = _blendMode;
	    		_graphics = _shape.graphics;
        	}
    		
    		
    		renderTriangle(tri);
        }
        
        internal var _mapping:Matrix;
        
        public function renderTriangle(tri:DrawTriangle):void
        {
        	_mapping = getMapping(tri);
        	
			if (precision) {
				session = tri.source.session;
            	focus = tri.projection.focus;
            	
            	map.a = _mapping.a;
	            map.b = _mapping.b;
	            map.c = _mapping.c;
	            map.d = _mapping.d;
	            map.tx = _mapping.tx;
	            map.ty = _mapping.ty;
	            
	            renderRec(tri.v0, tri.v1, tri.v2, 0);
			} else {
				tri.source.session.renderTriangleBitmap(_renderBitmap, _mapping, tri.v0, tri.v1, tri.v2, smooth, repeat, _graphics);
			}
			
            if (debug)
                tri.source.session.renderTriangleLine(0, 0x0000FF, 1, tri.v0, tri.v1, tri.v2);
        }
		
		public function getMapping(tri:DrawTriangle):Matrix
		{
			return tri.texturemapping || tri.transformUV(this);
		}
		
		internal var _s:Shape = new Shape();
		internal var _graphics:Graphics;
		internal var _bitmapRect:Rectangle;
		internal var _sourceVO:FaceVO;
		
		public function renderFace(face:Face, containerRect:Rectangle, parentFaceVO:FaceVO):FaceVO
		{
			//draw the bitmap once
			renderSource(face.parent, containerRect, new Matrix());
			
			//check to see if faceDictionary exists
			_faceVO = _faceDictionary[face];
			if (!_faceVO)
				_faceVO = _faceDictionary[face] = new FaceVO();
			
			//pass on resize value
			if (parentFaceVO.resized) {
				parentFaceVO.resized = false;
				_faceVO.resized = true;
			}
				
			//check to see if face update can be skipped
			if (parentFaceVO.updated || _faceVO.invalidated) {
				parentFaceVO.updated = false;
				
				//reset booleans
				_faceVO.invalidated = false;
				_faceVO.cleared = false;
				_faceVO.updated = true;
				
				//store a clone
				_faceVO.bitmap = parentFaceVO.bitmap.clone();
				
				//draw into faceBitmap
				_faceVO.bitmap.copyPixels(_sourceVO.bitmap, face.bitmapRect, _zeroPoint, null, null, true);
			}
			
			return _faceVO;
		}
		
		public function renderSource(source:Object3D, containerRect:Rectangle, mapping:Matrix):void
		{
			//check to see if sourceDictionary exists
			_sourceVO = _faceDictionary[source];
			if (!_sourceVO)
				_sourceVO = _faceDictionary[source] = new FaceVO();
			
			_sourceVO.resize(containerRect.width, containerRect.height);
			
			//check to see if rendering can be skipped
			if (_sourceVO.invalidated) {
				
				//calulate scale matrix
				mapping.scale(containerRect.width/width, containerRect.height/height);
				
				//reset booleans
				_sourceVO.invalidated = false;
				_sourceVO.cleared = false;
				_sourceVO.updated = true;
				
				//draw the bitmap
				if (mapping.a == 1 && mapping.d == 1 && mapping.b == 0 && mapping.c == 0 && mapping.tx == 0 && mapping.ty == 0) {
					//speedier version for non-transformed bitmap
					_sourceVO.bitmap.copyPixels(_bitmap, containerRect, _zeroPoint);
				}else {
					_graphics = _s.graphics;
					_graphics.clear();
					_graphics.beginBitmapFill(_bitmap, mapping, repeat, smooth);
					_graphics.drawRect(0, 0, containerRect.width, containerRect.height);
		            _graphics.endFill();
					_sourceVO.bitmap.draw(_s, null, null, null, _sourceVO.bitmap.rect);
				}
			}
		}
        
        public function createVertexArray():void
        {
            var index:Number = 100;
            while (index--) {
                svArray.push(new ScreenVertex());
            }
        }
        
        internal var session:AbstractRenderSession;
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
            
            if (!session.view.clip.rect(Math.min(ax, Math.min(bx, cx)), Math.min(ay, Math.min(by, cy)), Math.max(ax, Math.max(bx, cx)), Math.max(ay, Math.max(by, cy))))
                return;

            if ((az <= 0) && (bz <= 0) && (cz <= 0))
                return;
            
            if (index >= 100 || (focus == Infinity) || (Math.max(Math.max(ax, bx), cx) - Math.min(Math.min(ax, bx), cx) < 10) || (Math.max(Math.max(ay, by), cy) - Math.min(Math.min(ay, by), cy) < 10))
            {
                session.renderTriangleBitmap(_renderBitmap, map, a, b, c, smooth, repeat, _graphics);
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
                session.renderTriangleBitmap(_renderBitmap, map, a, b, c, smooth, repeat, _graphics);
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