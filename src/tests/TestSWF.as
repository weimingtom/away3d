package tests
{
	import away3dlite.debug.AwayStats;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	[SWF(backgroundColor="#000000", frameRate="30", width="800", height="600")]
	/**
	 * @author katopz
	 */
	public class TestSWF extends Sprite
	{
		private var _stat:AwayStats;

		public function TestSWF()
		{
			addChild(_stat = new AwayStats);
			addEventListener(Event.REMOVED_FROM_STAGE, function(event:Event):void
				{
					trace("TestSWF.REMOVED_FROM_STAGE");
					EventDispatcher(event.currentTarget).removeEventListener(event.type, arguments.callee);
					_stat.destroy();
					_stat = null;
				});
		}
	}
}