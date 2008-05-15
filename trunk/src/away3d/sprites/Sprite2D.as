package away3d.sprites
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.materials.*;
    import away3d.core.math.*;
    import away3d.core.base.*;
    import away3d.core.render.*;
    import away3d.core.base.*
    import away3d.core.utils.*;
    
    import flash.display.BitmapData;

    /** Simple billboard sprite */
    public class Sprite2D extends Object3D implements IPrimitiveProvider
    {
        private var center:Vertex = new Vertex();

        public var bitmap:BitmapData;
        public var scaling:Number;
        public var rotation:Number;
        public var smooth:Boolean;
        public var deltaZ:Number;
        
        private var primitive:DrawScaledBitmap;
    
        public function Sprite2D(init:Object = null)
        {
            super(init);
    
            scaling = ini.getNumber("scaling", 1, {min:0});
            rotation = ini.getNumber("rotation", 0);
            bitmap = ini.getBitmap("bitmap");
            smooth = ini.getBoolean("smooth", false);
            deltaZ = ini.getNumber("deltaZ", 0);
            primitive = new DrawScaledBitmap(this, smooth, bitmap);
            primitive.rotation = rotation;
        }
    
        override public function primitives(consumer:IPrimitiveConsumer, session:AbstractRenderSession):void
        {
        	super.primitives(consumer, session);
        	
            use namespace arcane;

            var sc:ScreenVertex = center.project(projection);
            if (!sc.visible)
                return;

            var persp:Number = projection.zoom / (1 + sc.z / projection.focus);
            sc.z += deltaZ;
            primitive.v = sc;
            primitive.scale = persp*scaling;
            primitive.calc();
            consumer.primitive(primitive);
        }
    }
}
