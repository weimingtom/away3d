package
{
	import away3dlite.core.base.Face;
	import away3dlite.events.MouseEvent3D;
	import away3dlite.materials.ColorMaterial;
	import away3dlite.primitives.Plane;
	import away3dlite.templates.BasicTemplate;

	[SWF(backgroundColor="#000000", frameRate="30", width="800", height="600")]
	/**
	 * Example : Change face material when click.
	 * @author katopz
	 */
	public class ExFaceClick extends BasicTemplate
	{
		private var _plane:Plane;

		override protected function onInit():void
		{
			title += " : Change face material when click.";

			_plane = new Plane(new ColorMaterial(0xFF0000), 200, 200, 2, 2);
			_plane.bothsides = true;
			_plane.rotationX = 45;
			scene.addChild(_plane);

			_plane.faces[0].material = new ColorMaterial(0xFF0000);
			_plane.faces[1].material = new ColorMaterial(0x00FF00);
			_plane.faces[2].material = new ColorMaterial(0x0000FF);
			_plane.faces[3].material = new ColorMaterial(0xFF00FF);

			scene.addEventListener(MouseEvent3D.MOUSE_UP, onSceneMouseUp);
		}

		private function onSceneMouseUp(e:MouseEvent3D):void
		{
			var _face:Face = e.face;
			_face.material = new ColorMaterial(int(Math.random() * 0xFFFFFF));
		}
	}
}