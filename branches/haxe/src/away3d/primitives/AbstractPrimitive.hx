package away3d.primitives;

import away3d.materials.IMaterial;
import away3d.materials.ITriangleMaterial;
import away3d.core.base.Face;
import away3d.core.base.Mesh;
import away3d.core.base.UV;
import away3d.core.base.Vertex;
import away3d.core.base.Element;


// use namespace arcane;

/**
 * Abstract base class for shaded primitives
 */
class AbstractPrimitive extends Mesh  {
	
	/** @private */
	public var _v:Vertex;
	/** @private */
	public var _vStore:Array<Dynamic>;
	/** @private */
	public var _vActive:Array<Dynamic>;
	/** @private */
	public var _uv:UV;
	/** @private */
	public var _uvStore:Array<Dynamic>;
	/** @private */
	public var _uvActive:Array<Dynamic>;
	/** @private */
	public var __face:Face;
	/** @private */
	public var _faceStore:Array<Dynamic>;
	/** @private */
	public var _faceActive:Array<Dynamic>;
	/** @private */
	public var _primitiveDirty:Bool;
	private var _index:Int;
	

	/** @private */
	public function createVertex(?x:Float=0, ?y:Float=0, ?z:Float=0):Vertex {
		
		if ((_vStore.length > 0)) {
			_vActive.push(_v = _vStore.pop());
			_v._x = x;
			_v._y = y;
			_v._z = z;
		} else {
			_vActive.push(_v = new Vertex(x, y, z));
		}
		return _v;
	}

	/** @private */
	public function createUV(?u:Float=0, ?v:Float=0):UV {
		
		if ((_uvStore.length > 0)) {
			_uvActive.push(_uv = _uvStore.pop());
			_uv.u = u;
			_uv.v = v;
		} else {
			_uvActive.push(_uv = new UV(u, v));
		}
		return _uv;
	}

	/** @private */
	public function createFace(v0:Vertex, v1:Vertex, v2:Vertex, ?material:ITriangleMaterial=null, ?uv0:UV=null, ?uv1:UV=null, ?uv2:UV=null):Face {
		
		if ((_faceStore.length > 0)) {
			_faceActive.push(__face = _faceStore.pop());
			__face.v0 = v0;
			__face.v1 = v1;
			__face.v2 = v2;
			__face.material = material;
			__face.uv0 = uv0;
			__face.uv1 = uv1;
			__face.uv2 = uv2;
		} else {
			_faceActive.push(__face = new Face(v0, v1, v2, material, uv0, uv1, uv2));
		}
		return __face;
	}

	/**
	 * Creates a new <code>AbstractPrimitive</code> object.
	 *
	 * @param	init			[optional]	An initialisation object for specifying default instance properties
	 */
	public function new(?init:Dynamic=null) {
		this._vStore = new Array<Dynamic>();
		this._vActive = new Array<Dynamic>();
		this._uvStore = new Array<Dynamic>();
		this._uvActive = new Array<Dynamic>();
		this._faceStore = new Array<Dynamic>();
		this._faceActive = new Array<Dynamic>();
		
		
		super(init);
	}

	public override function updateObject():Void {
		
		if (_primitiveDirty) {
			buildPrimitive();
		}
		super.updateObject();
	}

	/**
	 * Builds the vertex, face and uv objects that make up the 3d primitive.
	 */
	public function buildPrimitive():Void {
		
		_primitiveDirty = false;
		_objectDirty = true;
		//remove all elements from the mesh
		_index = faces.length;
		while ((_index-- > 0)) {
			removeFace(faces[_index]);
		}

		//clear vertex objects
		_vStore = _vStore.concat(_vActive);
		_vActive = [];
		//clear uv objects
		_uvStore = _uvStore.concat(_uvActive);
		_uvActive = [];
		//clear face objects
		_faceStore = _faceStore.concat(_faceActive);
		_faceActive = [];
	}

}

