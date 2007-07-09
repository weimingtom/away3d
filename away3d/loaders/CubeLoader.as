package away3d.loaders
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;
    import away3d.objects.*;

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

        public function CubeLoader(url:String, parse:Function, init:Object = null, title:String = null) 
        {
            super(url, parse, init, title);

            side = new MovieClip();
            var graphics:Graphics = side.graphics;
            graphics.lineStyle(1, 0xFFFFFF);
            graphics.drawCircle(50, 50, 50);
            info = new TextField();
            side.addChild(info);

            addChild(new Cube({material:new MovieMaterial(side, {transparent:true, smooth:true}), width:100, height:100, depth:100}));
        }

        protected override function onError(event:IOErrorEvent):void 
        {
            info.text = title + "\n" + event.toString();
            var graphics:Graphics = side.graphics;
            graphics.beginFill(0xFF0000);
            graphics.drawCircle(50, 50, 50);
            graphics.endFill();
        }

        protected override function onProgress(event:ProgressEvent):void 
        {
            info.text = title + "\n" + event.bytesLoaded + " of\n" + event.bytesTotal + " bytes";
            var graphics:Graphics = side.graphics;
            graphics.lineStyle(1, 0x808080);
            graphics.drawCircle(50, 50, 50*event.bytesLoaded/event.bytesTotal);
        }
    }
}