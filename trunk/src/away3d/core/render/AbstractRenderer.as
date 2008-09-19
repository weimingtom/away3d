package away3d.core.render
{
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.block.*;
	import away3d.core.clip.*;
	import away3d.core.draw.*;
	import away3d.core.filter.*;
	import away3d.core.light.*;
	import away3d.core.stats.*;
	import away3d.core.traverse.*;
	import away3d.materials.*;
	
	import flash.display.DisplayObject;
	import flash.utils.*;
    
    /** 
    * Default renderer for a view.
    * Contains the main render loop for rendering a scene to a view,
    * which resolves the projection, culls any drawing primitives that are occluded or outside the viewport,
    * and then z-sorts and renders them to screen.
    */
    public class AbstractRenderer
    {
    	private var _sc:ScreenVertex;
    	private var _tri:DrawTriangle;
		private var _seg:DrawSegment;
		private var _ddo:DrawDisplayObject;
    	private var _primitive:DrawPrimitive;
        private var _view:View3D;
        private var _scene:Scene3D;
        private var _camera:Camera3D;
        private var _clip:Clipping;
        private var _blockers:Array;
		private var _filter:IPrimitiveFilter;
		private var _scStore:Array = new Array();
        private var _scActive:Array = new Array();
		private var _dtStore:Array = new Array();
        private var _dtActive:Array = new Array();
        private var _dsStore:Array = new Array();
        private var _dsActive:Array = new Array();
        private var _ddStore:Array = new Array();
        private var _ddActive:Array = new Array();
        private var _screenObjects:Dictionary = new Dictionary(true);
        private var _screenVertices:Dictionary;
        
        public function clear(view:View3D):void
        {
        	_scStore = _scStore.concat(_scActive);
        	_scActive = new Array();
    	    _dtStore = _dtStore.concat(_dtActive);
        	_dtActive = new Array();
    	    _dsStore = _dsStore.concat(_dsActive);
        	_dsActive = new Array();
        	_ddStore = _ddStore.concat(_ddActive);
        	_ddActive = new Array();
        }
        
        public function createScreenVertex(source:Object3D, vertex:Vertex = null):ScreenVertex
        {
        	if (vertex) {
	        	if ((_screenVertices = _screenObjects[source]))
	        		return _screenVertices[vertex] || (_screenVertices[vertex] = new ScreenVertex());
	   			
	   			_screenVertices = _screenObjects[source] = new Dictionary();
	   			return _screenVertices[vertex] = new ScreenVertex();
        	}
        	
        	if ((_screenVertices = _screenObjects[source]))
        		return _screenVertices[source] || (_screenVertices[source] = new ScreenVertex());
   			
   			_screenVertices = _screenObjects[source] = new Dictionary();
   			return _screenVertices[source] = new ScreenVertex();
        }
        
        public function getScreenVertex(source:Object3D, vertex:Vertex = null):ScreenVertex
        {
        	if (vertex)
   				return _screenObjects[source][vertex];
   			
   			return _screenObjects[source][source];
        }
        
		public function createDrawTriangle(view:View3D, source:Object3D, face:Face, material:ITriangleMaterial = null, v0:ScreenVertex = null, v1:ScreenVertex = null, v2:ScreenVertex = null, uv0:UV = null, uv1:UV = null, uv2:UV = null):DrawTriangle
		{
			if (_dtStore.length) {
            	_dtActive.push(_tri = _dtStore.pop());
   			} else {
            	_dtActive.push(_tri = new DrawTriangle());
		        _tri.create = createDrawTriangle;
            }
            _tri.view = view;
            _tri.source = source;
            _tri.face = face;
            _tri.material = material;
            
            if (v0) {
	            _tri.v0 = v0;
	            _tri.v1 = v1;
	            _tri.v2 = v2;
	            _tri.uv0 = uv0;
	            _tri.uv1 = uv1;
	            _tri.uv2 = uv2;
            	_tri.calc();
            }
            return _tri;
		}
		
        public function createDrawSegment(view:View3D, source:Object3D, material:ISegmentMaterial = null, v0:ScreenVertex = null, v1:ScreenVertex = null):DrawSegment
        {
            if (_dsStore.length) {
            	_dsActive.push(_seg = _dsStore.pop());
            	_seg.create = createDrawSegment;
        	} else {
            	_dsActive.push(_seg = new DrawSegment());
	            _seg.create = createDrawSegment;
            }
            _seg.view = view;
            _seg.source = source;
            _seg.material = material;
            
            if (v0) {
	            _seg.v0 = v0;
	            _seg.v1 = v1;
	            _seg.calc();
            }
            return _seg;
        }
        
        public function createDrawDisplayObject(view:View3D, session:AbstractRenderSession, displayobject:DisplayObject, screenvertex:ScreenVertex):DrawDisplayObject
        {
            if (_ddStore.length) {
            	_ddActive.push(_ddo = _ddStore.pop());
        	} else {
            	_ddActive.push(_ddo = new DrawDisplayObject());
            }
            
            _ddo.view = view;
            _ddo.session = session;
            _ddo.displayobject = displayobject;
            _ddo.screenvertex = screenvertex;
            _ddo.calc();
            
            return _ddo;
        }
    }
}
