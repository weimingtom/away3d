package away3d.objects
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;
    
    /** Segment */ 
    public class Segment extends Mesh3D
    {
        public function get v0():Vertex3D
        {
            return vertices[0];
        }

        public function get v1():Vertex3D
        {
            return vertices[1];
        }

        public function Segment(material:IMaterial = null, edge:Number = 0, init:Object = null)
        {
            super(material, init);
    
            var a:Vertex3D = new Vertex3D(0, 0, 0); 
            var b:Vertex3D = new Vertex3D(1, 0, 0);

            addVertex3D(a);
            addVertex3D(b);

            segments.push(new Segment3D(a, b));
        }
    
    }
}
