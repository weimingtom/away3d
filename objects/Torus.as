package away3d.objects
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;
    
    import flash.display.BitmapData;
    
    public class Torus extends Mesh3D
    {
        public var segmentsR:int;
        public var segmentsT:int;
    
        public var radius:Number;
        public var tube:Number;

        public function Torus(material:IMaterial, init:Object = null)
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
                    var d:Vertex3D = vertices[ixp * (segmentsT) + iyp];

                    var uva:NumberUV = new NumberUV(ix     / segmentsR, iy     / segmentsT);
                    var uvb:NumberUV = new NumberUV((ix+1) / segmentsR, iy     / segmentsT);
                    var uvc:NumberUV = new NumberUV(ix     / segmentsR, (iy+1) / segmentsT);
                    var uvd:NumberUV = new NumberUV((ix+1) / segmentsR, (iy+1) / segmentsT);

                    faces.push(new Face3D(a, b, c, null, uva, uvb, uvc));
                    faces.push(new Face3D(d, c, b, null, uvd, uvc, uvb));
                }
        }

        public function vertice(ix:int, iy:int):Vertex3D
        {
            return vertices[ix * (segmentsT) + iy];
        }

    }
}
