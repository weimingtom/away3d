package
{
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.utils.Cast;
	import away3d.events.*;
	import away3d.lights.*;
	import away3d.loaders.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	import away3d.test.Button;
	
	import flash.display.*;
	import flash.events.*;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="LOW", width="800", height="600")]
	
	public class Advanced_ShadingMaterials extends Sprite
	{
		//Marble texture for torso
		[Embed(source="assets/torso_marble2.jpg")]
    	public static var TorsoImage:Class;
    	
    	//normal map for torso
    	[Embed(source="assets/torso_normal_400.jpg")]
    	public static var TorsoNormal:Class;
    	
    	//marble texture for pedestal
    	[Embed(source="assets/pedestal_marble2.jpg")]
    	public static var PedestalImage:Class;
    	
    	//cubic panorama textures
    	[Embed(source="assets/small_f_003.jpg")]
    	public static var PanoramaImageF:Class;
    	[Embed(source="assets/small_b_003.jpg")]
    	public static var PanoramaImageB:Class;
    	[Embed(source="assets/small_u_003.jpg")]
    	public static var PanoramaImageU:Class;
    	[Embed(source="assets/small_d_003.jpg")]
    	public static var PanoramaImageD:Class;
    	[Embed(source="assets/small_l_003.jpg")]
    	public static var PanoramaImageL:Class;
    	[Embed(source="assets/small_r_003.jpg")]
    	public static var PanoramaImageR:Class;
    	
    	//Torso mesh
    	[Embed(source="assets/torsov2.MD2",mimeType="application/octet-stream")]
    	public static var TorsoMD2:Class;
    	
    	//Pedestal mesh
    	[Embed(source="assets/pedestal2.MD2",mimeType="application/octet-stream")]
    	public static var PedestalMD2:Class;
    	
    	//signature swf
    	[Embed(source="assets/signature.swf", symbol="Signature")]
    	public static var SignatureSwf:Class;
		
		//engine variables
    	private var scene:Scene3D;
		private var camera:HoverCamera3D;
		private var view:View3D;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		//cubic panorama materials
		private var panoramaMaterialF:BitmapMaterial;
		private var panoramaMaterialL:BitmapMaterial;
		private var panoramaMaterialB:BitmapMaterial;
		private var panoramaMaterialR:BitmapMaterial;
		private var panoramaMaterialU:BitmapMaterial;
		private var panoramaMaterialD:BitmapMaterial;
		
		//pedestal materials
		private var pedestalMaterial:WhiteShadingBitmapMaterial;
		
		//torso materials
		private var torsoNormalMaterial:Dot3BitmapMaterialF10;
		private var torsoEnviroMaterial:EnviroBitmapMaterial;
		private var torsoPhongMaterial:PhongBitmapMaterial;
		private var torsoFlatMaterial:WhiteShadingBitmapMaterial;
		
		//light object
		private var light:DirectionalLight3D;
		
		//scene objects
		private var torso:Mesh;
		private var pedestal:Mesh;
		private var panorama:Skybox;
		
		//button objects
		private var buttonGroup:Sprite;
		private var normalButton:Button;
		private var enviroButton:Button;
		private var phongButton:Button;
		private var flatButton:Button;
		
		//navigation variables
		private var move:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		/**
		 * Constructor
		 */
		public function Advanced_ShadingMaterials()
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
			initLights();
			initObjects();
			initButtons();
			initListeners();
		}
		
		/**
		 * Initialise the engine
		 */
		private function initEngine():void
		{
			scene = new Scene3D();
			camera = new HoverCamera3D({zoom:3, focus:200, distance:40000});
			camera.targetpanangle = camera.panangle = 100;
			camera.targettiltangle = camera.tiltangle = 20;
			camera.mintiltangle = -90;
			camera.yfactor = 1;
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
			panoramaMaterialF = new BitmapMaterial(Cast.bitmap(PanoramaImageF));
			panoramaMaterialL = new BitmapMaterial(Cast.bitmap(PanoramaImageL));
			panoramaMaterialB = new BitmapMaterial(Cast.bitmap(PanoramaImageB));
			panoramaMaterialR = new BitmapMaterial(Cast.bitmap(PanoramaImageR));
			panoramaMaterialU = new BitmapMaterial(Cast.bitmap(PanoramaImageU));
			panoramaMaterialD = new BitmapMaterial(Cast.bitmap(PanoramaImageD));
			
			pedestalMaterial = new WhiteShadingBitmapMaterial(Cast.bitmap(PedestalImage));
			
			torsoNormalMaterial = new Dot3BitmapMaterialF10(Cast.bitmap(TorsoImage), Cast.bitmap(TorsoNormal));
			torsoEnviroMaterial = new EnviroBitmapMaterial(Cast.bitmap(TorsoImage), Cast.bitmap(PanoramaImageR), {reflectiveness:0.2});
			torsoPhongMaterial = new PhongBitmapMaterial(Cast.bitmap(TorsoImage), {specular:0.5});
			torsoFlatMaterial = new WhiteShadingBitmapMaterial(Cast.bitmap(TorsoImage));
		}
		
		/**
		 * Initialise the lights
		 */
		private function initLights():void
		{
			
			light = new DirectionalLight3D({color:0xFFFFFF, ambient:0.25, diffuse:0.75, specular:0.9});
			light.x = 40000;
            light.z = 40000;
            light.y = 40000;
			scene.addChild( light );
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
            
            torso = Md2still.parse(TorsoMD2, {ownCanvas:true, material:torsoNormalMaterial, name:"torso", back:panoramaMaterialF});
            torso.movePivot((torso.minX+torso.maxX)/2,(torso.minY+torso.maxY)/2,(torso.minZ+torso.maxZ)/2);
            torso.x = torso.z = 0;
            torso.scale(5);
            torso.y = 4000;
            scene.addChild( torso );
			
			pedestal = Md2still.parse(PedestalMD2, {ownCanvas:true, material:pedestalMaterial});
			pedestal.rotationZ = 180;
            pedestal.movePivot((pedestal.minX+pedestal.maxX)/2,(pedestal.minY+pedestal.maxY)/2,(pedestal.minZ+pedestal.maxZ)/2);
            pedestal.x = pedestal.z = 0;
            pedestal.scale(10);
            pedestal.rotationX = 180;
            pedestal.y = -30000;
			scene.addChild( pedestal );
			
			panorama = new Skybox(panoramaMaterialF, panoramaMaterialL, panoramaMaterialB, panoramaMaterialR, panoramaMaterialU, panoramaMaterialD);
			panorama.scale(0.15);
			panorama.quarterFaces();
			scene.addChild( panorama );
		}
		
		/**
		 * Initialise the buttons
		 */
		private function initButtons():void
		{
			buttonGroup = new Sprite();
			addChild(buttonGroup);
			normalButton = new Button("Normal Map", 90);
            normalButton.x = 0;
            normalButton.y = 0;
            buttonGroup.addChild(normalButton);
            enviroButton = new Button("Environment Map", 125);
            enviroButton.x = 110;
            enviroButton.y = 0;
            buttonGroup.addChild(enviroButton);
            phongButton = new Button("Phong Shading", 115);
            phongButton.x = 255;
            phongButton.y = 0;
            buttonGroup.addChild(phongButton);
            flatButton = new Button("Flat Shading", 95);
            flatButton.x = 390;
            flatButton.y = 0;
            buttonGroup.addChild(flatButton);
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			addEventListener( Event.ENTER_FRAME, onEnterFrame );
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			normalButton.addEventListener(MouseEvent.CLICK, onNormalClick);
			enviroButton.addEventListener(MouseEvent.CLICK, onEnviroClick);
			phongButton.addEventListener(MouseEvent.CLICK, onPhongClick);
			flatButton.addEventListener(MouseEvent.CLICK, onFlatClick);
            onResize(null);
		}
		
		/**
		 * Navigation and render loop
		 */
		private function onEnterFrame(event:Event):void
		{
			if (move) {
				camera.targetpanangle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle;
				camera.targettiltangle = 0.3*(stage.mouseY - lastMouseY) + lastTiltAngle;
			}
			
			torso.rotationY += 3;
			
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
		 * button listener for viewing normal map
		 */
		private function onNormalClick(event:MouseEvent):void
		{
			torso.material = torsoNormalMaterial;
		}
		
		/**
		 * button listener for viewing environment map
		 */
		private function onEnviroClick(event:MouseEvent):void
		{
			torso.material = torsoEnviroMaterial;
		}
		
		/**
		 * button listener for viewing phong shading
		 */
		private function onPhongClick(event:MouseEvent):void
		{
			torso.material = torsoPhongMaterial;
		}
		
		/**
		 * button listener for viewing flat shading
		 */
		private function onFlatClick(event:MouseEvent):void
		{
			torso.material = torsoFlatMaterial;
		}
		
		/**
		 * stage listener for resize events
		 */
		private function onResize(event:Event):void
		{
			view.x = stage.stageWidth / 2;
            view.y = stage.stageHeight / 2;
            SignatureBitmap.y = stage.stageHeight - Signature.height;
            buttonGroup.x = stage.stageWidth - 600;
            buttonGroup.y = stage.stageHeight - 40;
		}
	}
}