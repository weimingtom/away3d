package away3d.loaders.utils;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	
	
	
	/*[Event(name="complete", type="flash.events.Event")]*/
	/*[Event(name="httpStatus", type="flash.events.HTTPStatusEvent")]*/
	/*[Event(name="ioError", type="flash.events.IOErrorEvent")]*/
	/*[Event(name="progress", type="flash.events.ProgressEvent")]*/
	/*[Event(name="securityError", type="flash.events.SecurityErrorEvent")]*/
	
	/**
	 * Creates a queue of textures that load sequentially
	 */	
	class TextureLoadQueue extends EventDispatcher {
		public var currentItemIndex(getCurrentItemIndex, null) : Int
		;
		public var currentLoader(getCurrentLoader, null) : TextureLoader
		;
		public var currentURLRequest(getCurrentURLRequest, null) : URLRequest
		;
		public var images(getImages, null) : Array<Dynamic>
		;
		public var numItems(getNumItems, null) : Int
		;
		public var percentLoaded(getPercentLoaded, null) : Float
		;
		public var progress(getProgress, null) : Float
		;
		
		var _queue:Array<Dynamic>;
		var _currentItemIndex:Int;
		
		function redispatchEvent(e:Event):Void
		{
			dispatchEvent(e);
		}
		
		function onItemComplete(e:Event):Void
		{
			cleanUpOldItem(currentLoader);
			_currentItemIndex++;
			loadNext();
		}
		
		function loadNext():Void
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
		
		function calcProgress():Float
		{
			var baseAmount:Int = currentItemIndex / numItems;
			var currentItemFactor:Int = calcCurrentLoaderAmountLoaded() / numItems;
			return baseAmount = currentItemFactor;
		}
		
		function calcCurrentLoaderAmountLoaded():Float
		{
			if(currentLoader.contentLoaderInfo.bytesLoaded > 0){
				return currentLoader.contentLoaderInfo.bytesLoaded / currentLoader.contentLoaderInfo.bytesTotal;
			}else{
				return 0;
			}
		}
		
		function cleanUpOldItem(item:TextureLoader):Void
		{
			currentLoader.removeEventListener(Event.COMPLETE, onItemComplete, false);
			currentLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, redispatchEvent, false);
			currentLoader.removeEventListener(IOErrorEvent.IO_ERROR, redispatchEvent, false);
			currentLoader.removeEventListener(ProgressEvent.PROGRESS, redispatchEvent, false);
			currentLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, redispatchEvent, false);	
		}
		
		/**
		 * Returns the number of items whating in the queue to be loaded.
		 */
		public function getNumItems():Int
		{
			return _queue.length;
		}
		/**
		 * Returns the index of the current texture baing loaded
		 */
		public function getCurrentItemIndex():Int
		{
			return _currentItemIndex;
		}
		
		/**
		 * Returns an array of loader objects containing the loaded images
		 */
		public function getImages():Array<Dynamic>
		{
			var items:Array<Dynamic> = [];
			for (item in _queue)
			{
				items.push(item.loader);
			}
			return items;
		}
		
		/**
		 * Returns the loader object for the current texture being loaded
		 */
		public function getCurrentLoader():TextureLoader
		{
			return (cast( _queue[currentItemIndex], LoaderAndRequest)).loader;
		}
		
		/**
		 * Returns the url request object for the current texture being loaded
		 */
		public function getCurrentURLRequest():URLRequest
		{
			return (cast( _queue[currentItemIndex], LoaderAndRequest)).request;
		}
		
		
		/**
		 * Returns the overall progress of the loader queue.
		 * Progress of 0 means that nothing has loaded. Progress of 1 means that all the items are fully loaded
		 */
		public function getProgress():Float
		{
			return calcProgress();
		}
		
		/**
		 * Returns the overall progress of the loader queue as a percentage.
		 */
		public function getPercentLoaded():Float
		{
			return progress * 100;
		}
		
		/**
		 * Creates a new <code>TextureLoadQueue</code> object.
		 */
		public function new()
		{
			_queue = new Array();
			
		}
		
		/**
		 * Adds a new loader and request object to the load queue.
		 * 
		 * @param	loader		The laoder object to add to the queue.
		 * @param	request		The url request object to add tp the queue.
		 */
		public function addItem(loader:TextureLoader, request:URLRequest):Void
		{
			//check to stop duplicated loading
			for (_item in _queue) {
				if (_item.request.url == request.url)
					return;
			}
			_queue.push(new LoaderAndRequest(loader, request));
		}
		
		/**
		 * Starts the load queue loading.
		 */
		public function start():Void
		{
			_currentItemIndex = 0;
			loadNext();
		}
	}
