package away3dlite.materials
{
	import away3dlite.core.utils.Debug;
	import away3dlite.events.*;

	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
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
			bitmapData = Bitmap(_loader.content).bitmapData;

			if (!_materialloadsuccess)
				_materialloadsuccess = new MaterialEvent(MaterialEvent.LOAD_SUCCESS, this);

			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);

			dispatchEvent(_materialloadsuccess);
		}

		public function load(url:String):Loader
		{
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			_loader.load(new URLRequest(url));

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

		/**
		 * Creates a new <code>BitmapFileMaterial</code> object.
		 *
		 * @param	url					The location of the bitmapasset to load.
		 */
		public function BitmapFileMaterial(url:String = "")
		{
			super(new BitmapData(100, 100));

			if (url != "")
				load(url);
		}
	}
}