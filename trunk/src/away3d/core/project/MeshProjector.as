package away3d.core.project
{
	import away3d.cameras.*;
	import away3d.cameras.lenses.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.clip.*;
	import away3d.core.draw.*;
	import away3d.core.geom.*;
	import away3d.core.math.*;
	import away3d.core.utils.*;
	import away3d.materials.*;
	
	public class MeshProjector implements IPrimitiveProvider
	{
		private var _view:View3D;
		private var _drawPrimitiveStore:DrawPrimitiveStore;
		private var _cameraVarsStore:CameraVarsStore;
		private var _screenArray:Array;
		private var _screenIndexStart:int;
		private var _screenIndexEnd:int;
		private var _mesh:Mesh;
		private var _vertex:Vertex;
		private var _screenVertex:ScreenVertex;
		private var _clipFlag:Boolean;
		private var _faces:Array;
		private var _clippedFaceVOs:Array = new Array();
		private var _segments:Array;
		private var _clippedSegmentVOs:Array = new Array();
		private var _billboards:Array;
		private var _clippedBillboards:Array = new Array();
		private var _camera:Camera3D;
		private var _clipping:Clipping;
		private var _lens:ILens;
		private var _focus:Number;
		private var _zoom:Number;
		private var _faceMaterial:ITriangleMaterial;
		private var _segmentMaterial:ISegmentMaterial;
		private var _billboardMaterial:IBillboardMaterial;
		private var _face:Face;
		private var _faceVO:FaceVO;
		private var _tri:DrawTriangle;
        private var _backface:Boolean;
		private var _backmat:ITriangleMaterial;
		private var _segment:Segment;
		private var _segmentVO:SegmentVO;
		private var _seg:DrawSegment;
		private var _smaterial:ISegmentMaterial;
		private var _billboard:Billboard;
		private var _bmaterial:IBillboardMaterial;
		private var _n01:Face;
		private var _n12:Face;
		private var _n20:Face;
		
		private var _sStart:int;
		private var _sv0:ScreenVertex;
		private var _sv1:ScreenVertex;
		private var _sv2:ScreenVertex;
		
		private var i:int;
		
        private function front(face:Face, viewTransform:Matrix3D):Number
        {
        	_sStart = _screenArray.length;
        	
            _lens.project(viewTransform, face.vertices);
            
            _sv0 = _screenArray[_sStart];
            _sv1 = _screenArray[_sStart+1];
            _sv2 = _screenArray[_sStart+2];
            
            return (_sv0.x*(_sv2.y - _sv1.y) + _sv1.x*(_sv0.y - _sv2.y) + _sv2.x*(_sv1.y - _sv0.y));
        }
        
        public function get view():View3D
        {
        	return _view;
        }
        public function set view(val:View3D):void
        {
        	_view = val;
        	_drawPrimitiveStore = view.drawPrimitiveStore;
        	_cameraVarsStore = view.cameraVarsStore;
        }
        
		public function primitives(source:Object3D, viewTransform:Matrix3D, consumer:IPrimitiveConsumer):void
		{
			_screenArray = _drawPrimitiveStore.createScreenArray(source);
			_cameraVarsStore.createVertexClassificationDictionary(source);
			_screenIndexStart = 0;
			
			_mesh = source as Mesh;
			_faces = _mesh.faces;
			_segments = _mesh.segments;
			_billboards = _mesh.billboards;
			
			_camera = _view.camera;
			_clipping = _view.screenClipping;
			_lens = _camera.lens;
        	_focus = _camera.focus;
        	_zoom = _camera.zoom;
        	
			_faceMaterial = _mesh.faceMaterial;
			_segmentMaterial = _mesh.segmentMaterial;
			_billboardMaterial = _mesh.billboardMaterial;
			
			_backmat = _mesh.back || _faceMaterial;
			
			if (_cameraVarsStore.nodeClassificationDictionary[source] == Frustum.INTERSECT)
				_clipFlag = true;
			else
				_clipFlag = false;
			
			_clippedFaceVOs.length = 0;
			
			//loop through all faces
            for each (_face in _faces)
            {
                 if (!_face.visible)
                    continue;
                
                //check if a face needs clipping
                if (_clipFlag)
                	_clipping.checkFace(_face.faceVO, source, _clippedFaceVOs);
                else
                	_clippedFaceVOs[_clippedFaceVOs.length] = _face.faceVO;
            }
			
            for each (_faceVO in _clippedFaceVOs) {
				
				_screenIndexStart = _screenArray.length;
				
				if (!_lens.project(viewTransform, _faceVO.vertices))
                    continue;
                
                _screenIndexEnd = _screenArray.length;
                
            	_face = _faceVO.face;
            	
            	_tri = _drawPrimitiveStore.createDrawTriangle(source, _faceVO, null, _screenArray, _screenIndexStart, _screenIndexEnd, _faceVO.uv0, _faceVO.uv1, _faceVO.uv2, _faceVO.generated);
				//determine if _triangle is facing towards or away from camera
                
                _backface = _tri.backface = _tri.area < 0;
				
				//if _triangle facing away, check for backface material
                if (_backface) {
                    if (!_mesh.bothsides)
                    	continue;
                    
                    _tri.material = _faceVO.back;
                    
                    if (!_tri.material)
                    	_tri.material = _faceVO.material;
                } else {
                    _tri.material = _faceVO.material;
                }
                
				//determine the material of the _triangle
                if (!_tri.material) {
                    if (_backface)
                        _tri.material = _backmat;
                    else
                        _tri.material = _faceMaterial;
                }
                
				//do not draw material if visible is false
                if (_tri.material && !_tri.material.visible)
                    _tri.material = null;
				
				//if there is no material and no outline, continue
                if (!_mesh.outline && !_tri.material)
                	continue;
                
                //check whether screenClipping removes triangle
                if (!consumer.primitive(_tri))
                	continue;
				
                if (_mesh.pushback)
                    _tri.screenZ = _tri.maxZ;
				
                if (_mesh.pushfront)
                    _tri.screenZ = _tri.minZ;
				
				_tri.screenZ += _mesh.screenZOffset;
				
                if (_mesh.outline && !_backface)
                {
                    _n01 = _mesh.geometry.neighbour01(_face);
                    if (_n01 == null || front(_n01, viewTransform) <= 0)
                    	consumer.primitive(_drawPrimitiveStore.createDrawSegment(source, _faceVO, _mesh.outline, _screenArray, _screenIndexStart, _screenIndexEnd-1));
					
                    _n12 = _mesh.geometry.neighbour12(_face);
                    if (_n12 == null || front(_n12, viewTransform) <= 0)
                    	consumer.primitive(_drawPrimitiveStore.createDrawSegment(source, _faceVO, _mesh.outline, _screenArray, _screenIndexStart+1, _screenIndexEnd));
					
                    _n20 = _mesh.geometry.neighbour20(_face);
                    if (_n20 == null || front(_n20, viewTransform) <= 0)
                    	consumer.primitive(_drawPrimitiveStore.createDrawSegment(source, _faceVO, _mesh.outline, [_tri.v2, _tri.v0], 0, 2));
                }
            }
            
            _clippedSegmentVOs.length = 0;
            
            //loop through all segments
            for each (_segment in _segments)
            {
                 if (!_segment.visible)
                    continue;
                
                //check if a face needs clipping
                if (_clipFlag)
                	_clipping.checkSegment(_segment.segmentVO, source, _clippedSegmentVOs);
                else
                	_clippedSegmentVOs[_clippedSegmentVOs.length] = _segment.segmentVO;
            }
            
            for each (_segmentVO in _clippedSegmentVOs)
            {
            	
				_screenIndexStart = _screenArray.length;
				
				if (!_lens.project(viewTransform, _segmentVO.vertices))
                    continue;
                
                _screenIndexEnd = _screenArray.length;
				
            	_smaterial = _segmentVO.material || _segmentMaterial;
				
                if (!_smaterial.visible)
                    continue;
                
                _seg = _drawPrimitiveStore.createDrawSegment(source, _segmentVO, _smaterial, _screenArray, _screenIndexStart, _screenIndexEnd)
                
                //check whether screenClipping removes segment
                if (!consumer.primitive(_seg))
                	continue;
				
                if (_mesh.pushback)
                    _seg.screenZ = _seg.maxZ;
				
                if (_mesh.pushfront)
                    _seg.screenZ = _seg.minZ;
                
				_tri.screenZ += _mesh.screenZOffset;
            }
            
            _clippedBillboards.length = 0;
            
			//loop through all billboards
            for each (_billboard in _billboards)
            {
                 if (!_billboard.visible)
                    continue;
                
                //check if a billboard needs clipping
                if (_clipFlag)
                	_clipping.checkBillboard(_billboard, source, _clippedBillboards);
                else
                	_clippedBillboards[_clippedBillboards.length] = _billboard;
            }
            
            //loop through all clipped billboards
            for each (_billboard in _clippedBillboards)
            {
            	_screenIndexStart = _screenArray.length;
            	
				if (!_lens.project(viewTransform, _billboard.vertices))
                    continue;
                
                _bmaterial = _billboard.material || _billboardMaterial;
                
                if (!_bmaterial.visible)
                    continue;
		        
		        _sv0 = _screenArray[_screenIndexStart];
		        
	            consumer.primitive(_drawPrimitiveStore.createDrawBillboard(source, _bmaterial, _sv0, _billboard.width, _billboard.height, _billboard.scaling*_zoom / (1 + _sv0.z / _focus), _billboard.rotation));
            }
		}
	}
}