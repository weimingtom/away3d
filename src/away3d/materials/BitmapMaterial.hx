package away3d.materials;

    import away3d.containers.*;
    import away3d.arcane;
    import away3d.core.base.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;
    import away3d.events.*;
    
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.utils.*;
    
	use namespace arcane;
	
	 /**
	 * Dispatched when the bitmapData used for the material texture is resized.
	 * 
	 * @eventType away3d.events.AnimationEvent
	 */
	/*[Event(name="materialResize",type="away3d.events.MaterialEvent")]*/
	
    /**
    * Basic bitmap material
    */
    class BitmapMaterial extends EventDispatcher, implements ITriangleMaterial, implements IUVMaterial, implements ILayerMaterial {
    	public var alpha(getAlpha, setAlpha) : Float;
    	public var bitmap(getBitmap, setBitmap) : BitmapData;
    	public var blendMode(getBlendMode, setBlendMode) : String;
    	public var color(getColor, setColor) : UInt;
    	public var debug(getDebug, setDebug) : Bool;
    	public var height(getHeight, null) : Float
        ;
    	public var precision(getPrecision, setPrecision) : Float;
    	public var repeat(getRepeat, setRepeat) : Bool;
    	public var smooth(getSmooth, setSmooth) : Bool;
    	public var visible(getVisible, null) : Bool
        ;
    	public var width(getWidth, null) : Float
        ;
    	/** @private */
    	
    	/** @private */
    	arcane var _texturemapping:Matrix;
        /** @private */
    	arcane var _bitmap:BitmapData;
        /** @private */
        arcane var _faceDirty:Bool;
        /** @private */
    	arcane var _renderBitmap:BitmapData;
        /** @private */
        arcane var _bitmapDirty:Bool;
        /** @private */
    	arcane var _colorTransform:ColorTransform;
        /** @private */
    	arcane var _colorTransformDirty:Bool;
        /** @private */
        arcane var _blendMode:String;
        /** @private */
        arcane var _blendModeDirty:Bool;
        /** @private */
        arcane var _color:UInt ;
        /** @private */
		arcane var _red:Int ;
        /** @private */
		arcane var _green:Int ;
        /** @private */
		arcane var _blue:Int ;
        /** @private */
        arcane var _alpha:Int ;
        /** @private */
        arcane var _faceDictionary:Dictionary ;
        /** @private */
    	arcane var _zeroPoint:Point ;
        /** @private */
        arcane var _faceVO:FaceVO;
        /** @private */
        arcane var _mapping:Matrix;
        /** @private */
		arcane var _s:Shape ;
        /** @private */
		arcane var _graphics:Graphics;
        /** @private */
		arcane var _bitmapRect:Rectangle;
        /** @private */
		arcane var _sourceVO:FaceVO;
        /** @private */
        arcane var _session:AbstractRenderSession;
		/** @private */
        arcane function notifyMaterialUpdate():Void
        {
            if (!hasEventListener(MaterialEvent.MATERIAL_UPDATED))
                return;
			
            if (_materialupdated == null)
                _materialupdated = new MaterialEvent(MaterialEvent.MATERIAL_UPDATED, this);
                
            dispatchEvent(_materialupdated);
        }
        /** @private */
        arcane function clearShapeDictionary():Void
        {
        	for each (_shape in _shapeDictionary)
	        	_shape.graphics.clear();
        }
        /** @private */
        arcane function clearFaceDictionary():Void
        {
        	_faceDirty = false;
        	
        	notifyMaterialUpdate();
        	
        	for (_faceVO in _faceDictionary) {
        		if (!_faceVO.cleared)
        			_faceVO.clear();
        		_faceVO.invalidated = true;
        	}
        }
        /** @private */
		arcane function renderSource(source:Object3D, containerRect:Rectangle, mapping:Matrix):Void
		{
			//check to see if sourceDictionary exists
			if (!(_sourceVO = _faceDictionary[source]))
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
		
		var _view:View3D;
		var _smooth:Bool;
		var _debug:Bool;
		var _repeat:Bool;
        var _precision:Float;
        var _shapeDictionary:Dictionary ;
    	var _shape:Shape;
    	var _materialupdated:MaterialEvent;
        var focus:Float;
        var map:Matrix ;
        var triangle:DrawTriangle ; 
        var svArray:Array<Dynamic> ;
        var x:Float;
		var y:Float;
        var faz:Float;
        var fbz:Float;
        var fcz:Float;
        var mabz:Float;
        var mbcz:Float;
        var mcaz:Float;
        var mabx:Float;
        var maby:Float;
        var mbcx:Float;
        var mbcy:Float;
        var mcax:Float;
        var mcay:Float;
        var dabx:Float;
        var daby:Float;
        var dbcx:Float;
        var dbcy:Float;
        var dcax:Float;
        var dcay:Float;    
        var dsab:Float;
        var dsbc:Float;
        var dsca:Float;
        var dmax:Float;
        var ax:Float;
        var ay:Float;
        var az:Float;
        var bx:Float;
        var by:Float;
        var bz:Float;
        var cx:Float;
        var cy:Float;
        var cz:Float;
        
        function createVertexArray():Void
        {
            var index:Int = 100;
            while (index--) {
                svArray.push(new ScreenVertex());
            }
        }
        
        function renderRec(a:ScreenVertex, b:ScreenVertex, c:ScreenVertex, index:Float):Void
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
            
            if (!_view.clip.rect(Math.min(ax, Math.min(bx, cx)), Math.min(ay, Math.min(by, cy)), Math.max(ax, Math.max(bx, cx)), Math.max(ay, Math.max(by, cy))))
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

            var map_a:Int = map.a;
            var map_b:Int = map.b;
            var map_c:Int = map.c;
            var map_d:Int = map.d;
            var map_tx:Int = map.tx;
            var map_ty:Int = map.ty;
            
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
        var ini:Init;
        
    	/**
    	 * Updates the colortransform object applied to the texture from the <code>color</code> and <code>alpha</code> properties.
    	 * 
    	 * @see color
    	 * @see alpha
    	 */
    	function updateColorTransform():Void
        {
        	_colorTransformDirty = false;
			
			_bitmapDirty = true;
			_faceDirty = true;
        	
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
        }
    	
    	/**
    	 * Updates the texture bitmapData with the colortransform determined from the <code>color</code> and <code>alpha</code> properties.
    	 * 
    	 * @see color
    	 * @see alpha
    	 * @see setColorTransform()
    	 */
        function updateRenderBitmap():Void
        {
        	_bitmapDirty = false;
        	
        	if (_colorTransform) {
	        	if (!_bitmap.transparent && _alpha != 1) {
	                _renderBitmap = new BitmapData(_bitmap.width, _bitmap.height, true);
	                _renderBitmap.draw(_bitmap);
	            } else {
	        		_renderBitmap = _bitmap.clone();
	           }
	            _renderBitmap.colorTransform(_renderBitmap.rect, _colorTransform);
	        } else {
	        	_renderBitmap = _bitmap.clone();
	        }
	        
	        _faceDirty = true;
        }
        
        /**
        * Calculates the mapping matrix required to draw the triangle texture to screen.
        * 
        * @param	tri		The data object holding all information about the triangle to be drawn.
        * @return			The required matrix object.
        */
		function getMapping(tri:DrawTriangle):Matrix
		{
			if (tri.generated) {
				_texturemapping = tri.transformUV(this).clone();
				_texturemapping.invert();
				
				return _texturemapping;
			}
			
			_faceVO = getFaceVO(tri.face, tri.source, tri.view);
			if (_faceVO.texturemapping)
				return _faceVO.texturemapping;
			
			_texturemapping = tri.transformUV(this).clone();
			_texturemapping.invert();
			
			return _faceVO.texturemapping = _texturemapping;
		}
		
    	/**
    	 * Determines if texture bitmap is smoothed (bilinearly filtered) when drawn to screen.
    	 */
        public function getSmooth():Bool{
        	return _smooth;
        }
        
        public function setSmooth(val:Bool):Bool{
        	if (_smooth == val)
        		return
        	
        	_smooth = val;
        	
        	_faceDirty = true;
        	return val;
        }
        
        
        /**
        * Toggles debug mode: textured triangles are drawn with white outlines, precision correction triangles are drawn with blue outlines.
        */
        public function getDebug():Bool{
        	return _debug;
        }
        
        public function setDebug(val:Bool):Bool{
        	if (_debug == val)
        		return
        	
        	_debug = val;
        	
        	_faceDirty = true;
        	return val;
        }
        
        /**
        * Determines if texture bitmap will tile in uv-space
        */
        public function getRepeat():Bool{
        	return _repeat;
        }
        
        public function setRepeat(val:Bool):Bool{
        	if (_repeat == val)
        		return
        	
        	_repeat = val;
        	
        	_faceDirty = true;
        	return val;
        }
        
        
        /**
        * Corrects distortion caused by the affine transformation (non-perpective) of textures.
        * The number refers to the pixel correction value - ie. a value of 2 means a distorion correction to within 2 pixels of the correct perspective distortion.
        * 0 performs no precision.
        */
        public function getPrecision():Float{
        	return _precision;
        }
        
        public function setPrecision(val:Float):Float{
        	_precision = val*val*1.4;
        	
        	_faceDirty = true;
        	return val;
        }
        
		/**
		 * @inheritDoc
		 */
        public function getWidth():Float
        {
            return _bitmap.width;
        }
        
		/**
		 * @inheritDoc
		 */
        public function getHeight():Float
        {
            return _bitmap.height;
        }
        
		/**
		 * @inheritDoc
		 */
        public function getBitmap():BitmapData{
        	return _bitmap;
        }
        
        public function setBitmap(val:BitmapData):BitmapData{
        	_bitmap = val;
        	
        	_bitmapDirty = true;
        	return val;
        }
        
		/**
		 * @inheritDoc
		 */
        public function getPixel32(u:Float, v:Float):UInt
        {
        	if (repeat) {
        		x = u%1;
        		y = (1 - v%1);
        	} else {
        		x = u;
        		y = (1 - v);
        	}
        	return _bitmap.getPixel32(x*_bitmap.width, y*_bitmap.height);
        }
        
		/**
		 * Defines a colored tint for the texture bitmap.
		 */
		public function getColor():UInt{
			return _color;
		}
        public function setColor(val:UInt):UInt{
			if (_color == val)
				return;
			
			_color = val;
            _red = ((_color & 0xFF0000) >> 16)/255;
            _green = ((_color & 0x00FF00) >> 8)/255;
            _blue = (_color & 0x0000FF)/255;
            
            _colorTransformDirty = true;
			return val;
		}
        
        /**
        * Defines an alpha value for the texture bitmap.
        */
        public function getAlpha():Float{
            return _alpha;
        }
        
        public function setAlpha(value:Float):Float{
            if (value > 1)
                value = 1;

            if (value < 0)
                value = 0;

            if (_alpha == value)
                return;

            _alpha = value;

            _colorTransformDirty = true;
        	return value;
           }
        
        /**
        * Defines a blendMode value for the texture bitmap.
        * Applies to materials rendered as children of <code>BitmapMaterialContainer</code> or  <code>CompositeMaterial</code>.
        * 
        * @see away3d.materials.BitmapMaterialContainer
        * @see away3d.materials.CompositeMaterial
        */
        public function getBlendMode():String{
        	return _blendMode;
        }
    	
        public function setBlendMode(val:String):String{
        	if (_blendMode == val)
        		return;
        	
        	_blendMode = val;
        	_blendModeDirty = true;
        	return val;
        }
        
		/**
		 * Creates a new <code>BitmapMaterial</code> object.
		 * 
		 * @param	bitmap				The bitmapData object to be used as the material's texture.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function new(bitmap:BitmapData, ?init:Dynamic = null)
        {
        	
        	_color = 0xFFFFFF;
        	_red = 1;
        	_green = 1;
        	_blue = 1;
        	_alpha = 1;
        	_faceDictionary = new Dictionary(true);
        	_zeroPoint = new Point(0, 0);
        	_s = new Shape();
        	_shapeDictionary = new Dictionary(true);
        	map = new Matrix();
        	triangle = new DrawTriangle();
        	svArray = new Array();
        	_bitmap = bitmap;
            
            ini = Init.parse(init);
			
            smooth = ini.getBoolean("smooth", false);
            debug = ini.getBoolean("debug", false);
            repeat = ini.getBoolean("repeat", false);
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
        public function updateMaterial(source:Object3D, view:View3D):Void
        {
        	_graphics = null;
        	clearShapeDictionary();
        		
        	if (_colorTransformDirty)
        		updateColorTransform();
        		
        	if (_bitmapDirty)
        		updateRenderBitmap();
        	
        	if (_faceDirty || _blendModeDirty)
        		clearFaceDictionary();
        		
        	_blendModeDirty = false;
        }
        
        public function getFaceVO(face:Face, source:Object3D, ?view:View3D = null):FaceVO
        {
        	if ((_faceVO = _faceDictionary[face]))
        		return _faceVO;
        	
        	return _faceDictionary[face] = new FaceVO();
        }
        
        public function removeFaceDictionary():Void
        {
			_faceDictionary = new Dictionary(true);
        }
        
		/**
		 * @inheritDoc
		 */
        public function renderLayer(tri:DrawTriangle, layer:Sprite, level:Int):Void
        {
        	if (blendMode == BlendMode.NORMAL) {
        		_graphics = layer.graphics;
        	} else {
        		_session = tri.source.session;
	        	if (_session != tri.view.session) {
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
        public function renderTriangle(tri:DrawTriangle):Void
        {
        	_mapping = getMapping(tri);
			_session = tri.source.session;
        	_view = tri.view;
        	
        	if (!_graphics && _session != tri.view.session && _session.newLayer)
        		_graphics = _session.newLayer.graphics;
        	
			if (precision) {
            	focus = tri.view.camera.focus;
            	
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
		public function renderBitmapLayer(tri:DrawTriangle, containerRect:Rectangle, parentFaceVO:FaceVO):FaceVO
		{
			//draw the bitmap once
			renderSource(tri.source, containerRect, new Matrix());
			
			//check to see if faceDictionary exists
			if (!(_faceVO = _faceDictionary[tri]))
				_faceVO = _faceDictionary[tri] = new FaceVO();
			
			//pass on resize value
			if (parentFaceVO.resized) {
				parentFaceVO.resized = false;
				_faceVO.resized = true;
			}
			
			//pass on invtexturemapping value
			_faceVO.invtexturemapping = parentFaceVO.invtexturemapping;
			
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
				_faceVO.bitmap.copyPixels(_sourceVO.bitmap, tri.face.bitmapRect, _zeroPoint, null, null, true);
			}
			
			return _faceVO;
		}
        
		/**
		 * @inheritDoc
		 */
        public function getVisible():Bool
        {
            return _alpha > 0;
        }
        
		/**
		 * @inheritDoc
		 */
        public function addOnMaterialResize(listener:Dynamic):Void
        {
        	addEventListener(MaterialEvent.MATERIAL_RESIZED, listener, false, 0, true);
        }
        
		/**
		 * @inheritDoc
		 */
        public function removeOnMaterialResize(listener:Dynamic):Void
        {
        	removeEventListener(MaterialEvent.MATERIAL_RESIZED, listener, false);
        }
        
		/**
		 * @inheritDoc
		 */
        public function addOnMaterialUpdate(listener:Dynamic):Void
        {
        	addEventListener(MaterialEvent.MATERIAL_UPDATED, listener, false, 0, true);
        }
        
		/**
		 * @inheritDoc
		 */
        public function removeOnMaterialUpdate(listener:Dynamic):Void
        {
        	removeEventListener(MaterialEvent.MATERIAL_UPDATED, listener, false);
        }
    }
