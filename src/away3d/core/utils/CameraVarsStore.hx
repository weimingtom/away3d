package away3d.core.utils;

import away3d.materials.ITriangleMaterial;
import flash.events.EventDispatcher;
import away3d.containers.View3D;
import away3d.haxeutils.HashMap;
import away3d.core.base.Face;
import away3d.core.base.Object3D;
import away3d.core.geom.Plane3D;
import away3d.core.render.AbstractRenderSession;
import away3d.core.base.UV;
import away3d.core.math.Matrix3D;
import away3d.core.base.Vertex;
import away3d.core.base.Element;
import away3d.core.base.VertexClassification;
import away3d.core.geom.Frustum;


class CameraVarsStore  {
	
	private var _sourceDictionary:HashMap<Object3D, HashMap<Vertex, VertexClassification>>;
	private var _vertexClassificationDictionary:HashMap<Vertex, VertexClassification>;
	private var _vt:Matrix3D;
	private var _frustum:Frustum;
	private var _vertex:Vertex;
	private var _uv:UV;
	private var _vc:VertexClassification;
	private var _faceVO:FaceVO;
	private var _v:Vertex;
	private var _source:Object3D;
	private var _session:AbstractRenderSession;
	private var _vtActive:Array<Matrix3D>;
	private var _vtStore:Array<Matrix3D>;
	private var _frActive:Array<Frustum>;
	private var _frStore:Array<Frustum>;
	private var _vActive:Array<Vertex>;
	private var _vStore:Array<Vertex>;
	private var _vcStore:Array<VertexClassification>;
	private var _vcArray:Array<VertexClassification>;
	private var _uvDictionary:HashMap<AbstractRenderSession, Array<UV>>;
	private var _uvArray:Array<UV>;
	private var _uvStore:Array<UV>;
	private var _fActive:Array<FaceVO>;
	private var _fStore:Array<FaceVO>;
	public var view:View3D;
	/**
	 * Dictionary of all objects transforms calulated from the camera view for the last render frame
	 */
	public var viewTransformDictionary:HashMap<Object3D, Matrix3D>;
	public var nodeClassificationDictionary:HashMap<Object3D, Int>;
	public var frustumDictionary:HashMap<Object3D, Frustum>;
	

	public function createVertexClassificationDictionary(source:Object3D):HashMap<Vertex, VertexClassification> {
		
		if ((_vertexClassificationDictionary = _sourceDictionary.get(source)) == null) {
			_vertexClassificationDictionary = _sourceDictionary.put(source, new HashMap<Vertex, VertexClassification>());
		}
		return _vertexClassificationDictionary;
	}

	public function createVertexClassification(vertex:Vertex):VertexClassification {
		
		if (((_vc = _vertexClassificationDictionary.get(vertex)) != null)) {
			return _vc;
		}
		if ((_vcStore.length > 0)) {
			_vc = _vertexClassificationDictionary.put(vertex, _vcStore.pop());
		} else {
			_vc = _vertexClassificationDictionary.put(vertex, new VertexClassification());
		}
		_vc.vertex = vertex;
		_vc.plane = null;
		return _vc;
	}

	public function createViewTransform(node:Object3D):Matrix3D {
		
		if ((_vtStore.length > 0)) {
			_vtActive.push(_vt = viewTransformDictionary.put(node, _vtStore.pop()));
		} else {
			_vtActive.push(_vt = viewTransformDictionary.put(node, new Matrix3D()));
		}
		return _vt;
	}

	public function createFrustum(node:Object3D):Frustum {
		
		if ((_frStore.length > 0)) {
			_frActive.push(_frustum = frustumDictionary.put(node, _frStore.pop()));
		} else {
			_frActive.push(_frustum = frustumDictionary.put(node, new Frustum()));
		}
		return _frustum;
	}

	public function createVertex(x:Float, y:Float, z:Float):Vertex {
		
		if ((_vStore.length > 0)) {
			_vActive.push(_vertex = _vStore.pop());
			_vertex.x = x;
			_vertex.y = y;
			_vertex.z = z;
		} else {
			_vActive.push(_vertex = new Vertex(x, y, z));
		}
		return _vertex;
	}

	public function createUV(u:Float, v:Float, session:AbstractRenderSession):UV {
		
		if ((_uvArray = _uvDictionary.get(session)) == null) {
			_uvArray = _uvDictionary.put(session, new Array<UV>());
		}
		if ((_uvStore.length > 0)) {
			_uvArray.push(_uv = _uvStore.pop());
			_uv.u = u;
			_uv.v = v;
		} else {
			_uvArray.push(_uv = new UV(u, v));
		}
		return _uv;
	}

	public function createFaceVO(face:Face, v0:Vertex, v1:Vertex, v2:Vertex, material:ITriangleMaterial, back:ITriangleMaterial, uv0:UV, uv1:UV, uv2:UV):FaceVO {
		
		if ((_fStore.length > 0)) {
			_fActive.push(_faceVO = _fStore.pop());
		} else {
			_fActive.push(_faceVO = new FaceVO());
		}
		_faceVO.face = face;
		_faceVO.v0 = v0;
		_faceVO.v1 = v1;
		_faceVO.v2 = v2;
		_faceVO.uv0 = uv0;
		_faceVO.uv1 = uv1;
		_faceVO.uv2 = uv2;
		_faceVO.material = material;
		_faceVO.back = back;
		_faceVO.generated = true;
		return _faceVO;
	}

	public function reset():Void {
		
		for (_source in _sourceDictionary.keys()) {
			if (_source.session != null && _source.session.updated) {
				for (_v in _sourceDictionary.get(_source).keys()) {
					_vcStore.push(_sourceDictionary.get(_source).get(_v));
					_sourceDictionary.get(_source).remove(_v);
					
				}
			}
		}

		nodeClassificationDictionary = new HashMap<Object3D, Int>();
		_vtStore = _vtStore.concat(_vtActive);
		_vtActive = new Array();
		_frStore = _frStore.concat(_frActive);
		_frActive = new Array();
		_vStore = _vStore.concat(_vActive);
		_vActive = new Array();
		for (_session in _uvDictionary.keys()) {
			if (_session.updated) {
				_uvStore = _uvStore.concat(_uvDictionary.get(_session));
				_uvDictionary.remove(_session);
			}
			
		}

		_fStore = _fStore.concat(_fActive);
		_fActive = new Array();
	}

	// autogenerated
	public function new () {
		this._sourceDictionary = new HashMap<Object3D, HashMap<Vertex, VertexClassification>>();
		this._vtActive = new Array<Matrix3D>();
		this._vtStore = new Array<Matrix3D>();
		this._frActive = new Array<Frustum>();
		this._frStore = new Array<Frustum>();
		this._vActive = new Array<Vertex>();
		this._vStore = new Array<Vertex>();
		this._vcStore = new Array<VertexClassification>();
		this._uvDictionary = new HashMap<AbstractRenderSession, Array<UV>>();
		this._uvStore = new Array<UV>();
		this._fActive = new Array<FaceVO>();
		this._fStore = new Array<FaceVO>();
		this.viewTransformDictionary = new HashMap<Object3D, Matrix3D>();
		this.frustumDictionary = new HashMap<Object3D, Frustum>();
		
	}

	

}

