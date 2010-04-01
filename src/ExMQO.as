package
{
	import away3dlite.core.base.*;
	import away3dlite.events.*;
	import away3dlite.loaders.*;
	import away3dlite.templates.*;
	
	import flash.display.*;
	import flash.geom.Vector3D;

	[SWF(backgroundColor="#000000", frameRate="60", width="800", height="600")]

	/**
	 * Metasequoia example.
	 */
	public class ExMQO extends BasicTemplate
	{
		private var mqo:MQO;
		private var loader:Loader3D;
		
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
			camera.lookAt(new Vector3D(0,0,0));
			
			mqo = new MQO();
			
			loader = new Loader3D();
			loader.loadGeometry("mqo/L_R_vinet.mqo", mqo);
			scene.addChild(loader);
		}
		
		override protected function onPreRender():void
		{
			scene.rotationY++;
		}
	}
}