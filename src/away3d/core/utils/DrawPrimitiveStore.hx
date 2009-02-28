package away3d.core.utils;

import away3d.core.block.ConvexBlocker;
import away3d.materials.IMaterial;
import flash.events.EventDispatcher;
import flash.display.BitmapData;
import away3d.materials.ITriangleMaterial;
import away3d.materials.ISegmentMaterial;
import away3d.containers.View3D;
import flash.utils.Dictionary;
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
	
	private var _sourceDictionary:Dictionary;
	private var _vertexDictionary:Dictionary;
	private var _object:Dynamic;
	private var _vertex:Dynamic;
	private var _source:Object3D;
	private var _session:AbstractRenderSession;
	private var _sv:ScreenVertex;
	private var _bill:DrawBillboard;
	private var _seg:DrawSegment;
	private var _tri:DrawTriangle;
	private var _cblocker:ConvexBlocker;
	private var _sbitmap:DrawScaledBitmap;
	private var _dobject:DrawDisplayObject;
	private var _svStore:Array<Dynamic>;
	private var _dtDictionary:Dictionary;
	private var _dtArray:Array<Dynamic>;
	private var _dtStore:Array<Dynamic>;
	private var _dsDictionary:Dictionary;
	private var _dsArray:Array<Dynamic>;
	private var _dsStore:Array<Dynamic>;
	private var _dbDictionary:Dictionary;
	private var _dbArray:Array<Dynamic>;
	private var _dbStore:Array<Dynamic>;
	private var _cbDictionary:Dictionary;
	private var _cbArray:Array<Dynamic>;
	private var _cbStore:Array<Dynamic>;
	private var _sbDictionary:Dictionary;
	private var _sbArray:Array<Dynamic>;
	private var _sbStore:Array<Dynamic>;
	private var _doDictionary:Dictionary;
	private var _doArray:Array<Dynamic>;
	private var _doStore:Array<Dynamic>;
	public var view:View3D;
	public var blockerDictionary:Dictionary;
	

	public function reset():Void {
		
		var __keys:Iterator<Dynamic> = untyped (__keys__(_sourceDictionary)).iterator();
		for (_object in __keys) {
			_source = cast(_object, Object3D);
			if (_source.session && _source.session.updated) {
				var __keys:Iterator<Dynamic> = untyped (__keys__(_sourceDictionary[untyped _source])).iterator();
				for (_vertex in __keys) {
					_sv = _sourceDictionary[untyped _source][untyped _vertex];
					_svStore.push(_sv);
					_sourceDictionary[untyped _source][untyped _vertex] = null;
					
				}

			}
			
		}

		var __keys:Iterator<Dynamic> = untyped (__keys__(_dtDictionary)).iterator();
		for (_object in __keys) {
			_session = cast(_object, AbstractRenderSession);
			if (_session.updated) {
				_dtStore = _dtStore.concat(cast(_dtDictionary[untyped _session], Array<Dynamic>));
				_dtDictionary[untyped _session] = null;
			}
			
		}

		var __keys:Iterator<Dynamic> = untyped (__keys__(_dsDictionary)).iterator();
		for (_object in __keys) {
			_session = cast(_object, AbstractRenderSession);
			if (_session.updated) {
				_dsStore = _dsStore.concat(cast(_dsDictionary[untyped _session], Array<Dynamic>));
				_dsDictionary[untyped _session] = null;
			}
			
		}

		var __keys:Iterator<Dynamic> = untyped (__keys__(_dbDictionary)).iterator();
		for (_object in __keys) {
			_session = cast(_object, AbstractRenderSession);
			if (_session.updated) {
				_dbStore = _dbStore.concat(cast(_dbDictionary[untyped _session], Array<Dynamic>));
				_dbDictionary[untyped _session] = null;
			}
			
		}

		var __keys:Iterator<Dynamic> = untyped (__keys__(_cbDictionary)).iterator();
		for (_object in __keys) {
			_session = cast(_object, AbstractRenderSession);
			if (_session.updated) {
				_cbStore = _cbStore.concat(cast(_cbDictionary[untyped _session], Array<Dynamic>));
				_cbDictionary[untyped _session] = null;
			}
			
		}

		var __keys:Iterator<Dynamic> = untyped (__keys__(_sbDictionary)).iterator();
		for (_object in __keys) {
			_session = cast(_object, AbstractRenderSession);
			if (_session.updated) {
				_sbStore = _sbStore.concat(cast(_sbDictionary[untyped _session], Array<Dynamic>));
				_sbDictionary[untyped _session] = null;
			}
			
		}

		var __keys:Iterator<Dynamic> = untyped (__keys__(_doDictionary)).iterator();
		for (_object in __keys) {
			_session = cast(_object, AbstractRenderSession);
			if (_session.updated) {
				_doStore = _doStore.concat(cast(_doDictionary[untyped _session], Array<Dynamic>));
				_doDictionary[untyped _session] = null;
			}
			
		}

	}

	public function createVertexDictionary(source:Object3D):Dictionary {
		
		if ((_vertexDictionary = _sourceDictionary[untyped source]) == null) {
			_vertexDictionary = _sourceDictionary[untyped source] = new Dictionary(true);
		}
		return _vertexDictionary;
	}

	public function createScreenVertex(vertex:Vertex):ScreenVertex {
		
		if (((_sv = _vertexDictionary[untyped vertex]) != null)) {
			return _sv;
		}
		if ((_svStore.length > 0)) {
			_sv = _vertexDictionary[untyped vertex] = _svStore.pop();
		} else {
			_sv = _vertexDictionary[untyped vertex] = new ScreenVertex();
		}
		return _sv;
	}

	public function createDrawBillboard(source:Object3D, material:IBillboardMaterial, screenvertex:ScreenVertex, width:Float, height:Float, scale:Float, rotation:Float, ?generated:Bool=false):DrawBillboard {
		
		if ((_dbArray = _dbDictionary[untyped source.session]) == null) {
			_dbArray = _dbDictionary[untyped source.session] = [];
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
		
		if ((_dsArray = _dsDictionary[untyped source.session]) == null) {
			_dsArray = _dsDictionary[untyped source.session] = [];
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
		
		if ((_dtArray = _dtDictionary[untyped source.session]) == null) {
			_dtArray = _dtDictionary[untyped source.session] = [];
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

	public function createConvexBlocker(source:Object3D, vertices:Array<Dynamic>):ConvexBlocker {
		
		if ((_cbArray = _cbDictionary[untyped source.session]) == null) {
			_cbArray = _cbDictionary[untyped source.session] = [];
		}
		if ((_cbStore.length > 0)) {
			_cbArray.push(_cblocker = blockerDictionary[untyped source] = _cbStore.pop());
		} else {
			_cbArray.push(_cblocker = blockerDictionary[untyped source] = new ConvexBlocker());
			_cblocker.view = view;
			_cblocker.create = createConvexBlocker;
		}
		_cblocker.source = source;
		_cblocker.vertices = vertices;
		_cblocker.calc();
		return _cblocker;
	}

	public function createDrawScaledBitmap(source:Object3D, screenvertex:ScreenVertex, smooth:Bool, bitmap:BitmapData, scale:Float, rotation:Float, ?generated:Bool=false):DrawScaledBitmap {
		
		if ((_sbArray = _sbDictionary[untyped source.session]) == null) {
			_sbArray = _sbDictionary[untyped source.session] = [];
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
		
		if ((_doArray = _doDictionary[untyped source.session]) == null) {
			_doArray = _doDictionary[untyped source.session] = [];
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
		this._sourceDictionary = new Dictionary(true);
		this._svStore = new Array();
		this._dtDictionary = new Dictionary(true);
		this._dtStore = new Array();
		this._dsDictionary = new Dictionary(true);
		this._dsStore = new Array();
		this._dbDictionary = new Dictionary(true);
		this._dbStore = new Array();
		this._cbDictionary = new Dictionary(true);
		this._cbStore = new Array();
		this._sbDictionary = new Dictionary(true);
		this._sbStore = new Array();
		this._doDictionary = new Dictionary(true);
		this._doStore = new Array();
		
	}

	

}

