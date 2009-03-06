package away3d.core.utils
{
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.geom.*;
	import away3d.core.math.*;
	import away3d.core.render.*;
	import away3d.materials.ITriangleMaterial;
	
	import flash.utils.*;
	
	public class CameraVarsStore
	{
		private var _sourceDictionary:Dictionary = new Dictionary(true);
        private var _vertexClassificationDictionary:Dictionary;
		private var _vt:MatrixAway3D;
		private var _frustum:Frustum;
		private var _vertex:Vertex;
		private var _uv:UV;
		private var _vc:VertexClassification;
		private var _faceVO:FaceVO;
		private var _object:Object;
		private var _v:Object;
		private var _source:Object3D;
		private var _session:AbstractRenderSession;
		private var _vtActive:Array = new Array();
        private var _vtStore:Array = new Array();
		private var _frActive:Array = new Array();
        private var _frStore:Array = new Array();
        private var _vActive:Array = new Array();
		private var _vStore:Array = new Array();
		private var _vcStore:Array = new Array();
		private var _vcArray:Array;
		private var _uvDictionary:Dictionary = new Dictionary(true);
		private var _uvArray:Array;
        private var _uvStore:Array = new Array();
        private var _fActive:Array = new Array();
        private var _fStore:Array = new Array();
		public var view:View3D;
    	
        /**
        * Dictionary of all objects transforms calulated from the camera view for the last render frame
        */
        public var viewTransformDictionary:Dictionary = new Dictionary(true);
        
        public var nodeClassificationDictionary:Dictionary;
        
        public var frustumDictionary:Dictionary = new Dictionary(true);
        
		public function createVertexClassificationDictionary(source:Object3D):Dictionary
		{
	        if (!(_vertexClassificationDictionary = _sourceDictionary[source]))
				_vertexClassificationDictionary = _sourceDictionary[source] = new Dictionary(true);
			
			return _vertexClassificationDictionary;
		}
		
        public function createVertexClassification(vertex:Vertex):VertexClassification
		{
			if ((_vc = _vertexClassificationDictionary[vertex]))
        		return _vc;
        	
			if (_vcStore.length) {
	        	_vc = _vertexClassificationDictionary[vertex] = _vcStore.pop();
	  		} else {
	        	_vc = _vertexClassificationDictionary[vertex] = new VertexClassification();
	    	}
	    	
	        _vc.vertex = vertex;
	        _vc.plane = null;
	        return _vc;
  		}
  		
		public function createViewTransform(node:Object3D):MatrixAway3D
        {
        	if (_vtStore.length)
        		_vtActive.push(_vt = viewTransformDictionary[node] = _vtStore.pop());
        	else
        		_vtActive.push(_vt = viewTransformDictionary[node] = new MatrixAway3D());
        	
        	return _vt;
        }
        
		public function createFrustum(node:Object3D):Frustum
        {
        	if (_frStore.length)
        		_frActive.push(_frustum = frustumDictionary[node] = _frStore.pop());
        	else
        		_frActive.push(_frustum = frustumDictionary[node] = new Frustum());
        	
        	return _frustum;
        }
        
		public function createVertex(x:Number, y:Number, z:Number):Vertex
        {
        	if (_vStore.length) {
        		_vActive.push(_vertex = _vStore.pop());
        		_vertex.x = x;
        		_vertex.y = y;
        		_vertex.z = z;
        	} else {
        		_vActive.push(_vertex = new Vertex(x, y, z));
        	}
        	
        	return _vertex;
        }
        
		public function createUV(u:Number, v:Number, session:AbstractRenderSession):UV
        {
        	if (!(_uvArray = _uvDictionary[session]))
				_uvArray = _uvDictionary[session] = [];
			
        	if (_uvStore.length) {
        		_uvArray.push(_uv = _uvStore.pop());
        		_uv.u = u;
        		_uv.v = v;
        	} else
        		_uvArray.push(_uv = new UV(u, v));
        	
        	return _uv;
        }
        
        public function createFaceVO(face:Face, v0:Vertex, v1:Vertex, v2:Vertex, material:ITriangleMaterial, back:ITriangleMaterial, uv0:UV, uv1:UV, uv2:UV):FaceVO
        {
        	if (_fStore.length)
        		_fActive.push(_faceVO = _fStore.pop());
        	else
        		_fActive.push(_faceVO = new FaceVO());
        	
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
        
        public function reset():void
        {
        	
        	for (_object in _sourceDictionary) {
				_source = _object as Object3D;
				if (_source.session && _source.session.updated) {
					for (_v in _sourceDictionary[_source]) {
						_vcStore.push(_sourceDictionary[_source][_v]);
						delete _sourceDictionary[_source][_v];
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
        	
        	for (_object in _uvDictionary) {
				_session = _object as AbstractRenderSession;
				if (_session.updated) {
					_uvStore = _uvStore.concat(_uvDictionary[_session] as Array);
					_uvDictionary[_session] = [];
				}
			}
			
			_fStore = _fStore.concat(_fActive);
        	_fActive = new Array();
        }
	}
}