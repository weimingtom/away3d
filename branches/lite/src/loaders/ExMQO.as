package loaders
{
	import away3dlite.loaders.*;
	import away3dlite.templates.*;
	
	import flash.geom.Vector3D;

	[SWF(backgroundColor="#000000", frameRate="60", width="800", height="600")]

	/**
	 * Metasequoia example.
	 */
	public class ExMQO extends BasicTemplate
	{
		/**
		 * @inheritDoc
		 */
		override protected function onInit():void
		{
			title += " : Metasequoia Example.";

			useHandCursor = false;
			mouseEnabled = false;
			mouseChildren = false;

			camera.y = -3000;
			camera.z = -3000;
			camera.lookAt(new Vector3D(0, 0, 0));

			var loader:Loader3D = new Loader3D();
			loader.loadGeometry("../src/loaders/assets/mqo/L_R_vinet.mqo", new MQO());
			scene.addChild(loader);
		}

		override protected function onPreRender():void
		{
			camera.x = 20 * (300 - mouseY);
			camera.z = 20 * (300 - mouseX);
			camera.lookAt(new Vector3D(0, 0, 0));
		}
	}
}