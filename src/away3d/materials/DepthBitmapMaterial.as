package away3d.materials
{
	import away3d.core.utils.*;
	import away3d.materials.shaders.*;
	
	import flash.display.*;
	import flash.geom.ColorTransform;
	
	/**
	 * Bitmap material with depth shading.
	 */
	public class DepthBitmapMaterial extends CompositeMaterial
	{
		private var _bitmapMaterial:BitmapMaterial;
		private var _depthShader:DepthShader;
		
		private var _minZ:Number;
		private var _maxZ:Number;
		
		/**
		 * Coefficient for the minimum Z of the depth map.
		 */
        public function get minZ():Number
        {
        	return _depthShader.minZ;
        }
        
        public function set minZ(val:Number):void
        {
        	if (_minZ == val)
        		return;
        	
        	_minZ = val;
            _depthShader.minZ = val;
        }
				
		/**
		 * Coefficient for the maximum Z of the depth map.
		 */
        public function get maxZ():Number
        {
        	return _depthShader.maxZ;
        }
        
        public function set maxZ(val:Number):void
        {
        	if (_maxZ == val)
        		return;
        	
        	_maxZ = val;
        	
            _depthShader.maxZ = val;
        }
        
        /**
        * Returns the bitmapData object being used as the material texture.
        */
		public function get bitmap():BitmapData
		{
			return _bitmapMaterial.bitmap;
		}
		
		/**
		 * Creates a new <code>DepthBitmapMaterial</code> object.
		 * 
		 * @param	bitmap				The bitmapData object to be used as the material's texture.
		 * @param	enviroMap			The bitmapData object to be used as the material's normal map.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
		public function DepthBitmapMaterial(bitmap:BitmapData, init:Object = null)
		{
			//remove any reference to materials
			if (init && init["materials"])
				delete init["materials"];
			
			super(init);
			
			_minZ = ini.getNumber("minZ", 500);
			_maxZ = ini.getNumber("maxZ", 2000);
			
			//create new materials
			_bitmapMaterial = new BitmapMaterial(bitmap, ini);
			_depthShader = new DepthShader({minZ:_minZ, maxZ:_maxZ, blendMode:BlendMode.MULTIPLY});
			
			//add to materials array
			addMaterial(_bitmapMaterial);
			addMaterial(_depthShader);
			
		}
		
	}
}