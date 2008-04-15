package away3d.core.traverse
{
	import away3d.core.base.*;
	
    /** Traverser that updates time for all objects on scene */
    public class TickTraverser extends Traverser
    {
        public var now:int;

        public function TickTraverser()
        {
        }

        public override function enter(node:Object3D):void
        {
            node.tick(now);
        }
    }
}
