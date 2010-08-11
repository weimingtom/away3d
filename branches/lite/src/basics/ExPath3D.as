package basics
{
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	import away3dlite.templates.*;
	
	import flash.geom.Matrix3D;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;

	[SWF(backgroundColor="#000000", frameRate="30", width="800", height="600")]
	/**
	 * Example : Path3D
	 * @author katopz
	 */
	public class ExPath3D extends BasicTemplate
	{
		override protected function onInit():void
		{
			title += " : Path3D, draw line by commands";

			var _radius:int = 100;
			var _segment:int = 20;

			var _paths:Vector.<Number>;

			for (var i:int = 0; i < 10; i++)
			{
				_paths = new Vector.<Number>();

				for (var j:int = 0; j < _segment; j++)
				{
					var factor:Number = _radius * (0.1 + j) / _segment;

					var a:Vector3D = new Vector3D(
						factor + factor*.5 * Math.random() - factor*.5 * Math.random(), 
						factor + factor*.5 * Math.random() - factor*.5 * Math.random(), 
						factor + factor*.5 * Math.random() - factor*.5 * Math.random());

					var matrix:Matrix3D = new Matrix3D();
					matrix.appendRotation(i * Math.random(), Vector3D.X_AXIS);
					matrix.appendRotation(i * Math.random(), Vector3D.Y_AXIS);
					matrix.appendRotation(i * Math.random(), Vector3D.Z_AXIS);

					var b:Vector3D = Utils3D.projectVector(matrix, a);

					_paths.push(b.x, b.y, b.z);
				}
				
				scene.addChild(new Path3D(new PathMaterial(int(0xFF0000 * Math.random()), 0.5 + 0.5 * Math.random()), _paths));
			}
			
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