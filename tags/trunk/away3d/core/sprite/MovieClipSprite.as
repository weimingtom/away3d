package away3d.core.sprite
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.mesh.*;
    import away3d.core.render.*;
    import away3d.core.draw.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.utils.*;

    import flash.display.DisplayObject;

    public class MovieClipSprite extends Object3D implements IPrimitiveProvider
    {
        private var center:Vertex = new Vertex();

        public var movieclip:DisplayObject;
        public var scaling:Number;
        public var deltaZ:Number;

        public function MovieClipSprite(movieclip:DisplayObject, init:Object = null)
        {
            super(init);

            this.movieclip = movieclip;

            init = Init.parse(init);

            scaling = init.getNumber("scaling", NaN);
            deltaZ = init.getNumber("deltaZ", 0);
        }
    
        override public function primitives(consumer:IPrimitiveConsumer, session:RenderSession):void
        {
        	super.primitives(consumer, session);
        	
            use namespace arcane;

            var sc:ScreenVertex = center.project(projection);
            var persp:Number = projection.zoom / (1 + sc.z / projection.focus);
            sc.z += deltaZ;
            sc.x -= movieclip.width/2;
            sc.y -= movieclip.height/2;
            consumer.primitive(new DrawDisplayObject(this, movieclip, sc, session));
        }
    }
}
