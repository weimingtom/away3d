package
{
	import away3d.core.base.Object3D;
	import away3d.core.base.Vertex;
	import away3d.core.geom.Plane3D;
	import away3d.core.math.Matrix3D;
	import away3d.core.math.Number3D;
	import away3d.events.MouseEvent3D;
	import away3d.primitives.Cube;
	import away3d.primitives.LineSegment;
	import away3d.primitives.Plane;
	import away3d.test.SimpleView;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import jiglib.geometry.JBox;
	import jiglib.geometry.JPlane;
	import jiglib.math.JMatrix3D;
	import jiglib.math.JNumber3D;
	import jiglib.physics.PhysicsSystem;
	import jiglib.physics.RigidBody;
	import jiglib.physics.constraint.JConstraintWorldPoint;
	
	[SWF(backgroundColor="0xFFFFFF", frameRate="30", width="800", height="600")]
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
		private var boxBody			:Array = [];
		
		private var onDraging		:Boolean = false;
		
		private var currDragBody	:RigidBody;
		private var dragConstraint	:JConstraintWorldPoint;
		private var startMousePos	:JNumber3D;
		private var planeToDragOn	:Plane3D;
		private var dragLine		:LineSegment;
		
		public function ExJigLibMouseDragAway3D()
		{
			super("JigLib", "JigLib for Away3D 3.2.1, Mouse Drag by katopz");
			stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseRelease);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
		}
		
		override protected function create() : void
		{
			// Physics System
			var planeSkin:Plane = new Plane({width:500, height:500});
			var plane:JPlane = new JPlane(planeSkin);
			plane.MoveTo(new JNumber3D(0, 0, 0), JMatrix3D.multiply(JMatrix3D.rotationY(Math.PI / 2), JMatrix3D.rotationX(Math.PI / 2)));
			PhysicsSystem.getInstance().AddBody(plane);
			
			// Ground
			var ground:Plane = new Plane({width:1000, height:1000, pushback:true});
			view.scene.addChild(ground);
			
			// Decor
			var boxSkin:Cube;
			var boxSize:Number = 100;
			for (var i:uint = 0; i < 4; i++)
			{
			    boxSkin = new Cube({width:boxSize, height:boxSize, depth:boxSize});
			    boxSkin.addOnMouseDown(handleMousePress);
			    
				view.scene.addChild(boxSkin);
				boxBody[i] = new JBox(boxSkin,true,boxSize,boxSize,boxSize);
				boxBody[i].MoveTo(new JNumber3D(200, 240 + (boxSize * i + 60), -100), JMatrix3D.IDENTITY);
				PhysicsSystem.getInstance().AddBody(boxBody[i]);
			}
			
			// Dubug
			dragLine = new LineSegment();
			view.scene.addChild(dragLine);
			dragLine.visible = false;
			
			// Fun!
			start();
		}
		
		private function findSkinBody(skin:Object3D):int
		{
			for (var i:String in PhysicsSystem.getInstance().Bodys)
			{
				if (skin == PhysicsSystem.getInstance().Bodys[i].BodySkin)
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
			
			currDragBody = PhysicsSystem.getInstance().Bodys[findSkinBody(event.object)];
			planeToDragOn = new Plane3D();
			planeToDragOn.fromNormalAndPoint(new Number3D(0, 0, -1), new Number3D(0, 0, -startMousePos.z));
			
			var bodyPoint:JNumber3D = JNumber3D.sub(startMousePos, currDragBody.CurrentState.Position);
			dragConstraint = new JConstraintWorldPoint(currDragBody, bodyPoint, startMousePos);
			PhysicsSystem.getInstance().AddConstraint(dragConstraint);
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
				
				dragConstraint.WorldPosition = new JNumber3D(intersectPoint.x, intersectPoint.y, intersectPoint.z);
				
				// Debug
				dragLine.start = new Vertex(currDragBody.CurrentState.Position.x, currDragBody.CurrentState.Position.y, currDragBody.CurrentState.Position.z);
				dragLine.end = new Vertex(intersectPoint.x, intersectPoint.y, intersectPoint.z);
				
				dragLine.visible = true;
			}else{
				dragLine.visible = false;
			}
		}
		
		private function handleMouseRelease(event:MouseEvent):void
		{
			if (onDraging)
			{
				onDraging = false;
				PhysicsSystem.getInstance().RemoveConstraint(dragConstraint);
				currDragBody.SetActive();
			}
		}
			
		override protected function draw() : void
		{
			PhysicsSystem.getInstance().Integrate(0.2);
		}
	}
}