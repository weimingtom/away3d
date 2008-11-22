package away3d.materials;

	import away3d.arcane;
	import away3d.core.utils.*;
	import away3d.materials.shaders.*;
	
	import flash.display.*;
	
	use namespace arcane;
	
	/**
	 * Color material with phong shading.
	 */
	class PhongColorMaterial extends CompositeMaterial {
		public var shininess(getShininess, setShininess) : Float;
		public var specular(getSpecular, setSpecular) : Float;
		
		var _shininess:Float;
		var _specular:Float;
		var _phongShader:CompositeMaterial;
		var _ambientShader:AmbientShader;
		var _diffusePhongShader:DiffusePhongShader;
		var _specularPhongShader:SpecularPhongShader;
        
    	/**
    	 * Updates the colortransform object applied to the texture from the <code>color</code> and <code>alpha</code> properties.
    	 * 
    	 * @see away3d.materials.CompositeMaterial#color
    	 * @see away3d.materials.CompositeMaterial#alpha
    	 */
		override function setColorTransform():Void
		{
			_colorTransformDirty = false;
			
			if (_specular) {
				_colorTransform = null;
				_phongShader.color = _color;
				_phongShader.alpha = _alpha;
			} else {
				_phongShader.color = 0xFFFFFF;
				_phongShader.alpha = 1;
				super.setColorTransform();
			}
		}
		
		/**
		 * The exponential dropoff value used for specular highlights.
		 */
		public function getShininess():Float{
			return _shininess;
		}
		
		public function setShininess(val:Float):Float{
			_shininess = val;
			if (_specularPhongShader)
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
			if (_specular) {
				_specularPhongShader.shininess = _shininess;
				_specularPhongShader.specular = _specular;
				removeMaterial(_ambientShader);
				removeMaterial(_diffusePhongShader);
				addMaterial(_phongShader);
				addMaterial(_specularPhongShader);
   			} else {
   				removeMaterial(_phongShader);
				removeMaterial(_specularPhongShader);
   				addMaterial(_ambientShader);
				addMaterial(_diffusePhongShader);
   			}
            
			_colorTransformDirty = true;
			return val;
		}
		
		/**
		 * Creates a new <code>PhongBitmapMaterial</code> object.
		 * 
		 * @param	color				A string, hex value or colorname representing the color of the material.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
		public function new(color:Dynamic, ?init:Dynamic = null)
		{
			if (init && init.materials)
				delete init.materials;
			
			super(init);
			
			this.color = Cast.trycolor(color);
			
			_shininess = ini.getNumber("shininess", 20);
			_specular = ini.getNumber("specular", 0.7, {min:0, max:1});
			
			//create new materials
			_phongShader = new CompositeMaterial();
			_phongShader.addMaterial(_ambientShader = new AmbientShader({blendMode:BlendMode.ADD}));
			_phongShader.addMaterial(_diffusePhongShader = new DiffusePhongShader({blendMode:BlendMode.ADD}));
			_specularPhongShader = new SpecularPhongShader({shininess:_shininess, specular:_specular, blendMode:BlendMode.ADD});
			
			//add to materials array
			if (_specular) {
				addMaterial(_phongShader);
				addMaterial(_specularPhongShader);
			} else {
				addMaterial(_ambientShader);
				addMaterial(_diffusePhongShader);
			}
		}
		
	}
