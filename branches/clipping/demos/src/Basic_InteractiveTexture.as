package
{
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.utils.*;
	import away3d.events.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.Keyboard;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="HIGH", width="800", height="600")]
	
	public class Basic_InteractiveTexture extends Sprite
	{
		[Embed(source="assets/interactiveTexture.swf", mimeType="application/octet-stream")]
		private var InteractiveTexture:Class;
    	
		//signature swf
    	[Embed(source="assets/signature.swf", symbol="Signature")]
    	private var SignatureSwf:Class;
    	
		//loader for form swf
		private var loader:Loader;
		
    	//engine variables
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;
		
		//signature variables
		private var Signature:Sprite;
		
		//variables for form instance
		private var SymbolClass:Class;
		private var SymbolInstance:Sprite;
		
		//material objects
		private var material:MovieMaterial;
		
		//scene objects
		private var plane:Plane;
		
		//navigation variables
		private var rotateSpeed:Number = 1;
		private var moveSpeed:Number = 8;
		private var upFlag:Boolean = false;
		private var downFlag:Boolean = false;
		private var leftFlag:Boolean = false;
		private var rightFlag:Boolean = false;
		
		/**
		 * Constructor
		 */
		public function Basic_InteractiveTexture()
		{
			stage.quality = StageQuality.HIGH;
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, init);
			loader.loadBytes(new InteractiveTexture());
		}
		
		/**
		 * Global initialise function
		 */
		private function init(e:Event):void
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
			camera = new Camera3D({zoom:10, focus:100, x:0, y:0, z:-1000});
			
			SymbolClass = loader.contentLoaderInfo.applicationDomain.getDefinition("formUI") as Class;
			SymbolInstance = new SymbolClass() as Sprite;
			
			view = new View3D({scene:scene, camera:camera});
			view.x = 400;
			view.y = 300;
			addChild( view );
			
						
			//add signature
            Signature = Sprite(new SignatureSwf());
            addChild(Signature);
		}
		
		/**
		 * Initialise the materials
		 */
		private function initMaterials():void
		{
			material = new MovieMaterial(SymbolInstance, {interactive:true, smooth:true});
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			plane = new Plane({material:material, width:500, height:500, segmentsW:4, segmentsH:4, yUp:false});
			plane.bothsides = true;
			plane.pitch(-20);
			plane.yaw(20);
			plane.roll(10);
		 	scene.addChild(plane);
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			addEventListener( Event.ENTER_FRAME, onEnterFrame );
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			onResize(null);
		}
		
		/**
		 * Navigation and render loop
		 */
		private function onEnterFrame(event:Event):void
		{
			if (upFlag)
				plane.pitch(rotateSpeed);
			if (downFlag)
				plane.pitch(-rotateSpeed);
			if (leftFlag)
				plane.yaw(rotateSpeed);
			if (rightFlag)
				plane.yaw(-rotateSpeed);
			view.render();
		}
		
		/**
		 * Key down listener for navigation
		 */
		public function keyDownHandler(e:KeyboardEvent):void {
			switch(e.keyCode)
			{
				case Keyboard.UP:
					upFlag = true;
					break;
				case Keyboard.DOWN:
					downFlag = true;
					break;
				case Keyboard.LEFT:
					leftFlag = true;
					break;
				case Keyboard.RIGHT: 
					rightFlag = true;
					break;
				default:
			}
		}
		
		/**
		 * Key up listener for navigation
		 */
		private function keyUpHandler(e:KeyboardEvent):void {
			switch(e.keyCode)
			{
				case Keyboard.UP:
					upFlag = false;
					break;
				case Keyboard.DOWN:
					downFlag = false;
					break;
				case Keyboard.LEFT:
					leftFlag = false;
					break;
				case Keyboard.RIGHT: 
					rightFlag = false;
					break;
				default:
			}
		}
        
        /**
		 * Stage listener for resize events
		 */
		private function onResize(event:Event):void
		{
			view.x = stage.stageWidth / 2;
            view.y = stage.stageHeight / 2;
            Signature.y = stage.stageHeight - Signature.height;
		}
	}
}