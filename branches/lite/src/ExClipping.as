package
{
	import away3dlite.cameras.*;
	import away3dlite.containers.*;
	import away3dlite.core.clip.*;
	import away3dlite.core.utils.*;
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	import away3dlite.templates.BasicTemplate;
	
	import flash.display.*;
	import flash.events.*;
	
	[SWF(backgroundColor="#000000", frameRate="30", width="800", height="600")]
	public class ExClipping extends BasicTemplate
	{
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
		
		override protected function setupStage():void
		{
			super.setupStage();
		}
		
		override protected function onInit():void
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
			var _camera:HoverCamera3D = new HoverCamera3D();
			_camera.focus = 50;
			_camera.minTiltAngle = -90;
			_camera.maxTiltAngle = 90;
			_camera.panAngle = 0;
			_camera.tiltAngle = 0;
			_camera.hover(true);
			
			view.camera = camera = _camera;
			
			clipping = new RectangleClipping();
			clipping.minX = -300;
			clipping.minY = -200;
			clipping.maxX = 300;
			clipping.maxY = 200;
			
			view.clipping = clipping;
			
			var debugRect:Sprite = new Sprite();
			debugRect.graphics.lineStyle(1, 0xFF0000);
			debugRect.graphics.drawRect(clipping.minX, clipping.minY, Math.abs(clipping.minX) + clipping.maxX, Math.abs(clipping.minY) + clipping.maxY);
			debugRect.graphics.endFill();
			
			debugRect.x = _screenRect.width/2;
			debugRect.y = _screenRect.height/2;
			addChild(debugRect);
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
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		/**
		 * Navigation and render loop
		 */
		override protected function onPreRender():void
		{
			if (move) {
				HoverCamera3D(view.camera).panAngle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle;
				HoverCamera3D(view.camera).tiltAngle = 0.3*(stage.mouseY - lastMouseY) + lastTiltAngle;
			}
			
			HoverCamera3D(view.camera).hover();
		}
		
		/**
		 * Mouse down listener for navigation
		 */
		private function onMouseDown(event:MouseEvent):void
        {
            lastPanAngle = HoverCamera3D(view.camera).panAngle;
            lastTiltAngle = HoverCamera3D(view.camera).tiltAngle;
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