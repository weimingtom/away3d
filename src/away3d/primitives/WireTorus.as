package away3d.primitives
{
    import away3d.core.*;
    import away3d.core.base.*;
    import away3d.core.math.*;
    import away3d.core.utils.*;
    import away3d.materials.*;
    
    /** Wire torus */ 
    public class WireTorus extends WireMesh
    {
        public function WireTorus(init:Object = null)
        {
            super(init);
            
            init = Init.parse(init);

            var radius:Number = init.getNumber("radius", 100, {min:0});
            var tube:Number = init.getNumber("tube", 40, {min:0, max:radius});
            var segmentsR:int = init.getInt("segmentsR", 8, {min:3});
            var segmentsT:int = init.getInt("segmentsT", 6, {min:3})
			var yUp:Boolean = init.getBoolean("yUp", true);
			
            buildTorus(radius, tube, segmentsR, segmentsT, yUp);
        }
    
        private var grid:Array;

        private function buildTorus(radius:Number, tube:Number, segmentsR:int, segmentsT:int, yUp:Boolean):void
        {
            var i:int;
            var j:int;

            grid = new Array(segmentsR);
            for (i = 0; i < segmentsR; i++)
            {
                grid[i] = new Array(segmentsT);
                for (j = 0; j < segmentsT; j++)
                {
                    var u:Number = i / segmentsR * 2 * Math.PI;
                    var v:Number = j / segmentsT * 2 * Math.PI;
                    
                    if (yUp)
                    	grid[i][j] = new Vertex((radius + tube*Math.cos(v))*Math.cos(u), tube*Math.sin(v), (radius + tube*Math.cos(v))*Math.sin(u));
                    else
                    	grid[i][j] = new Vertex((radius + tube*Math.cos(v))*Math.cos(u), -(radius + tube*Math.cos(v))*Math.sin(u), tube*Math.sin(v));
                }
            }

            for (i = 0; i < segmentsR; i++)
                for (j = 0; j < segmentsT; j++)
                {
                    addSegment(new Segment(grid[i][j], grid[(i+1) % segmentsR][j]));
                    addSegment(new Segment(grid[i][j], grid[i][(j+1) % segmentsT]));
                }
				
			type = "WireTorus";
        	url = "primitive";
				
        }

        public function vertex(i:int, j:int):Vertex
        {
            return vertices[i][j];
        }

    }
}
