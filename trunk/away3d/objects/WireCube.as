package away3d.objects
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.mesh.*;
    import away3d.core.material.*;
    import away3d.core.utils.*;

    /** Wire cube */ 
    public class WireCube extends WireMesh
    {
        public var v000:Vertex;
        public var v001:Vertex;
        public var v010:Vertex;
        public var v011:Vertex;
        public var v100:Vertex;
        public var v101:Vertex;
        public var v110:Vertex;
        public var v111:Vertex;

        public function WireCube(init:Object = null)
        {
            super(init);
            
            init = Init.parse(init);

            var width:Number  = init.getNumber("width", 100, {min:0});
            var height:Number = init.getNumber("height", 100, {min:0});
            var depth:Number  = init.getNumber("depth", 100, {min:0});

            v000 = new Vertex(-width/2, -height/2, -depth/2); 
            v001 = new Vertex(-width/2, -height/2, +depth/2); 
            v010 = new Vertex(-width/2, +height/2, -depth/2); 
            v011 = new Vertex(-width/2, +height/2, +depth/2); 
            v100 = new Vertex(+width/2, -height/2, -depth/2); 
            v101 = new Vertex(+width/2, -height/2, +depth/2); 
            v110 = new Vertex(+width/2, +height/2, -depth/2); 
            v111 = new Vertex(+width/2, +height/2, +depth/2); 

            addSegment(new Segment(v000, v001));
            addSegment(new Segment(v011, v001));
            addSegment(new Segment(v011, v010));
            addSegment(new Segment(v000, v010));

            addSegment(new Segment(v100, v000));
            addSegment(new Segment(v101, v001));
            addSegment(new Segment(v111, v011));
            addSegment(new Segment(v110, v010));

            addSegment(new Segment(v100, v101));
            addSegment(new Segment(v111, v101));
            addSegment(new Segment(v111, v110));
            addSegment(new Segment(v100, v110));
			
			type = "WireCube";
        	url = "primitive";
        }

    }
    
}