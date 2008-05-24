package away3d.loaders
{
    import away3d.containers.*;
    import away3d.core.*;
    import away3d.core.base.*;
    import away3d.core.utils.*;
    import away3d.events.*;
    import away3d.loaders.data.*;
    import away3d.loaders.utils.*;
    
    import flash.events.*;
    import flash.net.*;
    			
	 /**
	 * Dispatched when the 3d object loader completes a file load successfully.
	 * 
	 * @eventType away3d.events.LoaderEvent
	 */
	[Event(name="loadsuccess",type="away3d.events.LoaderEvent")]
    			
	 /**
	 * Dispatched when the 3d object loader fails to load a file.
	 * 
	 * @eventType away3d.events.LoaderEvent
	 */
	[Event(name="loaderror",type="away3d.events.LoaderEvent")]
	
	/**
	 * Abstract loader class used as a placeholder for loading 3d content
	 */
    public class Object3DLoader extends ObjectContainer3D
    {
        use namespace arcane;
		/** @private */
        arcane static function loadGeometry(url:String, parse:Function, binary:Boolean, init:Object):Object3DLoader
        {
            var ini:Init = Init.parse(init);
            var loaderClass:Class = ini.getObject("loader") as Class || CubeLoader;
            var loader:Object3DLoader = new loaderClass(ini);
            
            loader.startLoadingGeometry(url, parse, binary);
            
            return loader;
        }
		/** @private */
        arcane static function loadTextures(result:Object3D, materialLibrary:MaterialLibrary, init:Object):Object3DLoader
        {
        	var ini:Init = Init.parse(init);
            var loaderClass:Class = ini.getObject("loader") as Class || CubeLoader;
            var loader:Object3DLoader = new loaderClass(ini);
            
            loader.startLoadingTextures(result, materialLibrary);
            
            return loader;
        }
        
        private var result:Object3D;
        private var urlloader:URLLoader;
        private var _child:Object3D;
        private var _materialData:MaterialData;
        private var _loadQueue:TextureLoadQueue;
        private var _loadsuccess:LoaderEvent;
        private var _loaderror:LoaderEvent;
		
        private function registerURL(object:Object3D):void
        {
        	if (object is ObjectContainer3D) {
        		for each (_child in (object as ObjectContainer3D).children)
        			registerURL(_child);
        	} else if (object is Mesh) {
        		(object as Mesh).url = url;
        	}
        }
        
        private function notifySuccess():void
        {
            if (!hasEventListener(LoaderEvent.LOAD_SUCCESS))
                return;
            
			if (!_loadsuccess)
				_loadsuccess = new LoaderEvent(LoaderEvent.LOAD_SUCCESS, this);
			
            dispatchEvent(_loadsuccess);
        }
        
        private function notifyError():void
        {
            if (!hasEventListener(LoaderEvent.LOAD_ERROR))
                return;
            
			if (!_loaderror)
				_loaderror = new LoaderEvent(LoaderEvent.LOAD_ERROR, this);
			
            dispatchEvent(_loaderror);
        }
        
        private function startLoadingGeometry(url:String, parse:Function, binary:Boolean):void
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
        
        private function startLoadingTextures(result:Object3D, materialLibrary:MaterialLibrary):void
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
        
        /**
        * Automatically fired on an error event.
        * 
        * @see away3d.loaders.utils.TextureLoadQueue
        */
        protected function onError(event:IOErrorEvent):void 
        {
            notifyError();
        }
        
        /**
        * Automatically fired on a progress event
        */
        protected function onProgress(event:ProgressEvent):void 
        {
        }
        
        /**
        * Automatically fired on a complete event
        */
        protected function onComplete(event:Event):void 
        {
        	if (mode == LOADING_GEOMETRY)
            	result = parse(urlloader.data, ini, this);
            
            if (materialLibrary) {
	        	if (mode == LOADING_GEOMETRY && materialLibrary.autoLoadTextures && materialLibrary.loadRequired) {
	        		startLoadingTextures(result, materialLibrary);
	        		return;
	        	} else if (mode == LOADING_TEXTURES) {
	        		materialLibrary.texturesLoaded(_loadQueue);
	        	}
            }
        	
            ini.addForCheck();
			
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
        
        /**
        * Constant value string representing the geometry loading mode of the 3d object loader.
        */
		public const LOADING_GEOMETRY:String = "loading_geometry";
        
        /**
        * Constant value string representing the texture loading mode of the 3d object loader.
        */
		public const LOADING_TEXTURES:String = "loading_textures";
		
		
        /**
        * Returns the current loading mode of the 3d object loader.
        */
		public var mode:String;
		
		/**
		 * Returns the material library being used by the loaded file.
		 */
        public var materialLibrary:MaterialLibrary;
        
        /**
        * Returns the the data container being used by the loaded file.
        */
        public var containerData:ContainerData;
        
        /**
        * Returns the filepath to the directory where any required texture files are located.
        */
        public var texturePath:String;
        
        /**
        * Function placeholder for the parse method from the correct file loader class.
        */
        public var parse:Function;
        
        /**
        * Returns the url string of the file being loaded.
        */
        public var url:String;

		/**
		 * Returns a 3d object relating to the currently visible model.
		 * While a file is being loaded, this takes the form of the 3d object loader placeholder.
		 * The default placeholder is <code>CubeLoader</code>
		 * 
		 * Once the file has been loaded and is ready to view, the <code>handle</code> returns the 
		 * parsed 3d object file and the placeholder object is swapped in the scenegraph tree.
		 * 
		 * @see	away3d.loaders.CubeLoader
		 */
        public function get handle():Object3D
        {
            return result || this;
        }
        
		/**
		 * Creates a new <code>Object3DLoader</code> object.
		 * Not intended for direct use, use the static <code>parse</code> or <code>load</code> methods found on the file loader classes.
		 * 
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function Object3DLoader(init:Object = null) 
        {
            ini = Init.parse(init);
            ini.removeFromCheck();
        }


		
		/**
		 * Default method for adding a loadsuccess event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnSuccess(listener:Function):void
        {
            addEventListener(LoaderEvent.LOAD_SUCCESS, listener, false, 0, true);
        }
		
		/**
		 * Default method for removing a loadsuccess event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnSuccess(listener:Function):void
        {
            removeEventListener(LoaderEvent.LOAD_SUCCESS, listener, false);
        }
		
		/**
		 * Default method for adding a loaderror event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnError(listener:Function):void
        {
            addEventListener(LoaderEvent.LOAD_ERROR, listener, false, 0, true);
        }
		
		/**
		 * Default method for removing a loaderror event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnError(listener:Function):void
        {
            removeEventListener(LoaderEvent.LOAD_ERROR, listener, false);
        }

    }
}