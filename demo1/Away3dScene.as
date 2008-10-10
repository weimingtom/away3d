package
{
	import away3d.cameras.Camera3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.base.Shape3D;
	import away3d.core.math.Number3D;
	import away3d.materials.WireColorMaterial;
	import away3d.primitives.Plane;
	import away3d.primitives.Sprite3D;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class Away3dScene extends Sprite
	{
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;
		private var origin:Number3D = new Number3D(0, 0, 0);
		
		public function Away3dScene()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(evt:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			initScene();
			initObjects();
			
			this.addEventListener(Event.ENTER_FRAME, animate);
		}
		
		private function initScene():void
		{
			scene = new Scene3D({name:"scene"});
			
			camera = new Camera3D({z:-1000, name:"camera"});
			
			view = new View3D({scene:scene, camera:camera});
			view.x = stage.stageWidth/2;
			view.y = stage.stageHeight/2;
			addChild(view);
		}
		
		private function initObjects():void
		{
			var plane:Plane = new Plane({name:"plane"});
			plane.z = 150;
			plane.width = plane.height = 300;
			plane.rotationX = 90;
			scene.addChild(plane); 
			
			var shp:Shape3D = new Shape3D();
			
			//A.
			shp.graphicsMoveTo(26.7,23.8);
			shp.graphicsLineTo(-0.7,95.2);
			shp.graphicsLineTo(12.2,95.2);
			shp.graphicsLineTo(18.95,76.3);
			shp.graphicsLineTo(47.4,76.3);
			shp.graphicsLineTo(54.1,95.2);
			shp.graphicsLineTo(67.55,95.2);
			shp.graphicsLineTo(40.05,23.8);
			shp.graphicsLineTo(26.7,23.8);
			shp.graphicsMoveTo(33.45,36.1);
			shp.graphicsLineTo(44.15,66.8);
			shp.graphicsLineTo(22.3,66.8);
			shp.graphicsLineTo(33.1,36.1);
			shp.graphicsLineTo(33.45,36.1);
			
			//"P".
			/* shp.graphicsMoveTo(51.45,26);
			shp.graphicsCurveTo(46.7,23.85,39.1,23.8);
			shp.graphicsLineTo(7.6,23.8);
			shp.graphicsLineTo(7.6,95.2);
			shp.graphicsLineTo(20.1,95.2);
			shp.graphicsLineTo(20.1,67.9);
			shp.graphicsLineTo(39.1,67.9);
			shp.graphicsCurveTo(46.7,67.85,51.45,65.75);
			shp.graphicsCurveTo(56.3,63.65,58.9,60.3);
			shp.graphicsCurveTo(61.45,56.9,62.45,53.1);
			shp.graphicsCurveTo(63.45,49.35,63.4,46);
			shp.graphicsCurveTo(63.45,42.55,62.45,38.75);
			shp.graphicsCurveTo(61.45,34.9,58.9,31.55);
			shp.graphicsCurveTo(56.3,28.15,51.45,26);
			shp.graphicsMoveTo(50.9,45.85);
			shp.graphicsCurveTo(50.85,50.35,48.9,52.95);
			shp.graphicsCurveTo(46.95,55.55,44.15,56.65);
			shp.graphicsCurveTo(41.25,57.75,38.4,57.7);
			shp.graphicsLineTo(20.1,57.7);
			shp.graphicsLineTo(20.1,34);
			shp.graphicsLineTo(38.55,34);
			shp.graphicsCurveTo(41.95,33.95,44.75,35);
			shp.graphicsCurveTo(47.5,36,49.15,38.6);
			shp.graphicsCurveTo(50.85,41.2,50.9,45.85); */
			
			var spr:Sprite3D = new Sprite3D();
			spr.z = -150;
			spr.addChild(shp);
			scene.addChild(spr);
		}
		
		private function animate(evt:Event):void
		{
			camera.x = 3*(mouseX - stage.stageWidth/2);
			camera.y = 3*(mouseY - stage.stageHeight/2);
			camera.lookAt(origin);
			
			view.render();
		}
	}
}