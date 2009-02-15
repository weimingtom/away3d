package away3d.lights;

import away3d.materials.IMaterial;
import flash.events.EventDispatcher;
import away3d.primitives.Sphere;
import away3d.primitives.AbstractPrimitive;
import away3d.core.light.ILightConsumer;
import away3d.core.utils.IClonable;
import away3d.core.base.Object3D;
import away3d.core.light.ILightProvider;
import away3d.materials.ColorMaterial;
import away3d.core.light.LightPrimitive;
import away3d.core.utils.Init;
import away3d.core.light.AmbientLight;


/**
 * Lightsource that colors all shaded materials evenly from any angle
 */
class AmbientLight3D extends Object3D, implements ILightProvider, implements IClonable {
	public var color(getColor, setColor) : Int;
	public var ambient(getAmbient, setAmbient) : Float;
	public var debug(getDebug, setDebug) : Bool;
	public var debugPrimitive(getDebugPrimitive, null) : Object3D;
	
	private var _color:Int;
	private var _red:Int;
	private var _green:Int;
	private var _blue:Int;
	private var _ambient:Float;
	private var _colorDirty:Bool;
	private var _ambientDirty:Bool;
	private var _ls:AmbientLight;
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
		_red = (_color & 0xFF0000) >> 16;
		_green = (_color & 0xFF00) >> 8;
		_blue = (_color & 0xFF);
		_colorDirty = true;
		return val;
	}

	/**
	 * Defines a coefficient for the ambient light intensity.
	 */
	public function getAmbient():Float {
		
		return _ambient;
	}

	public function setAmbient(val:Float):Float {
		
		_ambient = val;
		_ambientDirty = true;
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
			_debugPrimitive = new Sphere();
		}
		if (_debugMaterial == null) {
			_debugMaterial = new ColorMaterial();
			_debugPrimitive.material = _debugMaterial;
		}
		_debugMaterial.color = color;
		return _debugPrimitive;
	}

	/**
	 * Creates a new <code>AmbientLight3D</code> object.
	 * 
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(?init:Dynamic=null) {
		this._ls = new AmbientLight();
		
		
		super(init);
		color = ini.getColor("color", 0xFFFFFF);
		ambient = ini.getNumber("ambient", 0.5, {min:0, max:1});
		debug = ini.getBoolean("debug", false);
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
			_colorDirty = false;
		}
		//update ambient
		if (_ambientDirty) {
			_ambientDirty = false;
			_ls.updateAmbientBitmap(_ambient);
		}
		consumer.ambientLight(_ls);
	}

	/**
	 * Duplicates the light object's properties to another <code>AmbientLight3D</code> object
	 * 
	 * @param	object	[optional]	The new object instance into which all properties are copied
	 * @return						The new object instance with duplicated properties applied
	 */
	public override function clone(?object:Object3D=null):Object3D {
		
		var light:AmbientLight3D = (cast(object, AmbientLight3D));
		if (light == null)  {
			light = new AmbientLight3D();
		};
		super.clone(light);
		light.color = color;
		light.ambient = ambient;
		light.debug = debug;
		return light;
	}

}

