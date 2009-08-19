package
{
	import away3d.core.base.Object3D;
	import away3d.core.base.Vertex;
	import away3d.core.geom.Plane3D;
	import away3d.core.math.Number3D;
	import away3d.events.MouseEvent3D;
	import away3d.materials.WireframeMaterial;
	import away3d.primitives.LineSegment;
	import away3d.test.SimpleView;

	import flash.events.MouseEvent;

	import jiglib.math.JNumber3D;
	import jiglib.physics.RigidBody;
	import jiglib.physics.constraint.JConstraintWorldPoint;
	import jiglib.plugin.away3d.Away3DPhysics;
	import jiglib.plugin.away3d.Away3dMesh;

	[SWF(backgroundColor="0xFFFFFF", frameRate = "30", width = "800", height = "600")]
	/**
	 *
	 * JigLibFlash for Away3D Mouse Drag Demo
	 *
	 * @source http://code.google.com/p/jiglibflash/
	 * @author katopz@sleepydesign.com
	 *
	 */
	public class ExJigLibMouseDragAway3D extends SimpleView
	{
		private var physics:Away3DPhysics;

		private var boxBody:Array = [];

		private var onDraging:Boolean = false;

		private var currDragBody:RigidBody;
		private var dragConstraint:JConstraintWorldPoint;
		private var startMousePos:JNumber3D;
		private var planeToDragOn:Plane3D;
		private var dragLine:LineSegment;

		public function ExJigLibMouseDragAway3D()
		{
			super("JigLib", "JigLib for Away3D 3.2.1, Mouse Drag by katopz");
			stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseRelease);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
		}

		override protected function create():void
		{
			// Physics System
			physics = new Away3DPhysics(view, 10);

			// Ground
			var ground:RigidBody = physics.createGround(
			{
				width: 1000,
				height: 1000,
				material: new WireframeMaterial(),
				yUp: false,
				pushback: true
			}, 200);

			// Decor
			var box:RigidBody;
			var boxSize:Number = 100;
			for (var i:uint = 0; i < 4; i++)
			{
				box = physics.createCube({width: boxSize, height: boxSize, depth: boxSize})
				box.moveTo(new JNumber3D(200, 240 + (boxSize * i + 60), -100));
				Away3dMesh(box.skin).mesh.addOnMouseDown(handleMousePress);
			}

			// Fun!
			start();
		}

		private function findSkinBody(skin:Object3D):int
		{
			for (var i:String in physics.engine.bodys)
			{
				if (skin == physics.engine.bodys[i].skin.mesh)
				{
					return int(i);
				}
			}
			return -1;
		}

		private function handleMousePress(event:MouseEvent3D):void
		{
			onDraging = true;
			startMousePos = new JNumber3D(event.sceneX, event.sceneY, event.sceneZ);

			currDragBody = physics.engine.bodys[findSkinBody(event.object)];
			planeToDragOn = new Plane3D();
			planeToDragOn.fromNormalAndPoint(new Number3D(0, 0, -1), new Number3D(0, 0, -startMousePos.z));

			var bodyPoint:JNumber3D = JNumber3D.sub(startMousePos, currDragBody.currentState.position);
			dragConstraint = new JConstraintWorldPoint(currDragBody, bodyPoint, startMousePos);
			physics.engine.addConstraint(dragConstraint);
		}

		private function handleMouseMove(event:MouseEvent):void
		{
			if (onDraging)
			{
				var ray:Number3D = view.camera.unproject(view.mouseX, view.mouseY);
				ray.add(ray, new Number3D(view.camera.x, view.camera.y, view.camera.z));

				var cameraVertex:Vertex = new Vertex(view.camera.x, view.camera.y, view.camera.z);
				var rayVertex:Vertex = new Vertex(ray.x, ray.y, ray.z);
				var intersectPoint:Vertex = planeToDragOn.getIntersectionLine(cameraVertex, rayVertex);

				dragConstraint.worldPosition = new JNumber3D(intersectPoint.x, intersectPoint.y, intersectPoint.z);
			}
		}

		private function handleMouseRelease(event:MouseEvent):void
		{
			if (onDraging)
			{
				onDraging = false;
				physics.engine.removeConstraint(dragConstraint);
				currDragBody.setActive();
			}
		}

		override protected function draw():void
		{
			physics.engine.integrate(0.2);
		}
	}
}