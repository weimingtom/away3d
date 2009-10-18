package away3dlite.templates
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
	
	public class SkyTemplate extends Sprite
	{
    	//engine variables
    	private var scene:Scene3D;
		private var camera:HoverCamera3D;
		private var clipping:RectangleClipping;
		private var view:View3D;
		
		//material objects
		protected var material:Material;
		
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
		public function SkyTemplate()
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
			
			camera = new HoverCamera3D();
			camera.focus = 50;
			camera.mintiltangle = -90;
			camera.maxtiltangle = 90;
			camera.targetpanangle = camera.panangle = 0;
			camera.targettiltangle = camera.tiltangle = 0;
			
			clipping = new RectangleClipping();
			clipping.minX = -320;
			clipping.minY = -240;
			clipping.maxX = 320;
			clipping.maxY = 240;
			
			view = new View3D();
			view.scene = scene;
			view.camera = camera;
			view.clipping = clipping;
			
			addChild(view);
			
			addChild(new Stats);
		}
		
		/**
		 * Initialise the materials
		 */
		protected function initMaterials():void
		{
			//material = new BitmapMaterial(Cast.bitmap(SkyImage2));
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
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
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
		private function onResize(event:Event = null):void
		{
			view.x = stage.stageWidth / 2;
            view.y = stage.stageHeight / 2;
		}
	}
}