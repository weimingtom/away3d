package tests
{
	import away3dlite.events.*;
	import away3dlite.loaders.*;
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	import away3dlite.templates.*;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.system.System;

	[SWF(backgroundColor="#000000", frameRate="30", width="800", height="600")]
	/**
	 * @author katopz
	 */
	public class TestDestroyTemplate extends Sprite
	{
		private var _basicTemplate:BasicTemplate;

		public function TestDestroyTemplate()
		{
			create();
			addEventListener(Event.ADDED_TO_STAGE, onStage, false, 0, true);
		}

		private function onStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onStage);

			stage.addEventListener(MouseEvent.MOUSE_WHEEL, function(event:MouseEvent):void
				{
					dispose();
					create();
				});
			addEventListener(Event.REMOVED_FROM_STAGE, function(event:Event):void
				{
					trace("TestDestroyTemplate.REMOVED_FROM_STAGE");
					EventDispatcher(event.currentTarget).removeEventListener(event.type, arguments.callee);
					dispose();
				});
		}

		private function create():void
		{
			addChild(_basicTemplate = new TestDestroyPlane());
		}

		private function dispose():void
		{
			// destroy
			if (_basicTemplate)
			{
				_basicTemplate.destroy();
				removeChild(_basicTemplate);
			}
			_basicTemplate = null;

			// gc
			System.gc();
		}
	}
}