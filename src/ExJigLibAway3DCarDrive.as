package  
{
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Mesh;
	import away3d.events.LoaderEvent;
	import away3d.loaders.Collada;
	import away3d.loaders.Object3DLoader;
	import away3d.materials.WireColorMaterial;
	import away3d.primitives.Cube;
	import away3d.primitives.Plane;
	import away3d.test.SimpleView;
	
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import jiglib.geometry.JBox;
	import jiglib.geometry.JPlane;
	import jiglib.math.JMatrix3D;
	import jiglib.math.JNumber3D;
	import jiglib.physics.PhysicsSystem;
	import jiglib.vehicles.JCar;
	
	[SWF(backgroundColor="0xFFFFFF", frameRate="30", width="800", height="600")]
	/**
	 * 
	 * JigLibFlash for Away3D CarDrive Demo
	 * 
	 * @source http://code.google.com/p/jiglibflash/
	 * @author katopz@sleepydesign.com
	 * 
	 */	
	public class ExJigLibAway3DCarDrive extends SimpleView
	{
		private var carBody :JCar;
		private var carSkin :Collada;
		private var steerFR :ObjectContainer3D;
		private var steerFL :ObjectContainer3D;
		private var wheelFR :Mesh;
		private var wheelFL :Mesh;
		private var wheelRR :Mesh;
		private var wheelRL :Mesh;
		
		private var boxBody	:Array=[];
		
		public function ExJigLibAway3DCarDrive() 
		{
			super("JigLib", "JigLib CarDrive by katopz");
			stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler );
			stage.addEventListener( KeyboardEvent.KEY_UP, keyUpHandler );
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
				view.scene.addChild(boxSkin);
				boxBody[i] = new JBox(boxSkin,true,boxSize,boxSize,boxSize);
				boxBody[i].MoveTo(new JNumber3D(200, 240 + (boxSize * i + 60), -100), JMatrix3D.IDENTITY);
				PhysicsSystem.getInstance().AddBody(boxBody[i]);
			}
			
			// Car
			var loader:Object3DLoader = Collada.load("assets/Focus.dae",{scaling:.25});
			loader.addOnSuccess(onLoaderSuccess);
			view.scene.addChild(loader);
		}
		
		private function onLoaderSuccess(event:LoaderEvent):void
		{
			// Get Car
			var carSkin:ObjectContainer3D = ObjectContainer3D(event.loader.handle);
			view.scene.addChild(carSkin);
			
			// Bind Car -> Physics
			carBody = new JCar(carSkin);
			carBody.Chassis.MoveTo(new JNumber3D( 0, 400, -400), JMatrix3D.rotationY(80));
			carBody.Chassis.setMass(5);
			carBody.Chassis.Material.DynamicFriction = 0.3;
			carBody.Chassis.SideLengths = new JNumber3D(50, 20, 70);
			PhysicsSystem.getInstance().AddBody(carBody.Chassis);
			
			// Wheel
			carBody.SetupWheel("wheel_fl", new JNumber3D( -30, -5,  32), 2, 2, 0.5, 10, 0.7, 0.6, 1);
			carBody.SetupWheel("wheel_fr", new JNumber3D(  30, -5,  32), 2, 2, 0.5, 10, 0.7, 0.6, 1);
			carBody.SetupWheel("wheel_bl", new JNumber3D( -30, -5, -32), 2, 2, 0.5, 10, 0.7, 0.6, 1);
			carBody.SetupWheel("wheel_br", new JNumber3D(  30, -5, -32), 2, 2, 0.5, 10, 0.7, 0.6, 1);
			
			steerFR = carSkin.getChildByName( "Steer_FR" ) as ObjectContainer3D;
			steerFL = carSkin.getChildByName( "Steer_FL" ) as ObjectContainer3D;
			
			wheelFR = steerFR.getChildByName( "Steer_FR_Wheel_FR" ) as Mesh;
			wheelFL = steerFL.getChildByName( "Steer_FL_Wheel_FL" ) as Mesh;
			wheelRR = carSkin.getChildByName( "Focus_Wheel_RR" ) as Mesh;
			wheelRL = carSkin.getChildByName( "Focus_Wheel_RL" ) as Mesh;
			
			// Look at me please
			target = carSkin;
			
			// Fun!
			start();
		}
		
		private function keyDownHandler(event :KeyboardEvent):void
		{
			switch(event.keyCode)
			{
				case Keyboard.UP:
					carBody.SetAccelerate(1);
					break;
				case Keyboard.DOWN:
					carBody.SetAccelerate(-1);
					break;
				case Keyboard.LEFT:
					carBody.SetSteer(["wheel_fl", "wheel_fr"], -1);
					break;
				case Keyboard.RIGHT:
					carBody.SetSteer(["wheel_fl", "wheel_fr"], 1);
					break;
				case Keyboard.SPACE:
					carBody.SetHBrake(1);
					break;
			}
		}
		
		private function keyUpHandler(event:KeyboardEvent):void
		{
			switch(event.keyCode)
			{
				case Keyboard.UP:
					carBody.SetAccelerate(0);
					break;
				case Keyboard.DOWN:
					carBody.SetAccelerate(0);
					break;
				case Keyboard.LEFT:
					carBody.SetSteer(["wheel_fl", "wheel_fr"], 0);
					break;
				case Keyboard.RIGHT:
					carBody.SetSteer(["wheel_fl", "wheel_fr"], 0);
					break;
				case Keyboard.SPACE:
				   carBody.SetHBrake(0);
				   break;
			}
		}
		
		private function updateWheelSkin():void
		{
			steerFL.rotationY = carBody.Wheels["wheel_fl"].GetSteerAngle();
			steerFR.rotationY = carBody.Wheels["wheel_fr"].GetSteerAngle();
			
			wheelFR.roll(carBody.Wheels["wheel_fr"].getRollAngle());
			wheelFL.roll(-carBody.Wheels["wheel_fl"].getRollAngle());
			wheelRR.roll(carBody.Wheels["wheel_br"].getRollAngle());
			wheelRL.roll(-carBody.Wheels["wheel_bl"].getRollAngle());
		}
		
		private function resetBox():void
		{
			for each (var _boxBody:* in boxBody)
			{
				if (_boxBody.IsActive())
					_boxBody.BodySkin.material = new WireColorMaterial();
				else
					_boxBody.BodySkin.material = new WireColorMaterial(0xCCCCCC);
			}
		}
		
		override protected function draw() : void
		{
			PhysicsSystem.getInstance().Integrate(0.1);
			updateWheelSkin();
			resetBox();
		}
	}
}