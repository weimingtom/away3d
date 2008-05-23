package away3d.primitives
{
	import away3d.core.*;
	import away3d.core.base.*;
	import away3d.core.math.*;
	import away3d.core.utils.*;
	import away3d.materials.*;
    
    /**
    * Creates a 3d cone primitive.
    */ 
    public class AbstractWirePrimitive extends WireMesh
    {
    	use namespace arcane;
		/** @private */
		arcane var _v:Vertex;
		/** @private */
		arcane var _vStore:Array = new Array();
		/** @private */
        arcane var _vActive:Array = new Array();
		/** @private */
		arcane var _segment:Segment;
		/** @private */
		arcane var _segmentStore:Array = new Array();
		/** @private */
        arcane var _segmentActive:Array = new Array();
		/** @private */
        arcane var _primitiveDirty:Boolean;
		/** @private */
		arcane function createVertex(x:Number = 0, y:Number = 0, z:Number = 0):Vertex
		{
			if (_vStore.length) {
            	_vActive.push(_v = _vStore.pop());
	            _v.x = x;
	            _v.y = y;
	            _v.z = z;
   			} else {
            	_vActive.push(_v = new Vertex(x, y, z));
      		}
            return _v;
		}
		/** @private */
		arcane function createSegment(v0:Vertex, v1:Vertex, material:ISegmentMaterial = null):Segment
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
		
		/**
		 * @inheritDoc
		 */
        public override function get sceneTransform():Matrix3D
        {
        	if (_primitiveDirty)
        		buildPrimitive();
        	
        	return super.sceneTransform;
        }
		
		/**
		 * Creates a new <code>AbstractPrimitive</code> object.
		 *
		 * @param	init			[optional]	An initialisation object for specifying default instance properties
		 */
		public function AbstractWirePrimitive(init:Object = null)
		{
			super(init);
		}
		
		/**
		 * Builds the vertex, face and uv objects that make up the 3d primitive.
		 */
    	public function buildPrimitive():void
    	{
    		_primitiveDirty = false;
    		
    		//remove all elements from the mesh
    		for each (_segment in segments)
    			removeSegment(_segment);
    		
    		//clear vertex objects
    		_vStore = _vStore.concat(_vActive);
        	_vActive = new Array();
        	
        	//clear segment objects
    		_segmentStore = _segmentStore.concat(_segmentActive);
        	_segmentActive = new Array();
    	}
    }
}