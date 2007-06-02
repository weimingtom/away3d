package away3d.objects
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;
    
    /** Wire torus */ 
    public class WireTorus extends Mesh3D
    {
        public var segmentsR:int;
        public var segmentsT:int;
    
        public var radius:Number;
        public var tube:Number;

        public function WireTorus(material:ISegmentMaterial, init:Object = null)
        {
            super(material, init);
            
            init = Init.parse(init);

            segmentsR = init.getInt("segmentsR", 8, {min:3});
            segmentsT = init.getInt("segmentsT", 6, {min:3})
            radius = init.getInt("radius", 100, {min:0});
            tube = init.getInt("tube", 40, {min:0, max:radius});

            buildTorus();
        }
    
        private function buildTorus():void
        {
            for (var ix:int = 0; ix < segmentsR; ix++)
                for (var iy:int = 0; iy < segmentsT; iy++)
                {
                    var u:Number = ix / segmentsR * 2 * Math.PI;
                    var v:Number = iy / segmentsT * 2 * Math.PI;
                    vertices.push(new Vertex3D((radius + tube*Math.cos(v))*Math.cos(u), tube*Math.sin(v), (radius + tube*Math.cos(v))*Math.sin(u)));
                }

            for (ix = 0; ix < segmentsR; ix++)
                for (iy = 0; iy < segmentsT; iy++)
                {
                    var ixp:int = (ix+1) % segmentsR;
                    var iyp:int = (iy+1) % segmentsT;
                    var a:Vertex3D = vertices[ix  * (segmentsT) + iy]; 
                    var b:Vertex3D = vertices[ixp * (segmentsT) + iy];
                    var c:Vertex3D = vertices[ix  * (segmentsT) + iyp]; 

                    segments.push(new Segment3D(a, b));
                    segments.push(new Segment3D(a, c));
                }
        }

        public function vertice(ix:int, iy:int):Vertex3D
        {
            return vertices[ix * (segmentsT) + iy];
        }

    }
}
