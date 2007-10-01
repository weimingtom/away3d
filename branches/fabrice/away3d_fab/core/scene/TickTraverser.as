package away3d.core.scene
{
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
