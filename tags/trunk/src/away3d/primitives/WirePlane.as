package away3d.primitives
{
    import away3d.core.*;
    import away3d.core.base.*;
    import away3d.core.utils.*;
    import away3d.materials.*;
    
    /** Wire plane */ 
    public class WirePlane extends WireMesh
    {
        public function WirePlane(init:Object = null)
        {
            super(init);
            
            init = Init.parse(init);

            var width:Number = init.getNumber("width", 100, {min:0});
            var height:Number = init.getNumber("height", 100, {min:0});
            var segments:int = init.getInt("segments", 1, {min:1});
            var segmentsW:int = init.getInt("segmentsW", segments, {min:1});
            var segmentsH:int = init.getInt("segmentsH", segments, {min:1});
    		var yUp:Boolean = init.getBoolean("yUp", true);
    		
            buildWirePlane(width, height, segmentsW, segmentsH, yUp);
        }

        private var grid:Array;

        private function buildWirePlane(width:Number, height:Number, segmentsW:int, segmentsH:int, yUp:Boolean):void
        {
            var i:int;
            var j:int;

            grid = new Array(segmentsW+1);
            for (i = 0; i <= segmentsW; i++)
            {
                grid[i] = new Array(segmentsH+1);
                for (j = 0; j <= segmentsH; j++) {
                	if (yUp)
                    	grid[i][j] = new Vertex((i / segmentsW - 0.5) * width, 0, (j / segmentsH - 0.5) * height);
                    else
                    	grid[i][j] = new Vertex((i / segmentsW - 0.5) * width, (j / segmentsH - 0.5) * height, 0);
                }
            }

            for (i = 0; i < segmentsW; i++)
                for (j = 0; j < segmentsH + 1; j++)
                    addSegment(new Segment(grid[i][j], grid[i+1][j]));

            for (i = 0; i < segmentsW + 1; i++)
                for (j = 0; j < segmentsH; j++)
                    addSegment(new Segment(grid[i][j], grid[i][j+1]));
					
			type = "WirePlane";
        	url = "primitive";
        }

        public function vertex(i:int, j:int):Vertex
        {
            return grid[i][j];
        }
    }
}
