package away3d.core.scene
{
    import away3d.core.*;
    import away3d.core.mesh.*;
    import away3d.core.math.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.material.*;
    import away3d.core.utils.*;

    /** Light source */ 
    public class Light3D extends Object3D implements ILightProvider, IPrimitiveProvider, IClonable
    {
        public var color:int;
        public var ambient:Number;
        public var diffuse:Number;
        public var specular:Number;
        public var debug:Boolean;

        public function Light3D(init:Object = null)
        {
            super(init);

            init = Init.parse(init);

            var brightness:Number = init.getNumber("brightness", 1);
            var distance:Number = init.getNumber("distance", Math.sqrt(1000));
            color = init.getColor("color", 0xFFFFFF);
            ambient = init.getNumber("ambient", 1) * distance * distance * brightness;
            diffuse = init.getNumber("diffuse", 1) * distance * distance * brightness;
            specular = init.getNumber("specular", 1) * distance * distance * brightness;
            debug = init.getBoolean("debug", false);
        }

        public function light(transform:Matrix3D, consumer:ILightConsumer):void
        {
            consumer.pointLight(transform, color, ambient, diffuse, specular);
        }

        public function primitives(projection:Projection, consumer:IPrimitiveConsumer):void
        {
            use namespace arcane;

            if (!debug)
                return;

            var v:Vertex = new Vertex(0, 0, 0);
            var vp:ScreenVertex = v.project(projection);
            if (!vp.visible)
                return;

            var tri:DrawTriangle = new DrawTriangle();
            tri.v0 = new ScreenVertex(vp.x + 3, vp.y + 2, vp.z);
            tri.v1 = new ScreenVertex(vp.x - 3, vp.y + 2, vp.z);
            tri.v2 = new ScreenVertex(vp.x, vp.y - 3, vp.z);
            tri.calc();
            tri.source = this;
            tri.projection = projection;
            tri.material = new ColorMaterial(color);
            consumer.primitive(tri);

        }

        public override function clone(object:* = null):*
        {
            var light:Light3D = object || new Light3D();
            super.clone(light);
            light.color = color;
            light.ambient = ambient;
            light.diffuse = diffuse;
            light.specular = specular;
            light.debug = debug;
            return light;
        }

    }
}
