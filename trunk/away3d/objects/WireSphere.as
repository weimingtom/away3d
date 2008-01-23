package away3d.objects
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.mesh.*;
    import away3d.core.material.*;
    import away3d.core.utils.*;
    
    /** Wire sphere */ 
    public class WireSphere extends WireMesh
    {
        public function WireSphere(init:Object = null)
        {
            super(init);
    
            init = Init.parse(init);

            var segmentsW:int = init.getInt("segmentsW", 8, {min:3});
            var segmentsH:int = init.getInt("segmentsH", 6, {min:2})
            var radius:Number = init.getNumber("radius", 100, {min:0});

            buildWireSphere(radius, segmentsW, segmentsH);
        }
    
        private var grid:Array;

        private function buildWireSphere(radius:Number, segmentsW:int, segmentsH:int):void
        {
            var i:int;
            var j:int;

            grid = new Array(segmentsH + 1);
            for (j = 0; j <= segmentsH; j++)  
            { 
                var horangle:Number = j / segmentsH * Math.PI;
                var z:Number = -radius * Math.cos(horangle);
                var ringradius:Number = radius * Math.sin(horangle);

                grid[j] = new Array(segmentsW);

                var vertex:Vertex;
                for (i = 0; i < segmentsW; i++) 
                { 
                    var verangle:Number = 2 * i / segmentsW * Math.PI;
                    var x:Number = ringradius * Math.sin(verangle);
                    var y:Number = ringradius * Math.cos(verangle);

                    if ((i == 0) || ((0 < j) && (j < segmentsH)))
                        vertex = new Vertex(y, z, x);

                    grid[j][i] = vertex;
                }
            }

            for (j = 1; j <= segmentsH; j++) 
                for (i = 0; i < segmentsW; i++) 
                {
                    var a:Vertex = grid[j][i];
                    var b:Vertex = grid[j][(i-1+segmentsW) % segmentsW];
                    var c:Vertex = grid[j-1][(i-1+segmentsW) % segmentsW];
                    var d:Vertex = grid[j-1][i];

                    addSegment(new Segment(a, d));
                    addSegment(new Segment(b, c));
                    if (j < segmentsH)  
                        addSegment(new Segment(a, b));
                }
				
			type = "WireSphere";
        	url = "primitive";
        }

        public function vertex(i:int, j:int):Vertex
        {
            return grid[j][i];
        }
    }
}