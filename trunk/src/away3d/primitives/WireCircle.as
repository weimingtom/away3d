package away3d.primitives
{
    import away3d.core.base.*;
    import away3d.core.utils.*;
    
    /** Wire circle */ 
    public class WireCircle extends WireMesh
    {
        public function WireCircle(init:Object = null)
        {
            super(init);

            var radius:Number = ini.getNumber("radius", 100, {min:0});
            var segments:int = ini.getInt("segments", 8, {min:3});
			var yUp:Boolean = ini.getBoolean("yUp", true);
			
            buildCircle(radius, segments, yUp);
        }
    
        private function buildCircle(radius:Number, segments:int, yUp:Boolean):void
        {
            var vertices:Array = [];
            var i:int;
            for (i = 0; i < segments; i++)
            {
                var u:Number = i / segments * 2 * Math.PI;
                if (yUp)
                	vertices.push(new Vertex(radius*Math.cos(u), 0, -radius*Math.sin(u)));
                else
                	vertices.push(new Vertex(radius*Math.cos(u), radius*Math.sin(u), 0));
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
