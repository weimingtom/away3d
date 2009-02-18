package
{
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.clip.Clipping;
	import away3d.core.clip.FrustumClipping;
	import away3d.core.utils.*;
	import away3d.events.*;
	import away3d.loaders.*;
	import away3d.loaders.data.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="LOW", width="800", height="600")]
	 
	public class Advanced_SaltFlatsFerrari extends Sprite
	{
		//cracks texture for desert
		[Embed(source="assets/cracks.jpg")]
    	public var Cracks:Class;
    	
    	//horizon texture for gradient
    	[Embed(source="assets/cracksOverlay.png")]
    	public var CracksOverlay:Class;
    	
    	//skydome texture
    	[Embed(source="assets/morning_preview.jpg")]
    	public var Sky:Class;
		
		//ferrari texture
		[Embed(source="assets/fskingr.jpg")]
		private var GreenPaint:Class;
		
		//ferrari texture
		[Embed(source="assets/fskin.jpg")]
		private var RedPaint:Class;
				
		//ferrari texture
		[Embed(source="assets/fskiny.jpg")]
		private var YellowPaint:Class;
				
		//ferrari texture
		[Embed(source="assets/fsking.jpg")]
		private var GreyPaint:Class;
		
		//ferrari mesh
		[Embed(source="assets/f360.3ds", mimeType="application/octet-stream")]
		private var F360:Class;
		
    	//signature swf
    	[Embed(source="assets/signature.swf", symbol="Signature")]
    	public var SignatureSwf:Class;
    	
    	//engine variables
    	private var scene:Scene3D;
		private var camera:HoverCamera3D;
		private var clipping:Clipping;
		private var view:View3D;
		
		//signature variables
		private var Signature:Sprite;
		private var SignatureBitmap:Bitmap;
		
		//material objects
		private var carMaterial:BitmapMaterial;
		private var materialContainer:CompositeMaterial;
		private var floorMaterial:TransformBitmapMaterial;
		private var overlayMaterial:BitmapMaterial;
		private var skyMaterial:BitmapMaterial;
		private var materialArray:Array;
		private var materialIndex:int = 0;
		private var materialData:MaterialData;
		
		//scene objects
		private var model:ObjectContainer3D;
		private var floor:RegularPolygon;
		private var sky:Sphere;
		
		//navigation variables
		private var move:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		/**
		 * Constructor
		 */
		public function Advanced_SaltFlatsFerrari()
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
			camera = new HoverCamera3D({zoom:10, focus:50, x:0, y:2000, z:2000, lookat:"center"});
			camera.distance = 800;
			camera.maxtiltangle = 20;
			camera.mintiltangle = 0;
			camera.targetpanangle = camera.panangle = -140;
			camera.targettiltangle = camera.tiltangle = 4;
			clipping = new FrustumClipping();
			view = new View3D({scene:scene, camera:camera, clipping:clipping});
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
			carMaterial = new BitmapMaterial(Cast.bitmap(GreenPaint));
			floorMaterial = new TransformBitmapMaterial(Cast.bitmap(Cracks), {scaleX:0.05, scaleY:0.05, repeat:true});
			overlayMaterial = new BitmapMaterial(Cast.bitmap(CracksOverlay));
			materialContainer = new CompositeMaterial({materials:[floorMaterial, overlayMaterial]});
			
			//create mirrored sky bitmap for sphere texture
			var sky:BitmapData = Cast.bitmap(Sky);
			var skyMirror:BitmapData = new BitmapData(sky.width*2, sky.height*4 - 40, true, 0);
			stage.quality = StageQuality.HIGH;
			skyMirror.draw(sky, new Matrix(2, 0, 0, 2), null, null, new Rectangle(0, 0, sky.width*2, sky.height*2-20), true);
			stage.quality = StageQuality.LOW;
			skyMirror.draw(skyMirror.clone(), new Matrix(1, 0, 0, -1, 0, sky.height*4-40));
			skyMaterial = new BitmapMaterial(Cast.bitmap(skyMirror));
			
			materialArray = [GreenPaint, RedPaint, YellowPaint, GreyPaint];
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			//create ferrari model
			model = (Max3DS.parse(F360, {material:carMaterial, ownCanvas:true, centerMeshes:true, pushfront:true}) as ObjectContainer3D);
			materialData = model.materialLibrary.getMaterial("fskin");
			materialData.material = Cast.material(materialArray[materialIndex]);
			model.blendMode = BlendMode.HARDLIGHT;
			model.scale(100);
			model.rotationX = 90;
			model.y = -200;
			model.addOnMouseUp(onClickModel);
			scene.addChild(model);
			
			//create floor object
			floor = new RegularPolygon({material:materialContainer, ownCanvas:true, radius:5000, sides:20, subdivision:1, y:-200});
			floor.blendMode = BlendMode.MULTIPLY;
			scene.addChild( floor );
			
			//create sky object
			sky = new Sphere({material:skyMaterial, radius:5000, segmentsW:20, segmentsH:12, pushback:true});
			sky.scale(-1);
			sky.y = -200;
			sky.rotationX = 180;
			scene.addChild( sky );
		}
		
		/**
		 * Lsitener function for mouse click on car
		 */
		private function onClickModel(event:MouseEvent3D):void
		{
			materialIndex++;
			if (materialIndex > materialArray.length - 1)
				materialIndex = 0;
			materialData.material = Cast.material(materialArray[materialIndex]);
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
			
			if (model) {
				for each (var object:Object3D in model.children) {
					if (object.maxY - object.minY < 1)
						object.rotationX += 40;
				}
			}
			
			if (floorMaterial.offsetY < 0)
            	floorMaterial.offsetY += 512;
            
            floorMaterial.offsetY -= 4;
            
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
	}
}