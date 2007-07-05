package away3d.core.scene
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.render.*;

    /** Scene node that is transparent to mouse click */
    public class NoHitContainer extends ObjectContainer3D
    {
        public function NoHitContainer(init:Object = null, ...childarray)
        {
            super(init);

            for each (var child:Object3D in childarray)
                addChild(child);
        }

        public override function traverse(traverser:Traverser):void
        {
            if (traverser is FindHitTraverser)
                return;

            super.traverse(traverser);
        }

    }
}
