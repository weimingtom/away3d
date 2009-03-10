package away3d.core.project;

import away3d.materials.IMaterial;
import away3d.core.utils.CameraVarsStore;
import flash.events.EventDispatcher;
import away3d.core.base.Billboard;
import away3d.core.base.Segment;
import away3d.materials.ILayerMaterial;
import away3d.materials.ITriangleMaterial;
import away3d.materials.ISegmentMaterial;
import away3d.containers.View3D;
import flash.utils.Dictionary;
import away3d.cameras.Camera3D;
import away3d.core.base.Face;
import away3d.core.draw.DrawBillboard;
import away3d.core.utils.DrawPrimitiveStore;
import away3d.core.draw.DrawSegment;
import away3d.core.draw.IPrimitiveConsumer;
import away3d.core.draw.ScreenVertex;
import away3d.core.clip.Clipping;
import away3d.core.base.Object3D;
import away3d.cameras.lenses.ILens;
import away3d.core.base.Mesh;
import away3d.core.draw.IPrimitiveProvider;
import away3d.core.utils.FaceVO;
import away3d.core.utils.FaceMaterialVO;
import flash.display.Sprite;
import away3d.materials.IBillboardMaterial;
import away3d.core.draw.DrawTriangle;
import away3d.core.draw.DrawPrimitive;
import away3d.core.base.UV;
import away3d.core.math.Matrix3D;
import away3d.core.base.Vertex;
import away3d.core.base.Element;
import away3d.core.geom.Frustum;


class MeshProjector implements IPrimitiveProvider {
	public var view(getView, setView) : View3D;
	
	private var _view:View3D;
	private var _drawPrimitiveStore:DrawPrimitiveStore;
	private var _cameraVarsStore:CameraVarsStore;
	private var _mesh:Mesh;
	private var _frustumClipping:Bool;
	private var _frustum:Frustum;
	private var _vertices:Array<Dynamic>;
	private var _faces:Array<Dynamic>;
	private var _triangles:Array<Dynamic>;
	private var _clipFaceVOs:Bool;
	private var _clippedFaceVOs:Array<Dynamic>;
	private var _segments:Array<Dynamic>;
	private var _billboards:Array<Dynamic>;
	private var _camera:Camera3D;
	private var _clipping:Clipping;
	private var _lens:ILens;
	private var _focus:Float;
	private var _zoom:Float;
	private var _faceMaterial:ITriangleMaterial;
	private var _segmentMaterial:ISegmentMaterial;
	private var _billboardMaterial:IBillboardMaterial;
	private var _vertex:Vertex;
	private var _face:Face;
	private var _faceVO:FaceVO;
	private var _tri:DrawTriangle;
	private var _layerMaterial:ILayerMaterial;
	private var _faceMaterialVO:FaceMaterialVO;
	private var _uvt:UV;
	private var _smaterial:ISegmentMaterial;
	private var _bmaterial:IBillboardMaterial;
	private var _segment:Segment;
	private var _billboard:Billboard;
	private var _drawTriangle:DrawTriangle;
	private var _drawSegment:DrawSegment;
	private var _drawBillBoard:DrawBillboard;
	private var _backmat:ITriangleMaterial;
	private var _backface:Bool;
	private var _uvmaterial:Bool;
	private var _vt:ScreenVertex;
	private var _n01:Face;
	private var _n12:Face;
	private var _n20:Face;
	private var _sv0:ScreenVertex;
	private var _sv1:ScreenVertex;
	private var _sv2:ScreenVertex;
	

	private function front(face:Face, viewTransform:Matrix3D):Float {
		
		_sv0 = _lens.project(viewTransform, face.v0);
		_sv1 = _lens.project(viewTransform, face.v1);
		_sv2 = _lens.project(viewTransform, face.v2);
		return (_sv0.x * (_sv2.y - _sv1.y) + _sv1.x * (_sv0.y - _sv2.y) + _sv2.x * (_sv1.y - _sv0.y));
	}

	public function getView():View3D {
		
		return _view;
	}

	public function setView(val:View3D):View3D {
		
		_view = val;
		_drawPrimitiveStore = view.drawPrimitiveStore;
		_cameraVarsStore = view.cameraVarsStore;
		return val;
	}

	public function primitives(source:Object3D, viewTransform:Matrix3D, consumer:IPrimitiveConsumer):Void {
		
		_drawPrimitiveStore.createVertexDictionary(source);
		_cameraVarsStore.createVertexClassificationDictionary(source);
		_mesh = cast(source, Mesh);
		_vertices = _mesh.vertices;
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
		_backmat = _mesh.back;
		if (_backmat == null)  {
			_backmat = _faceMaterial;
		};
		_clippedFaceVOs = new Array<Dynamic>();
		if (_cameraVarsStore.nodeClassificationDictionary[untyped source] == Frustum.INTERSECT) {
			_clipFaceVOs = true;
		} else {
			_clipFaceVOs = false;
		}
		//loop through all faces
		for (__i in 0..._faces.length) {
			_face = _faces[__i];

			if (_face != null) {
				if (!_face.visible) {
					continue;
				}
				//check if a face needs clipping
				if (_clipFaceVOs) {
					_clipping.checkFace(_face.faceVO, source, _clippedFaceVOs);
				} else {
					_clippedFaceVOs.push(_face.faceVO);
				}
			}
		}

		for (__i in 0..._clippedFaceVOs.length) {
			_faceVO = _clippedFaceVOs[__i];

			if (_faceVO != null) {
				_sv0 = _lens.project(viewTransform, _faceVO.v0);
				_sv1 = _lens.project(viewTransform, _faceVO.v1);
				_sv2 = _lens.project(viewTransform, _faceVO.v2);
				if (!_sv0.visible || !_sv1.visible || !_sv2.visible) {
					continue;
				}
				_face = _faceVO.face;
				_tri = _drawPrimitiveStore.createDrawTriangle(source, _faceVO, null, _sv0, _sv1, _sv2, _faceVO.uv0, _faceVO.uv1, _faceVO.uv2, _faceVO.generated);
				//determine if _triangle is facing towards or away from camera
				_backface = _tri.backface = _tri.area < 0;
				//if _triangle facing away, check for backface material
				if (_backface) {
					if (!_mesh.bothsides) {
						continue;
					}
					_tri.material = _faceVO.back;
					if ((_tri.material == null)) {
						_tri.material = _faceVO.material;
					}
				} else {
					_tri.material = _faceVO.material;
				}
				//determine the material of the _triangle
				if (_tri.material == null) {
					if (_backface) {
						_tri.material = _backmat;
					} else {
						_tri.material = _faceMaterial;
					}
				}
				//do not draw material if visible is false
				if ((_tri.material != null) && !_tri.material.visible) {
					_tri.material = null;
				}
				//if there is no material and no outline, continue
				if ((_mesh.outline == null) && (_tri.material == null)) {
					continue;
				}
				//check whether screenClipping removes triangle
				if (!consumer.primitive(_tri)) {
					continue;
				}
				if (_mesh.pushback) {
					_tri.screenZ = _tri.maxZ;
				}
				if (_mesh.pushfront) {
					_tri.screenZ = _tri.minZ;
				}
				if ((_mesh.outline != null) && !_backface) {
					_n01 = _mesh.geometry.neighbour01(_face);
					if (_n01 == null || front(_n01, viewTransform) <= 0) {
						consumer.primitive(_drawPrimitiveStore.createDrawSegment(source, _mesh.outline, _tri.v0, _tri.v1));
					}
					_n12 = _mesh.geometry.neighbour12(_face);
					if (_n12 == null || front(_n12, viewTransform) <= 0) {
						consumer.primitive(_drawPrimitiveStore.createDrawSegment(source, _mesh.outline, _tri.v1, _tri.v2));
					}
					_n20 = _mesh.geometry.neighbour20(_face);
					if (_n20 == null || front(_n20, viewTransform) <= 0) {
						consumer.primitive(_drawPrimitiveStore.createDrawSegment(source, _mesh.outline, _tri.v2, _tri.v0));
					}
				}
			}
		}

		//loop through all segments
		for (__i in 0..._segments.length) {
			_segment = _segments[__i];

			if (_segment != null) {
				_sv0 = _lens.project(viewTransform, _segment.v0);
				_sv1 = _lens.project(viewTransform, _segment.v1);
				if (!_sv0.visible || !_sv1.visible) {
					continue;
				}
				_smaterial = _segment.material;
				if (_smaterial == null)  {
					_smaterial = _segmentMaterial;
				};
				if (!_smaterial.visible) {
					continue;
				}
				consumer.primitive(_drawPrimitiveStore.createDrawSegment(source, _smaterial, _sv0, _sv1));
			}
		}

		//loop through all billboards
		for (__i in 0..._billboards.length) {
			_billboard = _billboards[__i];

			if (_billboard != null) {
				if (!_billboard.visible) {
					continue;
				}
				_sv0 = _lens.project(viewTransform, _billboard.vertex);
				if (!_sv0.visible) {
					continue;
				}
				_bmaterial = _billboard.material;
				if (_bmaterial == null)  {
					_bmaterial = _billboardMaterial;
				};
				if (!_bmaterial.visible) {
					continue;
				}
				consumer.primitive(_drawPrimitiveStore.createDrawBillboard(source, _bmaterial, _sv0, _billboard.width, _billboard.height, _billboard.scaling * _zoom / (1 + _sv0.z / _focus), _billboard.rotation));
			}
		}

	}

	// autogenerated
	public function new () {
		
	}

	

}

