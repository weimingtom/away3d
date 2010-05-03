package
{
	import away3dlite.loaders.*;
	import away3dlite.materials.BitmapFileMaterial;
	import away3dlite.templates.*;

	[SWF(backgroundColor="#000000", frameRate="30", width="800", height="600")]
	/**
	 * .obj loader example.
	 */
	public class ExOBJ extends BasicTemplate
	{
		override protected function onInit():void
		{
			title += " : Object Example.";
			scene.addChild(new OBJ("assets/turtle.obj", new BitmapFileMaterial("assets/turtle.jpg")));
		}

		override protected function onPreRender():void
		{
			scene.rotationY++;
		}
	}
}