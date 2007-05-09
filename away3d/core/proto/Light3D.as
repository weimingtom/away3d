package away3d.core.proto
{
    import away3d.core.*;
    import away3d.core.geom.*;
    import away3d.core.math.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.material.*;
    
    public class Light3D extends Object3D implements ILightProvider, IPrimitiveProvider
    {
        public var color:int;
        public var ambient:Number;
        public var diffuse:Number;
        public var specular:Number;
        public var showsource:Boolean = true;

        public function Light3D(color:int, ambient:Number, diffuse:Number, specular:Number, init:Object = null)
        {
            super(init);

            var distance:Number = 30;
            if (init)
            {
                distance = init.distance || 30;
            }

            this.color = color;
            this.ambient = ambient * distance * distance;
            this.diffuse = diffuse * distance * distance;
            this.specular = specular * distance * distance;
        }

        public function light(transform:Matrix3D, consumer:ILightConsumer):void
        {
            consumer.pointLight(transform, color, ambient, diffuse, specular);
        }

        public function primitives(projection:Projection, consumer:IPrimitiveConsumer):void
        {
            if (!showsource)
                return;

            var v:Vertex3D = new Vertex3D(0, 0, 0);
            var vp:Vertex2D = v.project(projection);
            if (!vp.visible)
                return;

            var tri:DrawTriangle = new DrawTriangle();
            tri.v0 = new Vertex2D(vp.x + 3, vp.y + 2, vp.z);
            tri.v1 = new Vertex2D(vp.x - 3, vp.y + 2, vp.z);
            tri.v2 = new Vertex2D(vp.x, vp.y - 3, vp.z);
            tri.calc();
            tri.source = this;
            tri.projection = projection;
            tri.material = new ColorMaterial(color);
            consumer.primitive(tri);

        }

    }
}
