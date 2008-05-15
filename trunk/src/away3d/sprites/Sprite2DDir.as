package away3d.sprites
{
    import away3d.core.*;
    import away3d.core.base.*;
    import away3d.core.render.*;
    import away3d.core.draw.*;
    import away3d.core.utils.*;

    import flash.display.BitmapData;
    import flash.utils.Dictionary;

    /** Billboard sprite with different image for each direction */
    public class Sprite2DDir extends Object3D implements IPrimitiveProvider
    {
        private var center:Vertex = new Vertex();

        public var scaling:Number;
        public var rotation:Number;
        public var smooth:Boolean;
        public var vertices:Array = [];
        public var bitmaps:Dictionary = new Dictionary();
        public var deltaZ:Number;
        
        private var primitive:DrawScaledBitmap;
    
        public function Sprite2DDir(init:Object = null)
        {
            super(init);
    
            scaling = ini.getNumber("scaling", 1, {min:0});
            rotation = ini.getNumber("rotation", 0);
            smooth = ini.getBoolean("smooth", false);
            deltaZ = ini.getNumber("deltaZ", 0);

            var btmps:Array = ini.getArray("bitmaps");
            for each (var btmp:Init in btmps)
            {
                btmp = Init.parse(btmp);
                var x:Number = btmp.getNumber("x", 0);
                var y:Number = btmp.getNumber("y", 0);
                var z:Number = btmp.getNumber("z", 0);
                var b:BitmapData = btmp.getBitmap("bitmap");
                add(x, y, z, b);
            }
            
            primitive = new DrawScaledBitmap(this, true);
            primitive.rotation = rotation;
        }

        public function add(x:Number, y:Number, z:Number, bitmap:BitmapData):void
        {
            if (bitmap)
            for each (var v:Vertex in vertices)
                if ((v.x == x) && (v.y == y) && (v.z == z))
                {
                    Debug.warning("Same base point for two bitmaps: "+v);
                    return;
                }

            var vertex:Vertex = new Vertex(x, y, z);
            vertices.push(vertex);
            bitmaps[vertex] = bitmap;
        }
    
        override public function primitives(consumer:IPrimitiveConsumer, session:AbstractRenderSession):void
        {
        	super.primitives(consumer, session);
        	
            use namespace arcane;

            if (vertices.length == 0)
                return;
                
            var minz:Number = Infinity;
            var bitmap:BitmapData = null;
            
            for each (var vertex:Vertex in vertices)
            {
                var z:Number = vertex.project(projection).z;
                if (z < minz)
                {
                    minz = z;
                    bitmap = bitmaps[vertex];
                }
            }

            if (bitmap == null)
                return;

            var sc:ScreenVertex = center.project(projection);
            if (!sc.visible)
                return;
                
            var persp:Number = projection.zoom / (1 + sc.z / projection.focus);
            sc.z += deltaZ;
            primitive.v = sc;
            primitive.scale = persp*scaling;
            primitive.bitmap = bitmap;
            primitive.calc();
            consumer.primitive(primitive);
        }
    }
}
