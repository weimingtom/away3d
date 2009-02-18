package
{
	import away3d.materials.ColorMaterial;
	import away3d.materials.WireColorMaterial;
	import away3d.primitives.Cube;
	import away3d.primitives.Plane;
	import away3d.primitives.Sphere;
	import away3d.test.SimpleView;
	
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import jiglib.geometry.JBox;
	import jiglib.geometry.JPlane;
	import jiglib.geometry.JSphere;
	import jiglib.math.JMatrix3D;
	import jiglib.math.JNumber3D;
	import jiglib.physics.PhysicsSystem;
	import jiglib.physics.constraint.JConstraintPoint;
	
	[SWF(backgroundColor="0xFFFFFF", frameRate="30", width="800", height="600")]
	/**
	 * 
	 * JigLibFlash for Away3D test run
	 * 
	 * @source http://code.google.com/p/jiglibflash/
	 * @author katopz@sleepydesign.com
	 * 
	 */	
	public class ExJigLibAway3DFlash3DPhysics extends SimpleView
	{
		private var ballBody	:Array;
		private var boxBody		:Array;
		
		private var chainBody	:Array;
		private var chain		:Array;
		
		private var keyRight  	:Boolean = false;
		private var keyLeft   	:Boolean = false;
		private var keyForward 	:Boolean = false;
		private var keyReverse	:Boolean = false;
		private var keyUp		:Boolean = false;
		
		public function ExJigLibAway3DFlash3DPhysics()
		{
			super("JigLib", "JigLib for Away3D 3.2.1, Engine test run by katopz");
			stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler );
			stage.addEventListener( KeyboardEvent.KEY_UP, keyUpHandler );
		}
		
		override protected function create() : void
		{
			var groundSkin:Cube = new Cube();
			
			var ground:JBox = new JBox(groundSkin, false);
			PhysicsSystem.getInstance().AddBody(ground);
			ground.Material.Restitution = 0.6;
			ground.Material.StaticFriction = 0.9;
			
			var planeSkin:Plane = new Plane({width:500, height:500, pushback:true});
			view.scene.addChild(planeSkin);
			var plane:JPlane = new JPlane(planeSkin);
			PhysicsSystem.getInstance().AddBody(plane);
			
			ballBody = [];
			var color:uint;
			var sphereSkin:Sphere;
			for (var i:int = 0; i < 3; i++)
			{
				color = (i == 0)?0xff8888:0xeeee00;
				sphereSkin = new Sphere({radius:20});
				view.scene.addChild(sphereSkin);
				ballBody[i] = new JSphere(sphereSkin,true,20);
				ballBody[i].setMass(3);
				ballBody[i].MoveTo(new JNumber3D(-100, 240 + (60 * i + 60), -200), JMatrix3D.IDENTITY);
				PhysicsSystem.getInstance().AddBody(ballBody[i]);
			}
			ballBody[i-1].Material.Restitution = 0.9;
			 
			boxBody=[];
			var boxSkin:Cube;
			for (i = 0; i < 4; i++)
			{
			    boxSkin = new Cube({width:40, height:40, depth:40});
				view.scene.addChild(boxSkin);
				boxBody[i] = new JBox(boxSkin,true,40,40,40);
				boxBody[i].MoveTo(new JNumber3D(100, 240 + (60 * i + 60), -100), JMatrix3D.IDENTITY);
				PhysicsSystem.getInstance().AddBody(boxBody[i]);
			}
			 
			chain = [];
			chainBody = [];
			for (i = 0; i < 6; i++)
			{
				color = (i == 0)?0x77ee77:0xeeee00;
				sphereSkin = new Sphere({radius:15,segmentsW:3,segmentsH:2})
				view.scene.addChild(sphereSkin);
				chainBody[i] = new JSphere(sphereSkin,true,15);
				chainBody[i].MoveTo(new JNumber3D( -50 + (30 * i + 30), 430, 0), JMatrix3D.IDENTITY);
				PhysicsSystem.getInstance().AddBody(chainBody[i]);
			}
			chainBody[0].SetMovable(false);
			 
			var pos1:JNumber3D;
			var pos2:JNumber3D;
			for (i = 1; i < chainBody.length; i++ )
			{
				pos1 = JNumber3D.multiply(JNumber3D.UP, -chainBody[i - 1].BoundingSphere);
				pos2 = JNumber3D.multiply(JNumber3D.UP, chainBody[i].BoundingSphere);
				chain[i] = new JConstraintPoint(chainBody[i - 1], pos1, chainBody[i], pos2, 1, 0.2);
				PhysicsSystem.getInstance().AddConstraint(chain[i]);
			}
			
			target.x=0;
			target.y=250;
			target.z=0;
			
			view.camera.x = 0;
			view.camera.y = 500;
			view.camera.z = -400;
			view.camera.focus = 50;
			
			start();
		}
	
		private function keyDownHandler(event :KeyboardEvent):void
		{
			switch(event.keyCode)
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
			switch(event.keyCode)
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
				    keyUp=false;
			}
		}
		
		private function resetBox():void
		{
			for (var i:String in ballBody)
			{
				if (ballBody[i].CurrentState.Position.y < 0)
				{
					ballBody[i].MoveTo(new JNumber3D(-100, 240 + (60 * Number(i) + 60), -200), JMatrix3D.IDENTITY);
				}
				 
				if (ballBody[i].IsActive())
				{
					ballBody[i].BodySkin.material = new WireColorMaterial();
				}
				else
				{
					ballBody[i].BodySkin.material = new WireColorMaterial(0xCCCCCC);
				}
			}
			for (i in boxBody)
			{
				if (boxBody[i].CurrentState.Position.y < 0)
				{
					boxBody[i].MoveTo(new JNumber3D(100, 240 + (60 * Number(i) + 60), -100), JMatrix3D.IDENTITY);
				}
				
				if (boxBody[i].IsActive())
				{
					boxBody[i].BodySkin.material = new WireColorMaterial();
				}
				else
				{
					boxBody[i].BodySkin.material = new WireColorMaterial(0xCCCCCC);
				}
			}
		}
	
		override protected function draw():void
		{
			if(keyLeft)
			{
				ballBody[0].AddWorldForce(new JNumber3D(-100,0,0),ballBody[0].CurrentState.Position);
			}
			if(keyRight)
			{
				ballBody[0].AddWorldForce(new JNumber3D(100,0,0),ballBody[0].CurrentState.Position);
			}
			if(keyForward)
			{
				ballBody[0].AddWorldForce(new JNumber3D(0,0,100),ballBody[0].CurrentState.Position);
			}
			if(keyReverse)
			{
				ballBody[0].AddWorldForce(new JNumber3D(0,0,-100),ballBody[0].CurrentState.Position);
			}
			if(keyUp)
			{
				ballBody[0].AddWorldForce(new JNumber3D(0,100,0),ballBody[0].CurrentState.Position);
			}
			
			PhysicsSystem.getInstance().Integrate(0.1);
			resetBox();
		}
	}
}