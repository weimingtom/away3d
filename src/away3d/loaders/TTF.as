package away3d.loaders
{
	import away3d.loaders.data.FontData;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	public class TTF
	{
		public function TTF()
		{
			
		}
		
		public static function parse(data:*, init:Object = null):FontData
		{
			return new FontData();
		}
			
		public static function load(url:String, init:Object = null):FontData
        {
			return new FontData();
        }
	}
}