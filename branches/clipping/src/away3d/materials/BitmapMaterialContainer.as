package away3d.materials
{
	import away3d.containers.*;
	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.utils.*;
	import away3d.events.*;
	
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.*;
	
	use namespace arcane;
	
	/**
	 * Container for caching multiple bitmapmaterial objects.
	 * Renders each material by caching a bitmapData surface object for each face.
	 * For continually updating materials, use <code>CompositeMaterial</code>.
	 * 
	 * @see away3d.materials.CompositeMaterial
	 */
	public class BitmapMaterialContainer extends BitmapMaterial implements ITriangleMaterial, ILayerMaterial
	{
		private var _width:Number;
		private var _height:Number;
		private var _containerDictionary:Dictionary = new Dictionary(true);
		private var _cacheDictionary:Dictionary = new Dictionary(true);
		private var _containerVO:FaceMaterialVO;
		private var _faceWidth:int;
		private var _faceHeight:int;
		private var _forceRender:Boolean;
		private var _face:Face;
		private var _material:ILayerMaterial;
        private var _viewDictionary:Dictionary = new Dictionary(true);
        
        private function onMaterialUpdate(event:MaterialEvent):void
        {
        	_faceDirty = true;
        	dispatchEvent(event);
        }
        
		/**
		 * An array of bitmapmaterial objects to be overlayed sequentially.
		 */
		protected var materials:Array;
        
		/**
		 * @inheritDoc
		 */
		protected override function updateRenderBitmap():void
        {
        	_bitmapDirty = false;
        	_faceDirty = true;
        }
        
		/**
		 * @inheritDoc
		 */
		protected override function getMapping(tri:DrawTriangle):Matrix
        {
        	_face = tri.face;
    		_faceMaterialVO = getFaceMaterialVO(tri.face, tri.source, tri.view);
    		
    		if (tri.generated || _faceMaterialVO.invalidated || !_faceMaterialVO.texturemapping || _faceMaterialVO.backface != tri.backface) {
        		_faceMaterialVO.invalidated = false;
	    		
	        	//check to see if face drawtriangle needs updating
	        	if (!_faceMaterialVO.texturemapping || _faceMaterialVO.backface != tri.backface) {
		    		_faceMaterialVO.backface = tri.backface;
	        		
	        		//update face bitmapRect
	        		_face.bitmapRect = new Rectangle(int(_width*_face.minU), int(_height*(1 - _face.maxV)), int(_width*(_face.maxU-_face.minU)+2), int(_height*(_face.maxV-_face.minV)+2));
	        		_faceWidth = _face.bitmapRect.width;
	        		_faceHeight = _face.bitmapRect.height;
	        		
	        		//update texturemapping
	        		_faceMaterialVO.invtexturemapping = tri.transformUV(this).clone();
	        		_faceMaterialVO.texturemapping = _faceMaterialVO.invtexturemapping.clone();
	        		_faceMaterialVO.texturemapping.invert();
	        		
	        		//resize bitmapData for container
	        		_faceMaterialVO.resize(_faceWidth, _faceHeight, transparent);
	        	}
        		
	    		//call renderFace on each material
	    		for each (_material in materials)
	        		_faceMaterialVO = _material.renderBitmapLayer(tri, _bitmapRect, _faceMaterialVO);
	        	
	        	_cacheDictionary[_face] = _faceMaterialVO;
        		
        		_renderBitmap = _faceMaterialVO.bitmap;
	        	
	        	_faceMaterialVO.updated = false;
	        } else {
	        	_renderBitmap = _cacheDictionary[_face].bitmap;
	        }
        	
        	//check to see if tri texturemapping need updating
        	if (!_faceMaterialVO.texturemapping || _faceMaterialVO.backface != tri.backface) {
        		_faceMaterialVO.backface = tri.backface;
        		//update texturemapping
        		_faceMaterialVO.invtexturemapping = tri.transformUV(this).clone();
        		_faceMaterialVO.texturemapping = _faceMaterialVO.invtexturemapping.clone();
        		_faceMaterialVO.texturemapping.invert();
        	}
        	
        	return _faceMaterialVO.texturemapping;
        }
		
		/**
		 * Defines whether the caching bitmapData objects are transparent
		 */
		public var transparent:Boolean;
    	
		/**
		 * Creates a new <code>BitmapMaterialContainer</code> object.
		 * 
		 * @param	width				The containing width of the texture, applied to all child materials.
		 * @param	height				The containing height of the texture, applied to all child materials.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
		public function BitmapMaterialContainer(width:int, height:int, init:Object = null)
		{
			super(new BitmapData(width, height, true, 0x00FFFFFF), init);
			
			materials = ini.getArray("materials");
			_width = width;
			_height = height;
			_bitmapRect = new Rectangle(0, 0, _width, _height);
            
            for each (_material in materials)
            	_material.addOnMaterialUpdate(onMaterialUpdate);
			
			transparent = ini.getBoolean("transparent", true);
		}
		        
        public function addMaterial(material:ILayerMaterial):void
        {
        	material.addOnMaterialUpdate(onMaterialUpdate);
        	materials.push(material);
        	
        	_faceDirty = true;
        }
        
        public function removeMaterial(material:ILayerMaterial):void
        {
        	var index:int = materials.indexOf(material);
        	
        	if (index == -1)
        		return;
        	
        	material.removeOnMaterialUpdate(onMaterialUpdate);
        	
        	materials.splice(index, 1);
        	
        	_faceDirty = true;
        }
        
        public function clearMaterials():void
        {
        	var i:int = materials.length;
        	
        	while (i--)
        		removeMaterial(materials[i]);
        }
		
		/**
		 * Creates a new <code>BitmapMaterialContainer</code> object.
		 * 
		 * @param	width				The containing width of the texture, applied to all child materials.
		 * @param	height				The containing height of the texture, applied to all child materials.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public override function updateMaterial(source:Object3D, view:View3D):void
        {
        	if (_colorTransformDirty)
        		updateColorTransform();
        	
        	if (_bitmapDirty)
        		updateRenderBitmap();
        	
        	if (_faceDirty || _blendModeDirty)
        		clearFaceDictionary();
        	
        	for each (_material in materials)
        		_material.updateMaterial(source, view);
        	
        	_blendModeDirty = false;
        }
        
		/**
		 * @private
		 */
        public override function renderLayer(tri:DrawTriangle, layer:Sprite, level:int):void
        {
        	throw new Error("Not implemented");
        }
        
		/**
		 * @inheritDoc
		 */
        public override function renderBitmapLayer(tri:DrawTriangle, containerRect:Rectangle, parentFaceMaterialVO:FaceMaterialVO):FaceMaterialVO
		{
			_faceMaterialVO = getFaceMaterialVO(tri.face);
			
			//get width and height values
			_faceWidth = tri.face.bitmapRect.width;
    		_faceHeight = tri.face.bitmapRect.height;

			//check to see if bitmapContainer exists
			if (!(_containerVO = _containerDictionary[tri]))
				_containerVO = _containerDictionary[tri] = new FaceMaterialVO();
			
			//resize container
			if (parentFaceMaterialVO.resized) {
				parentFaceMaterialVO.resized = false;
				_containerVO.resize(_faceWidth, _faceHeight, transparent);
			}
			
			//call renderFace on each material
    		for each (_material in materials)
        		_containerVO = _material.renderBitmapLayer(tri, containerRect, _containerVO);
			
			//check to see if face update can be skipped
			if (parentFaceMaterialVO.updated || _containerVO.updated) {
				parentFaceMaterialVO.updated = false;
				_containerVO.updated = false;
				
				//reset booleans
				_faceMaterialVO.invalidated = false;
				_faceMaterialVO.cleared = false;
				_faceMaterialVO.updated = true;
        		
				//store a clone
				_faceMaterialVO.bitmap = parentFaceMaterialVO.bitmap.clone();
				_faceMaterialVO.bitmap.lock();
				
				_sourceVO = _faceMaterialVO;
	        	
	        	//draw into faceBitmap
	        	if (_blendMode == BlendMode.NORMAL && !_colorTransform)
	        		_faceMaterialVO.bitmap.copyPixels(_containerVO.bitmap, _containerVO.bitmap.rect, _zeroPoint, null, null, true);
	        	else
					_faceMaterialVO.bitmap.draw(_containerVO.bitmap, null, _colorTransform, _blendMode);
	  		}
	  		
	  		_containerVO.updated = false;
	  		
	  		return _faceMaterialVO;        	
		}
	}
}