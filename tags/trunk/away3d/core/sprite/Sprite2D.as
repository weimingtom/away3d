package away3d.core.sprite
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.mesh.*;
    import away3d.core.render.*;
    import away3d.core.scene.*;
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
    
        public function Sprite2D(init:Object = null)
        {
            super(init);

            init = Init.parse(init);
    
            scaling = init.getNumber("scaling", 1, {min:0});
            rotation = init.getNumber("rotation", 0);
            bitmap = init.getBitmap("bitmap");
            smooth = init.getBoolean("smooth", false);
            deltaZ = init.getNumber("deltaZ", 0);
        }
    
        override public function primitives(consumer:IPrimitiveConsumer, session:RenderSession):void
        {
        	super.primitives(consumer, session);
        	
            use namespace arcane;

            var sc:ScreenVertex = center.project(projection);
            if (!sc.visible)
                return;
            
            var persp:Number = projection.zoom / (1 + sc.z / projection.focus);
            sc.z += deltaZ;
            consumer.primitive(new DrawScaledBitmap(this, bitmap, sc, persp*scaling, rotation, smooth));
        }
    }
}
