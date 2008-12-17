package 
{
	import flash.display.*;
	import flash.events.*;
	
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="LOW", width="800", height="600")]
	
	public class Basic_SceneSetup extends Sprite
	{
    	//signature swf
    	[Embed(source="assets/signature.swf", symbol="Signature")]
    	public static var SignatureSwf:Class;
    	
		//engine variables
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		//material objects
		private var material:ColorMaterial;
		
		//scene objects
		private var plane:Plane;
		
		/**
		 * Constructor
		 */
		public function Basic_SceneSetup() 
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
			material = new ColorMaterial( 0xcc0000 );
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			plane = new Plane({material:material, width:500, height:500, yUp:false});
			plane.bothsides = true;
			scene.addChild( plane );
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			addEventListener( Event.ENTER_FRAME, onEnterFrame );
			onResize(null);
		}
		
		/**
		 * Render loop
		 */
		private function onEnterFrame( e:Event ):void
		{
			plane.rotationY += 2;
			view.render();
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