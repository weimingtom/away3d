package away3d.materials
{
	import away3d.containers.*;
	import away3d.core.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.render.AbstractRenderSession;
	import away3d.core.utils.*;
	
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.*;
	
	public class CompositeMaterial implements ITriangleMaterial, IUpdatingMaterial, ILayerMaterial
	{
		use namespace arcane;
		
		public var materials:Array;
		public var blendMode:String;
		
		internal var _colorTransform:ColorTransform = new ColorTransform();
		internal var _defaultColorTransform:ColorTransform = new ColorTransform();
    	internal var _colorTransformDirty:Boolean;
		internal var _color:uint;
		internal var _red:Number;
		internal var _green:Number;
		internal var _blue:Number;
        internal var _alpha:Number;
        
		internal var _spriteDictionary:Dictionary = new Dictionary(true);
        internal var _sprite:Sprite;
        internal var _source:Object3D;
        internal var _session:AbstractRenderSession;
        
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
                _colorTransform = null;
                return;
            } else if (!_colorTransform)
            	_colorTransform = new ColorTransform();
			
			_colorTransform.redMultiplier = _red;
			_colorTransform.greenMultiplier = _green;
			_colorTransform.blueMultiplier = _blue;
			_colorTransform.alphaMultiplier = _alpha;
        }
        
		public function CompositeMaterial(init:Object = null)
		{	
            init = Init.parse(init);
			
			if (!materials)
				materials = init.getArray("materials");
			blendMode = init.getString("blendMode", BlendMode.NORMAL);
			alpha = init.getNumber("alpha", 1, {min:0, max:1});
            color = init.getNumber("color", 0xFFFFFF, {min:0, max:0xFFFFFF});
		}
		
		internal var material:ILayerMaterial;
		
        public function updateMaterial(source:Object3D, view:View3D):void
        {
        	clearSpriteDictionary();
        	
        	if (_colorTransformDirty)
        		setColorTransform();
        	
        	for each (material in materials)
        		if (material is IUpdatingMaterial)
        			(material as IUpdatingMaterial).updateMaterial(source, view);
        }
        
        public function clearSpriteDictionary():void
        {
        	for each (_sprite in _spriteDictionary)
	        	_sprite.graphics.clear();
        }
        
		public function renderTriangle(tri:DrawTriangle):void
        {
        	_source = tri.source;
        	_session = _source.session;
    		var level:int = 0;
        	
        	if (_session != _session.view.session) {
        		//check to see if session sprite exists
	    		if (!(_sprite = _session.spriteLayers[level]))
	    			_sprite = _session.spriteLayers[level] = new Sprite();
        	} else {
	        	//check to see if face sprite exists
	    		if (!(_sprite = _spriteDictionary[tri.face]))
	    			_sprite = _spriteDictionary[tri.face] = new Sprite();
        	}
	    	
	    	if (!_session.children[_sprite]) {
	    		if (_session != _session.view.session)
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
    		for each (material in materials)
        		material.renderLayer(tri, _sprite, ++level);
        }
        
        
        public function renderLayer(tri:DrawTriangle, layer:Sprite, level:int):void
        {
        	if (!_colorTransform && blendMode == BlendMode.NORMAL) {
        		_sprite = layer;
        	} else {
        		_source = tri.source;
        		_session = _source.session;
        		
	        	if (_session != _session.view.session) {
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
    		for each (material in materials)
        		material.renderLayer(tri, _sprite, level++);
        }
        
        public function renderFace(face:Face, containerRect:Rectangle, parentFaceVO:FaceVO):FaceVO
		{
			throw new Error("Not implemented");
		}
		
        public function get visible():Boolean
        {
            return true;
        }
	}
}