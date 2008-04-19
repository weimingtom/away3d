package away3d.loaders
{
    import away3d.core.*;
    import away3d.materials.*;
    import away3d.containers.*;
    import away3d.core.base.*;
    import away3d.core.stats.*;
    import away3d.core.utils.*;
    import away3d.loaders.data.ContainerData;
    import away3d.loaders.data.MaterialData;
    import away3d.loaders.utils.TextureLoadQueue;
    import away3d.loaders.utils.TextureLoader;
    
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;

    public class Object3DLoader extends ObjectContainer3D
    {
        use namespace arcane;
		
		public var mode:String;
		public const LOADING_GEOMETRY:String = "loading_geometry";
		public const LOADING_TEXTURES:String = "loading_textures";
        public var result:Object3D;
        public var materialLibrary:MaterialLibrary;
        public var containerData:ContainerData;
        public var texturePath:String;
        public var parse:Function;
        public var url:String;

        private var urlloader:URLLoader;
        private var init:Init;

        public function get handle():Object3D
        {
            return result || this;
        }

        public function Object3DLoader(init:Object = null) 
        {
            this.init = Init.parse(init);
            this.init.removeFromCheck();
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
        	if (mode == LOADING_GEOMETRY)
            	result = parse(urlloader.data, init, this);
            
            if (materialLibrary) {
	        	if (mode == LOADING_GEOMETRY && materialLibrary.autoLoadTextures && materialLibrary.loadRequired) {
	        		startLoadingTextures(result, materialLibrary);
	        		return;
	        	} else if (mode == LOADING_TEXTURES) {
	        		materialLibrary.texturesLoaded(_loadQueue);
	        	}
            }
        	
            init.addForCheck();
			
        	result.name = name;
            result.transform = transform;

            if (parent != null)
            {
                result.parent = parent;
                parent = null;
            }
			
			//register url with hierarchy
			registerURL(result);

            notifySuccess();
        }
        
        private var _child:Object3D;
        
        public function registerURL(object:Object3D):void
        {
        	if (object is ObjectContainer3D) {
        		for each (_child in (object as ObjectContainer3D).children)
        			registerURL(_child);
        	} else if (object is Mesh) {
        		(object as Mesh).url = url;
        	}
        	
        }

        public static function loadGeometry(url:String, parse:Function, binary:Boolean, init:Object):Object3DLoader
        {
            init = Init.parse(init);
            var loaderClass:Class = init.getObject("loader") || CubeLoader;
            var loader:Object3DLoader = new loaderClass(init);
            
            loader.startLoadingGeometry(url, parse, binary);
            
            return loader;
        }
        
        public function startLoadingGeometry(url:String, parse:Function, binary:Boolean):void
        {
        	mode = LOADING_GEOMETRY;
        	
            this.parse = parse;
            this.url = url;
            urlloader = new URLLoader();
            urlloader.dataFormat = binary ? URLLoaderDataFormat.BINARY : URLLoaderDataFormat.TEXT;
            urlloader.addEventListener(IOErrorEvent.IO_ERROR, onError);
            urlloader.addEventListener(ProgressEvent.PROGRESS, onProgress);
            urlloader.addEventListener(Event.COMPLETE, onComplete);
            urlloader.load(new URLRequest(url));
        	
        }

        public static function loadTextures(result:Object3D, materialLibrary:MaterialLibrary, init:Object):Object3DLoader
        {
        	init = Init.parse(init);
        	
            var loaderClass:Class = init.getObject("loader") || CubeLoader;
            var loader:Object3DLoader = new loaderClass();
            
            loader.startLoadingTextures(result, materialLibrary);
            
            return loader;
        }
        
        private var _materialData:MaterialData;
        private var _loadQueue:TextureLoadQueue;
        
        public function startLoadingTextures(result:Object3D, materialLibrary:MaterialLibrary):void
        {
        	mode = LOADING_TEXTURES;
        	
        	this.result = result;
        	this.materialLibrary = materialLibrary;
        	this.texturePath = texturePath;
        	
        	_loadQueue = new TextureLoadQueue();
			
			for each (_materialData in materialLibrary)
			{
				if (_materialData.materialType == MaterialData.TEXTURE_MATERIAL && !_materialData.material)
				{
					var req:URLRequest = new URLRequest(materialLibrary.texturePath + _materialData.textureFileName);
					var loader:TextureLoader = new TextureLoader();
					
					_loadQueue.addItem(loader, req);
				}
			}
			_loadQueue.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_loadQueue.addEventListener(ProgressEvent.PROGRESS, onProgress);
			_loadQueue.addEventListener(Event.COMPLETE, onComplete);
			_loadQueue.start();
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