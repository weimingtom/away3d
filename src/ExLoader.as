package
{
	import flash.display.*;
	import flash.events.Event;
	import flash.net.URLRequest;

	[SWF(backgroundColor="#000000", frameRate="30", width="1024", height="768")]
	public class ExLoader extends Sprite
	{
		private var debugRect:Sprite;
		private var _container:Sprite;

		protected var _stageWidth:Number = stage ? stage.stageWidth : NaN;
		protected var _stageHeight:Number = stage ? stage.stageHeight : NaN;

		public function ExLoader():void
		{
			_container = new Sprite();
			_container.x = _stageWidth / 2;
			_container.y = _stageHeight / 2;
			addChild(_container);

			debugRect = new Sprite();
			addChild(debugRect);

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, onResize);

			draw();

			var loader:Loader = new Loader();
			loader.load(new URLRequest("ExClipping.swf"));
			_container.addChild(loader);
		}

		private function onResize(event:Event):void
		{
			draw();
		}

		private function draw():void
		{
			var _x0:Number = Number((_stageWidth - stage.stageWidth) / 2);
			var _y0:Number = Number((_stageHeight - stage.stageHeight) / 2);

			debugRect.graphics.clear();
			debugRect.graphics.lineStyle(1, 0x00FF00);
			debugRect.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			debugRect.graphics.endFill();

			debugRect.x = _x0;
			debugRect.y = _y0;

			_container.x = _x0;
			_container.y = _y0;
		}
	}
}