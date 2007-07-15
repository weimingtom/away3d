package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;

    /** Traverser that gathers drawing primitives to render the scene */
    public class PrimitiveTraverser extends ProjectionTraverser
    {
        private var consumer:IPrimitiveConsumer;
        private var lights:ILightConsumer;

        public function PrimitiveTraverser(consumer:IPrimitiveConsumer, lights:ILightConsumer, view:View3D)
        {
            this.consumer = consumer;
            this.lights = lights;
            super(view);
        }

        public override function apply(node:Object3D):void
        {
            var projection:Projection = new Projection(view, node.sceneTransform);
            if (node is IPrimitiveProvider)
            {
                var provider:IPrimitiveProvider = (node as IPrimitiveProvider);
                provider.primitives(projection, consumer);
            }

            if (node is ILightProvider)
            {
                var lightsource:ILightProvider = (node as ILightProvider);
                lightsource.light(projection, lights);
            }
        }

    }
}
