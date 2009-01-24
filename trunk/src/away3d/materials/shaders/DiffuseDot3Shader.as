package away3d.materials.shaders
{
	import away3d.arcane;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.math.*;
	import away3d.core.render.*;
	import away3d.core.utils.*;
	import away3d.events.*;
	import away3d.materials.*;
	
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.*;
	
	use namespace arcane;
	
	/**
	 * Diffuse Dot3 shader class for directional lighting.
	 * 
	 * @see away3d.lights.DirectionalLight3D
	 */
    public class DiffuseDot3Shader extends AbstractShader implements IUVMaterial
    {
        private var _zeroPoint:Point = new Point(0, 0);
        private var _bitmap:BitmapData;
        private var _sourceDictionary:Dictionary = new Dictionary(true);
        private var _sourceBitmap:BitmapData;
        private var _normalDictionary:Dictionary = new Dictionary(true);
        private var _normalBitmap:BitmapData;
		private var _diffuseTransform:Matrix3D;
		private var _szx:Number;
		private var _szy:Number;
		private var _szz:Number;
		private var _normal0z:Number;
		private var _normal1z:Number;
		private var _normal2z:Number;
		private var _normalFx:Number;
		private var _normalFy:Number;
		private var _normalFz:Number;
		private var _red:Number;
		private var _green:Number;
		private var _blue:Number;
		private var _texturemapping:Matrix;
		
        /**
        * Calculates the mapping matrix required to draw the triangle texture to screen.
        * 
        * @param	tri		The data object holding all information about the triangle to be drawn.
        * @return			The required matrix object.
        */
		private function getMapping(tri:DrawTriangle):Matrix
		{
			if (tri.generated) {
				_texturemapping = tri.transformUV(this).clone();
				_texturemapping.invert();
				
				return _texturemapping;
			}
			
			_faceMaterialVO = getFaceMaterialVO(tri.face, tri.source, tri.view);
			if (_faceMaterialVO.texturemapping)
				return _faceMaterialVO.texturemapping;
			
			_texturemapping = tri.transformUV(this).clone();
			_texturemapping.invert();
			
			return _faceMaterialVO.texturemapping = _texturemapping;
		}
		
		/**
		 * @inheritDoc
		 */
        public function clearFaceDictionary(source:Object3D = null, view:View3D = null):void
        {
        	notifyMaterialUpdate();
        	
        	for each (_faceMaterialVO in _faceDictionary) {
        		if (source == _faceMaterialVO.source) {
	        		if (!_faceMaterialVO.cleared)
	        			_faceMaterialVO.clear();
	        		_faceMaterialVO.invalidated = true;
	        	}
        	}
        }
        
		/**
		 * @inheritDoc
		 */
        protected override function renderShader(tri:DrawTriangle):void
        {
			//check to see if sourceDictionary exists
			_sourceBitmap = _sourceDictionary[tri];
			if (!_sourceBitmap || _faceMaterialVO.resized) {
				_sourceBitmap = _sourceDictionary[tri] = _parentFaceMaterialVO.bitmap.clone();
				_sourceBitmap.lock();
			}
			
			//check to see if normalDictionary exists
			_normalBitmap = _normalDictionary[tri];
			if (!_normalBitmap || _faceMaterialVO.resized) {
				_normalBitmap = _normalDictionary[tri] = _parentFaceMaterialVO.bitmap.clone();
				_normalBitmap.lock();
			}
			
			_face = tri.face;
			_n0 = _source.geometry.getVertexNormal(_face.v0);
			_n1 = _source.geometry.getVertexNormal(_face.v1);
			_n2 = _source.geometry.getVertexNormal(_face.v2);
			
			for each (directional in _source.lightarray.directionals)
	    	{
				_diffuseTransform = directional.diffuseTransform[_source];
				
				
				_szx = _diffuseTransform.szx;
				_szy = _diffuseTransform.szy;
				_szz = _diffuseTransform.szz;
				
				_normal0z = _n0.x * _szx + _n0.y * _szy + _n0.z * _szz;
				_normal1z = _n1.x * _szx + _n1.y * _szy + _n1.z * _szz;
				_normal2z = _n2.x * _szx + _n2.y * _szy + _n2.z * _szz;
				
				//check to see if the uv triangle lies inside the bitmap area
				if (_normal0z > -0.2 || _normal1z > -0.2 || _normal2z > -0.2) {
					
					//store a clone
					if (_faceMaterialVO.cleared && !_parentFaceMaterialVO.updated) {
						_faceMaterialVO.bitmap = _parentFaceMaterialVO.bitmap.clone();
						_faceMaterialVO.bitmap.lock();
					}
					
					//update booleans
					_faceMaterialVO.cleared = false;
					_faceMaterialVO.updated = true;
					
					//resolve normal map
		            _sourceBitmap.applyFilter(_bitmap, _face.bitmapRect, _zeroPoint, directional.normalMatrixTransform[_source]);
					
		            //normalise bitmap
					_normalBitmap.applyFilter(_sourceBitmap, _sourceBitmap.rect, _zeroPoint, directional.colorMatrixTransform[_source]);
		            
					//draw into faceBitmap
					_faceMaterialVO.bitmap.draw(_normalBitmap, null, directional.diffuseColorTransform, blendMode);
				}
	    	}
        }
        
        //TODO: implement tangent space option
        /**
        * Determines if the DOT3 mapping is rendered in tangent space (true) or object space (false).
        */
        public var tangentSpace:Boolean;
        
        /**
        * Returns the width of the bitmapData being used as the shader DOT3 map.
        */
        public function get width():Number
        {
            return _bitmap.width;
        }
        
        /**
        * Returns the height of the bitmapData being used as the shader DOT3 map.
        */
        public function get height():Number
        {
            return _bitmap.height;
        }
        
        /**
        * Returns the bitmapData object being used as the shader DOT3 map.
        */
        public function get bitmap():BitmapData
        {
        	return _bitmap;
        }
        
        /**
        * Returns the argb value of the bitmapData pixel at the given u v coordinate.
        * 
        * @param	u	The u (horizontal) texture coordinate.
        * @param	v	The v (verical) texture coordinate.
        * @return		The argb pixel value.
        */
        public function getPixel32(u:Number, v:Number):uint
        {
        	return _bitmap.getPixel32(u*_bitmap.width, (1 - v)*_bitmap.height);
        }
		
		/**
		 * Creates a new <code>DiffuseDot3Shader</code> object.
		 * 
		 * @param	bitmap			The bitmapData object to be used as the material's DOT3 map.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function DiffuseDot3Shader(bitmap:BitmapData, init:Object = null)
        {
            super(init);
            
			_bitmap = bitmap;
            
            tangentSpace = ini.getBoolean("tangentSpace", false);
        }
        
		/**
		 * @inheritDoc
		 */
		public override function updateMaterial(source:Object3D, view:View3D):void
        {
        	clearLightingShapeDictionary();
        	for each (directional in source.lightarray.directionals) {
        		if (!directional.diffuseTransform[source] || view.scene.updatedObjects[source]) {
        			directional.setDiffuseTransform(source);
        			directional.setNormalMatrixTransform(source);
        			directional.setColorMatrixTransform(source);
        			clearFaceDictionary(source, view);
        		}
        	}
        }
        
		/**
		 * @inheritDoc
		 */
        public override function renderLayer(tri:DrawTriangle, layer:Sprite, level:int):void
        {
        	super.renderLayer(tri, layer, level);
        	
        	for each (directional in _lights.directionals)
        	{
        		if (_lights.numLights > 1) {
					_shape = getLightingShape(layer, directional);
	        		_shape.filters = [directional.normalMatrixTransform[_source], directional.colorMatrixTransform[_source]];
	        		_shape.blendMode = blendMode;
	        		_shape.transform.colorTransform = directional.ambientDiffuseColorTransform;
	        		_graphics = _shape.graphics;
        		} else {
        			layer.filters = [directional.normalMatrixTransform[_source], directional.colorMatrixTransform[_source]];
	        		layer.transform.colorTransform = directional.ambientDiffuseColorTransform;
	        		_graphics = layer.graphics;
        		}
        		
        		_mapping = getMapping(tri);
        		
				_source.session.renderTriangleBitmap(_bitmap, _mapping, tri.v0, tri.v1, tri.v2, smooth, false, _graphics);
        	}
			
			if (debug)
                _source.session.renderTriangleLine(0, 0x0000FF, 1, tri.v0, tri.v1, tri.v2);
        }
        
		/**
		 * @inheritDoc
		 */
        public function addOnMaterialResize(listener:Function):void
        {
        	addEventListener(MaterialEvent.MATERIAL_RESIZED, listener, false, 0, true);
        }
        
		/**
		 * @inheritDoc
		 */
        public function removeOnMaterialResize(listener:Function):void
        {
        	removeEventListener(MaterialEvent.MATERIAL_RESIZED, listener, false);
        }
    }
}
