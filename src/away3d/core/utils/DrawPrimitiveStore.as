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
		private var _screenDictionary:Dictionary = new Dictionary(true);
		private var _screenArray:Array;
		private var _vertexDictionary:Dictionary = new Dictionary(true);
		private var _vertexArray:Array;
		private var _indexDictionary:Dictionary;
		private var _index:int;
		private var _length:int;
		private var _object:Object;
		private var _vertex:Object;
		private var _source:Object3D;
		private var _session:AbstractRenderSession;
		private var _sv:ScreenVertex;
		private var _bill:DrawBillboard;
		private var _seg:DrawSegment;
		private var _tri:DrawTriangle;
		private var _array:Array = new Array();
		private var _cblocker:ConvexBlocker;
		private var _sbitmap:DrawScaledBitmap;
		private var _dobject:DrawDisplayObject;
		private var _svArray:Array;
		private var _svStore:Array = [];
		private var _dtDictionary:Dictionary = new Dictionary(true);
		private var _dtArray:Array;
		private var _dtStore:Array = [];
		private var _dsDictionary:Dictionary = new Dictionary(true);
		private var _dsArray:Array;
        private var _dsStore:Array = [];
        private var _dbDictionary:Dictionary = new Dictionary(true);
		private var _dbArray:Array;
        private var _dbStore:Array = [];
        private var _cbDictionary:Dictionary = new Dictionary(true);
		private var _cbArray:Array;
		private var _cbStore:Array = [];
		private var _sbDictionary:Dictionary = new Dictionary(true);
		private var _sbArray:Array;
		private var _sbStore:Array = [];
		private var _doDictionary:Dictionary = new Dictionary(true);
		private var _doArray:Array;
        private var _doStore:Array = [];
        
		public var view:View3D;
		
		public var blockerDictionary:Dictionary = new Dictionary(true);
		
		public function reset():void
		{
			for (_object in _vertexDictionary) {
				_source = _object as Object3D;
				if (_source.session && _source.session.updated) {
					_svArray = _vertexDictionary[_source] as Array
					_svStore = _svStore.concat(_svArray);
					_svArray.length = 0;
					(_screenDictionary[_source] as Array).length = 0;
				}
			}
			
			for (_object in _dtDictionary) {
				_session = _object as AbstractRenderSession;
				if (_session.updated) {
					_dtArray = _dtDictionary[_session] as Array;
					_dtStore = _dtStore.concat(_dtArray);
					_dtArray.length = 0;
				}
			}
			
			for (_object in _dsDictionary) {
				_session = _object as AbstractRenderSession;
				if (_session.updated) {
					_dsArray = _dsDictionary[_session] as Array
					_dsStore = _dsStore.concat(_dsArray);
					_dsArray.length = 0;
				}
			}
			
			for (_object in _dbDictionary) {
				_session = _object as AbstractRenderSession;
				if (_session.updated) {
					_dbArray = _dbDictionary[_session] as Array;
					_dbStore = _dbStore.concat(_dbArray);
					_dbArray.length = 0;
				}
			}
			
			for (_object in _cbDictionary) {
				_session = _object as AbstractRenderSession;
				if (_session.updated) {
					_cbArray = _cbDictionary[_session] as Array;
					_cbStore = _cbStore.concat(_cbArray);
					_cbArray.length = 0;
				}
			}
			
			for (_object in _sbDictionary) {
				_session = _object as AbstractRenderSession;
				if (_session.updated) {
					_sbArray = _sbDictionary[_session] as Array;
					_sbStore = _sbStore.concat(_sbArray);
					_sbArray.length = 0;
				}
			}
			
			for (_object in _doDictionary) {
				_session = _object as AbstractRenderSession;
				if (_session.updated) {
					_doArray = _doDictionary[_session] as Array;
					_doStore = _doStore.concat(_doArray);
					_doArray.length = 0;
				}
			}
		}
		
		public function createScreenArray(source:Object3D):Array
		{
	        if (!(_screenArray = _screenDictionary[source]))
				_screenArray = _screenDictionary[source] = [];
			
			if (!(_vertexArray = _vertexDictionary[source]))
				_vertexArray = _vertexDictionary[source] = [];
			
			_length = 0;
			
			_indexDictionary = new Dictionary(true);
			
			return _screenArray;
		}
		
		public function getScreenArray():Array
		{
			return _screenArray;
		}
		
		public function createScreenVertex(vertex:Vertex):ScreenVertex
		{
			if (!_indexDictionary[vertex]) {
				_index = _indexDictionary[vertex] = _length++;
				
				if (_svStore.length)
		        	_sv = _screenArray[_index] = _vertexArray[_vertexArray.length] = _svStore.pop();
		        else
		        	_sv = _screenArray[_index] = _vertexArray[_vertexArray.length] = new ScreenVertex();
			} else {
				_sv = _screenArray[_length++] = _screenArray[_indexDictionary[vertex]];
			}
        	
			_sv.vectorInstructionType = vertex.vectorInstructionType;
			
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
	    
	    public function createDrawSegment(source:Object3D, elementVO:ElementVO, material:ISegmentMaterial, screenVertices:Array, screenIndexStart:int, screenIndexEnd:int, generated:Boolean = false):DrawSegment
	    {
	    	if (!(_dsArray = _dsDictionary[source.session]))
				_dsArray = _dsDictionary[source.session] = [];
			
	        if (_dsStore.length) {
	        	_dsArray[_dsArray.length] = _seg = _dsStore.pop();
	    	} else {
	        	_dsArray[_dsArray.length] = _seg = new DrawSegment();
	            _seg.view = view;
	            _seg.create = createDrawSegment;
	        }
	        _seg.generated = generated;
	        _seg.source = source;
	        _seg.elementVO = elementVO;
	        _seg.material = material;
	        _seg.screenVertices = screenVertices;
	        _seg.screenIndexStart = screenIndexStart;
	        _seg.screenIndexEnd = screenIndexEnd;
	        _seg.calc();
	        
	        return _seg;
	    }
	    
		public function createDrawTriangle(source:Object3D, faceVO:FaceVO, material:ITriangleMaterial, screenVertices:Array, screenIndexStart:int, screenIndexEnd:int, uv0:UV, uv1:UV, uv2:UV, generated:Boolean = false):DrawTriangle
		{
			if (!(_dtArray = _dtDictionary[source.session]))
				_dtArray = _dtDictionary[source.session] = [];
			
			if (_dtStore.length) {
	        	_dtArray[_dtArray.length] = _tri = _dtStore.pop();
	   		} else {
	        	_dtArray[_dtArray.length] = _tri = new DrawTriangle();
		        _tri.view = view;
		        _tri.create = createDrawTriangle;
	        }
	        
	        _tri.generated = generated;
	        _tri.source = source;
	        _tri.faceVO = faceVO;
	        _tri.material = material;
	        _tri.screenVertices = screenVertices;
	        _tri.screenIndexStart = screenIndexStart;
	        _tri.screenIndexEnd = screenIndexEnd;
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
	        	_cbArray[_cbArray.length] = _cblocker = blockerDictionary[source] = _cbStore.pop();
	   		} else {
	        	_cbArray[_cbArray.length] = _cblocker = blockerDictionary[source] = new ConvexBlocker();
		        _cblocker.view = view;
		        _cblocker.create = createConvexBlocker;
	        }
	        
	        _cblocker.source = source;
	        _cblocker.vertices = vertices;
	        _cblocker.calc();
	        
	        return _cblocker;
	    }
	    
	    public function createDrawScaledBitmap(source:Object3D, screenvertex:ScreenVertex, smooth:Boolean, bitmap:BitmapData, scale:Number, rotation:Number, generated:Boolean = false):DrawScaledBitmap
	    {
	    	if (!(_sbArray = _sbDictionary[source.session]))
				_sbArray = _sbDictionary[source.session] = [];
			
	        if (_sbStore.length) {
	        	_sbArray[_sbArray.length] = _sbitmap = _sbStore.pop();
	    	} else {
	        	_sbArray[_sbArray.length] = _sbitmap = new DrawScaledBitmap();
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
	        	_doArray[_doArray.length] = _dobject = _doStore.pop();
	    	} else {
	        	_doArray[_doArray.length] = _dobject = new DrawDisplayObject();
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