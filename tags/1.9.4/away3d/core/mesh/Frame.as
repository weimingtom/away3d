package away3d.core.mesh
{
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.mesh.*;
    
    import flash.geom.Matrix;
    import flash.events.Event;

    public class Frame
    {
        public var vertexpositions:Array = [];

        public function Frame()
        {
        }

        public function adjust(k:Number = 1):void
        {
            for each (var vertexposition:VertexPosition in vertexpositions)
                vertexposition.adjust(k);
        }
    }
}
