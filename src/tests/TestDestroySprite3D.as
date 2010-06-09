package tests
{
	import away3dlite.materials.MovieMaterial;
	import away3dlite.sprites.Sprite3D;
	import away3dlite.templates.BasicTemplate;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.system.System;

	[SWF(backgroundColor="#000000", frameRate="30", width="800", height="600")]
	/**
	 * @author katopz
	 */
	public class TestDestroySprite3D extends BasicTemplate
	{
		[Embed(source="../assets/Dot.swf", symbol="DotClip")]
		private var _DotClip:Class;
		private var _dotClip:MovieClip = new _DotClip();

		private var _sprite3Ds:Vector.<Sprite3D>;
		private const _size:uint = 32;

		override protected function onInit():void
		{
			title = "Click to Create and Destroy Sprite3D |";
			
			_sprite3Ds = new Vector.<Sprite3D>(100, true);

			create();

			stage.addEventListener(MouseEvent.CLICK, onClick);
		}

		private function onClick(event:MouseEvent):void
		{
			dispose();
			create();
		}

		private function create():void
		{
			var _material:MovieMaterial = new MovieMaterial(_dotClip);
			for (var i:int = 0; i < 100; i++)
			{
				var _sprite3D:Sprite3D = new Sprite3D(_material);
				_sprite3D.width = _sprite3D.height = _size;
				
				_sprite3D.x = 400 * Math.random() - 200;
				_sprite3D.y = 400 * Math.random() - 200;
				_sprite3D.z = 400 * Math.random() - 200;
				
				scene.addSprite(_sprite3D);
				_sprite3Ds[i] = _sprite3D;
			}
		}

		private function dispose():void
		{
			for (var i:int = 0; i < 100; i++)
			{
				var _sprite3D:Sprite3D = _sprite3Ds[i] as Sprite3D;
				scene.removeSprite(_sprite3D);
				_sprite3D.destroy();
				_sprite3Ds[i] = null;
			}
			_sprite3D = null;

			// gc
			System.gc();
		}

		override protected function onPreRender():void
		{
			scene.rotationY++;
		}
	}
}