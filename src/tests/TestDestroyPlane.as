package tests
{
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	import away3dlite.templates.BasicTemplate;

	import flash.events.MouseEvent;
	import flash.system.System;

	[SWF(backgroundColor="#000000", frameRate="30", width="800", height="600")]
	/**
	 * @author katopz
	 */
	public class TestDestroyPlane extends BasicTemplate
	{
		private var _planes:Vector.<Plane> = new Vector.<Plane>();

		override protected function onInit():void
		{
			title = "Create and Destroy test for planes |";
			
			create();

			stage.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void
				{
					dispose();
				});
		}

		private function create():void
		{
			var _total:uint = 32;
			var _gap:uint = 16;
			var _beg:int = 0xFF + int(Math.random() * 0xFFFF00);

			for (var i:int = 0; i < _total; i++)
			{
				var _plane:Plane = new Plane(new ColorMaterial(int(_beg + 0xFF * i / _total), .5 * i / _total));
				_plane.bothsides = true;
				_plane.rotationX = 45;
				_plane.rotationY = 180 * i / _total;
				_plane.rotationZ = 360 * i / _total;
				_plane.x = i * _gap - (_total - 1) * _gap / 2;

				_planes.push(_plane);

				scene.addChild(_plane);
			}
		}

		private function dispose():void
		{
			// destroy
			for each (var _plane:Plane in _planes)
				_plane.destroy();

			_planes = new Vector.<Plane>();

			// gc
			System.gc();

			// recreate
			create();
		}

		override protected function onPreRender():void
		{
			scene.rotationY++;
		}
	}
}