package
{
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	import away3dlite.templates.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.Vector3D;

	[SWF(backgroundColor="#000000", frameRate="30", quality="MEDIUM", width="800", height="600")]
	/**
	 * Example : LineSegment
	 * @author katopz
	 */
	public class ExLineSegment extends BasicTemplate
	{
		override protected function onInit():void
		{
			title += " : LineSegment";
			view.setSize(800, 600);
			view.x = 800/2;
			view.y = 600/2;
			
			var _xLine:LineSegment = new LineSegment(new WireframeMaterial(0xFF0000), new Vector3D(0,0,0), new Vector3D(100,100,100));
			scene.addChild(_xLine);
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