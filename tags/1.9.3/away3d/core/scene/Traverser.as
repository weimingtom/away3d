package away3d.core.scene
{
    /** Base abstract class for all actions on the whole scene */
    public class Traverser
    {
        public function match(node:Object3D):Boolean
        {
            return true;
        }

        public function enter(node:Object3D):void
        {
        }

        public function leave(node:Object3D):void
        {
        }

        public function apply(node:Object3D):void
        {
        }
    }
}

