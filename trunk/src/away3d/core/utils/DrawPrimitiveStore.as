package away3d.core.utils
{
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.block.*;
	import away3d.core.draw.*;
	import away3d.core.render.AbstractRenderSession;
	import away3d.materials.*;
	
	import flash.display.*;
	import flash.utils.*;
	
	public class DrawPrimitiveStore
	{
		private var _vertexDictionary:Dictionary;
		private var _sv:ScreenVertex;
		private var _bill:DrawBillboard;
		private var _seg:DrawSegment;
		private var _tri:DrawTriangle;
		private var _cblocker:ConvexBlocker;
		private var _sbitmap:DrawScaledBitmap;
		private var _dobject:DrawDisplayObject;
		private var _svStore:Array = new Array();
        private var _svActive:Array = new Array();
		private var _dtStore:Array = new Array();
        private var _dtActive:Array = new Array();
        private var _dsStore:Array = new Array();
        private var _dsActive:Array = new Array();
        private var _dbStore:Array = new Array();
        private var _dbActive:Array = new Array();
		private var _cbStore:Array = new Array();
        private var _cbActive:Array = new Array();
		private var _sbStore:Array = new Array();
        private var _sbActive:Array = new Array();
        private var _doStore:Array = new Array();
        private var _doActive:Array = new Array();
        
		public var view:View3D;
		
		public var blockerDictionary:Dictionary;
		
		public var sourceDictionary:Dictionary;
		
		public function reset():void
		{
			_svStore = _svStore.concat(_svActive);
			_svActive = new Array();
			sourceDictionary = new Dictionary(true);
			_dtStore = _dtStore.concat(_dtActive);
			_dtActive = new Array();
			_dsStore = _dsStore.concat(_dsActive);
			_dsActive = new Array();
			_dbStore = _dbStore.concat(_dbActive);
			_dbActive = new Array();
			_cbStore = _cbStore.concat(_cbActive);
			_cbActive = new Array();
			_sbStore = _sbStore.concat(_sbActive);
			_sbActive = new Array();
			_doStore = _doStore.concat(_doActive);
			_doActive = new Array();
			blockerDictionary = new Dictionary(true);
		}
		
		public function createVertexDictionary(source:Object3D):Dictionary
		{
	        if (!(_vertexDictionary = sourceDictionary[source]))
				_vertexDictionary = sourceDictionary[source] = new Dictionary(true);
			
			return _vertexDictionary;
		}
		
		public function createScreenVertex(vertex:Vertex):ScreenVertex
		{
			if (_svStore.length)
	        	_svActive.push(_sv = _vertexDictionary[vertex] = _svStore.pop());
	        else
	        	_svActive.push(_sv = _vertexDictionary[vertex] = new ScreenVertex());
			
	        return _sv;
		}
		
	    public function createDrawBillboard(source:Object3D, material:IBillboardMaterial, screenvertex:ScreenVertex, width:Number, height:Number, scale:Number, rotation:Number, generated:Boolean = false):DrawBillboard
	    {
	        if (_dbStore.length) {
	        	_dbActive.push(_bill = _dbStore.pop());
	    	} else {
	        	_dbActive.push(_bill = new DrawBillboard());
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
	        if (_dsStore.length) {
	        	_dsActive.push(_seg = _dsStore.pop());
	    	} else {
	        	_dsActive.push(_seg = new DrawSegment());
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
			if (_dtStore.length) {
	        	_dtActive.push(_tri = _dtStore.pop());
	   		} else {
	        	_dtActive.push(_tri = new DrawTriangle());
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
			if (_cbStore.length) {
	        	_cbActive.push(_cblocker = blockerDictionary[source] = _cbStore.pop());
	   		} else {
	        	_cbActive.push(_cblocker = blockerDictionary[source] = new ConvexBlocker());
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
	        if (_sbStore.length) {
	        	_sbActive.push(_sbitmap = _sbStore.pop());
	    	} else {
	        	_sbActive.push(_sbitmap = new DrawScaledBitmap());
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
			if (_doStore.length) {
	        	_doActive.push(_dobject = _doStore.pop());
	    	} else {
	        	_doActive.push(_dobject = new DrawDisplayObject());
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