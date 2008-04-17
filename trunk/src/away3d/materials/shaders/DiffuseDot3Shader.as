package away3d.materials.shaders
{
	import away3d.containers.*;
	import away3d.core.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.math.*;
	import away3d.core.render.*;
	import away3d.core.utils.*;
	import away3d.materials.IUVMaterial;
	
	import flash.display.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.utils.*;
	
    /** Basic phong texture material */
    public class DiffuseDot3Shader extends AbstractShader implements IUVMaterial
    {
    	use namespace arcane;
        
        internal var _zeroPoint:Point = new Point(0, 0);
        internal var _bitmap:BitmapData;
        
        public var tangentSpace:Boolean;
        
        private var _colorMatrixFilter:ColorMatrixFilter = new ColorMatrixFilter();
        
        public function get width():Number
        {
            return _bitmap.width;
        }

        public function get height():Number
        {
            return _bitmap.height;
        }
        
        public function get bitmap():BitmapData
        {
        	return _bitmap;
        }
        
        public function DiffuseDot3Shader(bitmap:BitmapData, init:Object = null)
        {
            super(init);
            
			_bitmap = bitmap;
			
            init = Init.parse(init);
            
            tangentSpace = init.getBoolean("tangentSpace", false);
        }
		
		public override function updateMaterial(source:Object3D, view:View3D):void
        {
        	clearLightingShapeDictionary();
        	for each (directional in source.session.lightarray.directionals) {
        		if (!directional.diffuseTransform[source] || source.sceneTransformed) {
        			directional.setDiffuseTransform(source);
        			directional.setNormalMatrixTransform(source);
        			directional.setColorMatrixTransform(source);
        			clearFaceDictionary(source, view);
        		}
        	}
        }
        
        internal var _sourceDictionary:Dictionary = new Dictionary(true);
        internal var _sourceBitmap:BitmapData;
        
        internal var _normalDictionary:Dictionary = new Dictionary(true);
        internal var _normalBitmap:BitmapData;
        
        public override function clearFaceDictionary(source:Object3D, view:View3D):void
        {
        	for each (_faceVO in _faceDictionary) {
        		if (source == _faceVO.source) {
	        		if (!_faceVO.cleared)
	        			_faceVO.clear();
	        		_faceVO.invalidated = true;
	        	}
        	}
        }
		
        public override function renderLayer(tri:DrawTriangle, layer:Sprite):void
        {
        	super.renderLayer(tri, layer);
        	
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
        		
        		_mapping = tri.texturemapping || tri.transformUV(this);
        		
				_source.session.renderTriangleBitmap(_bitmap, _mapping, tri.v0, tri.v1, tri.v2, smooth, false, _graphics);
        	}
			
			if (debug)
                _source.session.renderTriangleLine(0, 0x0000FF, 1, tri.v0, tri.v1, tri.v2);
        }
        
		internal var _diffuseTransform:Matrix3D;
		
		internal var _szx:Number;
		internal var _szy:Number;
		internal var _szz:Number;
		
		internal var _normal0z:Number;
		internal var _normal1z:Number;
		internal var _normal2z:Number;
		
		internal var _normalFx:Number;
		internal var _normalFy:Number;
		internal var _normalFz:Number;
		
		internal var _red:Number;
		internal var _green:Number;
		internal var _blue:Number;
		
        public override function renderShader(face:Face):void
        {
			//check to see if sourceDictionary exists
			_sourceBitmap = _sourceDictionary[face];
			if (!_sourceBitmap || _faceVO.resized) {
				_sourceBitmap = _sourceDictionary[face] = _parentFaceVO.bitmap.clone();
				_sourceBitmap.lock();
			}
			
			//check to see if normalDictionary exists
			_normalBitmap = _normalDictionary[face];
			if (!_normalBitmap || _faceVO.resized) {
				_normalBitmap = _normalDictionary[face] = _parentFaceVO.bitmap.clone();
				_normalBitmap.lock();
			}
			
			for each (directional in _source.session.lightarray.directionals)
	    	{
				_diffuseTransform = directional.diffuseTransform[_source];
				
				_n0 = _source.getVertexNormal(face.v0);
				_n1 = _source.getVertexNormal(face.v1);
				_n2 = _source.getVertexNormal(face.v2);
				
				_szx = _diffuseTransform.szx;
				_szy = _diffuseTransform.szy;
				_szz = _diffuseTransform.szz;
				
				_normal0z = _n0.x * _szx + _n0.y * _szy + _n0.z * _szz;
				_normal1z = _n1.x * _szx + _n1.y * _szy + _n1.z * _szz;
				_normal2z = _n2.x * _szx + _n2.y * _szy + _n2.z * _szz;
				
				//check to see if the uv triangle lies inside the bitmap area
				if (_normal0z > -0.2 || _normal1z > -0.2 || _normal2z > -0.2) {
					
					//store a clone
					if (_faceVO.cleared && !_parentFaceVO.updated) {
						_faceVO.bitmap = _parentFaceVO.bitmap.clone();
						_faceVO.bitmap.lock();
					}
					
					//update booleans
					_faceVO.cleared = false;
					_faceVO.updated = true;
					
					//resolve normal map
		            _sourceBitmap.applyFilter(_bitmap, face.bitmapRect, _zeroPoint, directional.normalMatrixTransform[_source]);
					
		            //normalise bitmap
					_normalBitmap.applyFilter(_sourceBitmap, _sourceBitmap.rect, _zeroPoint, directional.colorMatrixTransform[_source]);
		            
					//draw into faceBitmap
					_faceVO.bitmap.draw(_normalBitmap, null, directional.diffuseColorTransform, blendMode);
				}
	    	}
        }
    }
}
