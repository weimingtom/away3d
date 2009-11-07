package
{
	import away3d.materials.WireColorMaterial;
	import away3d.materials.WireframeMaterial;
	import away3d.test.SimpleView;
	
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import jiglib.cof.JConfig;
	import jiglib.math.JNumber3D;
	import jiglib.physics.PhysicsSystem;
	import jiglib.physics.RigidBody;
	import jiglib.physics.constraint.JConstraintPoint;
	import jiglib.plugin.away3d.Away3DPhysics;
	import jiglib.plugin.away3d.Away3dMesh;

	[SWF(backgroundColor="0xFFFFFF",frameRate="30",width="800",height="600")]
	/**
	 *
	 * JigLibFlash (rev99) for Away3D (rev1625) engine test
	 *
	 * @source http://jiglibflash.googlecode.com/svn/trunk/fp9/src
	 * @author katopz@sleepydesign.com
	 *
	 */
	public class ExFlash3DPhysics extends SimpleView
	{
		private var physics:Away3DPhysics;

		private var balls:Array;
		private var boxes:Array;

		private var spheres:Array;
		private var chains:Array;

		private var keyRight:Boolean = false;
		private var keyLeft:Boolean = false;
		private var keyForward:Boolean = false;
		private var keyReverse:Boolean = false;
		private var keyUp:Boolean = false;

		public function ExFlash3DPhysics()
		{
			super("JigLib", "JigLib rev99 via Away3D rev1625, Engine test by katopz");
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}

		override protected function create():void
		{
			JConfig.angVelThreshold = 5;
			JConfig.posThreshold = 0.2;
			JConfig.deactivationTime = 0.5;
			JConfig.numCollisionIterations = 4;
			JConfig.numContactIterations = 8;
			
			physics = new Away3DPhysics(view, 10);

			var ground:RigidBody = physics.createGround(
			{
				width: 1000, 
				height: 1000, 
				material:new WireframeMaterial(), 
				yUp:false, 
				pushback:true
			}, 200);

			balls = [];
			var i:int;
			var color:uint;
			for (i = 0; i < 3; i++)
			{
				var ball:RigidBody = physics.createSphere({radius: 20});
				ball.moveTo(new JNumber3D(-100, 240 + (60 * i + 60), -200));
				ball.mass = 3;
				balls.push(ball);
			}
			balls[i - 1].material.restitution = 0.9;

			boxes = [];
			for (i = 0; i < 4; i++)
			{
				var box:RigidBody = physics.createCube({width: 40, height: 40, depth: 40});
				box.moveTo(new JNumber3D(100, 240 + (60 * i + 60), -100));
				boxes.push(box);
			}

			spheres = [];
			for (i = 0; i < 6; i++)
			{
				var sphere:RigidBody = physics.createSphere({radius: 15, segmentsW: 3, segmentsH: 2})
				sphere.moveTo(new JNumber3D(-50 + (30 * i + 30), 430, 0));
				spheres.push(sphere);
			}
			spheres[0].movable = false;

			chains = [];
			var pos1:JNumber3D;
			var pos2:JNumber3D;
			for (i = 1; i < spheres.length; i++)
			{
				pos1 = JNumber3D.multiply(JNumber3D.UP, -spheres[i - 1].boundingSphere);
				pos2 = JNumber3D.multiply(JNumber3D.UP, spheres[i].boundingSphere);
				chains[i] = new JConstraintPoint(spheres[i - 1], pos1, spheres[i], pos2, 1, 0.2);
				PhysicsSystem.getInstance().addConstraint(chains[i]);
			}

			target.x = 0;
			target.y = 250;
			target.z = 0;

			view.camera.x = 0;
			view.camera.y = 500;
			view.camera.z = -400;
			view.camera.focus = 30;

			start();
		}

		private function keyDownHandler(event:KeyboardEvent):void
		{
			switch (event.keyCode)
			{
				case Keyboard.UP:
					keyForward = true;
					keyReverse = false;
					break;

				case Keyboard.DOWN:
					keyReverse = true;
					keyForward = false;
					break;

				case Keyboard.LEFT:
					keyLeft = true;
					keyRight = false;
					break;

				case Keyboard.RIGHT:
					keyRight = true;
					keyLeft = false;
					break;
				case Keyboard.SPACE:
					keyUp = true;
					break;
			}
		}


		private function keyUpHandler(event:KeyboardEvent):void
		{
			switch (event.keyCode)
			{
				case Keyboard.UP:
					keyForward = false;
					break;

				case Keyboard.DOWN:
					keyReverse = false;
					break;

				case Keyboard.LEFT:
					keyLeft = false;
					break;

				case Keyboard.RIGHT:
					keyRight = false;
					break;
				case Keyboard.SPACE:
					keyUp = false;
			}
		}

		private function resetBox():void
		{
			var i:int = 0;
			for each (var box:RigidBody in boxes)
			{
				if (box.currentState.position.y < 0)
				{
					box.moveTo(new JNumber3D(-100, 240 + (60 * int(i++) + 60), -200));
				}

				if (box.isActive())
				{
					Away3dMesh(box.skin).mesh.material = new WireColorMaterial();
				}
				else
				{
					Away3dMesh(box.skin).mesh.material = new WireColorMaterial(0xCCCCCC);
				}
			}

			for each (var ball:RigidBody in balls)
			{
				if (ball.currentState.position.y < 0)
				{
					ball.moveTo(new JNumber3D(-100, 240 + (60 * int(i++) + 60), -200));
				}

				if (ball.isActive())
				{
					Away3dMesh(ball.skin).mesh.material = new WireColorMaterial();
				}
				else
				{
					Away3dMesh(ball.skin).mesh.material = new WireColorMaterial(0xCCCCCC);
				}
			}
		}

		override protected function draw():void
		{
			if (keyLeft)
			{
				balls[0].addWorldForce(new JNumber3D(-100, 0, 0), balls[0].currentState.position);
			}
			if (keyRight)
			{
				balls[0].addWorldForce(new JNumber3D(100, 0, 0), balls[0].currentState.position);
			}
			if (keyForward)
			{
				balls[0].addWorldForce(new JNumber3D(0, 0, 100), balls[0].currentState.position);
			}
			if (keyReverse)
			{
				balls[0].addWorldForce(new JNumber3D(0, 0, -100), balls[0].currentState.position);
			}
			if (keyUp)
			{
				balls[0].addWorldForce(new JNumber3D(0, 100, 0), balls[0].currentState.position);
			}

			PhysicsSystem.getInstance().integrate(0.1);
			resetBox();
		}
	}
}