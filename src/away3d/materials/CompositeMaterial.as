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
		public var colorTransform:ColorTransform;
		
		internal var _spriteDictionary:Dictionary = new Dictionary(true);
        internal var _sprite:Sprite;
        internal var _source:Object3D;
        internal var _session:AbstractRenderSession;
        
		public function CompositeMaterial(init:Object = null)
		{	
            init = Init.parse(init);
			
			if (!materials)
				materials = init.getArray("materials");
			blendMode = init.getString("blendMode", BlendMode.NORMAL);
		}
		
		internal var material:ILayerMaterial;
		
        public function updateMaterial(source:Object3D, view:View3D):void
        {
        	clearSpriteDictionary();
        	
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
        	
        	if (_session != _session.view.session) {
        		//check to see if source sprite exists
	    		if (!(_sprite = _spriteDictionary[_session]))
	    			_sprite = _spriteDictionary[_session] = new Sprite();
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
        		
        		if (blendMode)
        			_sprite.blendMode = blendMode;
        		if (colorTransform)
	    			_sprite.transform.colorTransform = colorTransform;
      		}
        	
    		//call renderLayer on each material
    		for each (material in materials)
        		material.renderLayer(tri, _sprite);
        }
        
        
        public function renderLayer(tri:DrawTriangle, layer:Sprite):void
        {
        	if (!colorTransform && (!blendMode || blendMode == BlendMode.NORMAL)) {
        		_sprite = layer;
        	} else {
        		_source = tri.source;
        		_session = _source.session;
        		
	        	if (_session != _session.view.session) {
	        		//check to see if source sprite exists
		    		if (!(_sprite = _spriteDictionary[_session]))
		    			layer.addChild(_sprite = _spriteDictionary[_session] = new Sprite());
	        	} else {
		        	//check to see if face sprite exists
		    		if (!(_sprite = _spriteDictionary[tri.face]))
		    			layer.addChild(_sprite = _spriteDictionary[tri.face] = new Sprite());
	        	}
	        	if (blendMode)
	    			_sprite.blendMode = blendMode;
	    		if (colorTransform)
	    			_sprite.transform.colorTransform = colorTransform;
        	}
    		
	    	//call renderLayer on each material
    		for each (material in materials)
        		material.renderLayer(tri, _sprite);
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