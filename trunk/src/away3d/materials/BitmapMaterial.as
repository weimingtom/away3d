package away3d.materials
{
    import away3d.containers.*;
    import away3d.core.*;
    import away3d.core.base.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;
    import away3d.events.MaterialEvent;
    
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.utils.Dictionary;
    
	 /**
	 * Dispatched when the bitmapData used for the material texture is resized.
	 * 
	 * @eventType away3d.events.AnimationEvent
	 */
	[Event(name="materialresize",type="away3d.events.MaterialEvent")]
	
    /**
    * Basic bitmap material
    */
    public class BitmapMaterial extends EventDispatcher implements ITriangleMaterial, IUVMaterial, ILayerMaterial, IUpdatingMaterial
    {
    	use namespace arcane;
        /** @private */
    	arcane var _bitmap:BitmapData;
        /** @private */
    	arcane var _renderBitmap:BitmapData;
        /** @private */
    	arcane var _colorTransform:ColorTransform;
        /** @private */
    	arcane var _colorTransformDirty:Boolean;
        /** @private */
        arcane var _blendMode:String;
        /** @private */
        arcane var _blendModeDirty:Boolean;
        /** @private */
        arcane var _color:uint = 0xFFFFFF;
        /** @private */
		arcane var _red:Number = 1;
        /** @private */
		arcane var _green:Number = 1;
        /** @private */
		arcane var _blue:Number = 1;
        /** @private */
        arcane var _alpha:Number = 1;
        /** @private */
        arcane var _faceDictionary:Dictionary = new Dictionary(true);
        /** @private */
    	arcane var _zeroPoint:Point = new Point(0, 0);
        /** @private */
        arcane var _faceVO:FaceVO;
        /** @private */
        arcane var _mapping:Matrix;
        /** @private */
		arcane var _s:Shape = new Shape();
        /** @private */
		arcane var _graphics:Graphics;
        /** @private */
		arcane var _bitmapRect:Rectangle;
        /** @private */
		arcane var _sourceVO:FaceVO;
        /** @private */
        arcane var _session:AbstractRenderSession;
        /** @private */
        arcane function clearShapeDictionary():void
        {
        	for each (_shape in _shapeDictionary)
	        	_shape.graphics.clear();
        }
        /** @private */
        arcane function clearFaceDictionary():void
        {
        	for each (_faceVO in _faceDictionary) {
        		if (!_faceVO.cleared)
        			_faceVO.clear();
        		_faceVO.invalidated = true;
        	}
        }
        /** @private */
		arcane function renderSource(source:Object3D, containerRect:Rectangle, mapping:Matrix):void
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
		
        private var _precision:Number;
        private var _shapeDictionary:Dictionary = new Dictionary(true);
    	private var _shape:Shape;
        private var focus:Number;
        private var map:Matrix = new Matrix();
        private var triangle:DrawTriangle = new DrawTriangle(); 
        private var svArray:Array = new Array();
        private var faz:Number;
        private var fbz:Number;
        private var fcz:Number;
        private var mabz:Number;
        private var mbcz:Number;
        private var mcaz:Number;
        private var mabx:Number;
        private var maby:Number;
        private var mbcx:Number;
        private var mbcy:Number;
        private var mcax:Number;
        private var mcay:Number;
        private var dabx:Number;
        private var daby:Number;
        private var dbcx:Number;
        private var dbcy:Number;
        private var dcax:Number;
        private var dcay:Number;    
        private var dsab:Number;
        private var dsbc:Number;
        private var dsca:Number;
        private var dmax:Number;
        private var ax:Number;
        private var ay:Number;
        private var az:Number;
        private var bx:Number;
        private var by:Number;
        private var bz:Number;
        private var cx:Number;
        private var cy:Number;
        private var cz:Number;
        
        private function createVertexArray():void
        {
            var index:Number = 100;
            while (index--) {
                svArray.push(new ScreenVertex());
            }
        }
        
        private function renderRec(a:ScreenVertex, b:ScreenVertex, c:ScreenVertex, index:Number):void
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
            
            if (!_session.view.clip.rect(Math.min(ax, Math.min(bx, cx)), Math.min(ay, Math.min(by, cy)), Math.max(ax, Math.max(bx, cx)), Math.max(ay, Math.max(by, cy))))
                return;

            if ((az <= 0) && (bz <= 0) && (cz <= 0))
                return;
            
            if (index >= 100 || (focus == Infinity) || (Math.max(Math.max(ax, bx), cx) - Math.min(Math.min(ax, bx), cx) < 10) || (Math.max(Math.max(ay, by), cy) - Math.min(Math.min(ay, by), cy) < 10))
            {
                _session.renderTriangleBitmap(_renderBitmap, map, a, b, c, smooth, repeat, _graphics);
                if (debug)
                    _session.renderTriangleLine(1, 0x00FF00, 1, a, b, c);
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
                _session.renderTriangleBitmap(_renderBitmap, map, a, b, c, smooth, repeat, _graphics);
                if (debug)
                    _session.renderTriangleLine(1, 0x00FF00, 1, a, b, c);
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
        
        /**
        * Instance of the Init object used to hold and parse default property values
        * specified by the initialiser object in the 3d object constructor.
        */
        protected var ini:Init;
        
    	/**
    	 * Updates the colortransform object applied to the texture from the <code>color</code> and <code>alpha</code> properties.
    	 * 
    	 * @see color
    	 * @see alpha
    	 */
    	protected function setColorTransform():void
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
    	
    	/**
    	 * Updates the texture bitmapData with the colortransform determined from the <code>color</code> and <code>alpha</code> properties.
    	 * 
    	 * @see color
    	 * @see alpha
    	 * @see setColorTransform()
    	 */
        protected function updateRenderBitmap():void
        {
        	if (_colorTransform) {
	        	if (!_bitmap.transparent && _alpha != 1) {
	                _renderBitmap = new BitmapData(_bitmap.width, _bitmap.height, true);
	                _renderBitmap.draw(_bitmap);
	            } else {
	        		_renderBitmap = _bitmap.clone();
	           }
	            _renderBitmap.colorTransform(_renderBitmap.rect, _colorTransform);
	        } else {
	        	_renderBitmap = _bitmap;
	        }
        }
        
        /**
        * Calculates the mapping matrix required to draw the triangle texture to screen.
        * 
        * @param	tri		The data object holding all information about the triangle to be drawn.
        * @return			The required matrix object.
        */
		protected function getMapping(tri:DrawTriangle):Matrix
		{
			return tri.texturemapping || tri.transformUV(this);
		}
		
    	/**
    	 * Determines if texture bitmap is smoothed (bilinearly filtered) when drawn to screen.
    	 */
        public var smooth:Boolean = false;
        
        /**
        * Toggles debug mode: textured triangles are drawn with white outlines, precision correction triangles are drawn with blue outlines.
        */
        public var debug:Boolean = false;
        
        /**
        * Determines if texture bitmap will tile in uv-space
        */
        public var repeat:Boolean = false;
        
        /**
        * Corrects distortion caused by the affine transformation (non-perpective) of textures.
        * The number refers to the pixel correction value - ie. a value of 2 means a distorion correction to within 2 pixels of the correct perspective distortion.
        * 0 performs no precision.
        */
        public function get precision():Number
        {
        	return _precision;
        }
        
        public function set precision(val:Number):void
        {
        	_precision = val*val*1.4;
        }
        
		/**
		 * @inheritDoc
		 */
        public function get width():Number
        {
            return _bitmap.width;
        }
        
		/**
		 * @inheritDoc
		 */
        public function get height():Number
        {
            return _bitmap.height;
        }
        
		/**
		 * @inheritDoc
		 */
        public function get bitmap():BitmapData
        {
        	return _bitmap;
        }
        
		/**
		 * @inheritDoc
		 */
        public function getPixel32(u:Number, v:Number):uint
        {
        	return _bitmap.getPixel32(u*_bitmap.width, (1 - v)*_bitmap.height);
        }
        
		/**
		 * Defines a colored tint for the texture bitmap.
		 */
		public function get color():uint
		{
			return _color;
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
        
        /**
        * Defines an alpha value for the texture bitmap.
        */
        public function get alpha():Number
        {
            return _alpha;
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
        
        /**
        * Defines a blendMode value for the texture bitmap.
        * Applies to materials rendered as children of <code>BitmapMaterialContainer</code> or  <code>CompositeMaterial</code>.
        * 
        * @see away3d.materials.BitmapMaterialContainer
        * @see away3d.materials.CompositeMaterial
        */
        public function get blendMode():String
        {
        	return _blendMode;
        }
    	
        public function set blendMode(val:String):void
        {
        	if (_blendMode == val)
        		return;
        	
        	_blendMode = val;
        	_blendModeDirty = true;
        }
        
		/**
		 * Creates a new <code>BitmapMaterial</code> object.
		 * 
		 * @param	bitmap				The bitmapData object to be used as the material's texture.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function BitmapMaterial(bitmap:BitmapData, init:Object = null)
        {
        	_bitmap = bitmap;
            
            ini = Init.parse(init);
			
            smooth = ini.getBoolean("smooth", smooth);
            debug = ini.getBoolean("debug", debug);
            repeat = ini.getBoolean("repeat", repeat);
            precision = ini.getNumber("precision", 0);
            _blendMode = ini.getString("blendMode", BlendMode.NORMAL);
            alpha = ini.getNumber("alpha", _alpha, {min:0, max:1});
            color = ini.getColor("color", _color);
            
            _colorTransformDirty = true;
            
            createVertexArray();
        }
        
		/**
		 * @inheritDoc
		 */
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
        
		/**
		 * @inheritDoc
		 */
        public function renderLayer(tri:DrawTriangle, layer:Sprite, level:int):void
        {
        	if (blendMode == BlendMode.NORMAL) {
        		_graphics = layer.graphics;
        	} else {
        		_session = tri.source.session;
	        	if (_session != _session.view.session) {
	        		//check to see if source shape exists
		    		if (!(_shape = _shapeDictionary[_session]))
		    			layer.addChild(_shape = _shapeDictionary[_session] = new Shape());
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
        
		/**
		 * @inheritDoc
		 */
        public function renderTriangle(tri:DrawTriangle):void
        {
        	_mapping = getMapping(tri);
			_session = tri.source.session;
        	
        	if (!_graphics && _session != _session.view.session && _session.newLayer)
        		_graphics = _session.newLayer.graphics;
        	
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
				_session.renderTriangleBitmap(_renderBitmap, _mapping, tri.v0, tri.v1, tri.v2, smooth, repeat, _graphics);
			}
			
            if (debug)
                _session.renderTriangleLine(0, 0x0000FF, 1, tri.v0, tri.v1, tri.v2);
        }
        
		/**
		 * @inheritDoc
		 */
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
        
		/**
		 * @inheritDoc
		 */
        public function get visible():Boolean
        {
            return _alpha > 0;
        }
        
		/**
		 * @inheritDoc
		 */
        public function addOnResize(listener:Function):void
        {
        	addEventListener(MaterialEvent.RESIZED, listener, false, 0, true);
        }
        
		/**
		 * @inheritDoc
		 */
        public function removeOnResize(listener:Function):void
        {
        	removeEventListener(MaterialEvent.RESIZED, listener, false);
        }
 
    }
}