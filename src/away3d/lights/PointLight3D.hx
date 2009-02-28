package away3d.lights;

import away3d.primitives.Sphere;
import away3d.materials.IMaterial;
import flash.events.EventDispatcher;
import away3d.core.light.PointLight;
import away3d.core.light.ILightConsumer;
import away3d.core.utils.IClonable;
import away3d.core.base.Object3D;
import away3d.core.light.ILightProvider;
import away3d.materials.ColorMaterial;
import away3d.core.light.LightPrimitive;
import away3d.core.utils.Init;


// use namespace arcane;

/**
 * Lightsource that colors all shaded materials proportional to the dot product of the distance vector with the normal vector.
 * The scalar value of the distance is used to calulate intensity using the inverse square law of attenuation.
 */
class PointLight3D extends Object3D, implements ILightProvider, implements IClonable {
	public var debug(getDebug, setDebug) : Bool;
	public var debugPrimitive(getDebugPrimitive, null) : Object3D;
	
	private var _ls:PointLight;
	private var _debugPrimitive:Sphere;
	private var _debugMaterial:ColorMaterial;
	private var _debug:Bool;
	/**
	 * Defines the color of the light object.
	 */
	public var color:Int;
	/**
	 * Defines a coefficient for the ambient light intensity.
	 */
	public var ambient:Float;
	/**
	 * Defines a coefficient for the diffuse light intensity.
	 */
	public var diffuse:Float;
	/**
	 * Defines a coefficient for the specular light intensity.
	 */
	public var specular:Float;
	/**
	 * Defines a coefficient for the overall light intensity.
	 */
	public var brightness:Float;
	

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
	 * Creates a new <code>PointLight3D</code> object.
	 * 
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(?init:Dynamic=null) {
		this._ls = new PointLight();
		
		
		super(init);
		color = ini.getColor("color", 0xFFFFFF);
		ambient = ini.getNumber("ambient", 1);
		diffuse = ini.getNumber("diffuse", 1);
		specular = ini.getNumber("specular", 1);
		brightness = ini.getNumber("brightness", 1000) * 255;
		debug = ini.getBoolean("debug", false);
		_ls.light = this;
	}

	/**
	 * @inheritDoc
	 */
	public function light(consumer:ILightConsumer):Void {
		
		_ls.red = ((color & 0xFF0000) >> 16) / 255;
		_ls.green = ((color & 0xFF00) >> 8) / 255;
		_ls.blue = (color & 0xFF) / 255;
		_ls.ambient = ambient * brightness;
		_ls.diffuse = diffuse * brightness;
		_ls.specular = specular * brightness;
		consumer.pointLight(_ls);
	}

	/**
	 * Duplicates the light object's properties to another <code>PointLight3D</code> object
	 * 
	 * @param	object	[optional]	The new object instance into which all properties are copied
	 * @return						The new object instance with duplicated properties applied
	 */
	public override function clone(?object:Object3D=null):Object3D {
		
		var light:PointLight3D = (cast(object, PointLight3D));
		if (light == null)  {
			light = new PointLight3D();
		};
		super.clone(light);
		light.color = color;
		light.ambient = ambient;
		light.diffuse = diffuse;
		light.specular = specular;
		light.debug = debug;
		return light;
	}

}

