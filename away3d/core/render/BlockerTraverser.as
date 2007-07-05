package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.block.*;

    import flash.geom.*;

    /** Traverser that gathers blocker for occlution culling */
    public class BlockerTraverser extends ProjectionTraverser
    {
        private var consumer:IBlockerConsumer;

        public function BlockerTraverser(consumer:IBlockerConsumer, view:View3D)
        {
            this.consumer = consumer;
            super(view);
        }

        public override function apply(object:Object3D):void
        {
            if (object is IBlockerProvider)
            {
                var provider:IBlockerProvider = (object as IBlockerProvider);
                var projection:Projection = new Projection(transform, view.camera.focus, view.camera.zoom);
                provider.blockers(projection, consumer);
            }
        }

    }
}
