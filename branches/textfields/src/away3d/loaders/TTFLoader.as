package away3d.loaders
{
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	public class TTFLoader
	{
		private var loader:URLLoader;
		private var onComplete:Function;
		
		public function TTFLoader(source:String, onComplete:Function)
		{
			this.onComplete = onComplete;
			
			loader = new URLLoader(new URLRequest(source));
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			loader.addEventListener(Event.COMPLETE, completeHandler);
		}
		
		private function progressHandler(event:ProgressEvent):void
		{
			var progress:Number = event.bytesLoaded/event.bytesTotal;
		}
		
		private function completeHandler(event:Event):void
		{
			onComplete(loader.data);
		}
	}
}