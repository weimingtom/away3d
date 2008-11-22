package away3d.core.project;

	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.math.*;
	import away3d.materials.*;
	
	import flash.utils.*;
	
	class AbstractProjector
	 {
		public var source(getSource, setSource) : Object3D;
		public function new() {
		_dtStore = new Array();
		_dtActive = new Array();
		_dsStore = new Array();
		_dsActive = new Array();
		}
		
		var _source:Object3D;
		var _seg:DrawSegment;
		var _tri:DrawTriangle;
		var _dtStore:Array<Dynamic> ;
        var _dtActive:Array<Dynamic> ;
        var _dsStore:Array<Dynamic> ;
        var _dsActive:Array<Dynamic> ;
        
		var viewDictionary:Dictionary;
		
		var primitiveDictionary:Dictionary;
        
		public function getSource():Object3D{
			return _source;
		}
		
		public function setSource(val:Object3D):Object3D{
			if (_source == val)
				return;
			
			_source = val;
			
			viewDictionary = new Dictionary(true);
			return val;
		}
		
		public function primitives(view:View3D, viewTransform:Matrix3D, consumer:IPrimitiveConsumer):Void
		{
			if (!(primitiveDictionary = viewDictionary[view]))
				primitiveDictionary = viewDictionary[view] = new Dictionary(true);
		}
		
	    public function createDrawSegment(view:View3D, source:Object3D, material:ISegmentMaterial, v0:ScreenVertex, v1:ScreenVertex):DrawSegment
	    {
	        if (_dsStore.length) {
	        	_dsActive.push(_seg = _dsStore.pop());
	    	} else {
	        	_dsActive.push(_seg = new DrawSegment());
	            _seg.source = source;
	            _seg.create = createDrawSegment;
	        }
	        
	        _seg.view = view;
	        _seg.material = material;
	        _seg.v0 = v0;
	        _seg.v1 = v1;
	        _seg.calc();
	        
	        return _seg;
	    }
	    
		public function createDrawTriangle(view:View3D, source:Object3D, face:Face, material:ITriangleMaterial, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex, uv0:UV, uv1:UV, uv2:UV):DrawTriangle
		{
			if (_dtStore.length) {
	        	_dtActive.push(_tri = _dtStore.pop());
	   		} else {
	        	_dtActive.push(_tri = new DrawTriangle());
		        _tri.source = source;
		        _tri.create = createDrawTriangle;
		        _tri.generated = true;
	        }
	        
	        _tri.view = view;
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
