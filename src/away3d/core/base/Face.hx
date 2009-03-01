package away3d.core.base;

import flash.events.Event;
import away3d.core.utils.ValueObject;
import away3d.materials.IMaterial;
import flash.events.EventDispatcher;
import away3d.materials.ITriangleMaterial;
import away3d.core.utils.FaceVO;
import away3d.core.math.Number3D;
import away3d.events.FaceEvent;


/**
 * Dispatched when the uv mapping of the face changes.
 * 
 * @eventType away3d.events.FaceEvent
 */
// [Event(name="mappingChanged", type="away3d.events.FaceEvent")]

/**
 * Dispatched when the material of the face changes.
 * 
 * @eventType away3d.events.FaceEvent
 */
// [Event(name="materialChanged", type="away3d.events.FaceEvent")]

// use namespace arcane;

/**
 * A triangle element used in the mesh object
 * 
 * @see away3d.core.base.Mesh
 */
class Face extends Element  {
	public var normalDirty(null, setNormalDirty) : Bool;
	public var uvs(getUvs, null) : Array<Dynamic>;
	public var v0(getV0, setV0) : Vertex;
	public var v1(getV1, setV1) : Vertex;
	public var v2(getV2, setV2) : Vertex;
	public var material(getMaterial, setMaterial) : ITriangleMaterial;
	public var back(getBack, setBack) : ITriangleMaterial;
	public var uv0(getUv0, setUv0) : UV;
	public var uv1(getUv1, setUv1) : UV;
	public var uv2(getUv2, setUv2) : UV;
	public var area(getArea, null) : Float;
	public var normal(getNormal, null) : Number3D;
	
	/** @private */
	public var _v0:Vertex;
	/** @private */
	public var _v1:Vertex;
	/** @private */
	public var _v2:Vertex;
	/** @private */
	public var _uv0:UV;
	/** @private */
	public var _uv1:UV;
	/** @private */
	public var _uv2:UV;
	/** @private */
	public var _material:ITriangleMaterial;
	/** @private */
	public var _back:ITriangleMaterial;
	private var _normal:Number3D;
	private var _a:Float;
	private var _b:Float;
	private var _c:Float;
	private var _s:Float;
	private var _mappingchanged:FaceEvent;
	private var _materialchanged:FaceEvent;
	private var _index:Int;
	public var faceVO:FaceVO;
	

	/** @private */
	public function notifyMappingChange():Void {
		
		if (!hasEventListener(FaceEvent.MAPPING_CHANGED)) {
			return;
		}
		if (_mappingchanged == null) {
			_mappingchanged = new FaceEvent(FaceEvent.MAPPING_CHANGED, this);
		}
		dispatchEvent(_mappingchanged);
	}

	private function onUVChange(event:Event):Void {
		
		notifyMappingChange();
	}

	private function updateVertexProperties():Void {
		
		vertexDirty = false;
		var d1x:Float = _v1.x - _v0.x;
		var d1y:Float = _v1.y - _v0.y;
		var d1z:Float = _v1.z - _v0.z;
		var d2x:Float = _v2.x - _v0.x;
		var d2y:Float = _v2.y - _v0.y;
		var d2z:Float = _v2.z - _v0.z;
		var pa:Float = d1y * d2z - d1z * d2y;
		var pb:Float = d1z * d2x - d1x * d2z;
		var pc:Float = d1x * d2y - d1y * d2x;
		var pdd:Float = Math.sqrt(pa * pa + pb * pb + pc * pc);
		_normal.x = pa / pdd;
		_normal.y = pb / pdd;
		_normal.z = pc / pdd;
	}

	/**
	 * Forces the recalculation of the face normal
	 * @param bool      Boolean, forces the refresh of the normal calculation
	 */
	public function setNormalDirty(val:Bool):Bool {
		
		vertexDirty = true;
		return val;
	}

	/**
	 * Returns an array of vertex objects that are used by the face.
	 */
	public override function getVertices():Array<Dynamic> {
		
		return [_v0, _v1, _v2];
	}

	/**
	 * Returns an array of uv objects that are used by the face.
	 */
	public function getUvs():Array<Dynamic> {
		
		return [_uv0, _uv1, _uv2];
	}

	/**
	 * Defines the v0 vertex of the face.
	 */
	public function getV0():Vertex {
		
		return _v0;
	}

	public function setV0(value:Vertex):Vertex {
		
		if (_v0 == value) {
			return value;
		}
		if ((_v0 != null)) {
			_index = untyped _v0.parents.indexOf(this);
			if (_index != -1) {
				_v0.parents.splice(_index, 1);
			}
		}
		_v0 = faceVO.v0 = value;
		if ((_v0 != null)) {
			_v0.parents.push(this);
		}
		vertexDirty = true;
		return value;
	}

	/**
	 * Defines the v1 vertex of the face.
	 */
	public function getV1():Vertex {
		
		return _v1;
	}

	public function setV1(value:Vertex):Vertex {
		
		if (_v1 == value) {
			return value;
		}
		if ((_v1 != null)) {
			_index = untyped _v1.parents.indexOf(this);
			if (_index != -1) {
				_v1.parents.splice(_index, 1);
			}
		}
		_v1 = faceVO.v1 = value;
		if ((_v1 != null)) {
			_v1.parents.push(this);
		}
		vertexDirty = true;
		return value;
	}

	/**
	 * Defines the v2 vertex of the face.
	 */
	public function getV2():Vertex {
		
		return _v2;
	}

	public function setV2(value:Vertex):Vertex {
		
		if (_v2 == value) {
			return value;
		}
		if ((_v2 != null)) {
			_index = untyped _v2.parents.indexOf(this);
			if (_index != -1) {
				_v2.parents.splice(_index, 1);
			}
		}
		_v2 = faceVO.v2 = value;
		if ((_v2 != null)) {
			_v2.parents.push(this);
		}
		vertexDirty = true;
		return value;
	}

	/**
	 * Defines the material of the face.
	 */
	public function getMaterial():ITriangleMaterial {
		
		return _material;
	}

	public function setMaterial(value:ITriangleMaterial):ITriangleMaterial {
		
		if (value == _material) {
			return value;
		}
		if (_material != null && (parent != null)) {
			parent.removeMaterial(this, _material);
		}
		_material = faceVO.material = value;
		if (_material != null && (parent != null)) {
			parent.addMaterial(this, _material);
		}
		notifyMappingChange();
		return value;
	}

	/**
	 * Defines the optional back material of the face.
	 * Displays when the face is pointing away from the camera.
	 */
	public function getBack():ITriangleMaterial {
		
		return _back;
	}

	public function setBack(value:ITriangleMaterial):ITriangleMaterial {
		
		if (value == _back) {
			return value;
		}
		if (_back != null) {
			parent.removeMaterial(this, _back);
		}
		_back = faceVO.back = value;
		if (_back != null) {
			parent.addMaterial(this, _back);
		}
		notifyMappingChange();
		return value;
	}

	/**
	 * Defines the uv0 coordinate of the face.
	 */
	public function getUv0():UV {
		
		return _uv0;
	}

	public function setUv0(value:UV):UV {
		
		if (value == _uv0) {
			return value;
		}
		if (_uv0 != null) {
			if ((_uv0 != _uv1) && (_uv0 != _uv2)) {
				_uv0.removeOnChange(onUVChange);
			}
		}
		_uv0 = faceVO.uv0 = value;
		if (_uv0 != null) {
			if ((_uv0 != _uv1) && (_uv0 != _uv2)) {
				_uv0.addOnChange(onUVChange);
			}
		}
		notifyMappingChange();
		return value;
	}

	/**
	 * Defines the uv1 coordinate of the face.
	 */
	public function getUv1():UV {
		
		return _uv1;
	}

	public function setUv1(value:UV):UV {
		
		if (value == _uv1) {
			return value;
		}
		if (_uv1 != null) {
			if ((_uv1 != _uv0) && (_uv1 != _uv2)) {
				_uv1.removeOnChange(onUVChange);
			}
		}
		_uv1 = faceVO.uv1 = value;
		if (_uv1 != null) {
			if ((_uv1 != _uv0) && (_uv1 != _uv2)) {
				_uv1.addOnChange(onUVChange);
			}
		}
		notifyMappingChange();
		return value;
	}

	/**
	 * Defines the uv2 coordinate of the face.
	 */
	public function getUv2():UV {
		
		return _uv2;
	}

	public function setUv2(value:UV):UV {
		
		if (value == _uv2) {
			return value;
		}
		if (_uv2 != null) {
			if ((_uv2 != _uv1) && (_uv2 != _uv0)) {
				_uv2.removeOnChange(onUVChange);
			}
		}
		_uv2 = faceVO.uv2 = value;
		if (_uv2 != null) {
			if ((_uv2 != _uv1) && (_uv2 != _uv0)) {
				_uv2.addOnChange(onUVChange);
			}
		}
		notifyMappingChange();
		return value;
	}

	/**
	 * Returns the calculated 2 dimensional area of the face.
	 */
	public function getArea():Float {
		// not quick enough
		
		_a = v0.position.distance(v1.position);
		_b = v1.position.distance(v2.position);
		_c = v2.position.distance(v0.position);
		_s = (_a + _b + _c) / 2;
		return Math.sqrt(_s * (_s - _a) * (_s - _b) * (_s - _c));
	}

	/**
	 * Returns the normal vector of the face.
	 */
	public function getNormal():Number3D {
		
		if (vertexDirty) {
			updateVertexProperties();
		}
		return _normal;
	}

	/**
	 * Returns the squared bounding radius of the face.
	 */
	public override function getRadius2():Float {
		
		var rv0:Float = _v0._x * _v0._x + _v0._y * _v0._y + _v0._z * _v0._z;
		var rv1:Float = _v1._x * _v1._x + _v1._y * _v1._y + _v1._z * _v1._z;
		var rv2:Float = _v2._x * _v2._x + _v2._y * _v2._y + _v2._z * _v2._z;
		if (rv0 > rv1) {
			if (rv0 > rv2) {
				return rv0;
			} else {
				return rv2;
			}
		} else {
			if (rv1 > rv2) {
				return rv1;
			} else {
				return rv2;
			}
		}
		
		// autogenerated
		return 0;
	}

	/**
	 * Returns the maximum x value of the face
	 * 
	 * @see		away3d.core.base.Vertex#x
	 */
	public override function getMaxX():Float {
		
		if (_v0._x > _v1._x) {
			if (_v0._x > _v2._x) {
				return _v0._x;
			} else {
				return _v2._x;
			}
		} else {
			if (_v1._x > _v2._x) {
				return _v1._x;
			} else {
				return _v2._x;
			}
		}
		
		// autogenerated
		return 0;
	}

	/**
	 * Returns the minimum x value of the face
	 * 
	 * @see		away3d.core.base.Vertex#x
	 */
	public override function getMinX():Float {
		
		if (_v0._x < _v1._x) {
			if (_v0._x < _v2._x) {
				return _v0._x;
			} else {
				return _v2._x;
			}
		} else {
			if (_v1._x < _v2._x) {
				return _v1._x;
			} else {
				return _v2._x;
			}
		}
		
		// autogenerated
		return 0;
	}

	/**
	 * Returns the maximum y value of the face
	 * 
	 * @see		away3d.core.base.Vertex#y
	 */
	public override function getMaxY():Float {
		
		if (_v0._y > _v1._y) {
			if (_v0._y > _v2._y) {
				return _v0._y;
			} else {
				return _v2._y;
			}
		} else {
			if (_v1._y > _v2._y) {
				return _v1._y;
			} else {
				return _v2._y;
			}
		}
		
		// autogenerated
		return 0;
	}

	/**
	 * Returns the minimum y value of the face
	 * 
	 * @see		away3d.core.base.Vertex#y
	 */
	public override function getMinY():Float {
		
		if (_v0._y < _v1._y) {
			if (_v0._y < _v2._y) {
				return _v0._y;
			} else {
				return _v2._y;
			}
		} else {
			if (_v1._y < _v2._y) {
				return _v1._y;
			} else {
				return _v2._y;
			}
		}
		
		// autogenerated
		return 0;
	}

	/**
	 * Returns the maximum zx value of the face
	 * 
	 * @see		away3d.core.base.Vertex#z
	 */
	public override function getMaxZ():Float {
		
		if (_v0._z > _v1._z) {
			if (_v0._z > _v2._z) {
				return _v0._z;
			} else {
				return _v2._z;
			}
		} else {
			if (_v1._z > _v2._z) {
				return _v1._z;
			} else {
				return _v2._z;
			}
		}
		
		// autogenerated
		return 0;
	}

	/**
	 * Returns the minimum z value of the face
	 * 
	 * @see		away3d.core.base.Vertex#z
	 */
	public override function getMinZ():Float {
		
		if (_v0._z < _v1._z) {
			if (_v0._z < _v2._z) {
				return _v0._z;
			} else {
				return _v2._z;
			}
		} else {
			if (_v1._z < _v2._z) {
				return _v1._z;
			} else {
				return _v2._z;
			}
		}
		
		// autogenerated
		return 0;
	}

	/**
	 * Creates a new <code>Face</code> object.
	 *
	 * @param	v0						The first vertex object of the triangle
	 * @param	v1						The second vertex object of the triangle
	 * @param	v2						The third vertex object of the triangle
	 * @param	material	[optional]	The material used by the triangle to render
	 * @param	uv0			[optional]	The first uv object of the triangle
	 * @param	uv1			[optional]	The second uv object of the triangle
	 * @param	uv2			[optional]	The third uv object of the triangle
	 * 
	 * @see	away3d.core.base.Vertex
	 * @see	away3d.materials.ITriangleMaterial
	 * @see	away3d.core.base.UV
	 */
	public function new(v0:Vertex, v1:Vertex, v2:Vertex, ?material:ITriangleMaterial=null, ?uv0:UV=null, ?uv1:UV=null, ?uv2:UV=null) {
		// autogenerated
		super();
		this._normal = new Number3D();
		this.faceVO = new FaceVO();
		
		
		this.v0 = v0;
		this.v1 = v1;
		this.v2 = v2;
		this.material = material;
		this.uv0 = uv0;
		this.uv1 = uv1;
		this.uv2 = uv2;
		faceVO.face = this;
		vertexDirty = true;
	}

	/**
	 * Inverts the geometry of the face object by swapping the <code>v1</code>, <code>v2</code> and <code>uv1</code>, <code>uv2</code> points.
	 */
	public function invert():Void {
		
		var v1:Vertex = this._v1;
		var v2:Vertex = this._v2;
		var uv1:UV = this._uv1;
		var uv2:UV = this._uv2;
		this._v1 = v2;
		this._v2 = v1;
		this._uv1 = uv2;
		this._uv2 = uv1;
		notifyVertexChange();
		notifyMappingChange();
	}

	/**
	 * Default method for adding a mappingchanged event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnMappingChange(listener:Dynamic):Void {
		
		addEventListener(FaceEvent.MAPPING_CHANGED, listener, false, 0, true);
	}

	/**
	 * Default method for removing a mappingchanged event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnMappingChange(listener:Dynamic):Void {
		
		removeEventListener(FaceEvent.MAPPING_CHANGED, listener, false);
	}

}

