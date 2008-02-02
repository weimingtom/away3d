package away3d.loaders
{
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.mesh.*;
    import away3d.core.scene.*;
    import away3d.core.stats.*;
    import away3d.core.utils.*;
    
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;

    public class Object3DLoader extends ObjectContainer3D
    {
        use namespace arcane;

        public var result:Object3D;

        private var urlloader:URLLoader;
        private var parse:Function;
        private var init:Init;
        private var url:String;

        public function get handle():Object3D
        {
            return result || this;
        }

        public function Object3DLoader(url:String, parse:Function, binary:Boolean, init:Object = null) 
        {
            this.parse = parse;
            this.url = url;
            this.init = Init.parse(init);
            this.init.removeFromCheck();

            urlloader = new URLLoader();
            urlloader.dataFormat = binary ? URLLoaderDataFormat.BINARY : URLLoaderDataFormat.TEXT;
            urlloader.addEventListener(IOErrorEvent.IO_ERROR, onError);
            urlloader.addEventListener(ProgressEvent.PROGRESS, onProgress);
            urlloader.addEventListener(Event.COMPLETE, onComplete);
            urlloader.load(new URLRequest(url));
        }

        protected function onError(event:IOErrorEvent):void 
        {
            notifyError();
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
            	result.name = name;
                result.transform = transform;
                result.parent = parent;
            	name = null;
                parent = null;
            }
			
			//register mesh url
            if (result is Mesh)
            {
            	(result as Mesh).url = url;
            }

            if (result is ObjectContainer3D)
            {
                // register collada
            }

            notifySuccess();
        }

        public static function load(url:String, parse:Function, binary:Boolean, init:Object):Object3DLoader
        {
            init = Init.parse(init);
            var loader:Class = init.getObject("loader") || CubeLoader;
            return new loader(url, parse, binary, init);
        }

        public function addOnSuccess(listener:Function):void
        {
            addEventListener("loadsuccess", listener, false, 0, true);
        }
        public function removeOnSuccess(listener:Function):void
        {
            removeEventListener("loadsuccess", listener, false);
        }
        protected function notifySuccess():void
        {
            if (!hasEventListener("loadsuccess"))
                return;

            dispatchEvent(new Event("loadsuccess"));
        }

        public function addOnError(listener:Function):void
        {
            addEventListener("loaderror", listener, false, 0, true);
        }
        public function removeOnError(listener:Function):void
        {
            removeEventListener("loaderror", listener, false);
        }
        protected function notifyError():void
        {
            if (!hasEventListener("loaderror"))
                return;
                
            dispatchEvent(new Event("loaderror"));
        }

    }
}