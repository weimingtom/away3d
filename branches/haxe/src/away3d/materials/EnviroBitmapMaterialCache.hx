package away3d.materials;

import flash.events.EventDispatcher;
import flash.display.BitmapData;
import away3d.materials.shaders.AbstractShader;
import away3d.materials.shaders.EnviroShader;
import away3d.core.utils.Init;


/**
 * Bitmap material with cached environment shading.
 */
class EnviroBitmapMaterialCache extends BitmapMaterialContainer  {
	public var mode(getMode, setMode) : String;
	public var reflectiveness(getReflectiveness, setReflectiveness) : Float;
	public var enviroMap(getEnviroMap, null) : BitmapData;
	public var bitmap(getBitmap, null) : BitmapData;
	
	private var _mode:String;
	private var _reflectiveness:Float;
	private var _bitmapMaterial:BitmapMaterial;
	private var _enviroShader:EnviroShader;
	

	/**
	 * Setting for possible mapping methods.
	 */
	public function getMode():String {
		
		return _mode;
	}

	public function setMode(val:String):String {
		
		_mode = val;
		_enviroShader.mode = val;
		return val;
	}

	/**
	 * Coefficient for the reflectiveness of the material.
	 */
	public function getReflectiveness():Float {
		
		return _reflectiveness;
	}

	public function setReflectiveness(val:Float):Float {
		
		_reflectiveness = val;
		_enviroShader.reflectiveness = val;
		return val;
	}

	/**
	 * Returns the bitmapData object being used as the material environment map.
	 */
	public function getEnviroMap():BitmapData {
		
		return _enviroShader.bitmap;
	}

	/**
	 * Returns the bitmapData object being used as the material texture.
	 */
	public override function getBitmap():BitmapData {
		
		return _bitmapMaterial.bitmap;
	}

	/**
	 * Creates a new <code>EnviroBitmapMaterialCache</code> object.
	 * 
	 * @param	bitmap				The bitmapData object to be used as the material's texture.
	 * @param	enviroMap			The bitmapData object to be used as the material's environment map.
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(bitmap:BitmapData, enviroMap:BitmapData, ?init:Dynamic=null) {
		
		
		ini = Init.parse(init);
		_mode = ini.getString("mode", "linear");
		_reflectiveness = ini.getNumber("reflectiveness", 0.5, {min:0, max:1});
		//create new materials
		_bitmapMaterial = new BitmapMaterial(bitmap, ini);
		_enviroShader = new EnviroShader(enviroMap, {mode:_mode, reflectiveness:_reflectiveness});
		//add to materials array
		materials = new Array<Dynamic>();
		materials.push(_bitmapMaterial);
		materials.push(_enviroShader);
		super(bitmap.width, bitmap.height);
	}

}

