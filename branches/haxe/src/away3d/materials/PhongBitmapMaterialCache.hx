package away3d.materials;

import flash.events.EventDispatcher;
import flash.display.BitmapData;
import away3d.materials.shaders.SpecularPhongShader;
import away3d.materials.shaders.AbstractShader;
import away3d.materials.shaders.AmbientShader;
import flash.display.BlendMode;
import away3d.core.utils.Init;
import away3d.materials.shaders.DiffusePhongShader;


/**
 * Bitmap material with cached phong shading.
 */
class PhongBitmapMaterialCache extends BitmapMaterialContainer  {
	public var shininess(getShininess, setShininess) : Float;
	public var specular(getSpecular, setSpecular) : Float;
	
	private var _shininess:Float;
	private var _specular:Float;
	private var _bitmapMaterial:BitmapMaterial;
	private var _phongShader:BitmapMaterialContainer;
	private var _ambientShader:AmbientShader;
	private var _diffusePhongShader:DiffusePhongShader;
	private var _specularPhongShader:SpecularPhongShader;
	

	/**
	 * The exponential dropoff value used for specular highlights.
	 */
	public function getShininess():Float {
		
		return _shininess;
	}

	public function setShininess(val:Float):Float {
		
		_shininess = val;
		if ((_specularPhongShader != null)) {
			_specularPhongShader.shininess = val;
		}
		return val;
	}

	/**
	 * Coefficient for specular light level.
	 */
	public function getSpecular():Float {
		
		return _specular;
	}

	public function setSpecular(val:Float):Float {
		
		if (_specular == val) {
			return val;
		}
		_specular = val;
		_specularPhongShader.specular = val;
		if ((_specular > 0)) {
			addMaterial(_specularPhongShader);
		} else if ((_specularPhongShader != null)) {
			removeMaterial(_specularPhongShader);
		}
		return val;
	}

	/**
	 * Creates a new <code>PhongBitmapMaterial</code> object.
	 * 
	 * @param	bitmap				The bitmapData object to be used as the material's texture.
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(bitmap:BitmapData, ?init:Dynamic=null) {
		
		
		if ((init != null) && init.materials) {
			init.materials = null;
		}
		super(bitmap.width, bitmap.height, init);
		_shininess = ini.getNumber("shininess", 20);
		_specular = ini.getNumber("specular", 0.7, {min:0, max:1});
		//create new materials
		_bitmapMaterial = new BitmapMaterial(bitmap);
		_phongShader = new BitmapMaterialContainer(bitmap.width, bitmap.height, {blendMode:BlendMode.MULTIPLY, transparent:false});
		_phongShader.addMaterial(_ambientShader = new AmbientShader({blendMode:BlendMode.ADD}));
		_phongShader.addMaterial(_diffusePhongShader = new DiffusePhongShader({blendMode:BlendMode.ADD}));
		_specularPhongShader = new SpecularPhongShader({shininess:_shininess, specular:_specular, blendMode:BlendMode.ADD});
		//add to materials array
		addMaterial(_bitmapMaterial);
		addMaterial(_phongShader);
		if ((_specular > 0)) {
			addMaterial(_specularPhongShader);
		}
	}

}

