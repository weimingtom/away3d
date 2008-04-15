package away3d.materials
{
	import away3d.containers.*;
	import away3d.core.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.utils.*;
	
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.*;
	
	public class BitmapMaterialContainer extends BitmapMaterial implements ITriangleMaterial, IUpdatingMaterial, ILayerMaterial
	{
		use namespace arcane;
		
		public var materials:Array;
		public var transparent:Boolean;
		public var colorTransform:ColorTransform;
		
		internal var _cache:Boolean;
		internal var _width:Number;
		internal var _height:Number;
		internal var _containerDictionary:Dictionary = new Dictionary(true);
		internal var _cacheDictionary:Dictionary;
		internal var _containerVO:FaceVO;
		
		public function set cache(val:Boolean):void
		{
			_cache = val;
			if (val)
				_cacheDictionary = new Dictionary(true);
			else
				_cacheDictionary = null; 
		}
		
		public function get cache():Boolean
		{
			return _cache;
		}
		
		public function update():void
		{
			if (_cache)
				_cacheDictionary = new Dictionary(true);
		}
		
		public function BitmapMaterialContainer(width:int, height:int, init:Object = null)
		{
			super(new BitmapData(width, height, true, 0x00FFFFFF), init);
			
			_width = width;
			_height = height;
			_bitmapRect = new Rectangle(0, 0, _width, _height);
			
            init = Init.parse(init);
			
			if (!materials)
				materials = init.getArray("materials");
			
			transparent = init.getBoolean("transparent", true);
			cache = init.getBoolean("cache", true);
		}
		
		internal var _faceWidth:int;
		internal var _faceHeight:int;
		internal var _forceRender:Boolean;
		internal var face:Face;
		internal var dt:DrawTriangle;
		internal var material:ILayerMaterial;
		
        public override function updateMaterial(source:Object3D, view:View3D):void
        {
        	for each (material in materials)
        		if (material is IUpdatingMaterial)
        			(material as IUpdatingMaterial).updateMaterial(source, view);
        }
        
		public override function getMapping(tri:DrawTriangle):Matrix
        {
        	face = tri.face;
			dt = face._dt;
			
        	if (!_cacheDictionary || !_cacheDictionary[face]) {
        		
	    		//check to see if faceDictionary exists
	    		_faceVO = _faceDictionary[face];
	    		if (!_faceVO)
	    			_faceVO = _faceDictionary[face] = new FaceVO();
	    		
	        	//check to see if face drawtriangle needs updating
	        	if (!dt.texturemapping) {
	        		
	        		//update face bitmapRect
	        		face.bitmapRect = new Rectangle(int(_width*face.minU), int(_height*(1 - face.maxV)), int(_width*(face.maxU-face.minU)+2), int(_height*(face.maxV-face.minV)+2));
	        		_faceWidth = face.bitmapRect.width;
	        		_faceHeight = face.bitmapRect.height;
	        		
	        		//update texturemapping
	        		dt.transformUV(this);
	        		
	        		//resize bitmapData for container
	        		_faceVO.resize(_faceWidth, _faceHeight, transparent);
	        	}
        		
	    		//call renderFace on each material
	    		for each (material in materials)
	        		_faceVO = material.renderFace(face, _bitmapRect, _faceVO);
	        		
	        	_faceVO.updated = false;
	        	
	        	if (_cacheDictionary)
	        		_cacheDictionary[face] = _faceVO;
	        }
        	
        	//check to see if tri texturemapping need updating
        	if (!tri.texturemapping)
        	    tri.transformUV(this);
        	
        	if (_cacheDictionary)
        		_renderBitmap = _cacheDictionary[face].bitmap;
        	else
        		_renderBitmap = _faceVO.bitmap;
        	
        	return tri.texturemapping;
        }
                
        public override function renderLayer(tri:DrawTriangle, layer:Sprite):void
        {
        	throw new Error("Not implemented");
        }
        
        public override function renderFace(face:Face, containerRect:Rectangle, parentFaceVO:FaceVO):FaceVO
		{
			//check to see if faceDictionary exists
			_faceVO = _faceDictionary[face];
			if (!_faceVO)
				_faceVO = _faceDictionary[face] = new FaceVO();
			
			//get width and height values
			_faceWidth = face.bitmapRect.width;
    		_faceHeight = face.bitmapRect.height;

			//check to see if bitmapContainer exists
			_containerVO = _containerDictionary[face];
			if (!_containerVO)
				_containerVO = _containerDictionary[face] = new FaceVO();
			
			//resize container
			if (parentFaceVO.resized) {
				parentFaceVO.resized = false;
				_containerVO.resize(_faceWidth, _faceHeight, transparent);
			}
			
			//call renderFace on each material
    		for each (material in materials)
        		_containerVO = material.renderFace(face, containerRect, _containerVO);
			
			//check to see if face update can be skipped
			if (parentFaceVO.updated || _containerVO.updated) {
				parentFaceVO.updated = false;
				_containerVO.updated = false;
				
				//reset booleans
				_faceVO.invalidated = false;
				_faceVO.cleared = false;
				_faceVO.updated = true;
        		
				//store a clone
				_faceVO.bitmap = parentFaceVO.bitmap.clone();
				_faceVO.bitmap.lock();
				
				_sourceVO = _faceVO;
	        	
	        	//draw into faceBitmap
	        	if (_blendMode == BlendMode.NORMAL)
	        		_faceVO.bitmap.copyPixels(_containerVO.bitmap, _containerVO.bitmap.rect, _zeroPoint, null, null, true);
	        	else
					_faceVO.bitmap.draw(_containerVO.bitmap, null, colorTransform, _blendMode);
	  		}
	  		
	  		_containerVO.updated = false;
	  		
	  		return _faceVO;        	
		}
	}
}