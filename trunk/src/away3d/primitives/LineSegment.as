package away3d.primitives
{
    import away3d.core.base.*;
    import away3d.materials.*;
	import away3d.core.math.Number3D;
    
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
			var segments:Number = ini.getNumber("segments", 1, {min:1});
			var p1:Number3D = ini.getPosition("start") || new Number3D(-edge, 0, 0);
			var p2:Number3D = ini.getPosition("end") || new Number3D(edge, 0, 0);
			
			var i:int;
			var difx:Number;
			var dify:Number;
			var difz:Number;
			
			difx=(p1.x-p2.x)/segments;
			dify=(p1.y-p2.y)/segments;
			difz=(p1.z-p2.z)/segments;
					
			if(segments>1){
				for (i = 1; i <= segments; i++)
            	{
					_segment = new Segment(new Vertex(p1.x-(difx*(i)), p1.y-(dify*(i)), p1.z-(difz*(i))), new Vertex(p2.x+(difx*(segments-(i-1))), p2.y+(dify*(segments-(i-1))), p2.z+(difz*(segments-(i-1)))));
             		addSegment(_segment);
				}
			}else{
				_segment = new Segment(new Vertex(p1.x, p1.y, p1.z), new Vertex(p2.x, p2.y, p2.z));
             	addSegment(_segment);
			}
			
			type = "LineSegment";
        	url = "primitive";
        }
    
    }
}
