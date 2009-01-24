package away3d.primitives
{
    import away3d.core.base.*;
    import away3d.materials.*;
    
    /**
    * Creates a 3d line segment.
    */ 
    public class LineSegment extends Mesh
    {
        private var _segment:Segment;
		
		protected override function getDefaultMaterial():IMaterial
		{
			return ini.getSegmentMaterial("material") || new WireframeMaterial();
		}
		
		/**
		 * Defines the starting vertex.
		 */
        public function get start():Vertex
        {
            return _segment.v0;
        }

        public function set start(value:Vertex):void
        {
            _segment.v0 = value;
        }
		
		/**
		 * Defines the ending vertex.
		 */
        public function get end():Vertex
        {
            return _segment.v1;
        }
		
        public function set end(value:Vertex):void
        {
            _segment.v1 = value;
        }
		
		/**
		 * Creates a new <code>LineSegment</code> object.
		 *
		 * @param	init			[optional]	An initialisation object for specifying default instance properties.
		 */
        public function LineSegment(init:Object = null)
        {
            super(init);
			
            var edge:Number = ini.getNumber("edge", 100, {min:0}) / 2;
            var v1:Vertex = ini.getObjectOrInit("start", Vertex) as Vertex || new Vertex(-edge, 0, 0);
            var v2:Vertex = ini.getObjectOrInit("end", Vertex) as Vertex || new Vertex(edge, 0, 0);
            _segment = new Segment(v1, v2);
            addSegment(_segment);
			
			type = "LineSegment";
        	url = "primitive";
        }
    
    }
}
