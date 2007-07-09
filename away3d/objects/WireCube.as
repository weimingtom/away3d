package away3d.objects
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.geom.*;
    import away3d.core.mesh.*;
    import away3d.core.material.*;

    /** Wire cube */ 
    public class WireCube extends WireMesh
    {
        public function WireCube(init:Object = null)
        {
            super(init);
            
            init = Init.parse(init);

            var width:Number  = init.getNumber("width", 100, {min:0});
            var height:Number = init.getNumber("height", 100, {min:0});
            var depth:Number  = init.getNumber("depth", 100, {min:0});

            var v000:Vertex = new Vertex(-width/2, -height/2, -depth/2); 
            var v001:Vertex = new Vertex(-width/2, -height/2, +depth/2); 
            var v010:Vertex = new Vertex(-width/2, +height/2, -depth/2); 
            var v011:Vertex = new Vertex(-width/2, +height/2, +depth/2); 
            var v100:Vertex = new Vertex(+width/2, -height/2, -depth/2); 
            var v101:Vertex = new Vertex(+width/2, -height/2, +depth/2); 
            var v110:Vertex = new Vertex(+width/2, +height/2, -depth/2); 
            var v111:Vertex = new Vertex(+width/2, +height/2, +depth/2); 

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
        }
    }
    
}