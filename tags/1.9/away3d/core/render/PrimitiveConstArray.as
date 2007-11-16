package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;

    import flash.geom.*;

    /** Constant size array for storing drawing primitives */
    public class PrimitiveConstArray implements IPrimitiveConsumer
    {
        private var triangle_count:int = 0;
        private var triangle_index:int = -1;
        private var triangles:Array;
        private var clip:Clipping;

        public function PrimitiveConstArray(clip:Clipping)
        {
            this.clip = clip;
            this.triangles = new Array(1000);
            this.triangle_count = 1000;
        }

        public function primitive(pri:DrawPrimitive):void
        {
            if (clip.check(pri))
            {
                triangle_index++;
                if (triangle_index == triangle_count)
                {
                    triangle_count++;
                    triangles.push(pri);
                }
                else
                    triangles[triangle_index] = pri;

                //triangles.push(pri);
            }
        }

        public function list():Array
        {
            return triangles;
        }

    }
}
