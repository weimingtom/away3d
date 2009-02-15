package 
{
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.utils.*;
	import away3d.lights.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	import flash.display.*;
	import flash.events.*;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="LOW", width="800", height="600")]
	
	public class Basic_Cube extends Sprite
	{
		//texture for globe
		[Embed(source="assets/earth512.png")]
    	public static var EarthImage:Class;
		
    	//signature swf
    	[Embed(source="assets/signature.swf", symbol="Signature")]
    	public var SignatureSwf:Class;
    	
		//engine variables
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		//material objects
		private var material:BitmapMaterial;
		
		//scene objects
		private var cube:Cube;
		private var spherecontainer:ObjectContainer3D;
		
		//light objects
		private var light:DirectionalLight3D;
		
		//navigation variables
		private var navigate:Boolean = false;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		private var lastRotationX:Number;
		private var lastRotationY:Number;
		
		/**
		 * Constructor
		 */
		public function Basic_Cube() 
		{
			init();
		}
		
		/**
		 * Global initialise function
		 */
		private function init():void
		{
			initEngine();
			initMaterials();
			initObjects();
			initLights();
			initListeners();
		}
		
		/**
		 * Initialise the engine
		 */
		private function initEngine():void
		{
			scene = new Scene3D();
			camera = new Camera3D({zoom:10, focus:100, x:0, y:0, z:-1000});
			
			view = new View3D({scene:scene, camera:camera});
			view.x = 400;
			view.y = 300;
			addChild( view );
			
			//add signature
            Signature = Sprite(new SignatureSwf());
            SignatureBitmap = new Bitmap(new BitmapData(Signature.width, Signature.height, true, 0));
            stage.quality = StageQuality.HIGH;
            SignatureBitmap.bitmapData.draw(Signature);
            stage.quality = StageQuality.LOW;
            addChild(SignatureBitmap);
		}
		
		/**
		 * Initialise the materials
		 */
		private function initMaterials():void
		{
			material = new BitmapMaterial( Cast.bitmap(EarthImage), {repeat:true} );
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			cube = new Cube({ownCanvas:true, material:material, width:400, height:400, depth:400});
			spherecontainer = new ObjectContainer3D();
			spherecontainer.addChild(cube);
			scene.addChild( spherecontainer );
		}
		
		/**
		 * Initialise the lights
		 */
		private function initLights():void
		{
			light = new DirectionalLight3D({x:1, y:1, z:-1, ambient:0.2});
			scene.addChild(light);
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			addEventListener( Event.ENTER_FRAME, onEnterFrame );
			stage.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
			onResize(null);
		}
		
		/**
		 * Navigation and render loop
		 */
		private function onEnterFrame( e:Event ):void
		{
			view.render();
			cube.rotationY += 2;
			cube.rotationX += 2;
			if (navigate) {
				spherecontainer.rotationX = (mouseY - lastMouseY)/2 + lastRotationX;
				if (spherecontainer.rotationX > 90)
					spherecontainer.rotationX = 90;
				if (spherecontainer.rotationX < -90)
					spherecontainer.rotationX = -90;
				cube.rotationY = (lastMouseX - mouseX)/2 + lastRotationY;
			}
		}
		
		/**
		 * Mouse down listener for navigation
		 */
		private function onMouseUp(e:MouseEvent):void
		{
			navigate = false;
		}
		
		/**
		 * Mouse up listener for navigation
		 */
		private function onMouseDown(e:MouseEvent):void
		{
			lastRotationX = spherecontainer.rotationX;
			lastRotationY = cube.rotationY;
			lastMouseX = mouseX;
			lastMouseY = mouseY;
			navigate = true;
		}
		
		/**
		 * stage listener for resize events
		 */
		private function onResize(event:Event):void
		{
			view.x = stage.stageWidth / 2;
            view.y = stage.stageHeight / 2;
            SignatureBitmap.y = stage.stageHeight - Signature.height;
		}
	}
}