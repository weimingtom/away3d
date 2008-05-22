package 
{
	import flash.display.*;
	import flash.events.*;
	
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.math.*;
	import away3d.core.render.Renderer;
	import away3d.core.utils.Cast;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="LOW", width="800", height="600")]
	
	public class Intermediate_ZSortCorrection extends Sprite
	{
		//brick texture for floor
		[Embed(source="assets/brick.jpg")]
		private var Brick1:Class;
		
		//brick texture for spheres
		[Embed(source="assets/brick2.jpg")]
		private var Brick2:Class;
    	
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
		private var planeMaterial:BitmapMaterial;
		private var sphereMaterial:BitmapMaterial;
		
		//scene objects
		private var plane:Plane;
		private var container:ObjectContainer3D;
		private var sphere1:Sphere;
		private var sphere2:Sphere;
		
		/**
		 * Constructor
		 */
		public function Intermediate_ZSortCorrection() 
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
			camera = new Camera3D({zoom:10, focus:50, x:0, y:-500, z:-250});
			
			view = new View3D({scene:scene, camera:camera, renderer:Renderer.INTERSECTING_OBJECTS});
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
			planeMaterial = new BitmapMaterial( Cast.bitmap(Brick1) );
			sphereMaterial = new BitmapMaterial( Cast.bitmap(Brick2) );
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			plane = new Plane({material:planeMaterial, width:500, height:500, segmentsW:4, segmentsH:4, yUp:false});
			sphere1 = new Sphere({material:sphereMaterial, radius:50, x:100, y:100});
			sphere2 = new Sphere({material:sphereMaterial, radius:50, x:-100, y:-100});
			container = new ObjectContainer3D({z:-100}, sphere1, sphere2);
			scene.addChild( plane );
			scene.addChild( container );
			camera.lookAt(plane.position);
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
			plane.rotationZ += 2;
			container.rotationX += 2;
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