package tests
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	[SWF(backgroundColor="#FFFFFF", frameRate="30", width="800", height="600")]
	/**
	 * @author katopz
	 */
	public class TestDestroySWF extends Sprite
	{
		private var _loader:Loader = new Loader();
		private var _textField:TextField = new TextField();

		public function TestDestroySWF()
		{
			// debug
			addChild(_textField);
			_textField.text = "Click to Create and Destroy SWF";
			_textField.autoSize = TextFieldAutoSize.LEFT;

			create();
			stage.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void
				{
					dispose();
					create();
				});
		}

		private function create():void
		{
			// before
			_textField.appendText("\nCreate : " + Number((System.totalMemory * 0.000000954).toFixed(3)) + "\t->\t");
			_loader.load(new URLRequest("TestSWF.swf"));
		}

		private function dispose():void
		{
			// destroy
			_loader.unloadAndStop(true);

			// gc
			System.gc();

			// after
			_textField.appendText(String(Number((System.totalMemory * 0.000000954).toFixed(3))));
		}
	}
}