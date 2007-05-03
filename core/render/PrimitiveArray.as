package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;

    import flash.geom.*;

    public class PrimitiveArray implements IPrimitiveConsumer
    {
        private var triangles:Array;
        private var clip:Clipping;

        public function PrimitiveArray(clip:Clipping)
        {
            this.clip = clip;
            this.triangles = [];
        }

        public function primitive(pri:DrawPrimitive):void
        {
            if (clip.check(pri))
            {
                triangles.push(pri);
            }
        }

        public function list():Array
        {
            var triangles:Array = this.triangles;
            this.triangles = null;
            return triangles;
        }

    }
}
