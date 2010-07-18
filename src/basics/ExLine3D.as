package basics
{
	import away3dlite.containers.Lines;
	import away3dlite.core.base.Line3D;
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	import away3dlite.templates.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Vector3D;

	[SWF(backgroundColor="#000000", frameRate="30", width="800", height="600")]
	/**
	 * Line3D Example
	 * @author katopz
	 */
	public class ExLine3D extends BasicTemplate
	{
		private var _lines:Lines;
		private var _lineMaterial:LineMaterial;

		private const radius:uint = 300;
		private const total:int = 1000;

		override protected function onInit():void
		{
			title = "Away3DLite | Lines : " + total + " | Click to toggle Lines Draw mode (sprite/bitmap)";

			// create materials
			_lineMaterial = new LineMaterial(0xFF0000);

			// create lines
			_lines = new Lines();
			scene.addChild(_lines);

			// positions
			for (var i:int = 0; i < total; i++)
				_lines.addLine(new Line3D(
					new Vector3D(radius*Math.random() - radius*Math.random(), radius*Math.random() - radius*Math.random(), radius*Math.random() - radius*Math.random()), 
					new Vector3D(radius*Math.random() - radius*Math.random(), radius*Math.random() - radius*Math.random(), radius*Math.random() - radius*Math.random()), 
					new LineMaterial(int(Math.random()*0xFFFFFF))));

			// center
			scene.addChild(new Sphere(null, 50, 6, 6));

			// toggle
			stage.addEventListener(MouseEvent.CLICK, onClick);
		}

		private function onClick(event:MouseEvent):void
		{
			if (!_lines.bitmap)
			{
				_lines.bitmap = new Bitmap(new BitmapData(view.screenWidth, view.screenHeight, true, 0x00000000));
				addChild(_lines.bitmap);

				// bitmap effect
				//_lines.bitmap.filters = [new BlurFilter(8, 8)];
				//_lines.bitmap.blendMode = BlendMode.ADD;
			}
			else
			{
				removeChild(_lines.bitmap);
				_lines.bitmap.bitmapData.dispose();
				_lines.bitmap = null;
			}
		}

		override protected function onPreRender():void
		{
			scene.rotationX += .5;
			scene.rotationY += .5;
			scene.rotationZ += .5;
		}
	}
}