package away3d.objects
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;
    
    /** Triangle */ 
    public class Triangle extends Mesh3D
    {
        public function get v0():Vertex3D
        {
            return vertices[0];
        }

        public function get v1():Vertex3D
        {
            return vertices[1];
        }

        public function get v2():Vertex3D
        {
            return vertices[2];
        }

        public function Triangle(material:IMaterial = null, bordermaterial:ISegmentMaterial = null, edge:Number = 0, init:Object = null)
        {
            super(material, init);
    
            if (edge == 0)
                edge = 170;

            edge /= 2;

            var s3:Number = 1 / Math.sqrt(3);

            var a:Vertex3D = new Vertex3D(0, 2 * s3 * edge, 0); 
            var b:Vertex3D = new Vertex3D(edge, - s3 * edge, 0);  
            var c:Vertex3D = new Vertex3D(-edge, - s3 * edge, 0);

            var uva:NumberUV = new NumberUV(0, 0);
            var uvb:NumberUV = new NumberUV(1, 0);
            var uvc:NumberUV = new NumberUV(0, 1);

            vertices.push(a);
            vertices.push(b);
            vertices.push(c);

            faces.push(new Face3D(a, b, c, null, uva, uvb, uvc));
            faces.push(new Face3D(a, c, b, null, uva, uvc, uvb));

            if (bordermaterial == null)
                bordermaterial = new WireframeMaterial(0x000000);

            segments.push(new Segment3D(a, b, bordermaterial));
            segments.push(new Segment3D(b, c, bordermaterial));
            segments.push(new Segment3D(c, a, bordermaterial));
        }
    
    }
}
