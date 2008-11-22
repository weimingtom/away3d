package away3d.materials;

	import away3d.core.utils.*;
	import away3d.materials.shaders.*;
	
	import flash.display.*;
	
	/**
	 * Bitmap material with cached DOT3 shading.
	 */
	class Dot3BitmapMaterialCache extends BitmapMaterialContainer {
		public var bitmap(getBitmap, null) : BitmapData
		;
		public var normalMap(getNormalMap, null) : BitmapData
		;
		public var shininess(getShininess, setShininess) : Float;
		public var specular(getSpecular, setSpecular) : Float;
		
		var _shininess:Float;
		var _specular:Float;
		var _bitmapMaterial:BitmapMaterial;
		var _phongShader:BitmapMaterialContainer;
		var _ambientShader:AmbientShader;
		var _diffuseDot3Shader:DiffuseDot3Shader;
		var _specularPhongShader:SpecularPhongShader;
		
		/**
		 * The exponential dropoff value used for specular highlights.
		 */
		public function getShininess():Float{
			return _shininess;
		}
		
		public function setShininess(val:Float):Float{
			_shininess = val;
            //_specularPhongShader.shininess = val;
			return val;
		}
		
		/**
		 * Coefficient for specular light level.
		 */
		public function getSpecular():Float{
			return _specular;
		}
        
		public function setSpecular(val:Float):Float{
			_specular = val;
            //_specularPhongShader.specular = val;
			return val;
		}
		
        /**
        * Returns the bitmapData object being used as the material normal map.
        */
		public function getNormalMap():BitmapData
		{
			return _diffuseDot3Shader.bitmap;
		}
        
		/**
		 * @inheritDoc
		 */
		public override function getBitmap():BitmapData
		{
			return _bitmapMaterial.bitmap;
		}
		
		/**
		 * Creates a new <code>Dot3BitmapMaterialCache</code> object.
		 * 
		 * @param	bitmap				The bitmapData object to be used as the material's texture.
		 * @param	normalMap			The bitmapData object to be used as the material's DOT3 map.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
		public function new(bitmap:BitmapData, normalMap:BitmapData, ?init:Dynamic = null)
		{
			super(bitmap.width, bitmap.height, init);
			
			_shininess = ini.getNumber("shininess", 20);
			_specular = ini.getNumber("specular", 0.7);
			
			//create new materials
			_bitmapMaterial = new BitmapMaterial(bitmap, ini);
			_phongShader = new BitmapMaterialContainer(bitmap.width, bitmap.height, {blendMode:BlendMode.MULTIPLY, transparent:false});
			_phongShader.addMaterial(_ambientShader = new AmbientShader({blendMode:BlendMode.ADD}));
			_phongShader.addMaterial(_diffuseDot3Shader = new DiffuseDot3Shader(normalMap, {blendMode:BlendMode.ADD}));
			
			//add to materials array
			addMaterial(_bitmapMaterial);
			addMaterial(_phongShader);
			//materials.push(_specularPhongShader = new SpecularPhongShader({shininess:_shininess, specular:_specular, blendMode:BlendMode.ADD}));
		}
		
	}
