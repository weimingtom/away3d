package away3d.core.proto
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;

    import flash.geom.*;

    /** Traverser that updates time for all objects on scene */
    public class TickTraverser extends Traverser
    {
        protected var now:int;

        public function TickTraverser(now:int)
        {
            this.now = now;
        }

        public override function enter(node:Object3D):void
        {
            node.tick(now);
        }
    }
}
