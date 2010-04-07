package
{
	import away3dlite.core.base.Object3D;
	import away3dlite.loaders.AWData;
	import away3dlite.loaders.Loader3D;
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	import away3dlite.templates.*;
	
	import flash.display.*;
	import flash.events.*;

	[SWF(backgroundColor="#000000",frameRate="30",width="800",height="600")]
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