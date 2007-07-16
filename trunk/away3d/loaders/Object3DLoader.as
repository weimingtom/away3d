package away3d.loaders
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.mesh.*;
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
        use namespace arcane;

        public var result:Object3D;

        private var urlloader:URLLoader;
        private var parse:Function;
        private var init:Init;

        public function get handle():Object3D
        {
            return result || this;
        }

        public function Object3DLoader(url:String, parse:Function, init:Object = null) 
        {
            this.parse = parse;
            this.init = Init.parse(init);
            this.init.removeFromCheck();

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
            init.addForCheck();

            result = parse(urlloader.data, init);

            if (parent != null)
            {
                result.transform = transform;
                result.parent = parent;
                parent = null;
            }
        }

        public static function load(url:String, parse:Function, init:Object):Object3DLoader
        {
            init = Init.parse(init);
            var loader:Class = init.getObject("loader") || CubeLoader;
            return new loader(url, parse, init);
        }

    }
}