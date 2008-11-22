package away3d.materials;

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
	class BitmapMaterialContainer extends BitmapMaterial, implements ITriangleMaterial, implements ILayerMaterial {
		
		var _width:Float;
		var _height:Float;
		var _containerDictionary:Dictionary ;
		var _cacheDictionary:Dictionary ;
		var _containerVO:FaceVO;
		var _faceWidth:Int;
		var _faceHeight:Int;
		var _forceRender:Bool;
		var _face:Face;
		var _material:ILayerMaterial;
        var _viewDictionary:Dictionary ;
        
        function onMaterialUpdate(event:MaterialEvent):Void
        {
        	_faceDirty = true;
        	dispatchEvent(event);
        }
        
		/**
		 * An array of bitmapmaterial objects to be overlayed sequentially.
		 */
		var materials:Array<Dynamic>;
        
		/**
		 * @inheritDoc
		 */
		override function updateRenderBitmap():Void
        {
        	_bitmapDirty = false;
        	_faceDirty = true;
        }
        
		/**
		 * @inheritDoc
		 */
		override function getMapping(tri:DrawTriangle):Matrix
        {
        	_face = tri.face;
    		_faceVO = getFaceVO(tri.face, tri.source, tri.view);
    		
    		if (_faceVO.invalidated || !_faceVO.texturemapping) {
        		_faceVO.invalidated = false;
	    		//_faceVO.backface = tri.backface;
	    		
	        	//check to see if face drawtriangle needs updating
	        	if (!_faceVO.texturemapping) {
	        		
	        		//update face bitmapRect
	        		_face.bitmapRect = new Rectangle(int(_width*_face.minU), int(_height*(1 - _face.maxV)), int(_width*(_face.maxU-_face.minU)+2), int(_height*(_face.maxV-_face.minV)+2));
	        		_faceWidth = _face.bitmapRect.width;
	        		_faceHeight = _face.bitmapRect.height;
	        		
	        		//update texturemapping
	        		_faceVO.invtexturemapping = tri.transformUV(this).clone();
	        		_faceVO.texturemapping = _faceVO.invtexturemapping.clone();
	        		_faceVO.texturemapping.invert();
	        		
	        		//resize bitmapData for container
	        		_faceVO.resize(_faceWidth, _faceHeight, transparent);
	        	}
        		
	    		//call renderFace on each material
	    		for each (_material in materials)
	        		_faceVO = _material.renderBitmapLayer(tri, _bitmapRect, _faceVO);
	        	
	        	_cacheDictionary[_face] = _faceVO;
        		
        		_renderBitmap = _faceVO.bitmap;
	        	
	        	_faceVO.updated = false;
	        } else {
	        	_renderBitmap = _cacheDictionary[_face].bitmap;
	        }
        	
        	//check to see if tri texturemapping need updating
        	if (!_faceVO.texturemapping) {
        		//update texturemapping
        		_faceVO.invtexturemapping = tri.transformUV(this).clone();
        		_faceVO.texturemapping = _faceVO.invtexturemapping.clone();
        		_faceVO.texturemapping.invert();
        	}
        	
        	return _faceVO.texturemapping;
        }
		
		/**
		 * Defines whether the caching bitmapData objects are transparent
		 */
		public var transparent:Bool;
    	
		/**
		 * Creates a new <code>BitmapMaterialContainer</code> object.
		 * 
		 * @param	width				The containing width of the texture, applied to all child materials.
		 * @param	height				The containing height of the texture, applied to all child materials.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
		public function new(width:Int, height:Int, ?init:Dynamic = null)
		{
			
			_containerDictionary = new Dictionary(true);
			_cacheDictionary = new Dictionary(true);
			_viewDictionary = new Dictionary(true);
			super(new BitmapData(width, height, true, 0x00FFFFFF), init);
			
			materials = ini.getArray("materials");
			_width = width;
			_height = height;
			_bitmapRect = new Rectangle(0, 0, _width, _height);
            
            for each (_material in materials)
            	_material.addOnMaterialUpdate(onMaterialUpdate);
			
			transparent = ini.getBoolean("transparent", true);
		}
		        
        public function addMaterial(material:ILayerMaterial):Void
        {
        	material.addOnMaterialUpdate(onMaterialUpdate);
        	materials.push(material);
        	
        	_faceDirty = true;
        }
        
        public function removeMaterial(material:ILayerMaterial):Void
        {
        	var index:Int = materials.indexOf(material);
        	
        	if (index == -1)
        		return;
        	
        	material.removeOnMaterialUpdate(onMaterialUpdate);
        	
        	materials.splice(index, 1);
        	
        	_faceDirty = true;
        }
        
        public function clearMaterials():Void
        {
        	var i:Int = materials.length;
        	
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
        public override function updateMaterial(source:Object3D, view:View3D):Void
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
        
        public override function getFaceVO(face:Face, source:Object3D, ?view:View3D = null):FaceVO
        {
        	if ((_faceDictionary = _viewDictionary[view])) {
        		if ((_faceVO = _faceDictionary[face]))
	        		return _faceVO;
        	} else {
        		_faceDictionary = _viewDictionary[view] = new Dictionary(true);
        	}
        	
        	return _faceDictionary[face] = new FaceVO();
        }
        
        public override function removeFaceDictionary():Void
        {
			_viewDictionary = new Dictionary(true);
        }
        
		/**
		 * @private
		 */
        public override function renderLayer(tri:DrawTriangle, layer:Sprite, level:Int):Void
        {
        	throw new Error("Not implemented");
        }
        
		/**
		 * @inheritDoc
		 */
        public override function renderBitmapLayer(tri:DrawTriangle, containerRect:Rectangle, parentFaceVO:FaceVO):FaceVO
		{
			_faceVO = getFaceVO(tri.face, tri.source, tri.view);
			
			//get width and height values
			_faceWidth = tri.face.bitmapRect.width;
    		_faceHeight = tri.face.bitmapRect.height;

			//check to see if bitmapContainer exists
			if (!(_containerVO = _containerDictionary[tri]))
				_containerVO = _containerDictionary[tri] = new FaceVO();
			
			//resize container
			if (parentFaceVO.resized) {
				parentFaceVO.resized = false;
				_containerVO.resize(_faceWidth, _faceHeight, transparent);
			}
			
			//call renderFace on each material
    		for each (_material in materials)
        		_containerVO = _material.renderBitmapLayer(tri, containerRect, _containerVO);
			
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
	        	if (_blendMode == BlendMode.NORMAL && !_colorTransform)
	        		_faceVO.bitmap.copyPixels(_containerVO.bitmap, _containerVO.bitmap.rect, _zeroPoint, null, null, true);
	        	else
					_faceVO.bitmap.draw(_containerVO.bitmap, null, _colorTransform, _blendMode);
	  		}
	  		
	  		_containerVO.updated = false;
	  		
	  		return _faceVO;        	
		}
	}
