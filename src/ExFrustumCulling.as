package
{
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	import away3dlite.templates.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;

	[SWF(backgroundColor="#000000",frameRate="30",quality="MEDIUM",width="800",height="600")]
	/**
	 * FrustumCulling Example
	 * @author katopz
	 */
	public class ExFrustumCulling extends BasicTemplate
	{
		private var spheres:Array = [];
		private var step:Number=0;
		private var max:int = 4;
		override protected function onInit():void
		{
			renderer.cullObjects = true;
			
			// center
			scene.addChild(new Sphere(null, 100, 6, 6));

			var colors:Array = [0xFFFFFF, 0xFF0000, 0x00FF00, 0x0000FF];
			
			// orbit
			var i:Number = 0;
			for (var j:int = 0; j < max; j++)
			{
				var sphere:Sphere = new Sphere(new WireColorMaterial(colors[j%4]), 50, 6, 6);
				scene.addChild(sphere);
				sphere.x = 600 * Math.cos(i);
				sphere.z = 600 * Math.sin(i);
				i += 2 * Math.PI / max;
				spheres.push(sphere);
			}
			
			// debug axis cube
			var length:int = 900;
			var oCube:Cube6 = new Cube6(new ColorMaterial(0xFFFFFF), 10, 10, 10);
			scene.addChild(oCube);

			var xCube:Cube6 = new Cube6(new ColorMaterial(0xFF0000), 10, 10, 10);
			xCube.x = length;
			scene.addChild(xCube);

			var yCube:Cube6 = new Cube6(new ColorMaterial(0x00FF00), 10, 10, 10);
			yCube.y = length;
			scene.addChild(yCube);

			var zCube:Cube6 = new Cube6(new ColorMaterial(0x0000FF), 10, 10, 10);
			zCube.z = length;
			scene.addChild(zCube);
			
			//
			
			var _xCube:Cube6 = new Cube6(new ColorMaterial(0x660000), 10, 10, 10);
			_xCube.x = -length;
			scene.addChild(_xCube);

			var _yCube:Cube6 = new Cube6(new ColorMaterial(0x006600), 10, 10, 10);
			_yCube.y = -length;
			scene.addChild(_yCube);

			var _zCube:Cube6 = new Cube6(new ColorMaterial(0x000066), 10, 10, 10);
			_zCube.z = -length;
			scene.addChild(_zCube);
			
			 // toggle
			stage.addEventListener(MouseEvent.CLICK, onClick);
		}

		private function onClick(event:MouseEvent):void
		{
			renderer.cullObjects = !renderer.cullObjects;
		}
		
		override protected function onPreRender():void
		{
			title = "Away3DLite | Frustum Culling : " + renderer.numCulled + " | Click to toggle Culling : " + renderer.cullObjects +" | ";
			
			/*
			var i:Number = 0;
			for each(var sphere:Sphere in spheres)
			{
				sphere.x = 2000 * Math.cos(i+step);
				sphere.z = 2000 * Math.sin(i+step);
				i += 2 * Math.PI / max;
			}
			step+=.01;
			*/
			
			//scene.rotationX += .5;
			scene.rotationY += .5;
			//scene.rotationZ += .5;

			//camera.x = 1000 * Math.cos(step);
			//spheres[0].x = 10 * (300 - mouseY);
			//camera.y = 10 * (300 - mouseY);
			//camera.z = 1000 * Math.sin(step);
			//camera.lookAt(new Vector3D(0, 0, 0));
			step += .01;
			
		}
	}
}