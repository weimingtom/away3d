package away3d.core.mesh
{
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.mesh.*;
    
    import flash.geom.Matrix;
    import flash.events.Event;

    public class VertexPosition
    {
        public var x:Number;
        public var y:Number;
        public var z:Number;

        public var vertex:Vertex;

        public function VertexPosition(vertex:Vertex)
        {
            this.vertex = vertex;
            this.x = 0;
            this.y = 0;
            this.z = 0;
        }

        public function adjust(k:Number = 1):void
        {
            vertex.x = vertex.x * (1 - k) + x * k;
            vertex.y = vertex.y * (1 - k) + y * k;
            vertex.z = vertex.z * (1 - k) + z * k;
        }
    }
}
