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
    import flash.utils.Dictionary;

    /** Billboard sprite with different image for each direction */
    public class Sprite2DDir extends Object3D implements IPrimitiveProvider
    {
        private var center:Vertex3D = new Vertex3D();

        public var scaling:Number;
        public var vertices:Array = [];
        public var bitmaps:Dictionary = new Dictionary();
    
        public function Sprite2DDir(scaling:Number = 1, init:Object = null)
        {
            super(init);
    
            this.scaling = scaling;
        }

        public function add(x:Number, y:Number, z:Number, bitmap:BitmapData):void
        {
            var v:Vertex3D = new Vertex3D(x, y, z);
            vertices.push(v);
            bitmaps[v] = bitmap;
        }
    
        public function primitives(projection:Projection, consumer:IPrimitiveConsumer):void
        {
            var minz:Number = Infinity;
            var bitmap:BitmapData = null;
            
            for each (var v:Vertex3D in vertices)
            {
                var z:Number = v.project(projection).z;
                if (z < minz)
                {
                    minz = z;
                    bitmap = bitmaps[v];
                }
            }

            if (bitmap == null)
                throw new Error("AAAAAA");

            var sc:Vertex2D = center.project(projection);
            if (!sc.visible)
            	return;
            	
            var persp:Number = projection.zoom / (1 + sc.z / projection.focus);

            consumer.primitive(new DrawScaledBitmap(this, bitmap, sc, persp*scaling));
        }
    }
}
