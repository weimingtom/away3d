package away3d.core.utils;

import away3d.materials.ITriangleMaterial;
import flash.events.EventDispatcher;
import away3d.containers.View3D;
import flash.utils.Dictionary;
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
	
	private var _sourceDictionary:Dictionary;
	private var _vertexClassificationDictionary:Dictionary;
	private var _vt:Matrix3D;
	private var _frustum:Frustum;
	private var _vertex:Vertex;
	private var _uv:UV;
	private var _vc:VertexClassification;
	private var _faceVO:FaceVO;
	private var _object:Dynamic;
	private var _v:Dynamic;
	private var _source:Object3D;
	private var _session:AbstractRenderSession;
	private var _vtActive:Array<Dynamic>;
	private var _vtStore:Array<Dynamic>;
	private var _frActive:Array<Dynamic>;
	private var _frStore:Array<Dynamic>;
	private var _vActive:Array<Dynamic>;
	private var _vStore:Array<Dynamic>;
	private var _vcStore:Array<Dynamic>;
	private var _vcArray:Array<Dynamic>;
	private var _uvDictionary:Dictionary;
	private var _uvArray:Array<Dynamic>;
	private var _uvStore:Array<Dynamic>;
	private var _fActive:Array<Dynamic>;
	private var _fStore:Array<Dynamic>;
	public var view:View3D;
	/**
	 * Dictionary of all objects transforms calulated from the camera view for the last render frame
	 */
	public var viewTransformDictionary:Dictionary;
	public var nodeClassificationDictionary:Dictionary;
	public var frustumDictionary:Dictionary;
	

	public function createVertexClassificationDictionary(source:Object3D):Dictionary {
		
		if ((_vertexClassificationDictionary = _sourceDictionary[untyped source]) == null) {
			_vertexClassificationDictionary = _sourceDictionary[untyped source] = new Dictionary(true);
		}
		return _vertexClassificationDictionary;
	}

	public function createVertexClassification(vertex:Vertex):VertexClassification {
		
		if (((_vc = _vertexClassificationDictionary[untyped vertex]) != null)) {
			return _vc;
		}
		if ((_vcStore.length > 0)) {
			_vc = _vertexClassificationDictionary[untyped vertex] = _vcStore.pop();
		} else {
			_vc = _vertexClassificationDictionary[untyped vertex] = new VertexClassification();
		}
		_vc.vertex = vertex;
		_vc.plane = null;
		return _vc;
	}

	public function createViewTransform(node:Object3D):Matrix3D {
		
		if ((_vtStore.length > 0)) {
			_vtActive.push(_vt = viewTransformDictionary[untyped node] = _vtStore.pop());
		} else {
			_vtActive.push(_vt = viewTransformDictionary[untyped node] = new Matrix3D());
		}
		return _vt;
	}

	public function createFrustum(node:Object3D):Frustum {
		
		if ((_frStore.length > 0)) {
			_frActive.push(_frustum = frustumDictionary[untyped node] = _frStore.pop());
		} else {
			_frActive.push(_frustum = frustumDictionary[untyped node] = new Frustum());
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
		
		if ((_uvArray = _uvDictionary[untyped session]) == null) {
			_uvArray = _uvDictionary[untyped session] = [];
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
		
		var __keys:Iterator<Dynamic> = untyped (__keys__(_sourceDictionary)).iterator();
		for (_object in __keys) {
			_source = cast(_object, Object3D);
			if (_source.session != null && _source.session.updated) {
				var __keys:Iterator<Dynamic> = untyped (__keys__(_sourceDictionary[untyped _source])).iterator();
				for (_v in __keys) {
					_vcStore.push(_sourceDictionary[untyped _source][untyped _v]);
					_sourceDictionary[untyped _source][untyped _v] = null;
					
				}

			}
			
		}

		nodeClassificationDictionary = new Dictionary(true);
		_vtStore = _vtStore.concat(_vtActive);
		_vtActive = new Array();
		_frStore = _frStore.concat(_frActive);
		_frActive = new Array();
		_vStore = _vStore.concat(_vActive);
		_vActive = new Array();
		var __keys:Iterator<Dynamic> = untyped (__keys__(_uvDictionary)).iterator();
		for (_object in __keys) {
			_session = cast(_object, AbstractRenderSession);
			if (_session.updated) {
				_uvStore = _uvStore.concat(cast(_uvDictionary[untyped _session], Array<Dynamic>));
				_uvDictionary[untyped _session] = [];
			}
			
		}

		_fStore = _fStore.concat(_fActive);
		_fActive = new Array();
	}

	// autogenerated
	public function new () {
		this._sourceDictionary = new Dictionary(true);
		this._vtActive = new Array();
		this._vtStore = new Array();
		this._frActive = new Array();
		this._frStore = new Array();
		this._vActive = new Array();
		this._vStore = new Array();
		this._vcStore = new Array();
		this._uvDictionary = new Dictionary(true);
		this._uvStore = new Array();
		this._fActive = new Array();
		this._fStore = new Array();
		this.viewTransformDictionary = new Dictionary(true);
		this.frustumDictionary = new Dictionary(true);
		
	}

	

}

