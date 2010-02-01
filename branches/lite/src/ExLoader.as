package
{
	import flash.display.*;
	import flash.net.URLRequest;

	[SWF(backgroundColor="#000000",frameRate="30",quality="MEDIUM",width="640",height="480")]
	public class ExLoader extends Sprite
	{
		public function ExLoader():void
		{
			var loader:Loader = new Loader();
			loader.load(new URLRequest("ExClipping.swf"));
			addChild(loader);
		}
	}
}