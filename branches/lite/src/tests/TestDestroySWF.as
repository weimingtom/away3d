package tests
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.system.System;

	[SWF(backgroundColor="#000000", frameRate="30", width="800", height="600")]
	/**
	 * @author katopz
	 */
	public class TestDestroySWF extends Sprite
	{
		private var _loader:Loader;

		public function TestDestroySWF()
		{
			create();
			stage.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void
				{
					dispose();
					create();
				});
		}

		private function create():void
		{
			trace(" > " + Number((System.totalMemory * 0.000000954).toFixed(3)));

			addChild(_loader = new Loader());
			_loader.load(new URLRequest("TestSWF.swf"));
		}

		private function dispose():void
		{
			// destroy
			_loader.unloadAndStop(true);
			removeChild(_loader);
			_loader = null;

			// gc
			System.gc();

			trace(" < " + Number((System.totalMemory * 0.000000954).toFixed(3)));
		}
	}
}