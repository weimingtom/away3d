package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.block.*;

    import flash.geom.*;

    public class PrimitiveArray implements IPrimitiveConsumer
    {
        private var triangles:Array = [];

        private var clip:Clipping;
        private var blockers:Array;

        public function PrimitiveArray(clip:Clipping, blockers:Array)
        {
            this.clip = clip;
            this.blockers = blockers;
        }

        public function primitive(pri:DrawPrimitive):void
        {
            if (clip.check(pri))
            {
                var blockercount:int = blockers.length;
                var i:int = 0;
                while (i < blockercount)
                {          
                    var blocker:Blocker = blockers[i];
                    if (blocker.screenZ > pri.minZ)
                        break;
                    if (blocker.block(pri))
                        return;
                    i++;
                }
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
