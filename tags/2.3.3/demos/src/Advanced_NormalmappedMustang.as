package
{
	import AS3s.*;
	
	import away3d.cameras.*;
	import away3d.cameras.lenses.SphericalLens;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.render.*;
	import away3d.core.utils.*;
	import away3d.events.*;
	import away3d.lights.*;
	import away3d.loaders.*;
	import away3d.loaders.data.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	[SWF(backgroundColor="#677999", frameRate="30", quality="LOW", width="800", height="600")]
	 
	public class Advanced_NormalmappedMustang extends Sprite
	{
		//cracks texture for desert
		[Embed(source="assets/discbrakes.png")]
    	public var BrakesTexture:Class;
    	
    	//horizon texture for gradient
    	[Embed(source="assets/dragradial.png")]
    	public var TiresTexture1:Class;
    	
    	//skydome texture
    	[Embed(source="assets/dragradialbump.jpg")]
    	public var TiresTexture2:Class;
		
		//ferrari texture
		[Embed(source="assets/eleanor_hub.png")]
		private var HubTexture:Class;
		
		//ferrari texture
		[Embed(source="assets/eleanor_shadow_256.png")]
		private var ShadowTexture:Class;
				
		//ferrari texture
		[Embed(source="assets/Mustang_diffuse.png")]
		private var BodyTexture:Class;
				
		//ferrari texture
		[Embed(source="assets/MustangObject_NRM.png")]
		private var Normalmap:Class;
		
    	//signature swf
    	[Embed(source="assets/signature.swf", symbol="Signature")]
    	public var SignatureSwf:Class;
    	
    	//engine variables
    	private var scene:Scene3D;
		private var camera:HoverCamera3D;
		private var view:View3D;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		//material objects
		private var bodyMaterial:Dot3BitmapMaterial;
		//private var hubMaterial:Dot3BitmapMaterial;
		private var hubMaterial:WhiteShadingBitmapMaterial;
		private var brakesMaterial:WhiteShadingBitmapMaterial;
		private var tiresMaterial:WhiteShadingBitmapMaterial;
		private var shadowMaterial:BitmapMaterial;
		
		//scene objects
		private var mustang:MustangGT500;
		private var shadow:Mesh;
		private var floor:RegularPolygon;
		private var sky:Sphere;
		
		//scene lights
		private var light:DirectionalLight3D;
		
		//navigation variables
		private var move:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		/**
		 * Constructor
		 */
		public function Advanced_NormalmappedMustang()
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
			camera = new HoverCamera3D({zoom:20, focus:50, lookat:"center"});
			camera.lens = new SphericalLens();
			camera.distance = 600;
			camera.maxtiltangle = 70;
			camera.mintiltangle = 0;
			camera.targetpanangle = camera.panangle = -140;
			camera.targettiltangle = camera.tiltangle = 20;
			view = new View3D({scene:scene, camera:camera});
			view.x = 400;
			view.y = 300;
			view.addSourceURL("srcview/index.html");
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
			bodyMaterial = new Dot3BitmapMaterial(Cast.bitmap(BodyTexture), Cast.bitmap(Normalmap), {specular:0.5, shininess:40});
			hubMaterial = new WhiteShadingBitmapMaterial(Cast.bitmap(HubTexture));
			brakesMaterial = new WhiteShadingBitmapMaterial(Cast.bitmap(BrakesTexture));
			tiresMaterial = new WhiteShadingBitmapMaterial(Cast.bitmap(TiresTexture1));
			shadowMaterial = new BitmapMaterial(Cast.bitmap(ShadowTexture));
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			//create mustang model
			mustang = new MustangGT500({scaling:.06});
			
			var backLeftWheelSession:SpriteRenderSession = new SpriteRenderSession();
			var backRightWheelSession:SpriteRenderSession = new SpriteRenderSession();
			var frontLeftWheelSession:SpriteRenderSession = new SpriteRenderSession();
			var frontRightWheelSession:SpriteRenderSession = new SpriteRenderSession();
			
			var frontLeftTire:Mesh = mustang.meshes[0];
			frontLeftTire.material = tiresMaterial;
			frontLeftTire.ownSession = frontLeftWheelSession;
			frontLeftTire.screenZOffset = 10;
			frontLeftTire.centerPivot();
			
			var frontRightTire:Mesh = mustang.meshes[13];
			frontRightTire.material = tiresMaterial;
			frontRightTire.ownSession = frontRightWheelSession;
			frontRightTire.screenZOffset = 10;
			frontRightTire.centerPivot();
			
			var frontLeftBrake:Mesh = mustang.meshes[10];
			frontLeftBrake.material = brakesMaterial;
			frontLeftBrake.ownSession = frontLeftWheelSession;
			frontLeftBrake.screenZOffset = 10;
			frontLeftBrake.centerPivot();
			
			var frontRightBrake:Mesh = mustang.meshes[6];
			frontRightBrake.material = brakesMaterial;
			frontRightBrake.ownSession = frontRightWheelSession;
			frontRightBrake.screenZOffset = 10;
			frontRightBrake.centerPivot();
			
			var frontLeftHub:Mesh = mustang.meshes[9];
			frontLeftHub.material = hubMaterial;
			frontLeftHub.ownSession = frontLeftWheelSession;
			frontLeftHub.screenZOffset = 10;
			frontLeftHub.centerPivot();
			
			var frontRightHub:Mesh = mustang.meshes[7];
			frontRightHub.material = hubMaterial;
			frontRightHub.ownSession = frontRightWheelSession;
			frontRightHub.screenZOffset = 10;
			frontRightHub.centerPivot();
			
			var backLeftTire:Mesh = mustang.meshes[12];
			backLeftTire.material = tiresMaterial;
			backLeftTire.ownSession = backLeftWheelSession;
			backLeftTire.screenZOffset = 10;
			backLeftTire.centerPivot();
			
			var backRightTire:Mesh = mustang.meshes[1];
			backRightTire.material = tiresMaterial;
			backRightTire.ownSession = backRightWheelSession;
			backRightTire.screenZOffset = 10;
			backRightTire.centerPivot();
			
			var backLeftBrake:Mesh = mustang.meshes[2];
			backLeftBrake.material = brakesMaterial;
			backLeftBrake.ownSession = backLeftWheelSession;
			backLeftBrake.screenZOffset = 10;
			backLeftBrake.centerPivot();
			
			var backRightBrake:Mesh = mustang.meshes[5];
			backRightBrake.material = brakesMaterial;
			backRightBrake.ownSession = backRightWheelSession;
			backRightBrake.screenZOffset = 10;
			backRightBrake.centerPivot();
			
			var backLeftHub:Mesh = mustang.meshes[3];
			backLeftHub.material = hubMaterial;
			backLeftHub.ownSession = backLeftWheelSession;
			backLeftHub.screenZOffset = 10;
			backLeftHub.centerPivot();
			
			var backRightHub:Mesh = mustang.meshes[4];
			backRightHub.material = hubMaterial;
			backRightHub.ownSession = backRightWheelSession;
			backRightHub.screenZOffset = 10;
			backRightHub.centerPivot();
			
			shadow = mustang.meshes[8];
			shadow.material = shadowMaterial;
			shadow.ownCanvas = true;
			shadow.pushback = true;
			
			mustang.meshes[11].material = bodyMaterial;
			
			scene.addChild(mustang);
		}
		
		/**
		 * Initialise the lights
		 */
		private function initLights():void
		{
			light = new DirectionalLight3D({x:0, y:700, z:1000, color:0xFFFFFF, ambient:0.4, diffuse:0.7});
			light.debug = true;
			scene.addChild( light );
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			addEventListener( Event.ENTER_FRAME, onEnterFrame );
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			onResize(null);
		}
		
		/**
		 * Navigation and render loop
		 */
		private function onEnterFrame(event:Event):void
		{
			tick(getTimer());
			
			if (move) {
				camera.targetpanangle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle;
				camera.targettiltangle = 0.3*(stage.mouseY - lastMouseY) + lastTiltAngle;
			}
			
			camera.hover();  
			view.render();
		}
		
		/**
		 * Mouse down listener for navigation
		 */
		private function onMouseDown(event:MouseEvent):void
        {
            lastPanAngle = camera.targetpanangle;
            lastTiltAngle = camera.targettiltangle;
            lastMouseX = stage.mouseX;
            lastMouseY = stage.mouseY;
        	move = true;
        	stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
        }
		
		/**
		 * Mouse up listener for navigation
		 */
        private function onMouseUp(event:MouseEvent):void
        {
        	move = false;
        	stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);     
        }
        
		/**
		 * Mouse stage leave listener for navigation
		 */
        private function onStageMouseLeave(event:Event):void
        {
        	move = false;
        	stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);     
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
		
        private function tick(time:int):void
	    {
	    	light.x = 1000*Math.cos(time/2000);
	    	light.z = 1000*Math.sin(time/2000);
	    	shadow.x = -20*Math.cos(time/2000);
	    	shadow.z = -20*Math.sin(time/2000);
	    }
	}
}