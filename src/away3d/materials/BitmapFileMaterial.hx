package away3d.materials;

	import away3d.arcane;
	import away3d.events.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
    			
	use namespace arcane;
	
	 /**
	 * Dispatched when the material completes a file load successfully.
	 * 
	 * @eventType away3d.events.LoaderEvent
	 */
	/*[Event(name="loadSuccess",type="away3d.events.LoaderEvent")]*/
    			
	 /**
	 * Dispatched when the material fails to load a file.
	 * 
	 * @eventType away3d.events.LoaderEvent
	 */
	/*[Event(name="loadError",type="away3d.events.LoaderEvent")]*/
    			
	 /**
	 * Dispatched every frame the material is loading.
	 * 
	 * @eventType away3d.events.LoaderEvent
	 */
	/*[Event(name="loadProgress",type="away3d.events.LoaderEvent")]*/
	
    /**
    * Bitmap material that loads it's texture from an external bitmapasset file.
    */
    class BitmapFileMaterial extends TransformBitmapMaterial, implements ITriangleMaterial, implements IUVMaterial {
		
		var _loader:Loader;
		var _materialresize:MaterialEvent;
		var _materialloaderror:MaterialEvent;
		var _materialloadprogress:MaterialEvent;
		var _materialloadsuccess:MaterialEvent;
		
		function onError(e:IOErrorEvent):Void
		{			
			if (!_materialloaderror)
				_materialloaderror = new MaterialEvent(MaterialEvent.LOAD_ERROR, this);
			
            dispatchEvent(_materialloaderror);
		}
		
		function onProgress(e:ProgressEvent):Void
		{
			if (!_materialloadprogress)
				_materialloadprogress = new MaterialEvent(MaterialEvent.LOAD_PROGRESS, this);
			
            dispatchEvent(_materialloadprogress);
		}
		
		function onComplete(e:Event):Void
		{
			_renderBitmap = _bitmap = Bitmap(_loader.content).bitmapData;
			
			if (_materialresize == null)
				_materialresize = new MaterialEvent(MaterialEvent.MATERIAL_RESIZED, this);
			
			dispatchEvent(_materialresize);
			
			if (!_materialloadsuccess)
				_materialloadsuccess = new MaterialEvent(MaterialEvent.LOAD_SUCCESS, this);
			
            dispatchEvent(_materialloadsuccess);
		}
    	
		/**
		 * Creates a new <code>BitmapFileMaterial</code> object.
		 *
		 * @param	url					The location of the bitmapasset to load.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
		public function new( ?url :String="", ?init:Dynamic = null)
        {
            super(new BitmapData(100,100), init);
			
			_loader = new Loader();
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
            _loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			_loader.load(new URLRequest(url));
        }
        
		/**
		 * Default method for adding a loadSuccess event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnLoadSuccess(listener:Dynamic):Void
        {
            addEventListener(MaterialEvent.LOAD_SUCCESS, listener, false, 0, true);
        }
		
		/**
		 * Default method for removing a loadSuccess event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnLoadSuccess(listener:Dynamic):Void
        {
            removeEventListener(MaterialEvent.LOAD_SUCCESS, listener, false);
        }
		
		/**
		 * Default method for adding a loadProgress event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnLaodProgress(listener:Dynamic):Void
        {
            addEventListener(MaterialEvent.LOAD_PROGRESS, listener, false, 0, true);
        }
		
		/**
		 * Default method for removing a loadProgress event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnLoadProgress(listener:Dynamic):Void
        {
            removeEventListener(MaterialEvent.LOAD_PROGRESS, listener, false);
        }	
        	
		/**
		 * Default method for adding a loadError event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnLoadError(listener:Dynamic):Void
        {
            addEventListener(MaterialEvent.LOAD_ERROR, listener, false, 0, true);
        }
		
		/**
		 * Default method for removing a loadError event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnLoadError(listener:Dynamic):Void
        {
            removeEventListener(MaterialEvent.LOAD_ERROR, listener, false);
        }
    }
