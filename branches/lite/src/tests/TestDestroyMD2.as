package tests
{
	import away3dlite.animators.MovieMesh;
	import away3dlite.events.*;
	import away3dlite.loaders.*;
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	import away3dlite.templates.*;

	import flash.events.MouseEvent;
	import flash.system.System;

	[SWF(backgroundColor="#FFFFFF", frameRate="30", width="800", height="600")]
	/**
	 * @author katopz
	 */
	public class TestDestroyMD2 extends BasicTemplate
	{
		private var loader:Loader3D;
		private var _model:MovieMesh;

		override protected function onInit():void
		{
			title = "Click to Create and Destroy MD2 |";

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
			var md2:MD2 = new MD2();
			md2.scaling = 5;
			md2.material = new BitmapFileMaterial("../src/loaders/assets/md2/pg.png");

			loader = new Loader3D();
			loader.addEventListener(Loader3DEvent.LOAD_SUCCESS, onSuccess, false, 0, true);
			loader.loadGeometry("../src/loaders/assets/md2/pg.md2", md2);
		}

		private function onSuccess(event:Loader3DEvent):void
		{
			loader.removeEventListener(Loader3DEvent.LOAD_SUCCESS, onSuccess);

			_model = event.loader.handle as MovieMesh;
			_model.rotationX = 90;
			_model.fps = 16;
			_model.play("walk");
			scene.addChild(_model);
		}

		private function dispose():void
		{
			// destroy
			_model.destroy();
			scene.removeChild(_model);
			_model = null;

			loader = null;

			// gc
			System.gc();
		}

		override protected function onPreRender():void
		{
			scene.rotationY++;
		}
	}
}