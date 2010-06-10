package basics
{
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	import away3dlite.templates.*;

	[SWF(backgroundColor="#000000", frameRate="30", quality="MEDIUM", width="800", height="600")]

	public class ExSphere extends BasicTemplate
	{
		override protected function onInit():void
		{
			var segments:uint = 30;
			title += " : Sphere stress test " + segments + "x" + segments + " segments";
			var sphere:Sphere = new Sphere(new WireColorMaterial, 100, segments, segments);
			scene.addChild(sphere);
		}

		override protected function onPreRender():void
		{
			scene.rotationY += 0.2;
		}
	}
}