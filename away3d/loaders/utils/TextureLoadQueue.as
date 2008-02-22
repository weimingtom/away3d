package away3d.loaders.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	
	
	
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="httpStatus", type="flash.events.HTTPStatusEvent")]
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]
	
	/**
	 * Creates a queue of textures that load sequentially
	 */	
	public class TextureLoadQueue extends EventDispatcher
	{
		
		private var _queue:Array;
		private var _currentItemIndex:int;
		
		
		public function get numItems():int
		{
			return _queue.length;
		}
		
		public function get currentItemIndex():int
		{
			return _currentItemIndex;
		}
		
		public function get images():Array
		{
			var items:Array = [];
			for each (var item:LoaderAndRequest in _queue)
			{
				items.push(item.loader);
			}
			return items;
		}
		
		public function get currentLoader():TextureLoader
		{
			return (_queue[currentItemIndex] as LoaderAndRequest).loader;
		}
		
		public function get currentURLRequest():URLRequest
		{
			return (_queue[currentItemIndex] as LoaderAndRequest).request;
		}
		
		
		/**
		 * Progress of 0 means that nothing has loaded. Progress of 1 means that all the items are fully loaded
		 * 
		 */
		public function get progress():Number
		{
			return calcProgress();
		}
		
		public function get percentLoaded():Number
		{
			return progress * 100;
		}
		
		
		
		public function TextureLoadQueue()
		{
			_queue = new Array();
			
		}
		
		
		public function addItem(loader:TextureLoader, request:URLRequest):void
		{
			//check to stop duplicated loading
			for each (var _item:LoaderAndRequest in _queue) {
				if (_item.request.url == request.url)
					return;
			}
			_queue.push(new LoaderAndRequest(loader, request));
		}
		
		
		public function start():void
		{
			_currentItemIndex = 0;
			loadNext();
		}
		
		
		private function redispatchEvent(e:Event):void
		{
			dispatchEvent(e);
		}
		
		
		private function onItemComplete(e:Event):void
		{
			cleanUpOldItem(currentLoader);
			_currentItemIndex++;
			loadNext();
		}
		
		
		private function loadNext():void
		{
			if(_currentItemIndex >= numItems){
				dispatchEvent(new Event(Event.COMPLETE));
			}else{
				var evt:ProgressEvent = new ProgressEvent(ProgressEvent.PROGRESS);
				evt.bytesTotal = 100;
				evt.bytesLoaded = percentLoaded;
				dispatchEvent(evt);
				if(currentLoader.contentLoaderInfo.bytesLoaded > 0 && currentLoader.contentLoaderInfo.bytesLoaded == currentLoader.contentLoaderInfo.bytesTotal){
					
				}else{
				
					// make it lowest priority so we handle it after the loader handles the event itself. That means that when we
					// re-dispatch the event, the loaders have already processed their data and are ready for use
					currentLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onItemComplete, false, int.MIN_VALUE, true);
					
					currentLoader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, redispatchEvent, false, 0, true);
					currentLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, redispatchEvent, false, 0, true);
					currentLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, redispatchEvent, false, 0, true);
					currentLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, redispatchEvent, false, 0, true);
					currentLoader.load(currentURLRequest);
				}
			}
		}
		
		
		
		private function calcProgress():Number
		{
			var baseAmount:Number = currentItemIndex / numItems;
			var currentItemFactor:Number = calcCurrentLoaderAmountLoaded() / numItems;
			return baseAmount = currentItemFactor;
		}
		
		private function calcCurrentLoaderAmountLoaded():Number
		{
			if(currentLoader.contentLoaderInfo.bytesLoaded > 0){
				return currentLoader.contentLoaderInfo.bytesLoaded / currentLoader.contentLoaderInfo.bytesTotal;
			}else{
				return 0;
			}
		}
		
		
		private function cleanUpOldItem(item:TextureLoader):void
		{
			currentLoader.removeEventListener(Event.COMPLETE, onItemComplete, false);
			currentLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, redispatchEvent, false);
			currentLoader.removeEventListener(IOErrorEvent.IO_ERROR, redispatchEvent, false);
			currentLoader.removeEventListener(ProgressEvent.PROGRESS, redispatchEvent, false);
			currentLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, redispatchEvent, false);	
		}
		
	}
}

import flash.net.URLRequest;
import away3d.loaders.utils.TextureLoader;


class LoaderAndRequest {
	
	public var loader:TextureLoader;
	public var request:URLRequest;
	
	public function LoaderAndRequest(loader:TextureLoader, request:URLRequest)
	{
		this.loader = loader;
		this.request = request;
	}
}