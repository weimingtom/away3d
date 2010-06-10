package loaders
{
	import away3dlite.core.utils.*;
	import away3dlite.loaders.*;
	import away3dlite.templates.*;

	[SWF(backgroundColor="#000000", frameRate="30", quality="MEDIUM", width="800", height="600")]

	/**
	 * Collada example.
	 */
	public class ExCollada extends BasicTemplate
	{
		private var collada:Collada;
		private var loader:Loader3D;

		override protected function onInit():void
		{
			Debug.active = true;

			collada = new Collada();
			collada.bothsides = false;
			collada.scaling = 25;

			loader = new Loader3D();
			loader.loadGeometry("../src/loaders/assets/dae/30_box_smooth_translate.dae", collada);
			scene.addChild(loader);
		}

		override protected function onPreRender():void
		{
			scene.rotationX = (mouseX - stage.stageWidth / 2) / 5;
			scene.rotationZ = (mouseY - stage.stageHeight / 2) / 5;
			scene.rotationY++;
		}
	}
}