package tests
{
	import away3dlite.animators.MovieMesh;
	import away3dlite.events.*;
	import away3dlite.loaders.*;
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	import away3dlite.templates.*;
	
	import flash.display.Sprite;
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

			stage.addEventListener(MouseEvent.MOUSE_WHEEL, function(event:MouseEvent):void
				{
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
			_basicTemplate.destroy();
			removeChild(_basicTemplate);
			_basicTemplate = null;

			// gc
			System.gc();

			// recreate
			create();
		}
	}
}