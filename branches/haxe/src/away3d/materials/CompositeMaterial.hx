package away3d.materials;

	import away3d.containers.*;
	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.render.AbstractRenderSession;
	import away3d.core.utils.*;
	import away3d.events.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	
	use namespace arcane;
	
	/**
	 * Container for layering multiple material objects.
	 * Renders each material by drawing one triangle per meterial layer.
	 * For static bitmap materials, use <code>BitmapMaterialContainer</code>.
	 * 
	 * @see away3d.materials.BitmapMaterialContainer
	 */
	class CompositeMaterial extends EventDispatcher, implements ITriangleMaterial, implements ILayerMaterial {
        public var alpha(getAlpha, setAlpha) : Float;
        public var color(getColor, setColor) : UInt;
        public var visible(getVisible, null) : Bool
        ;
        /** @private */
		
        /** @private */
		arcane var _color:UInt;
        /** @private */
        arcane var _alpha:Float;
        /** @private */
		arcane var _colorTransform:ColorTransform ;
        /** @private */
    	arcane var _colorTransformDirty:Bool;
        /** @private */
		arcane var _spriteDictionary:Dictionary ;
        /** @private */
        arcane var _sprite:Sprite;
        /** @private */
        arcane var _source:Object3D;
        /** @private */
        arcane var _session:AbstractRenderSession;
		
		var _defaultColorTransform:ColorTransform ;
		var _red:Float;
		var _green:Float;
		var _blue:Float;
		var _material:ILayerMaterial;
        
        function clearSpriteDictionary():Void
        {
        	for each (_sprite in _spriteDictionary)
	        	_sprite.graphics.clear();
        }
        
        function onMaterialUpdate(event:MaterialEvent):Void
        {
        	dispatchEvent(event);
        }
        
		/**
		 * An array of bitmapmaterial objects to be overlayed sequentially.
		 */
		var materials:Array<Dynamic>;
		
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
        function setColorTransform():Void
        {
        	_colorTransformDirty = false;
        	
            if (_alpha == 1 && _color == 0xFFFFFF) {
                _colorTransform = null;
                return;
            } else if (!_colorTransform)
            	_colorTransform = new ColorTransform();
            
			_colorTransform.redMultiplier = _red;
			_colorTransform.greenMultiplier = _green;
			_colorTransform.blueMultiplier = _blue;
			_colorTransform.alphaMultiplier = _alpha;
        }
        
        /**
        * Defines a blendMode value for the layer container.
        */
		public var blendMode:String;
        
		/**
		 * Defines a colored tint for the layer container.
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
        * Defines an alpha value for the layer container.
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
		 * @inheritDoc
		 */
        public function getVisible():Bool
        {
            return true;
        }
        
		/**
		 * Creates a new <code>CompositeMaterial</code> object.
		 * 
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
		public function new(?init:Dynamic = null)
		{
            
            _colorTransform = new ColorTransform();
            _spriteDictionary = new Dictionary(true);
            _defaultColorTransform = new ColorTransform();
            ini = Init.parse(init);
            
			materials = ini.getArray("materials");
			blendMode = ini.getString("blendMode", BlendMode.NORMAL);
			alpha = ini.getNumber("alpha", 1, {min:0, max:1});
            color = ini.getColor("color", 0xFFFFFF);
            
            for each (_material in materials)
            	_material.addOnMaterialUpdate(onMaterialUpdate);
            
            _colorTransformDirty = true;
		}
        
        public function addMaterial(material:ILayerMaterial):Void
        {
        	material.addOnMaterialUpdate(onMaterialUpdate);
        	materials.push(material);
        }
        
        public function removeMaterial(material:ILayerMaterial):Void
        {
        	var index:Int = materials.indexOf(material);
        	
        	if (index == -1)
        		return;
        	
        	material.removeOnMaterialUpdate(onMaterialUpdate);
        	
        	materials.splice(index, 1);
        }
        
		/**
		 * @inheritDoc
		 */
        public function updateMaterial(source:Object3D, view:View3D):Void
        {
        	clearSpriteDictionary();
        	
        	if (_colorTransformDirty)
        		setColorTransform();
        	
        	for each (_material in materials)
        		_material.updateMaterial(source, view);
        }
        
		/**
		 * @inheritDoc
		 */
		public function renderTriangle(tri:DrawTriangle):Void
        {
        	_source = tri.source;
        	_session = _source.session;
    		var level:Int = 0;
        	
        	if (_session != tri.view.session) {
        		//check to see if session sprite exists
	    		if (!(_sprite = _session.spriteLayers[level]))
	    			_sprite = _session.spriteLayers[level] = new Sprite();
        	} else {
	        	//check to see if face sprite exists
	    		if (!(_sprite = _spriteDictionary[tri.face]))
	    			_sprite = _spriteDictionary[tri.face] = new Sprite();
        	}
	    	
	    	if (!_session.children[_sprite]) {
	    		if (_session != tri.view.session)
        			_session.addLayerObject(_sprite);
        		else
        			_session.addDisplayObject(_sprite);
        		
	    		_sprite.filters = [];
        		_sprite.blendMode = blendMode;
        		
        		if (_colorTransform)
	    			_sprite.transform.colorTransform = _colorTransform;
	    		else
	    			_sprite.transform.colorTransform = _defaultColorTransform;
      		}
        	
    		//call renderLayer on each material
    		for each (_material in materials)
        		_material.renderLayer(tri, _sprite, ++level);
        }
        
		/**
		 * @inheritDoc
		 */
        public function renderLayer(tri:DrawTriangle, layer:Sprite, level:Int):Void
        {
        	if (!_colorTransform && blendMode == BlendMode.NORMAL) {
        		_sprite = layer;
        	} else {
        		_source = tri.source;
        		_session = _source.session;
        		
	        	if (_session != tri.view.session) {
	        		//check to see if session sprite exists
		    		if (!(_sprite = _session.spriteLayers[level]))
		    			layer.addChild(_sprite = _session.spriteLayers[level] = new Sprite());
	        	} else {
		        	//check to see if face sprite exists
		    		if (!(_sprite = _spriteDictionary[tri.face]))
		    			layer.addChild(_sprite = _spriteDictionary[tri.face] = new Sprite());
	        	}
	        	
	        	_sprite.filters = [];
	        	_sprite.blendMode = blendMode;
	        	
	    		if (_colorTransform)
	    			_sprite.transform.colorTransform = _colorTransform;
	    		else
	    			_sprite.transform.colorTransform = _defaultColorTransform;
        	}
    		
	    	//call renderLayer on each material
    		for each (_material in materials)
        		_material.renderLayer(tri, _sprite, level++);
        }
        
		/**
		 * @private
		 */
        public function renderBitmapLayer(tri:DrawTriangle, containerRect:Rectangle, parentFaceVO:FaceVO):FaceVO
		{
			throw new Error("Not implemented");
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
