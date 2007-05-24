package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.block.*;

    import flash.geom.*;

    public class BlockerTraverser extends ProjectionTraverser
    {
        private var consumer:IBlockerConsumer;

        public function BlockerTraverser(consumer:IBlockerConsumer, camera:Camera3D)
        {
            this.consumer = consumer;
            super(camera);
        }

        public override function apply(object:Object3D):void
        {
            if (object is IBlockerProvider)
            {
                var provider:IBlockerProvider = (object as IBlockerProvider);
                var projection:Projection = new Projection(view, camera.focus, camera.zoom);
                provider.blockers(projection, consumer);
            }
        }

    }
}
