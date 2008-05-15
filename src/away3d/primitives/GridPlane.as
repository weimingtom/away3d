package away3d.primitives
{
    import away3d.core.*;
    import away3d.core.base.*;
    import away3d.core.stats.*;
    import away3d.core.utils.*;
    import away3d.materials.*;
    
    /** Grid plane */ 
    public class GridPlane extends WireMesh
    {
        public function GridPlane(init:Object = null)
        {
            super(init);

            var width:Number = ini.getNumber("width", 100, {min:0});
            var height:Number = ini.getNumber("height", 100, {min:0});
            var segments:int = ini.getInt("segments", 1, {min:1});
            var segmentsW:int = ini.getInt("segmentsW", segments, {min:1});
            var segmentsH:int = ini.getInt("segmentsH", segments, {min:1});
    		var yUp:Boolean = ini.getBoolean("yUp", true);
    		
            buildPlane(width, height, segmentsW, segmentsH, yUp);
        }

        private function buildPlane(width:Number, height:Number, segmentsW:int, segmentsH:int, yUp:Boolean):void
        {
        	var i:int;
        	var j:int;
        	
        	if (yUp) {
	            for (i = 0; i <= segmentsW; i++)
	                addSegment(new Segment(new Vertex((i/segmentsW - 0.5)*width, 0, -0.5*height), new Vertex((i/segmentsW - 0.5)*width, 0, 0.5*height)));
	
	            for (j = 0; j <= segmentsH; j++)
	                addSegment(new Segment(new Vertex(-0.5*width, 0, (j/segmentsH - 0.5)*height), new Vertex(0.5*width, 0, (j/segmentsH - 0.5)*height)));
        	} else {
        		for (i = 0; i <= segmentsW; i++)
	                addSegment(new Segment(new Vertex((i/segmentsW - 0.5)*width, -0.5*height, 0), new Vertex((i/segmentsW - 0.5)*width, 0.5*height, 0)));
	
	            for (j = 0; j <= segmentsH; j++)
	                addSegment(new Segment(new Vertex(-0.5*width, (j/segmentsH - 0.5)*height, 0), new Vertex(0.5*width, (j/segmentsH - 0.5)*height, 0)));
	       
        	}
	   		type = "GridPlane";
        	url = "primitive";
		}
    }
}
