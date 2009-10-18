package
{
	import away3dlite.core.base.*;
	import away3dlite.loaders.*;
	import away3dlite.materials.BitmapFileMaterial;
	import away3dlite.templates.*;
	
	import flash.display.*;

	[SWF(backgroundColor="#000000", frameRate="30", quality="MEDIUM", width="800", height="600")]
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