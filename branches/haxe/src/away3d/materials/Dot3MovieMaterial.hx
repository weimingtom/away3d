package away3d.materials;

import flash.events.EventDispatcher;
import flash.display.BitmapData;
import away3d.materials.shaders.SpecularPhongShader;
import away3d.materials.shaders.AbstractShader;
import away3d.materials.shaders.AmbientShader;
import flash.display.BlendMode;
import away3d.core.utils.Init;
import flash.display.Sprite;
import away3d.materials.shaders.DiffuseDot3Shader;


/**
 * Animated movie material with DOT3 shading.
 */
class Dot3MovieMaterial extends CompositeMaterial  {
	public var shininess(getShininess, setShininess) : Float;
	public var specular(getSpecular, setSpecular) : Float;
	public var normalMap(getNormalMap, null) : BitmapData;
	public var bitmap(getBitmap, null) : BitmapData;
	public var moviematerial(getMoviematerial, null) : MovieMaterial;
	
	private var _shininess:Float;
	private var _specular:Float;
	private var _movieMaterial:MovieMaterial;
	private var _phongShader:CompositeMaterial;
	private var _ambientShader:AmbientShader;
	private var _diffuseDot3Shader:DiffuseDot3Shader;
	private var _specularPhongShader:SpecularPhongShader;
	

	/**
	 * The exponential dropoff value used for specular highlights.
	 */
	public function getShininess():Float {
		
		return _specular;
	}

	public function setShininess(val:Float):Float {
		
		_shininess = val;
		_specularPhongShader.shininess = val;
		return val;
	}

	/**
	 * Coefficient for specular light level.
	 */
	public function getSpecular():Float {
		
		return _specular;
	}

	public function setSpecular(val:Float):Float {
		
		_specular = val;
		//specularPhongShader.specular = val;
		
		return val;
	}

	/**
	 * Returns the bitmapData object being used as the material normal map.
	 */
	public function getNormalMap():BitmapData {
		
		return _diffuseDot3Shader.bitmap;
	}

	/**
	 * Returns the bitmapData object being used as the material texture.
	 */
	public function getBitmap():BitmapData {
		
		return _movieMaterial.bitmap;
	}

	/**
	 * Returns the MovieMaterial object being used as the material texture.
	 */
	public function getMoviematerial():MovieMaterial {
		
		return _movieMaterial;
	}

	/**
	 * Creates a new <code>Dot3MovieMaterial</code> object.
	 * 
	 * @param	movie				The movieclip to be used as the material's texture.
	 * @param	normalMap			The bitmapData object to be used as the material's DOT3 map.
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(movie:Sprite, normalMap:BitmapData, ?init:Dynamic=null) {
		
		
		if ((init != null) && init.materials) {
			init.materials = null;
		}
		super(init);
		_shininess = ini.getNumber("shininess", 20);
		_specular = ini.getNumber("specular", 0.7);
		//create new materials
		_movieMaterial = new MovieMaterial(movie, ini);
		_phongShader = new CompositeMaterial({blendMode:BlendMode.MULTIPLY});
		_phongShader.addMaterial(_ambientShader = new AmbientShader({blendMode:BlendMode.ADD}));
		_phongShader.addMaterial(_diffuseDot3Shader = new DiffuseDot3Shader(normalMap, {blendMode:BlendMode.ADD}));
		//add to materials array
		addMaterial(_movieMaterial);
		addMaterial(_phongShader);
		//materials.push(specularPhongShader = new SpecularPhongShader({shininess:_shininess, specular:_specular, blendMode:BlendMode.ADD}));
		
	}

}

