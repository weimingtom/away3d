package away3d.objects
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.mesh.*;
    import away3d.core.material.*;
    import away3d.core.utils.*;
    
    /** Wire circle */ 
    public class WireCircle extends WireMesh
    {
        public function WireCircle(init:Object = null)
        {
            super(init);
            
            init = Init.parse(init);

            var radius:Number = init.getNumber("radius", 100, {min:0});
            var segments:int = init.getInt("segments", 8, {min:3});

            buildCircle(radius, segments);
        }
    
        private function buildCircle(radius:Number, segments:int):void
        {
            var vertices:Array = [];
            var i:int;
            for (i = 0; i < segments; i++)
            {
                var u:Number = i / segments * 2 * Math.PI;
                vertices.push(new Vertex(radius*Math.cos(u), 0, radius*Math.sin(u)));
            }

            for (i = 0; i < segments; i++)
			{
                addSegment(new Segment(vertices[i], vertices[(i+1) % segments]));
			}
			type = "WireCircle";
        	url = "primitive";
        }

    }
}
