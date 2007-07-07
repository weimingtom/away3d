package away3d.objects
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;
    
    /** Wire circle */ 
    public class WireCircle extends Mesh3D
    {
        public function WireCircle(material:ISegmentMaterial, init:Object = null)
        {
            super(material, init);
            
            init = Init.parse(init);

            var radius:Number = init.getNumber("radius", 100, {min:0});
            var segmentsR:int = init.getInt("segmentsR", 8, {min:3});

            buildCircle(radius, segmentsR);
        }
    
        private function buildCircle(radius:Number, segmentsR:int):void
        {
            for (var ix:int = 0; ix < segmentsR; ix++)
            {
                var u:Number = ix / segmentsR * 2 * Math.PI;
                vertices.push(new Vertex3D(radius*Math.cos(u), 0, radius*Math.sin(u)));
            }

            for (ix = 0; ix < segmentsR; ix++)
            {
                var ixp:int = (ix+1) % segmentsR;
                var a:Vertex3D = vertices[ix ]; 
                var b:Vertex3D = vertices[ixp];

                segments.push(new Segment3D(a, b));
            }
        }

        public function vertice(ix:int):Vertex3D
        {
            return vertices[ix];
        }

    }
}
