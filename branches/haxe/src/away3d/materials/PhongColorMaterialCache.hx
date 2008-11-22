package away3d.materials;

	import away3d.arcane;
	import away3d.core.utils.*;
	import away3d.materials.shaders.*;
	
	import flash.display.*;
	
	use namespace arcane;
	
	/**
	 * Color material with cached phong shading.
	 */
	class PhongColorMaterialCache extends BitmapMaterialContainer {
		public var shininess(getShininess, setShininess) : Float;
		public var specular(getSpecular, setSpecular) : Float;
		
		var _shininess:Float;
		var _specular:Float;
		var _phongShader:BitmapMaterialContainer;
		var _ambientShader:AmbientShader;
		var _diffusePhongShader:DiffusePhongShader;
		var _specularPhongShader:SpecularPhongShader;
        
    	/**
    	 * Updates the colortransform object applied to the texture from the <code>color</code> and <code>alpha</code> properties.
    	 * 
    	 * @see away3d.materials.BitmapMaterialContainer#color
    	 * @see away3d.materials.BitmapMaterialContainer#alpha
    	 */
		override function updateColorTransform():Void
		{
			_phongShader.color = _color;
			_phongShader.alpha = _alpha;
		}
		
		/**
		 * The exponential dropoff value used for specular highlights.
		 */
		public function getShininess():Float{
			return _shininess;
		}
				
		public function setShininess(val:Float):Float{
			_shininess = val;
			_specularPhongShader.shininess = val;
			return val;
		}
		
		/**
		 * Coefficient for specular light level.
		 */
		public function getSpecular():Float{
			return _specular;
		}
		
		public function setSpecular(val:Float):Float{
			if (_specular == val)
				return;
			
			_specular = val;
			_specularPhongShader.specular = val;
			
			if (_specular && materials.length < 3)
        		addMaterial(_specularPhongShader);
   			else if (materials.length > 2)
            	removeMaterial(_specularPhongShader);
			return val;
		}
		
		/**
		 * Creates a new <code>PhongColorMaterialCache</code> object.
		 * 
		 * @param	color				A string, hex value or colorname representing the color of the material.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
		public function new(color:Dynamic, ?init:Dynamic=null)
		{
			if (init && init.materials)
				delete init.materials;
			
			super(512, 512, init);
			
			this.color = Cast.trycolor(color);
			
			_shininess = ini.getNumber("shininess", 20);
			_specular = ini.getNumber("specular", 0.7, {min:0, max:1});
			
			//create new materials
			_phongShader = new BitmapMaterialContainer(512, 512, {transparent:false});
			_phongShader.addMaterial(_ambientShader = new AmbientShader({blendMode:BlendMode.ADD}));
			_phongShader.addMaterial(_diffusePhongShader = new DiffusePhongShader({blendMode:BlendMode.ADD}));
			_specularPhongShader = new SpecularPhongShader({shininess:_shininess, specular:_specular, blendMode:BlendMode.ADD});
			
			//add to materials array
			addMaterial(_phongShader);
			
			if (_specular)
				addMaterial(_specularPhongShader);
		}
		
	}
