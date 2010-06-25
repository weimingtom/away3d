package interactives
{
	import away3dlite.core.math.Plane3D;
	import away3dlite.materials.WireColorMaterial;
	import away3dlite.primitives.Plane;
	import away3dlite.primitives.Sphere;
	import away3dlite.templates.BasicTemplate;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	[SWF(backgroundColor="#666666", frameRate="30", quality="MEDIUM", width="800", height="600")]
	/**
	 * Example : Face Click and Drag on Plane3D.
	 * @author katopz
	 */
	public class ExPlane3D extends BasicTemplate
	{
		private var _sphere:Sphere;
		private var _plane:Plane;
		private var _target:Vector3D;

		override protected function onInit():void
		{
			title += " | Mouse Control | click to move red ballon Plane3D | ";

			// view
			camera.y = -1000;
			camera.lookAt(new Vector3D());

			// object
			scene.addChild(_sphere = new Sphere(new WireColorMaterial(null, 0.5), 50));
			scene.addChild(_plane = new Plane(new WireColorMaterial(null, 0.5), 1000, 1000, 8, 5));

			// object layer
			view.addChild(_sphere.layer = new Sprite);

			// sphere don't need to be clickable
			_sphere.layer.mouseEnabled = false;

			// set target position
			_target = _sphere.transform.matrix3D.position;

			// wait for click
			view.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}

		private function onMouseDown(event:MouseEvent):void
		{
			// get position from plane
			var _normal:Vector3D = _plane.transform.matrix3D.deltaTransformVector(Vector3D.Y_AXIS);
			var _plane3D:Vector3D = Plane3D.fromNormalAndPoint(_normal, new Vector3D());
			var _ray:Vector3D = camera.lens.unProject(view.mouseX, view.mouseY, camera.screenMatrix3D.position.z);
			_ray = camera.transform.matrix3D.transformVector(_ray);

			// set target position
			_target = Plane3D.getIntersectionLine(_plane3D, camera.position, _ray);

			// get face index by x,z position, simulate real face click
			var _faceIndex:int = getFaceIndexHit(_target.x, _target.z, _plane.width, _plane.height, _plane.segmentsW, _plane.segmentsH);

			// apply face material if face hit
			if (_faceIndex != -1)
				_plane.faces[_faceIndex].material = new WireColorMaterial(null, 0.5);
		}

		private function getFaceIndexHit(x:Number, y:Number, width:Number, height:Number, segmentsW:int, segmentsH:int):int
		{
			// hit test
			var _rect:Rectangle = new Rectangle(-width * .5, -height * .5, width, height);
			if (_rect.contains(x, z))
				return int(_plane.segmentsH * (y / _plane.height + .5)) * _plane.segmentsW + int(_plane.segmentsW * (x / _plane.width + .5));
			else
				return -1;
		}

		override protected function onPreRender():void
		{
			// move
			_sphere.x += (_target.x - _sphere.x) / 4;
			_sphere.y += (_target.y - _sphere.y) / 4;
			_sphere.z += (_target.z - _sphere.z) / 4;
		}
	}
}