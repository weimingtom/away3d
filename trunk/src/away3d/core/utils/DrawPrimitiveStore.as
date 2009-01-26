package away3d.core.utils
{
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.block.*;
	import away3d.core.draw.*;
	import away3d.core.render.*;
	import away3d.materials.*;
	
	import flash.display.*;
	import flash.utils.*;
	
	public class DrawPrimitiveStore
	{
		private var _sourceDictionary:Dictionary = new Dictionary(true);
		private var _vertexDictionary:Dictionary;
		private var _object:Object;
		private var _vertex:Object;
		private var _source:Object3D;
		private var _session:AbstractRenderSession;
		private var _sv:ScreenVertex;
		private var _bill:DrawBillboard;
		private var _seg:DrawSegment;
		private var _tri:DrawTriangle;
		private var _cblocker:ConvexBlocker;
		private var _sbitmap:DrawScaledBitmap;
		private var _dobject:DrawDisplayObject;
		private var _svStore:Array = new Array();
		private var _dtDictionary:Dictionary = new Dictionary(true);
		private var _dtArray:Array;
		private var _dtStore:Array = new Array();
		private var _dsDictionary:Dictionary = new Dictionary(true);
		private var _dsArray:Array;
        private var _dsStore:Array = new Array();
        private var _dbDictionary:Dictionary = new Dictionary(true);
		private var _dbArray:Array;
        private var _dbStore:Array = new Array();
        private var _cbDictionary:Dictionary = new Dictionary(true);
		private var _cbArray:Array;
		private var _cbStore:Array = new Array();
		private var _sbDictionary:Dictionary = new Dictionary(true);
		private var _sbArray:Array;
		private var _sbStore:Array = new Array();
		private var _doDictionary:Dictionary = new Dictionary(true);
		private var _doArray:Array;
        private var _doStore:Array = new Array();
        
		public var view:View3D;
		
		public var blockerDictionary:Dictionary;
		
		public function reset():void
		{
			for (_object in _sourceDictionary) {
				_source = _object as Object3D;
				if (_source.session && _source.session.updated) {
					for (_vertex in _sourceDictionary[_source]) {
						_sv = _sourceDictionary[_source][_vertex];
						_svStore.push(_sv);
						delete _sourceDictionary[_source][_vertex];
					}
				}
			}
			
			for (_object in _dtDictionary) {
				_session = _object as AbstractRenderSession;
				if (_session.updated) {
					_dtStore = _dtStore.concat(_dtDictionary[_session] as Array);
					_dtDictionary[_session] = [];
				}
			}
			
			for (_object in _dsDictionary) {
				_session = _object as AbstractRenderSession;
				if (_session.updated) {
					_dsStore = _dsStore.concat(_dsDictionary[_session] as Array);
					_dsDictionary[_session] = [];
				}
			}
			
			for (_object in _dbDictionary) {
				_session = _object as AbstractRenderSession;
				if (_session.updated) {
					_dbStore = _dbStore.concat(_dbDictionary[_session] as Array);
					_dbDictionary[_session] = [];
				}
			}
			
			for (_object in _cbDictionary) {
				_session = _object as AbstractRenderSession;
				if (_session.updated) {
					_cbStore = _cbStore.concat(_cbDictionary[_session] as Array);
					_cbDictionary[_session] = [];
				}
			}
			
			for (_object in _sbDictionary) {
				_session = _object as AbstractRenderSession;
				if (_session.updated) {
					_sbStore = _sbStore.concat(_sbDictionary[_session] as Array);
					_sbDictionary[_session] = [];
				}
			}
			
			for (_object in _doDictionary) {
				_session = _object as AbstractRenderSession;
				if (_session.updated) {
					_doStore = _doStore.concat(_doDictionary[_session] as Array);
					_doDictionary[_session] = [];
				}
			}
		}
		
		public function createVertexDictionary(source:Object3D):Dictionary
		{
	        if (!(_vertexDictionary = _sourceDictionary[source]))
				_vertexDictionary = _sourceDictionary[source] = new Dictionary(true);
			
			return _vertexDictionary;
		}
		
		public function createScreenVertex(vertex:Vertex):ScreenVertex
		{
			if ((_sv = _vertexDictionary[vertex]))
        		return _sv;
        	
			if (_svStore.length)
	        	_sv = _vertexDictionary[vertex] = _svStore.pop();
	        else
	        	_sv = _vertexDictionary[vertex] = new ScreenVertex();
			
	        return _sv;
		}
		
	    public function createDrawBillboard(source:Object3D, material:IBillboardMaterial, screenvertex:ScreenVertex, width:Number, height:Number, scale:Number, rotation:Number, generated:Boolean = false):DrawBillboard
	    {
	    	if (!(_dbArray = _dbDictionary[source.session]))
				_dbArray = _dbDictionary[source.session] = [];
			
	        if (_dbStore.length) {
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
	    
	    public function createDrawSegment(source:Object3D, material:ISegmentMaterial, v0:ScreenVertex, v1:ScreenVertex, generated:Boolean = false):DrawSegment
	    {
	    	if (!(_dsArray = _dsDictionary[source.session]))
				_dsArray = _dsDictionary[source.session] = [];
			
	        if (_dsStore.length) {
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
	    
		public function createDrawTriangle(source:Object3D, face:Face, material:ITriangleMaterial, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex, uv0:UV, uv1:UV, uv2:UV, generated:Boolean = false):DrawTriangle
		{
			if (!(_dtArray = _dtDictionary[source.session]))
				_dtArray = _dtDictionary[source.session] = [];
			
			if (_dtStore.length) {
	        	_dtArray.push(_tri = _dtStore.pop());
	   		} else {
	        	_dtArray.push(_tri = new DrawTriangle());
		        _tri.view = view;
		        _tri.create = createDrawTriangle;
	        }
	        
	        _tri.generated = generated;
	        _tri.source = source;
	        _tri.face = face;
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
	    
		public function createConvexBlocker(source:Object3D, vertices:Array):ConvexBlocker
		{
			if (!(_cbArray = _cbDictionary[source.session]))
				_cbArray = _cbDictionary[source.session] = [];
			
			if (_cbStore.length) {
	        	_cbArray.push(_cblocker = blockerDictionary[source] = _cbStore.pop());
	   		} else {
	        	_cbArray.push(_cblocker = blockerDictionary[source] = new ConvexBlocker());
		        _cblocker.view = view;
		        _cblocker.create = createConvexBlocker;
	        }
	        
	        _cblocker.source = source
	        _cblocker.vertices = vertices;
	        _cblocker.calc();
	        
	        return _cblocker;
	    }
	    
	    public function createDrawScaledBitmap(source:Object3D, screenvertex:ScreenVertex, smooth:Boolean, bitmap:BitmapData, scale:Number, rotation:Number, generated:Boolean = false):DrawScaledBitmap
	    {
	    	if (!(_sbArray = _sbDictionary[source.session]))
				_sbArray = _sbDictionary[source.session] = [];
			
	        if (_sbStore.length) {
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
	    
	    public function createDrawDisplayObject(source:Object3D, screenvertex:ScreenVertex, session:AbstractRenderSession, displayobject:DisplayObject, generated:Boolean = false):DrawDisplayObject
	    {
	    	if (!(_doArray = _doDictionary[source.session]))
				_doArray = _doDictionary[source.session] = [];
			
			if (_doStore.length) {
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
	}
}