package
{
	import away3dlite.animators.MovieMesh;
	import away3dlite.events.*;
	import away3dlite.loaders.*;
	import away3dlite.materials.BitmapFileMaterial;
	import away3dlite.templates.*;

	[SWF(backgroundColor="#FFFFFF", frameRate="30", width="800", height="600")]

	/**
	 * MD2 example.
	 */
	public class ExMD2 extends BasicTemplate
	{
		/**
		 * @inheritDoc
		 */
		override protected function onInit():void
		{
			title += " : MD2 Example.";

			var md2:MD2 = new MD2();
			md2.scaling = 5;
			md2.material = new BitmapFileMaterial("assets/pg.png");

			var loader:Loader3D = new Loader3D();
			loader.addEventListener(Loader3DEvent.LOAD_SUCCESS, onSuccess);
			loader.loadGeometry("assets/pg.md2", md2);
			scene.addChild(loader);
		}

		private function onSuccess(event:Loader3DEvent):void
		{
			var model:MovieMesh = event.loader.handle as MovieMesh;
			model.rotationX = 90;
			model.play("walk");
		}

		override protected function onPreRender():void
		{
			scene.rotationY++;
		}
	}
}