package away3d.primitives;

    import away3d.core.base.*;
    import away3d.materials.*;
    
    /**
    * Creates a 3d line segment.
    */ 
    class LineSegment extends Mesh {
        public var end(getEnd, setEnd) : Vertex;
        public var start(getStart, setStart) : Vertex;
        
        var _segment:Segment;
		
		override function getDefaultMaterial():IMaterial
		{
			return ini.getSegmentMaterial("material") || new WireframeMaterial();
		}
		
		/**
		 * Defines the starting vertex.
		 */
        public function getStart():Vertex{
            return _segment.v0;
        }

        public function setStart(value:Vertex):Vertex{
            _segment.v0 = value;
        	return value;
           }
		
		/**
		 * Defines the ending vertex.
		 */
        public function getEnd():Vertex{
            return _segment.v1;
        }
		
        public function setEnd(value:Vertex):Vertex{
            _segment.v1 = value;
        	return value;
           }
		
		/**
		 * Creates a new <code>LineSegment</code> object.
		 *
		 * @param	init			[optional]	An initialisation object for specifying default instance properties.
		 */
        public function new(?init:Dynamic = null)
        {
            super(init);
			
            var edge:Int = ini.getNumber("edge", 100, {min:0}) / 2;
            _segment = new Segment(new Vertex(-edge, 0, 0), new Vertex(edge, 0, 0));
            addSegment(_segment);
			
			type = "LineSegment";
        	url = "primitive";
        }
    
    }
