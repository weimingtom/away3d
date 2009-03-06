package
{
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.clip.*;
	import away3d.core.render.*;
	import away3d.core.utils.Cast;
	import away3d.loaders.*;
	import away3d.materials.*;
	import away3d.primitives.Skybox6;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="LOW", width="800", height="600")]
	
	public class Intermediate_Skybox extends Sprite
	{
		//skybox image 1
		[Embed(source="assets/peterskybox1.jpg")]
    	public var SkyImage1:Class;
    	
    	//skybox image 2
		[Embed(source="assets/peterskybox2.jpg")]
    	public var SkyImage2:Class;
    	
    	//skybox image 3
    	[Embed(source="assets/peterskybox3.jpg")]
    	public var SkyImage3:Class;
    	
		//signature swf
    	[Embed(source="assets/signature.swf", symbol="Signature")]
    	private var SignatureSwf:Class;
    	
    	//engine variables
    	private var scene:Scene3D;
		private var camera:HoverCamera3D;
		private var view:View3D;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		//material objects
		private var material:BitmapMaterial;
		
		//scene objects
		private var skybox:Skybox6;
		
		//navigation variables
		private var move:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		/**
		 * Constructor
		 */
		public function Intermediate_Skybox()
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
			initListeners();
		}
		
		/**
		 * Initialise the engine
		 */
		private function initEngine():void
		{
			scene = new Scene3D();
			camera = new HoverCamera3D({zoom:10, focus:50});
			camera.mintiltangle = -80;
			camera.maxtiltangle = 20;
			camera.targetpanangle = camera.panangle = 0;
			camera.targettiltangle = camera.tiltangle = 0;
			view = new View3D({scene:scene, camera:camera});
			//view.clipping = RectangleClipping({minX:-320, minY:-240, maxX:320, maxY:240});
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
			material = new BitmapMaterial( Cast.bitmap(SkyImage2) );
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			skybox = new Skybox6( material );
			skybox.quarterFaces();
			scene.addChild( skybox );
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
		 * Stage listener for resize events
		 */
		private function onResize(event:Event):void
		{
			view.x = stage.stageWidth / 2;
            view.y = stage.stageHeight / 2;
            SignatureBitmap.y = stage.stageHeight - Signature.height;
		}
	}
}