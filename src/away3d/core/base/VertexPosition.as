package away3d.core.base
{
    import away3d.core.*;
    import away3d.materials.*;
    import away3d.core.math.*;
    import away3d.core.base.*;
    
    import flash.geom.Matrix;
    import flash.events.Event;

    public class VertexPosition
    {
        use namespace arcane;
        
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
            vertex._x = vertex._x * (1 - k) + x * k;
            vertex._y = vertex._y * (1 - k) + y * k;
            vertex._z = vertex._z * (1 - k) + z * k;
        }
    }
}
