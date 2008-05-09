package away3d.materials
{
    import away3d.containers.*;
    import away3d.core.*;
    import away3d.core.base.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;
    import away3d.events.MaterialEvent;
    
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.utils.Dictionary;

    /** Basic bitmap texture material */
    public class BitmapMaterial extends EventDispatcher implements ITriangleMaterial, IUVMaterial, ILayerMaterial, IUpdatingMaterial
    {
    	use namespace arcane;
    	
    	internal var _bitmap:BitmapData;
    	internal var _renderBitmap:BitmapData;
    	internal var _colorTransform:ColorTransform;
    	internal var _defaultColorTransform:ColorTransform = new ColorTransform();
    	internal var _colorTransformDirty:Boolean;
        internal var _blendMode:String;
        internal var _blendModeDirty:Boolean;
        internal var _color:uint;
		internal var _red:Number;
		internal var _green:Number;
		internal var _blue:Number;
        internal var _alpha:Number;
        
        internal var _faceDictionary:Dictionary = new Dictionary(true);
        
    	internal var _zeroPoint:Point = new Point(0, 0);
        internal var _precision:Number;
        internal var _shapeDictionary:Dictionary = new Dictionary(true);
    	internal var _shape:Shape;
    	
        public var smooth:Boolean = false;
        public var debug:Boolean = false;
        public var repeat:Boolean = false;
        
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
        
        public function getPixel32(u:Number, v:Number):uint
        {
        	return _bitmap.getPixel32(u*_bitmap.width, (1 - v)*_bitmap.height);
        }
        
        public function set color(val:uint):void
		{
			if (_color == val)
				return;
			
			_color = val;
            _red = ((_color & 0xFF0000) >> 16)/255;
            _green = ((_color & 0x00FF00) >> 8)/255;
            _blue = (_color & 0x0000FF)/255;
            
            _colorTransformDirty = true;
		}
		
		public function get color():uint
		{
			return _color;
		}
        
        public function set alpha(value:Number):void
        {
            if (value > 1)
                value = 1;

            if (value < 0)
                value = 0;

            if (_alpha == value)
                return;

            _alpha = value;

            _colorTransformDirty = true;
        }
		
        public function get alpha():Number
        {
            return _alpha;
        }
        
        internal function setColorTransform():void
        {
        	_colorTransformDirty = false;
        	
            if (_alpha == 1 && _color == 0xFFFFFF) {
                _renderBitmap = _bitmap;
                _colorTransform = null;
                return;
            } else if (!_colorTransform)
            	_colorTransform = new ColorTransform();
			
			_colorTransform.redMultiplier = _red;
			_colorTransform.greenMultiplier = _green;
			_colorTransform.blueMultiplier = _blue;
			_colorTransform.alphaMultiplier = _alpha;

            if (_alpha == 0) {
                _renderBitmap = null;
                return;
            }
			
			updateRenderBitmap();
        }
        
        internal function updateRenderBitmap():void
        {
        	_renderBitmap = _bitmap.clone();
            _renderBitmap.colorTransform(_renderBitmap.rect, _colorTransform);
        }
        
        internal var _faceVO:FaceVO;
        
        public function updateMaterial(source:Object3D, view:View3D):void
        {
        	_graphics = null;
        	clearShapeDictionary();
        	
        	if (_colorTransformDirty || _blendModeDirty)
        		clearFaceDictionary();
        		
        	if (_colorTransformDirty)
        		setColorTransform();
        		
        	_blendModeDirty = false;
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
        	if (_blendMode == val)
        		return;
        	
        	_blendMode = val;
        	_blendModeDirty = true;
        }
        
        public function get blendMode():String
        {
        	return _blendMode;
        }
        
        public function BitmapMaterial(bitmap:BitmapData, init:Object = null)
        {
        	if (!bitmap.transparent) {
                _bitmap = new BitmapData(bitmap.width, bitmap.height, true);
                _bitmap.draw(bitmap);
            } else {
            	_bitmap = bitmap;
            }
            
            init = Init.parse(init);
			
            smooth = init.getBoolean("smooth", smooth);
            debug = init.getBoolean("debug", debug);
            repeat = init.getBoolean("repeat", repeat);
            precision = init.getNumber("precision", 0);
            _blendMode = init.getString("blendMode", BlendMode.NORMAL);
            alpha = init.getNumber("alpha", 1, {min:0, max:1});
            color = init.getNumber("color", 0xFFFFFF, {min:0, max:0xFFFFFF});
            
            
            createVertexArray();
        }
        
        public function renderLayer(tri:DrawTriangle, layer:Sprite, level:int):void
        {
        	if (!_colorTransform && blendMode == BlendMode.NORMAL) {
        		_graphics = layer.graphics;
        	} else {
        		session = tri.source.session;
	        	if (session != session.view.session) {
	        		//check to see if source shape exists
		    		if (!(_shape = _shapeDictionary[session]))
		    			layer.addChild(_shape = _shapeDictionary[session] = new Shape());
	        	} else {
		        	//check to see if face shape exists
		    		if (!(_shape = _shapeDictionary[tri.face]))
		    			layer.addChild(_shape = _shapeDictionary[tri.face] = new Shape());
	        	}
	    		_shape.blendMode = _blendMode;
	    		
	    		if (_colorTransform)
	    			_shape.transform.colorTransform = _colorTransform;
	    		else
	    			_shape.transform.colorTransform = _defaultColorTransform;
	    		
	    		_graphics = _shape.graphics;
        	}
    		
    		
    		renderTriangle(tri);
        }
        
        internal var _mapping:Matrix;
        
        public function renderTriangle(tri:DrawTriangle):void
        {
        	_mapping = getMapping(tri);
			session = tri.source.session;
        	
        	if (!_graphics && session != session.view.session && session.newLayer)
        		_graphics = session.newLayer.graphics;
        	
			if (precision) {
            	focus = tri.projection.focus;
            	
            	map.a = _mapping.a;
	            map.b = _mapping.b;
	            map.c = _mapping.c;
	            map.d = _mapping.d;
	            map.tx = _mapping.tx;
	            map.ty = _mapping.ty;
	            
	            renderRec(tri.v0, tri.v1, tri.v2, 0);
			} else {
				session.renderTriangleBitmap(_renderBitmap, _mapping, tri.v0, tri.v1, tri.v2, smooth, repeat, _graphics);
			}
			
            if (debug)
                session.renderTriangleLine(0, 0x0000FF, 1, tri.v0, tri.v1, tri.v2);
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
					_sourceVO.bitmap.draw(_s, null, _colorTransform, _blendMode, _sourceVO.bitmap.rect);
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
            return _alpha > 0;
        }
        
        public function addOnResize(listener:Function):void
        {
        	addEventListener(MaterialEvent.RESIZED, listener, false, 0, true);
        }
        
        public function removeOnResize(listener:Function):void
        {
        	removeEventListener(MaterialEvent.RESIZED, listener, false);
        }
 
    }
}