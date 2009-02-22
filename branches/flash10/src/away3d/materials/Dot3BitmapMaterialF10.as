package away3d.materials
{
	import away3d.containers.View3D;
	import away3d.core.base.Object3D;
	import away3d.core.utils.*;
	import away3d.materials.shaders.*;
	
	import flash.display.*;

;

;
	
	/**
	 * Bitmap material with DOT3 shading.
	 */
	public class Dot3BitmapMaterialF10 extends BitmapMaterial
	{
		private var _shininess:Number;
		private var _specular:Number;
		private var _normalMap:BitmapData;
		private var _normalShader:Shader;
		
		[Embed(source="normalMapping.pbj",mimeType="application/octet-stream")]
    	private var NormalShader:Class;
    	
		/**
		 * The exponential dropoff value used for specular highlights.
		 */
		public function get shininess():Number
		{
			return _shininess;
		}
		
		public function set shininess(val:Number):void
		{
			_shininess = val;
            //_specularPhongShader.shininess = val;
		}
		
		/**
		 * Coefficient for specular light level.
		 */
		public function get specular():Number
		{
			return _specular;
		}
		
		public function set specular(val:Number):void
		{
			_specular = val;
            //_specularPhongShader.specular = val;
		}
        
        /**
        * Returns the bitmapData object being used as the material normal map.
        */
		public function get normalMap():BitmapData
		{
			return _normalMap;
		}
		
		/**
		 * Creates a new <code>Dot3BitmapMaterial</code> object.
		 * 
		 * @param	bitmap				The bitmapData object to be used as the material's texture.
		 * @param	normalMap			The bitmapData object to be used as the material's DOT3 map.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
		public function Dot3BitmapMaterialF10(bitmap:BitmapData, normalMap:BitmapData, init:Object = null)
		{
			super(bitmap, init);
			
			
			_normalMap = normalMap;
			
			_normalShader = new Shader();
			
			_shininess = ini.getNumber("shininess", 20);
			_specular = ini.getNumber("specular", 0.7);
		}
		
		/**
		 * @inheritDoc
		 */
        public override function updateMaterial(source:Object3D, view:View3D):void
        {
        	super.updateMaterial(source, view);
        	/*
        	for each (_directional in source.lightarray.directionals) {
        		if (!_directional.diffuseTransform[source] || view.scene.updatedObjects[source]) {
        			_directional.setDiffuseTransform(source);
        			_directional.setNormalMatrixTransform(source);
        			_directional.setColorMatrixTransform(source);
        			clearFaces(source, view);
        			
        			
        		}
        	}*/
        }
	}
}