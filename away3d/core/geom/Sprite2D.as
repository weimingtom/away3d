package away3d.core.geom
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.render.*;
    import away3d.core.draw.*;
    import away3d.core.material.*;
    import away3d.core.math.*;

    import flash.display.BitmapData;

    /** Simple billboard sprite */
    public class Sprite2D extends Object3D implements IPrimitiveProvider
    {
        private var center:Vertex3D = new Vertex3D();

        public var bitmap:BitmapData;
        public var scaling:Number;
    
        public function Sprite2D(bitmap:BitmapData, scaling:Number = 1, init:Object = null)
        {
            super(init);
    
            this.bitmap = bitmap;
            this.scaling = scaling;
        }
    
        public function primitives(projection:Projection, consumer:IPrimitiveConsumer):void
        {
            var sc:Vertex2D = center.project(projection);
            var persp:Number = projection.zoom / (1 + sc.z / projection.focus);

            consumer.primitive(new DrawScaledBitmap(bitmap, sc, persp*scaling));
        }
    }
}
