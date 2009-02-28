package away3d.core.filter;

import away3d.haxeutils.Error;
import away3d.core.base.Object3D;
import away3d.containers.Scene3D;
import away3d.containers.ObjectContainer3D;
import flash.events.EventDispatcher;
import away3d.core.draw.DrawFog;
import away3d.materials.ITriangleMaterial;
import away3d.cameras.Camera3D;
import away3d.core.clip.Clipping;
import away3d.materials.ColorMaterial;
import away3d.core.utils.Init;
import away3d.materials.IFogMaterial;
import away3d.core.draw.DrawPrimitive;


/**
 * Adds fog layers to a view and provides automatic farfield filtering for primitives outside the furthest fog layers.
 */
class FogFilter implements IPrimitiveFilter {
	public var material(getMaterial, setMaterial) : IFogMaterial;
	
	private var i:Int;
	private var _primitives:Array<Dynamic>;
	private var pri:DrawPrimitive;
	private var _material:IFogMaterial;
	private var _minZ:Float;
	private var _maxZ:Int;
	private var _subdivisions:Int;
	private var _materials:Array<Dynamic>;
	private var _fogPrimitives:Array<Dynamic>;
	private var fog:DrawFog;
	/**
	 * Instance of the Init object used to hold and parse default property values
	 * specified by the initialiser object in the 3d object constructor.
	 */
	private var ini:Init;
	

	/**
	 * Defines the material used by the fog layers.
	 */
	public function getMaterial():IFogMaterial {
		
		return _material;
	}

	public function setMaterial(val:IFogMaterial):IFogMaterial {
		
		_material = val;
		return val;
	}

	/**
	 * Allows color change at runtime of the filter
	 * @param	color			The new color for the filter
	 */
	public function updateMaterialColor(color:Int):Void {
		
		for (__i in 0..._fogPrimitives.length) {
			var fog:DrawFog = _fogPrimitives[__i];

			if (fog != null) {
				if (Std.is(fog.material, ColorMaterial)) {
					fog.material = new ColorMaterial(color, {alpha:fog.material.alpha});
				}
			}
		}

	}

	function new(?init:Dynamic=null):Void {
		this._materials = [];
		this._fogPrimitives = [];
		
		
		ini = Init.parse(init);
		_material = cast(ini.getMaterial("material"), IFogMaterial);
		_minZ = ini.getNumber("minZ", 1000, {min:0});
		_maxZ = Std.int(ini.getNumber("maxZ", 5000, {min:0}));
		_subdivisions = ini.getInt("subdivisions", 20, {min:1, max:50});
		_materials = ini.getArray("materials");
		if (!(Std.is(_material, IFogMaterial))) {
			throw new Error("FogFilter requires IFogMaterial");
		}
		if (_material == null && _materials.length == 0) {
			_material = new ColorMaterial(0x000000);
		}
		//materials override subdivisions
		if (_materials.length == 0) {
			i = _subdivisions;
			while ((i-- > 0)) {
				_materials.push(_material.clone());
			}

		} else {
			_subdivisions = _materials.length;
		}
		i = _subdivisions;
		while ((i-- > 0)) {
			(cast(_materials[i], IFogMaterial)).alpha = 0.45 * i / _subdivisions;
			fog = new DrawFog();
			fog.screenZ = _minZ + (_maxZ - _minZ) * i / (_subdivisions - 1);
			fog.material = _materials[i];
			_fogPrimitives.unshift(fog);
		}

	}

	/**
	 * @inheritDoc
	 */
	public function filter(primitives:Array<Dynamic>, scene:Scene3D, camera:Camera3D, clip:Clipping):Array<Dynamic> {
		
		if (primitives.length == 0 || !primitives[0].source || primitives[0].source.session != scene.session) {
			return primitives;
		}
		for (__i in 0..._fogPrimitives.length) {
			fog = _fogPrimitives[__i];

			if (fog != null) {
				fog.source = scene;
				fog.clip = clip;
				primitives.push(fog);
			}
		}

		_primitives = [];
		for (__i in 0...primitives.length) {
			pri = primitives[__i];

			if (pri != null) {
				if (pri.screenZ < _maxZ) {
					_primitives.push(pri);
				}
			}
		}

		return _primitives;
	}

	/**
	 * Used to trace the values of a filter.
	 * 
	 * @return A string representation of the filter object.
	 */
	public function toString():String {
		
		return "FogFilter";
	}

}

