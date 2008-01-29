package away3d.objects
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.mesh.*;
    import away3d.core.material.*;
    import away3d.core.utils.*;
	import away3d.core.stats.*;
    
    /** Grid plane */ 
    public class GridPlane extends WireMesh
    {
        public function GridPlane(init:Object = null)
        {
            super(init);
            
            init = Init.parse(init);

            var width:Number = init.getNumber("width", 100, {min:0});
            var height:Number = init.getNumber("height", 100, {min:0});
            var segments:int = init.getInt("segments", 1, {min:1});
            var segmentsW:int = init.getInt("segmentsW", segments, {min:1});
            var segmentsH:int = init.getInt("segmentsH", segments, {min:1});
    
            buildPlane(width, height, segmentsW, segmentsH);
        }

        private function buildPlane(width:Number, height:Number, segmentsW:int, segmentsH:int):void
        {
            for (var i:int = 0; i <= segmentsW; i++)
                addSegment(new Segment(new Vertex((i/segmentsW - 0.5)*width, 0, -0.5*height), new Vertex((i/segmentsW - 0.5)*width, 0, 0.5*height)));

            for (var j:int = 0; j <= segmentsH; j++)
                addSegment(new Segment(new Vertex(-0.5*width, 0, (j/segmentsH - 0.5)*height), new Vertex(0.5*width, 0, (j/segmentsH - 0.5)*height)));
       
	   		type = "GridPlane";
        	url = "primitive";
		}
    }
}
