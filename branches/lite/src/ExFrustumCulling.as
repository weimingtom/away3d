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
			//scene.addChild(new Sphere(null, 100, 6, 6));

			var colors:Array = [0xFFFFFF, 0xFF0000, 0x00FF00, 0x0000FF];
			
			// orbit
			var i:Number = 0;
			for (var j:int = 0; j < max; j++)
			{
				var sphere:Sphere = new Sphere(new WireColorMaterial(colors[j%4]), 50, 6, 6);
				scene.addChild(sphere);
				sphere.x = 1000 * Math.cos(i);
				sphere.z = 1000 * Math.sin(i);
				i += 2 * Math.PI / max;
				spheres.push(sphere);
			}
			
			// layer test
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