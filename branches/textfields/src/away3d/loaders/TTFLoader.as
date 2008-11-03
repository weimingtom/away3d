package away3d.loaders
{
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	public class TTFLoader
	{
		private var _loader:URLLoader;
		private var _onComplete:Function;
		
		public function TTFLoader(source:String, onComplete:Function)
		{
			_onComplete = onComplete;
			
			trace("Loading: " + source);
			_loader = new URLLoader(new URLRequest(source));
			_loader.dataFormat = URLLoaderDataFormat.BINARY;
			_loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			_loader.addEventListener(Event.COMPLETE, completeHandler);
		}
		
		private function progressHandler(event:ProgressEvent):void
		{
			//var progress:Number = event.bytesLoaded/event.bytesTotal;
		}
		
		private function completeHandler(event:Event):void
		{
			_onComplete(_loader.data);
		}
	}
}