package away3d.loaders
{
    import away3d.core.*;
    import away3d.core.base.*
    import away3d.core.base.*;
    import away3d.materials.*;
    import away3d.core.utils.*;
    import away3d.primitives.*

    import flash.display.MovieClip;
    import flash.display.Graphics;
    import flash.text.TextField;
    import flash.net.URLRequest;
    import flash.net.URLLoader;
    import flash.events.EventDispatcher;
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.events.IOErrorEvent;
 

    public class CubeLoader extends Object3DLoader
    {
        private var side:MovieClip;
        private var info:TextField;
        private var geometryTitle:String;
		private var textureTitle:String;
		
        public function CubeLoader(init:Object = null) 
        {
            super(init);

            side = new MovieClip();
            var graphics:Graphics = side.graphics;
            graphics.lineStyle(1, 0xFFFFFF);
            graphics.drawCircle(50, 50, 50);
            info = new TextField();
            info.wordWrap = true;
            side.addChild(info);

            init = Init.parse(init);
            var size:Number = init.getNumber("loadersize", 200);
            geometryTitle = init.getString("geometrytitle", "Loading Geometry...");
            textureTitle = init.getString("texturetitle", "Loading Texture...");

            addChild(new Cube({material:new MovieMaterial(side, {transparent:true, smooth:true}), width:size, height:size, depth:size}));
        }

        protected override function onError(event:IOErrorEvent):void 
        {
            super.onError(event);
            info.text = ((mode == LOADING_GEOMETRY)? geometryTitle : textureTitle) + "\n" + event.text;
            var graphics:Graphics = side.graphics;
            graphics.beginFill(0xFF0000);
            graphics.drawRect(0, 0, 100, 100);
            graphics.endFill();
        }

        protected override function onProgress(event:ProgressEvent):void 
        {
            info.text = ((mode == LOADING_GEOMETRY)? geometryTitle : textureTitle) + "\n" + event.bytesLoaded + " of\n" + event.bytesTotal + " bytes";
            var graphics:Graphics = side.graphics;
            graphics.lineStyle(1, 0x808080);
            graphics.drawCircle(50, 50, 50*event.bytesLoaded/event.bytesTotal);
        }
    }
}