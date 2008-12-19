package away3d.core.project
{
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.math.*;
	import away3d.core.utils.*;
	import away3d.materials.*;
	
	public class FaceProjector extends AbstractProjector implements IPrimitiveProvider
	{
		private var _mesh:Mesh;
		private var _triangleMaterial:ITriangleMaterial;
		private var _vertex:Vertex;
		private var _screenVertex:ScreenVertex;
		private var _face:Face;
		private var _tri:DrawTriangle;
		private var _drawTriangle:DrawTriangle;
		private var _triangles:Array;
		private var _clippedTriangles:Array;
		private var _backmat:ITriangleMaterial;
        private var _backface:Boolean;
        private var _uvmaterial:Boolean;
        private var _vt:ScreenVertex;
        private var _uvt:UV;
        private var _dtStore:Array = new Array();
        private var _dtActive:Array = new Array();
		private var _n01:Face;
		private var _n12:Face;
		private var _n20:Face;
		private var _sv0:ScreenVertex;
		private var _sv1:ScreenVertex;
		private var _sv2:ScreenVertex;
		
        private function front(face:Face):Number
        {
            _sv0 = primitiveDictionary[face.v0];
            _sv1 = primitiveDictionary[face.v1];
            _sv2 = primitiveDictionary[face.v2];
            
            return (_sv0.x*(_sv2.y - _sv1.y) + _sv1.x*(_sv0.y - _sv2.y) + _sv2.x*(_sv1.y - _sv0.y));
        }
        
		public override function primitives(view:View3D, viewTransform:Matrix3D, consumer:IPrimitiveConsumer):void
		{
			super.primitives(view, viewTransform, consumer);
			
			_mesh = source as Mesh;
			
			if (!_mesh)
				Debug.error("FaceProjector must process a Mesh object");
			
			_triangleMaterial = _mesh.material as ITriangleMaterial;
			
			if (!_triangleMaterial && _mesh.material)
				Debug.error("FaceProjector mesh material must be an ITriangleMaterial");
			
			for each (_vertex in _mesh.vertices) {
				if (!(_screenVertex = primitiveDictionary[_vertex]))
					_screenVertex = primitiveDictionary[_vertex] = new ScreenVertex();
				
				view.camera.lens.project(viewTransform, _vertex, _screenVertex);
			}
			
			_backmat = _mesh.back || _triangleMaterial;
			
			_triangles = new Array();
			
            for each (_face in _mesh.faces)
            {
                if (!_face.visible)
                    continue;
				
				_sv0 = primitiveDictionary[_face.v0];
				_sv1 = primitiveDictionary[_face.v1];
				_sv2 = primitiveDictionary[_face.v2];
				
                if (!_sv0.visible && !_sv1.visible && !_sv2.visible)
                    continue;
				
				
            	if (!(_drawTriangle = primitiveDictionary[_face])) {
					_drawTriangle = primitiveDictionary[_face] = new DrawTriangle();
	            	_drawTriangle.view = view;
	            	_drawTriangle.source = _mesh;
	            	_drawTriangle.face = _face;
	            	_drawTriangle.create = createDrawTriangle;
            	}
				
				_drawTriangle.v0 = _sv0;
				_drawTriangle.v1 = _sv1;
				_drawTriangle.v2 = _sv2;
				_drawTriangle.uv0 = _face.uv0;
	            _drawTriangle.uv1 = _face.uv1;
	            _drawTriangle.uv2 = _face.uv2;
	            
				_clippedTriangles = view.clipping.check(_drawTriangle);
				
				for each (_tri in _clippedTriangles)
					_triangles.push(_tri);
            }
            
            for each (_tri in _triangles) {
				
				//calculate Draw_triangle properties
                _tri.calc();
                
				//determine if _triangle is facing towards or away from camera
                _backface = _tri.area < 0;
				
				//if _triangle facing away, check for backface material
                if (_backface) {
                    if (!_mesh.bothsides)
                    	continue;
                    
                    _tri.material = _face.back;
                    
                    if (_tri.material == null)
                    	_tri.material = _face.material;
                } else {
                    _tri.material = _face.material;
                }
                
				//determine the material of the _triangle
                if (_tri.material == null) {
                    if (_backface)
                        _tri.material = _backmat;
                    else
                        _tri.material = _triangleMaterial;
                }
                
				//do not draw material if visible is false
                if (_tri.material != null && !_tri.material.visible)
                    _tri.material = null;
				
				//if there is no material and no outline, continue
                if (_mesh.outline == null && _tri.material == null)
                        continue;
				
                if (_mesh.pushback)
                    _tri.screenZ = _tri.maxZ;
				
                if (_mesh.pushfront)
                    _tri.screenZ = _tri.minZ;
				
				_uvmaterial = (_tri.material is IUVMaterial || _tri.material is ILayerMaterial);
				
				//swap ScreenVerticies if _triangle facing away from camera
                if (_backface) {
                    _vt = _tri.v1;
                    _tri.v1 = _tri.v2;
                    _tri.v2 = _vt;
					
                    _tri.area = -_tri.area;
                    
                    if (_uvmaterial) {
						//pass accross uv values
						_uvt = _tri.uv1;
						_tri.uv1 = _tri.uv2;
                    	_tri.uv2 = _uvt;
                    }
                }
				
                //check if face swapped direction
                if (_tri.backface != _backface) {
                	_tri.backface = _backface;
                	if (_tri.material is IUVMaterial)
                		(_tri.material as IUVMaterial).getFaceVO(_tri.face, _mesh, view).texturemapping = null;
                }
				
                if (_mesh.outline != null && !_backface)
                {
                    _n01 = _mesh.geometry.neighbour01(_face);
                    if (_n01 == null || front(_n01) <= 0)
                    	consumer.primitive(createDrawSegment(view, _mesh, _mesh.outline, _tri.v0, _tri.v1));
					
                    _n12 = _mesh.geometry.neighbour12(_face);
                    if (_n12 == null || front(_n12) <= 0)
                    	consumer.primitive(createDrawSegment(view, _mesh, _mesh.outline, _tri.v1, _tri.v2));
					
                    _n20 = _mesh.geometry.neighbour20(_face);
                    if (_n20 == null || front(_n20) <= 0)
                    	consumer.primitive(createDrawSegment(view, _mesh, _mesh.outline, _tri.v2, _tri.v0));
					
                    if (_tri.material == null)
                    	continue;
                }
                
                consumer.primitive(_tri);
            }
		}
		
		public function clone():IPrimitiveProvider
		{
			return new FaceProjector();
		}
	}
}