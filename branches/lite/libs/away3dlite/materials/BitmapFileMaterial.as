package away3dlite.materials
{
	import away3dlite.core.utils.Debug;
	import away3dlite.events.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;

	/**
	 * Dispatched when the material completes a file load successfully.
	 *
	 * @eventType away3dlite.events.MaterialEvent
	 */
	[Event(name="loadSuccess", type="away3dlite.events.MaterialEvent")]

	/**
	 * Dispatched when the material fails to load a file.
	 *
	 * @eventType away3dlite.events.MaterialEvent
	 */
	[Event(name="loadError", type="away3dlite.events.MaterialEvent")]

	/**
	 * Dispatched every frame the material is loading.
	 *
	 * @eventType away3dlite.events.MaterialEvent
	 */
	[Event(name="loadProgress", type="away3dlite.events.MaterialEvent")]

	/**
	 * Bitmap material that loads it's texture from an external bitmapasset file.
	 */
	public class BitmapFileMaterial extends BitmapMaterial
	{
		private var _loader:Loader;
		private var _materialloaderror:MaterialEvent;
		private var _materialloadprogress:MaterialEvent;
		private var _materialloadsuccess:MaterialEvent;
		
		private function onError(e:IOErrorEvent):void
		{
			if (!_materialloaderror)
				_materialloaderror = new MaterialEvent(MaterialEvent.LOAD_ERROR, this);

			dispatchEvent(_materialloaderror);
			Debug.warning(e);
		}

		private function onProgress(e:ProgressEvent):void
		{
			if (!_materialloadprogress)
				_materialloadprogress = new MaterialEvent(MaterialEvent.LOAD_PROGRESS, this);

			dispatchEvent(_materialloadprogress);
		}

		private function onComplete(e:Event):void
		{
			if(!e.target.content)
			{
				dispatchEvent(new MaterialEvent(MaterialEvent.LOAD_ERROR, this));
				return;
			}
			
			bitmapData = Bitmap(e.target.content).bitmapData.clone();

			if (!_materialloadsuccess)
				_materialloadsuccess = new MaterialEvent(MaterialEvent.LOAD_SUCCESS, this);

			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			
			dispatchEvent(_materialloadsuccess);
			
			Bitmap(e.target.content).bitmapData.dispose();
			_loader = null;
		}

		public function load(url:String, loaderContext:LoaderContext = null):Loader
		{
			this.url = url;
			
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			_loader.load(new URLRequest(url), loaderContext);

			return _loader;
		}

		public function loadBytes(byteArray:ByteArray):Loader
		{
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			_loader.loadBytes(byteArray);

			return _loader;
		}
		
		public function unload():void
		{
			if(!_loader)
				return;
				
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			_loader = null;
		}

		/**
		 * Creates a new <code>BitmapFileMaterial</code> object.
		 *
		 * @param	url					The location of the bitmapasset to load.
		 */
		public function BitmapFileMaterial(url:String = "", loaderContext:LoaderContext = null)
		{
			super(new BitmapData(64, 64));

			if (url != "")
				load(url, loaderContext);
		}
	}
}