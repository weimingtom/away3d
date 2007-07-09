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

    public class Object3DLoader extends ObjectContainer3D
    {
        public var result:Object3D;

        private var urlloader:URLLoader;
        private var parse:Function;
        private var init:Object;

        protected var title:String;

        public function Object3DLoader(url:String, parse:Function, init:Object = null, title:String = null) 
        {
            this.parse = parse;
            this.title = title || "Loading...";
            this.init = init;

            urlloader = new URLLoader();
            urlloader.addEventListener(IOErrorEvent.IO_ERROR, onError);
            urlloader.addEventListener(ProgressEvent.PROGRESS, onProgress);
            urlloader.addEventListener(Event.COMPLETE, onComplete);
            urlloader.load(new URLRequest(url));
        }

        protected function onError(event:IOErrorEvent):void 
        {
        }

        protected function onProgress(event:ProgressEvent):void 
        {
        }

        private function onComplete(event:Event):void 
        {
            result = parse(urlloader.data, init);

            if (parent != null)
            {
                result.setTransform(transform);
                result.parent = parent;
                parent = null;
            }
        }

    }
}