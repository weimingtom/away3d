package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;

    import flash.geom.*;

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

        public override function apply(object:Object3D):void
        {
            if (object is IPrimitiveProvider)
            {
                var provider:IPrimitiveProvider = (object as IPrimitiveProvider);
                var projection:Projection = new Projection(transform, view.camera.focus, view.camera.zoom);
                provider.primitives(projection, consumer);
            }

            if (object is ILightProvider)
            {
                var lightsource:ILightProvider = (object as ILightProvider);
                lightsource.light(transform, lights);
            }
        }

    }
}
