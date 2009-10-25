package
{
	import away3dlite.cameras.*;
	import away3dlite.containers.*;
	import away3dlite.core.clip.*;
	import away3dlite.core.utils.*;
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	
	import flash.display.*;
	import flash.events.*;
	
	import net.hires.debug.Stats;
	
	[SWF(backgroundColor="#000000", frameRate="60", quality="MEDIUM", width="800", height="600")]
	
	public class ExClipping extends Sprite
	{
    	//engine variables
    	private var scene:Scene3D;
		private var camera:HoverCamera3D;
		private var clipping:RectangleClipping;
		private var view:View3D;
		
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
		public function ExClipping()
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		/**
		 * Global initialise function
		 */
		private function init(e:*):void
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
			stage.scaleMode = StageScaleMode.NO_SCALE;
				
			scene = new Scene3D();
			
			camera = new HoverCamera3D();
			camera.focus = 50;
			camera.minTiltAngle = -90;
			camera.maxTiltAngle = 90;
			camera.panAngle = 0;
			camera.tiltAngle = 0;
			camera.hover(true);
			
			clipping = new RectangleClipping();
			clipping.minX = -300;
			clipping.minY = -200;
			clipping.maxX = 300;
			clipping.maxY = 200;
			
			view = new View3D();
			view.scene = scene;
			view.camera = camera;
			view.clipping = clipping;
						
			//view.addSourceURL("srcview/index.html");
			addChild(view);
			
			view.setSize(800, 600);
			
			var debugRect:Sprite = new Sprite();
			debugRect.graphics.lineStyle(1, 0xFF0000);
			debugRect.graphics.drawRect(clipping.minX, clipping.minY, Math.abs(clipping.minX) + clipping.maxX, Math.abs(clipping.minY) + clipping.maxY);
			debugRect.graphics.endFill();
			
			debugRect.x = stage.stageWidth/2;
			debugRect.y = stage.stageHeight/2;
			addChild(debugRect);
			
            addChild(new Stats);
		}
		
		/**
		 * Initialise the materials
		 */
		private function initMaterials():void
		{
			material = new BitmapFileMaterial("assets/peterskybox2.jpg");
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			skybox = new Skybox6();
			skybox.material = material;
			scene.addChild(skybox);
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		/**
		 * Navigation and render loop
		 */
		private function onEnterFrame(event:Event):void
		{
			if (move) {
				camera.panAngle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle;
				camera.tiltAngle = 0.3*(stage.mouseY - lastMouseY) + lastTiltAngle;
			}
			
			camera.hover();
			view.render();
		}
		
		/**
		 * Mouse down listener for navigation
		 */
		private function onMouseDown(event:MouseEvent):void
        {
            lastPanAngle = camera.panAngle;
            lastTiltAngle = camera.tiltAngle;
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
	}
}