package away3d.core.project
{
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.math.*;
	import away3d.materials.*;
	
	import flash.utils.*;
	
	public class AbstractProjector
	{
		private var _sv:ScreenVertex;
		private var _bill:DrawBillboard;
		private var _seg:DrawSegment;
		private var _tri:DrawTriangle;
		protected var _svStore:Array = new Array();
        protected var _svActive:Array = new Array();
		protected var _dtStore:Array = new Array();
        protected var _dtActive:Array = new Array();
        protected var _dsStore:Array = new Array();
        protected var _dsActive:Array = new Array();
        protected var _dbStore:Array = new Array();
        protected var _dbActive:Array = new Array();
        
		protected var sourceDictionary:Dictionary = new Dictionary(true);
		
		protected var primitiveDictionary:Dictionary;
        
        public var view:View3D
		
		public function reset():void
		{
			_svStore = _svStore.concat(_svActive);
			_svActive = new Array();
			_dtStore = _dtStore.concat(_dtActive);
			_dtActive = new Array();
			_dsStore = _dsStore.concat(_dsActive);
			_dsActive = new Array();
			_dbStore = _dbStore.concat(_dbActive);
			_dbActive = new Array();
		}
		
		public function primitives(source:Object3D, viewTransform:Matrix3D, consumer:IPrimitiveConsumer):void
		{
			if (!(primitiveDictionary = sourceDictionary[source]))
				primitiveDictionary = sourceDictionary[source] = new Dictionary(true);
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
	}
}