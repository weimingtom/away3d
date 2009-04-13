package away3d.core.utils;

import away3d.core.block.ConvexBlocker;
import away3d.materials.IMaterial;
import flash.events.EventDispatcher;
import flash.display.BitmapData;
import away3d.materials.ITriangleMaterial;
import away3d.materials.ISegmentMaterial;
import away3d.containers.View3D;
import away3d.haxeutils.HashMap;
import away3d.core.draw.DrawScaledBitmap;
import away3d.core.draw.DrawBillboard;
import away3d.core.draw.DrawSegment;
import away3d.core.draw.ScreenVertex;
import away3d.core.base.Object3D;
import flash.display.DisplayObject;
import away3d.core.render.AbstractRenderSession;
import away3d.core.draw.DrawDisplayObject;
import flash.display.Sprite;
import away3d.materials.IBillboardMaterial;
import away3d.core.draw.DrawTriangle;
import away3d.core.draw.DrawPrimitive;
import away3d.core.base.UV;
import away3d.core.base.Vertex;
import away3d.core.block.Blocker;


class DrawPrimitiveStore  {
	
	private var _sourceDictionary:HashMap<Object3D, HashMap<Vertex, ScreenVertex>>;
	private var _vertexDictionary:HashMap<Vertex, ScreenVertex>;
	private var _vertex:Vertex;
	private var _source:Object3D;
	private var _session:AbstractRenderSession;
	private var _sv:ScreenVertex;
	private var _bill:DrawBillboard;
	private var _seg:DrawSegment;
	private var _tri:DrawTriangle;
	private var _cblocker:ConvexBlocker;
	private var _sbitmap:DrawScaledBitmap;
	private var _dobject:DrawDisplayObject;
	private var _svStore:Array<ScreenVertex>;
	private var _dtDictionary:HashMap<AbstractRenderSession, Array<DrawTriangle>>;
	private var _dtArray:Array<DrawTriangle>;
	private var _dtStore:Array<DrawTriangle>;
	private var _dsDictionary:HashMap<AbstractRenderSession, Array<DrawSegment>>;
	private var _dsArray:Array<DrawSegment>;
	private var _dsStore:Array<DrawSegment>;
	private var _dbDictionary:HashMap<AbstractRenderSession, Array<DrawBillboard>>;
	private var _dbArray:Array<DrawBillboard>;
	private var _dbStore:Array<DrawBillboard>;
	private var _cbDictionary:HashMap<AbstractRenderSession, Array<ConvexBlocker>>;
	private var _cbArray:Array<ConvexBlocker>;
	private var _cbStore:Array<ConvexBlocker>;
	private var _sbDictionary:HashMap<AbstractRenderSession, Array<DrawScaledBitmap>>;
	private var _sbArray:Array<DrawScaledBitmap>;
	private var _sbStore:Array<DrawScaledBitmap>;
	private var _doDictionary:HashMap<AbstractRenderSession, Array<DrawDisplayObject>>;
	private var _doArray:Array<DrawDisplayObject>;
	private var _doStore:Array<DrawDisplayObject>;
	public var view:View3D;
	public var blockerDictionary:HashMap<Object3D, ConvexBlocker>;
	

	public function reset():Void {
		
		for (_source in _sourceDictionary.keys()) {
			if (_source.session != null && _source.session.updated) {
				for (_vertex in _sourceDictionary.get(_source).keys()) {
					_sv = _sourceDictionary.get(_source).get(_vertex);
					_svStore.push(_sv);
					_sourceDictionary.get(_source).remove(_vertex);
				}
			}
		}

		for (_session in _dtDictionary.keys()) {
			if (_session.updated) {
				_dtStore = _dtStore.concat(_dtDictionary.get(_session));
				_dtDictionary.remove(_session);
			}
			
		}

		for (_session in _dsDictionary.keys()) {
			if (_session.updated) {
				_dsStore = _dsStore.concat(_dsDictionary.get(_session));
				_dsDictionary.remove(_session);
			}
			
		}

		for (_session in _dbDictionary.keys()) {
			if (_session.updated) {
				_dbStore = _dbStore.concat(_dbDictionary.get(_session));
				_dbDictionary.remove(_session);
			}
			
		}

		for (_session in _cbDictionary.keys()) {
			if (_session.updated) {
				_cbStore = _cbStore.concat(_cbDictionary.get(_session));
				_cbDictionary.remove(_session);
			}
			
		}

		for (_session in _sbDictionary.keys()) {
			if (_session.updated) {
				_sbStore = _sbStore.concat(_sbDictionary.get(_session));
				_sbDictionary.remove(_session);
			}
			
		}

		for (_session in _doDictionary.keys()) {
			if (_session.updated) {
				_doStore = _doStore.concat(_doDictionary.get(_session));
				_doDictionary.remove(_session);
			}
			
		}

	}

	public function createVertexDictionary(source:Object3D):HashMap<Vertex, ScreenVertex> {
		
		if ((_vertexDictionary = _sourceDictionary.get(source)) == null) {
			_vertexDictionary = _sourceDictionary.put(source, new HashMap<Vertex, ScreenVertex>());
		}
		return _vertexDictionary;
	}

	public function createScreenVertex(vertex:Vertex):ScreenVertex {
		
		if (((_sv = _vertexDictionary.get(vertex)) != null)) {
			return _sv;
		}
		if ((_svStore.length > 0)) {
			_sv = _vertexDictionary.put(vertex, _svStore.pop());
		} else {
			_sv = _vertexDictionary.put(vertex, new ScreenVertex());
		}
		return _sv;
	}

	public function createDrawBillboard(source:Object3D, material:IBillboardMaterial, screenvertex:ScreenVertex, width:Float, height:Float, scale:Float, rotation:Float, ?generated:Bool=false):DrawBillboard {
		
		if ((_dbArray = _dbDictionary.get(source.session)) == null) {
			_dbArray = _dbDictionary.put(source.session, new Array<DrawBillboard>());
		}
		if ((_dbStore.length > 0)) {
			_dbArray.push(_bill = _dbStore.pop());
		} else {
			_dbArray.push(_bill = new DrawBillboard());
			_bill.view = view;
			_bill.create = createDrawBillboard;
		}
		_bill.generated = generated;
		_bill.source = source;
		_bill.material = material;
		_bill.screenvertex = screenvertex;
		_bill.width = width;
		_bill.height = height;
		_bill.scale = scale;
		_bill.rotation = rotation;
		_bill.calc();
		return _bill;
	}

	public function createDrawSegment(source:Object3D, material:ISegmentMaterial, v0:ScreenVertex, v1:ScreenVertex, ?generated:Bool=false):DrawSegment {
		
		if ((_dsArray = _dsDictionary.get(source.session)) == null) {
			_dsArray = _dsDictionary.put(source.session, new Array<DrawSegment>());
		}
		if ((_dsStore.length > 0)) {
			_dsArray.push(_seg = _dsStore.pop());
		} else {
			_dsArray.push(_seg = new DrawSegment());
			_seg.view = view;
			_seg.create = createDrawSegment;
		}
		_seg.generated = generated;
		_seg.source = source;
		_seg.material = material;
		_seg.v0 = v0;
		_seg.v1 = v1;
		_seg.calc();
		return _seg;
	}

	public function createDrawTriangle(source:Object3D, faceVO:FaceVO, material:ITriangleMaterial, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex, uv0:UV, uv1:UV, uv2:UV, ?generated:Bool=false):DrawTriangle {
		
		if ((_dtArray = _dtDictionary.get(source.session)) == null) {
			_dtArray = _dtDictionary.put(source.session, new Array<DrawTriangle>());
		}
		if ((_dtStore.length > 0)) {
			_dtArray.push(_tri = _dtStore.pop());
		} else {
			_dtArray.push(_tri = new DrawTriangle());
			_tri.view = view;
			_tri.create = createDrawTriangle;
		}
		_tri.generated = generated;
		_tri.source = source;
		_tri.faceVO = faceVO;
		_tri.material = material;
		_tri.v0 = v0;
		_tri.v1 = v1;
		_tri.v2 = v2;
		_tri.uv0 = uv0;
		_tri.uv1 = uv1;
		_tri.uv2 = uv2;
		_tri.calc();
		return _tri;
	}

	public function createConvexBlocker(source:Object3D, vertices:Array<ScreenVertex>):ConvexBlocker {
		
		if ((_cbArray = _cbDictionary.get(source.session)) == null) {
			_cbArray = _cbDictionary.put(source.session, new Array<ConvexBlocker>());
		}
		if ((_cbStore.length > 0)) {
			_cbArray.push(_cblocker = blockerDictionary.put(source, _cbStore.pop()));
		} else {
			_cbArray.push(_cblocker = blockerDictionary.put(source, new ConvexBlocker()));
			_cblocker.view = view;
			_cblocker.create = createConvexBlocker;
		}
		_cblocker.source = source;
		_cblocker.vertices = vertices;
		_cblocker.calc();
		return _cblocker;
	}

	public function createDrawScaledBitmap(source:Object3D, screenvertex:ScreenVertex, smooth:Bool, bitmap:BitmapData, scale:Float, rotation:Float, ?generated:Bool=false):DrawScaledBitmap {
		
		if ((_sbArray = _sbDictionary.get(source.session)) == null) {
			_sbArray = _sbDictionary.put(source.session, new Array<DrawScaledBitmap>());
		}
		if ((_sbStore.length > 0)) {
			_sbArray.push(_sbitmap = _sbStore.pop());
		} else {
			_sbArray.push(_sbitmap = new DrawScaledBitmap());
			_sbitmap.view = view;
			_sbitmap.create = createDrawSegment;
		}
		_sbitmap.generated = generated;
		_sbitmap.source = source;
		_sbitmap.screenvertex = screenvertex;
		_sbitmap.smooth = smooth;
		_sbitmap.bitmap = bitmap;
		_sbitmap.scale = scale;
		_sbitmap.rotation = rotation;
		_sbitmap.calc();
		return _sbitmap;
	}

	public function createDrawDisplayObject(source:Object3D, screenvertex:ScreenVertex, session:AbstractRenderSession, displayobject:DisplayObject, ?generated:Bool=false):DrawDisplayObject {
		
		if ((_doArray = _doDictionary.get(source.session)) == null) {
			_doArray = _doDictionary.put(source.session, new Array<DrawDisplayObject>());
		}
		if ((_doStore.length > 0)) {
			_doArray.push(_dobject = _doStore.pop());
		} else {
			_doArray.push(_dobject = new DrawDisplayObject());
			_dobject.view = view;
			_dobject.create = createDrawSegment;
		}
		_dobject.generated = generated;
		_dobject.source = source;
		_dobject.screenvertex = screenvertex;
		_dobject.session = session;
		_dobject.displayobject = displayobject;
		_dobject.calc();
		return _dobject;
	}

	// autogenerated
	public function new () {
		this._sourceDictionary = new HashMap<Object3D, HashMap<Vertex, ScreenVertex>>();
		this._svStore = new Array<ScreenVertex>();
		this._dtDictionary = new HashMap<AbstractRenderSession, Array<DrawTriangle>>();
		this._dtStore = new Array<DrawTriangle>();
		this._dsDictionary = new HashMap<AbstractRenderSession, Array<DrawSegment>>();
		this._dsStore = new Array<DrawSegment>();
		this._dbDictionary = new HashMap<AbstractRenderSession, Array<DrawBillboard>>();
		this._dbStore = new Array<DrawBillboard>();
		this._cbDictionary = new HashMap<AbstractRenderSession, Array<ConvexBlocker>>();
		this._cbStore = new Array<ConvexBlocker>();
		this._sbDictionary = new HashMap<AbstractRenderSession, Array<DrawScaledBitmap>>();
		this._sbStore = new Array<DrawScaledBitmap>();
		this._doDictionary = new HashMap<AbstractRenderSession, Array<DrawDisplayObject>>();
		this._doStore = new Array<DrawDisplayObject>();
		
	}

	

}

