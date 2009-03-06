package
{
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.math.Number3D;
	import away3d.core.clip.RectangleClipping;
	import away3d.core.utils.*;
	import away3d.lights.AmbientLight3D;
	import away3d.lights.DirectionalLight3D;
	import away3d.loaders.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.ColorMatrixFilter;
	import flash.utils.getTimer;
	
	[SWF(backgroundColor="#B2DBE6", frameRate="30", quality="LOW", width="800", height="600")]
	 
	public class Intermediate_LightmapProjection extends Sprite
	{
		//tile texture for pool sides
		[Embed(source="assets/bathroomtilegray3.jpg")]
    	public static var PoolTile:Class;
    	
    	//caustics animation for projected texture
    	[Embed(source="assets/caustics.swf", symbol="caustics")]
    	public var Caustics:Class;
    	
    	//Lifering texture
    	[Embed(source="assets/caustics.swf", symbol="lifering")]
    	public var LifeRing:Class;
    	
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
		
		//material objects
		private var poolTileMaterial:TransformBitmapMaterial;
		private var poolWaterMaterial:AnimatedBitmapMaterial;
		private var poolMaterial:CompositeMaterial;
		private var lifeRingMaterial:TransformBitmapMaterial;
		private var ringMaterial:CompositeMaterial;
		
		//movieclips for animated caustics material
		private var poolCaustics:MovieClip;
		private var poolContainer:MovieClip;
		
		//projection vector value
		private var projectionVector:Number3D = new Number3D(0.5, -1, 0.5);
		
		//scene objects
		private var pool:Cube;
		private var ring:Torus;
		
		//navigation variables
		private var move:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		/**
		 * Constructor
		 */
		public function Intermediate_LightmapProjection()
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
			camera = new HoverCamera3D({zoom:10, focus:50, lookat:"center"});
			camera.distance = 30000;
			camera.yfactor = 1;
			camera.maxtiltangle = 90;
			camera.mintiltangle = 10;
			camera.targetpanangle = camera.panangle = 0;
			camera.targettiltangle = camera.tiltangle = 10;
			view = new View3D({scene:scene, camera:camera, clipping:new RectangleClipping({minX:-400, minY:-300, maxX:400, maxY:300})});
			view.x = 400;
			view.y = 300;
			view.addSourceURL("srcview/index.html");
			addChild(view);
			
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
			//create transformed tile material for pool sides
			poolTileMaterial = new TransformBitmapMaterial(Cast.bitmap(PoolTile), {offsetX:-1.2, offsetY:-0.6, scaleX:0.2, scaleY:0.2, repeat:true});
			
			//create water material with filter applied
			poolCaustics = new Caustics() as MovieClip;
			poolCaustics.filters = [new ColorMatrixFilter([1, 0, 0, 0, 0, 0, 1, 0, 0, 127, 0, 0, 1, 0, 200, 0.25, 0, 0, 0, 64])];
			poolContainer = new MovieClip();
			poolContainer.addChild(poolCaustics);
			poolWaterMaterial = new AnimatedBitmapMaterial(poolContainer, {projectionVector:projectionVector, throughProjection:true, globalProjection:true, repeat:true, scaleX:50, scaleY:50});
			
			//add frames manually to animated bitmapmaterial
			var i:int = poolCaustics.totalFrames;
			var frames:Array = new Array();
			var bitmapData:BitmapData;
			while(i--) {
				bitmapData = new BitmapData(256, 256, true, 0);
				poolCaustics.gotoAndStop(i+1);
				bitmapData.draw(poolContainer);
				frames.unshift(bitmapData);
			}
			poolWaterMaterial.setFrames(frames);
			
			//poolTileMaterial.debug = true;
			poolTileMaterial.precision = 1;
			
			//create composite material for pool
			poolMaterial = new CompositeMaterial({materials:[poolTileMaterial, poolWaterMaterial]});
			
			//create transformed lifering material 
			lifeRingMaterial = new TransformBitmapMaterial(Cast.bitmap(LifeRing), {projectionVector:new Number3D(0, 1, 0), scaleX:100, scaleY:100, offsetX:-12800, offsetY:-12800, throughProjection:true});
			
			//create composite material for lifering
			ringMaterial = new CompositeMaterial({materials:[lifeRingMaterial, poolWaterMaterial]});
        }
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			//create pool sides
			pool = new Cube({material:poolMaterial, width:50000, height:50000, depth:50000});
			pool.y = 10000;
			pool.quarterFaces();
			pool.quarterFaces();
			pool.scale(-1);
			scene.addChild(pool);
			
			//create lifering
			ring = new Torus({ownCanvas:true, material:ringMaterial, radius:6000, tube:2500, segmentsR:20, segmentsT:10});
			scene.addChild(ring);
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
            
            ring.rotationX += 3;
            ring.rotationY += 3;
            
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