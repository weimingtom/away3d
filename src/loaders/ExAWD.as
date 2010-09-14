package loaders
{
	import away3dlite.loaders.*;
	import away3dlite.materials.BitmapFileMaterial;
	import away3dlite.templates.*;
	
	import loaders.assets.awd.TurtleAWD;

	[SWF(backgroundColor="#000000", frameRate="30", width="800", height="600")]
	/**
	 * Load AWD file that export from Prefab 
	 * @author katopz
	 */
	public class ExAWD extends BasicTemplate
	{
		override protected function onInit():void
		{
			scene.addChild(new TurtleAWD);
		}

		override protected function onPreRender():void
		{
			scene.rotationY++;
		}
	}
}