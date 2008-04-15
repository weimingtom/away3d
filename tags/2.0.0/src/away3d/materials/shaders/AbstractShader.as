package away3d.materials.shaders
{
	import away3d.containers.*;
	import away3d.core.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.light.*;
	import away3d.core.math.*;
	import away3d.core.render.*;
	import away3d.core.utils.*;
	import away3d.materials.*;
	
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.*;	

    public class AbstractShader implements IUpdatingMaterial, ILayerMaterial
    {
		use namespace arcane;
		
        public var smooth:Boolean;
        public var debug:Boolean;
        public var blendMode:String;
        
        internal var _faceDictionary:Dictionary = new Dictionary(true);
        
        internal var _spriteDictionary:Dictionary = new Dictionary(true);
        internal var _sprite:Sprite;
        
        internal var _shapeDictionary:Dictionary = new Dictionary(true);
        internal var _shape:Shape;
        
        internal var _dict:Dictionary;
        
		internal var eTri0x:Number;
		internal var eTri0y:Number;
		internal var eTri1x:Number;
		internal var eTri1y:Number;
		internal var eTri2x:Number;
		internal var eTri2y:Number;
        
        public function AbstractShader(init:Object = null)
        {
            init = Init.parse(init);
            smooth = init.getBoolean("smooth", false);
            debug = init.getBoolean("debug", false);
            blendMode = init.getString("blendMode", BlendMode.NORMAL);
            
        }
		
		internal var ambient:AmbientLightSource;
		internal var directional:DirectionalLightSource;
		
		public function updateMaterial(source:Object3D, view:View3D):void
        {
        	throw new Error("Not implemented");
        }
        
		internal var _faceVO:FaceVO;
        
        public function clearShapeDictionary():void
        {
        	for each (_shape in _shapeDictionary)
        		_shape.graphics.clear();
        }
        
        public function clearLightingShapeDictionary():void
        {
        	for each (_dict in _shapeDictionary)
        		for each (_shape in _dict)
	        		_shape.graphics.clear();
        }
                
        public function clearFaceDictionary(source:Object3D, view:View3D):void
        {
        	throw new Error("Not implemented");
        }
        
		internal var _normal0:Number3D = new Number3D();
		internal var _normal1:Number3D = new Number3D();
		internal var _normal2:Number3D = new Number3D();
		
		internal var _mapping:Matrix = new Matrix();
		
        public function renderLayer(tri:DrawTriangle, layer:Sprite):void
        {
        	_source = tri.source as Mesh;
			_view = _source.session.view;
			_face = tri.face;
			_lights = tri.source.session.lightarray
        }
        
        public function getShape(layer:Sprite):Shape
        {
        	if (_source.ownCanvas) {
        		//check to see if source shape exists
	    		if (!(_shape = _shapeDictionary[_source]))
	    			layer.addChild(_shape = _shapeDictionary[_source] = new Shape());
        	} else {
	        	//check to see if face shape exists
	    		if (!(_shape = _shapeDictionary[_face]))
	    			layer.addChild(_shape = _shapeDictionary[_face] = new Shape());
        	}
        	return _shape;
        }
        
        public function getLightingShape(layer:Sprite, light:AbstractLightSource):Shape
        {
        	if (_source.ownCanvas) {
    			if (!_shapeDictionary[_source])
    				_shapeDictionary[_source] = new Dictionary(true);
        		//check to see if source shape exists
	    		if (!(_shape = _shapeDictionary[_source][light]))
	    			layer.addChild(_shape = _shapeDictionary[_source][light] = new Shape());
        	} else {
        		if (!_shapeDictionary[_face])
    				_shapeDictionary[_face] = new Dictionary(true);
	        	//check to see if face shape exists
	    		if (!(_shape = _shapeDictionary[_face][light]))
	    			layer.addChild(_shape = _shapeDictionary[_face][light] = new Shape());
        	}
        	return _shape;
        }
        
        internal var _s:Shape = new Shape();
		internal var _graphics:Graphics;
		internal var _bitmapRect:Rectangle;
		internal var _source:Mesh;
		internal var _view:View3D;
		internal var _face:Face;
		internal var _lights:LightArray;
		internal var _parentFaceVO:FaceVO;
		
		internal var _n0:Number3D;
		internal var _n1:Number3D;
		internal var _n2:Number3D;
		
        public function renderFace(face:Face, containerRect:Rectangle, parentFaceVO:FaceVO):FaceVO
        {
        	_source = face.parent;
			_view = _source.session.view;
			_parentFaceVO = parentFaceVO;
			
        	//check to see if faceDictionary exists
			_faceVO = _faceDictionary[face];
			if (!_faceVO)
				_faceVO = _faceDictionary[face] = new FaceVO(_source, _view);
			
			//pass on resize value
			if (parentFaceVO.resized) {
				parentFaceVO.resized = false;
				_faceVO.resized = true;
			}
			
			//check to see if rendering can be skipped
			if (parentFaceVO.updated || _faceVO.invalidated) {
				parentFaceVO.updated = false;
				
				//retrieve the bitmapRect
				_bitmapRect = face.bitmapRect;
				
				//reset booleans
				if (_faceVO.invalidated)
					_faceVO.invalidated = false;
				else 
					_faceVO.updated = true;
				
				//store a clone
				_faceVO.bitmap = parentFaceVO.bitmap;
				
				//draw shader
				renderShader(face);
			}
			
			return _faceVO;
        }
        
        public function renderShader(face:Face):void
        {
        	throw new Error("Not implemented");
        }
        
		public final function contains(v0x:Number, v0y:Number, v1x:Number, v1y:Number, v2x:Number, v2y:Number, x:Number, y:Number):Boolean
        {   
            if (v0x*(y - v1y) + v1x*(v0y - y) + x*(v1y - v0y) < -0.001)
                return false;

            if (v0x*(v2y - y) + x*(v0y - v2y) + v2x*(y - v0y) < -0.001)
                return false;

            if (x*(v2y - v1y) + v1x*(y - v2y) + v2x*(v1y - y) < -0.001)
                return false;

            return true;
        }
        
        public function get visible():Boolean
        {
            return true;
        }
    }
}
