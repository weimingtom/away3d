package basics
{
	import away3dlite.core.base.Face;
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	import away3dlite.templates.*;

	[SWF(backgroundColor="#000000", frameRate="30", quality="MEDIUM", width="800", height="600")]
	public class ExQuadWireframeMaterial extends BasicTemplate
	{
		override protected function onInit():void
		{
			scene.addChild(new Cube6(new QuadWireframeMaterial(0x0000FF, .5, 4), 100, 100, 100)).x = 200;
			scene.addChild(new Sphere(new QuadWireframeMaterial)).x = -200;
			scene.addChild(new Torus(new QuadWireframeMaterial)).z = 200;
			scene.addChild(new Cone(new QuadWireframeMaterial)).z = -200;
		}
		
		override protected function onPreRender():void
		{
			scene.rotationX++;
			scene.rotationY++;
			scene.rotationZ++;
		}
	}
}