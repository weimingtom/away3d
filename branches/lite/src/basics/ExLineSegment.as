package basics
{
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	import away3dlite.templates.*;

	import flash.geom.Vector3D;

	[SWF(backgroundColor="#000000", frameRate="30", width="800", height="600")]
	/**
	 * Example : LineSegment
	 * @author katopz
	 */
	public class ExLineSegment extends BasicTemplate
	{
		override protected function onInit():void
		{
			title += " : LineSegment";

			var _radius:int = 200;
			for (var i:int = 0; i < 100; i++)
				scene.addChild(new LineSegment(new WireframeMaterial(int(0xFF0000 * Math.random()), 0.5 * Math.random()), new Vector3D(), new Vector3D(500 * Math.random() - _radius * Math.random(), _radius * Math.random() - _radius * Math.random(), _radius * Math.random() - _radius * Math.random())));

			// Axis Trident
			scene.addChild(new Trident);
		}

		/**
		 * @inheritDoc
		 */
		override protected function onPreRender():void
		{
			scene.rotationX++;
			scene.rotationY++;
			scene.rotationZ++;
		}
	}
}