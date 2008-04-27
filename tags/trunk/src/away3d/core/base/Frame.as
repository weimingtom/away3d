package away3d.core.base
{
    import away3d.core.*;
    import away3d.materials.*;
    import away3d.core.math.*;
    
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
