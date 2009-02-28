package away3d.lights;

import away3d.materials.ColorMaterial;
import away3d.primitives.Sphere;
import flash.events.EventDispatcher;
import away3d.core.light.ILightConsumer;
import away3d.core.utils.IClonable;
import away3d.core.light.DirectionalLight;
import away3d.core.base.Object3D;
import away3d.core.light.ILightProvider;
import away3d.core.light.LightPrimitive;
import away3d.core.utils.Init;


/**
 * Lightsource that colors all shaded materials proportional to the dot product of the offset vector with the normal vector.
 * The scalar value of distance does not affect the resulting light intensity, it is calulated as if the
 * source is an infinite distance away with an infinite brightness.
 */
class DirectionalLight3D extends Object3D, implements ILightProvider, implements IClonable {
	public var color(getColor, setColor) : Int;
	public var ambient(getAmbient, setAmbient) : Float;
	public var diffuse(getDiffuse, setDiffuse) : Float;
	public var specular(getSpecular, setSpecular) : Float;
	public var brightness(getBrightness, setBrightness) : Float;
	public var debug(getDebug, setDebug) : Bool;
	public var debugPrimitive(getDebugPrimitive, null) : Object3D;
	
	private var _color:Int;
	private var _red:Float;
	private var _green:Float;
	private var _blue:Float;
	private var _ambient:Float;
	private var _diffuse:Float;
	private var _specular:Float;
	private var _brightness:Float;
	private var _colorDirty:Bool;
	private var _ambientDirty:Bool;
	private var _diffuseDirty:Bool;
	private var _specularDirty:Bool;
	private var _ls:DirectionalLight;
	private var _debugPrimitive:Sphere;
	private var _debugMaterial:ColorMaterial;
	private var _debug:Bool;
	

	/**
	 * Defines the color of the light object.
	 */
	public function getColor():Int {
		
		return _color;
	}

	public function setColor(val:Int):Int {
		
		_color = val;
		_red = ((color & 0xFF0000) >> 16) / 255;
		_green = ((color & 0xFF00) >> 8) / 255;
		_blue = (color & 0xFF) / 255;
		_colorDirty = true;
		_ambientDirty = true;
		_diffuseDirty = true;
		_specularDirty = true;
		return val;
	}

	/**
	 * Defines a coefficient for the ambient light intensity.
	 */
	public function getAmbient():Float {
		
		return _ambient;
	}

	public function setAmbient(val:Float):Float {
		
		if (val < 0) {
			val = 0;
		}
		_ambient = val;
		_ambientDirty = true;
		return val;
	}

	/**
	 * Defines a coefficient for the diffuse light intensity.
	 */
	public function getDiffuse():Float {
		
		return _diffuse;
	}

	public function setDiffuse(val:Float):Float {
		
		if (val < 0) {
			val = 0;
		}
		_diffuse = val;
		_diffuseDirty = true;
		return val;
	}

	/**
	 * Defines a coefficient for the specular light intensity.
	 */
	public function getSpecular():Float {
		
		return _specular;
	}

	public function setSpecular(val:Float):Float {
		
		if (val < 0) {
			val = 0;
		}
		_specular = val;
		_specularDirty = true;
		return val;
	}

	//TODO: brightness on directional light needs implementing
	/**
	 * Defines a coefficient for the overall light intensity.
	 */
	public function getBrightness():Float {
		
		return _brightness;
	}

	public function setBrightness(val:Float):Float {
		
		_brightness = val;
		_ambientDirty = true;
		_diffuseDirty = true;
		_specularDirty = true;
		return val;
	}

	/**
	 * Toggles debug mode: light object is visualised in the scene.
	 */
	public function getDebug():Bool {
		
		return _debug;
	}

	public function setDebug(val:Bool):Bool {
		
		_debug = val;
		return val;
	}

	public function getDebugPrimitive():Object3D {
		
		if (_debugPrimitive == null) {
			_debugPrimitive = new Sphere({radius:10});
		}
		if (_debugMaterial == null) {
			_debugMaterial = new ColorMaterial();
			_debugPrimitive.material = _debugMaterial;
		}
		_debugMaterial.color = color;
		return _debugPrimitive;
	}

	/**
	 * Creates a new <code>DirectionalLight3D</code> object.
	 * 
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(?init:Dynamic=null) {
		this._ls = new DirectionalLight();
		
		
		super(init);
		color = ini.getColor("color", 0xFFFFFF);
		ambient = ini.getNumber("ambient", 0.5, {min:0, max:1});
		diffuse = ini.getNumber("diffuse", 0.5, {min:0, max:10});
		specular = ini.getNumber("specular", 1, {min:0, max:1});
		brightness = ini.getNumber("brightness", 1);
		debug = ini.getBoolean("debug", false);
		_ls.light = this;
	}

	/**
	 * @inheritDoc
	 */
	public function light(consumer:ILightConsumer):Void {
		//update color
		
		if (_colorDirty) {
			_ls.red = _red;
			_ls.green = _green;
			_ls.blue = _blue;
		}
		//update coefficients
		_ls.ambient = _ambient * _brightness;
		_ls.diffuse = _diffuse * _brightness;
		_ls.specular = _specular * _brightness;
		//update ambient diffuse
		if (_ambientDirty || _diffuseDirty) {
			_ls.updateAmbientDiffuseBitmap();
		}
		//update ambient
		if (_ambientDirty) {
			_ambientDirty = false;
			_ls.updateAmbientBitmap();
		}
		//update diffuse
		if (_diffuseDirty) {
			_diffuseDirty = false;
			_ls.updateDiffuseBitmap();
		}
		//update specular
		if (_specularDirty) {
			_specularDirty = false;
			_ls.updateSpecularBitmap();
		}
		consumer.directionalLight(_ls);
		_colorDirty = false;
	}

	/**
	 * Duplicates the light object's properties to another <code>DirectionalLight3D</code> object
	 * 
	 * @param	object	[optional]	The new object instance into which all properties are copied
	 * @return						The new object instance with duplicated properties applied
	 */
	public override function clone(?object:Object3D=null):Object3D {
		
		var light:DirectionalLight3D = (cast(object, DirectionalLight3D));
		if (light == null)  {
			light = new DirectionalLight3D();
		};
		super.clone(light);
		light.color = color;
		light.brightness = brightness;
		light.ambient = ambient;
		light.diffuse = diffuse;
		light.specular = specular;
		light.debug = debug;
		return light;
	}

}

