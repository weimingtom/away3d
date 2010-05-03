package
{
	import away3dlite.loaders.AWData;
	import away3dlite.templates.*;

	[SWF(backgroundColor="#000000", frameRate="30", width="800", height="600")]
	public class ExAWD extends BasicTemplate
	{
		[Embed(source="assets/AWD_turtle.awd", mimeType="application/octet-stream")]
		private var AWDTurtle:Class;

		override protected function onInit():void
		{
			scene.addChild(AWData.parse(new AWDTurtle()));
		}

		override protected function onPreRender():void
		{
			scene.rotationY++;
		}
	}
}