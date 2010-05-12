package
{
	import away3dlite.core.base.Face;
	import away3dlite.events.MouseEvent3D;
	import away3dlite.materials.ColorMaterial;
	import away3dlite.primitives.Plane;
	import away3dlite.templates.BasicTemplate;

	[SWF(backgroundColor="#000000", frameRate="30", width="800", height="600")]
	/**
	 * Example : Change Face Material when hit
	 * @author katopz
	 */
	public class ExFaceClick extends BasicTemplate
	{
		private var _plane:Plane;

		override protected function onInit():void
		{
			title += " : Change Face Material when hit";

			_plane = new Plane(new ColorMaterial(0xFF0000), 200, 200, 2, 2);
			_plane.bothsides = true;
			_plane.rotationX = 45;
			scene.addChild(_plane);

			scene.addEventListener(MouseEvent3D.MOUSE_UP, onSceneMouseUp);
		}

		private function onSceneMouseUp(e:MouseEvent3D):void
		{
			var _face:Face = e.face;
			_face.material = new ColorMaterial(int(Math.random() * 0xFF0000));
		}

		/**
		 * @inheritDoc
		 */
		override protected function onPreRender():void
		{
			//scene.rotationY++;
		}
	}
}