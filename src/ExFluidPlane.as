package
{
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	import away3dlite.templates.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Vector3D;

	[SWF(backgroundColor="#000000", frameRate="30", width="800", height="600")]
	/**
	 * Fluid Plane Example
	 * @author katopz
	 */
	public class ExFluidPlane extends BasicTemplate
	{
		private var force:Number = 0;
		private var plane:Plane;
		private var step:Number = 0;

		override protected function onInit():void
		{
			camera.y = -500;
			camera.lookAt(new Vector3D(0, 0, 0));

			plane = new Plane(new BitmapFileMaterial("assets/sea01.jpg"), 500, 500, 10, 10);
			scene.addChild(plane);
		}

		override protected function onPreRender():void
		{
			scene.rotationY += .25;
			
			var _vertices:Vector.<Number> = plane.vertices;
			var _length:int = _vertices.length;

			for (var i:int = 1; i < _length; i += 3)
			{
				_vertices[i] = i * 0.1 * Math.sin(force + i/3);
				force += 0.001;
			}

			step += .01;
		}
	}
}