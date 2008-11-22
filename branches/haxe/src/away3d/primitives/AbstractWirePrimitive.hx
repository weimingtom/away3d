package away3d.primitives;

	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.core.math.*;
	import away3d.core.utils.*;
	import away3d.materials.*;
    
	use namespace arcane;
	
    /**
    * Creates a 3d cone primitive.
    */ 
    class AbstractWirePrimitive extends Mesh {
		/** @private */
		
		/** @private */
		arcane var _v:Vertex;
		/** @private */
		arcane var _vStore:Array<Dynamic> ;
		/** @private */
        arcane var _vActive:Array<Dynamic> ;
		/** @private */
		arcane var _segment:Segment;
		/** @private */
		arcane var _segmentStore:Array<Dynamic> ;
		/** @private */
        arcane var _segmentActive:Array<Dynamic> ;
		/** @private */
        arcane var _primitiveDirty:Bool;
		/** @private */
		arcane function createVertex(?x:Int = 0, ?y:Int = 0, ?z:Int = 0):Vertex
		{
			if (_vStore.length) {
            	_vActive.push(_v = _vStore.pop());
	            _v._x = x;
	            _v._y = y;
	            _v._z = z;
   			} else {
            	_vActive.push(_v = new Vertex(x, y, z));
      		}
            return _v;
		}
		/** @private */
		arcane function createSegment(v0:Vertex, v1:Vertex, ?material:ISegmentMaterial = null):Segment
		{
			if (_segmentStore.length) {
            	_segmentActive.push(_segment = _segmentStore.pop());
	            _segment.v0 = v0;
	            _segment.v1 = v1;
	            _segment.material = material;
			} else {
            	_segmentActive.push(_segment = new Segment(v0, v1, material));
   			}
            return _segment;
		}
		
		var _index:Int;
		
		override function getDefaultMaterial():IMaterial
		{
			return ini.getSegmentMaterial("material") || new WireframeMaterial();
		}
		
		/**
		 * Creates a new <code>AbstractPrimitive</code> object.
		 *
		 * @param	init			[optional]	An initialisation object for specifying default instance properties
		 */
		public function new(?init:Dynamic = null)
		{
			
			_vStore = new Array();
			_vActive = new Array();
			_segmentStore = new Array();
			_segmentActive = new Array();
			super(init);
		}
		
		public override function updateObject():Void
    	{
    		if (_primitiveDirty)
        		buildPrimitive();
        	
        	super.updateObject();
     	}
     	
		/**
		 * Builds the vertex, face and uv objects that make up the 3d primitive.
		 */
    	public function buildPrimitive():Void
    	{
    		_primitiveDirty = false;
    		
    		//remove all elements from the mesh
    		_index = segments.length;
    		while (_index--)
    			removeSegment(segments[_index]);
    		
    		//clear vertex objects
    		_vStore = _vStore.concat(_vActive);
        	_vActive = new Array();
        	
        	//clear segment objects
    		_segmentStore = _segmentStore.concat(_segmentActive);
        	_segmentActive = new Array();
    	}
    }
