package
{
	import away3dlite.animators.MovieMesh;
	import away3dlite.core.base.*;
	import away3dlite.events.*;
	import away3dlite.loaders.*;
	import away3dlite.materials.BitmapFileMaterial;
	import away3dlite.materials.WireColorMaterial;
	import away3dlite.templates.*;
	
	import flash.display.*;
	import flash.geom.Vector3D;

	[SWF(backgroundColor="#FFFFFF", frameRate="30", width="800", height="600")]
	/**
	 * Example : Simple MD2 tester.
	 * @author katopz
	 */	
	public class ExMD2 extends BasicTemplate
	{
		override protected function onInit():void
		{
			// better view angle
			camera.y = -500;
			camera.lookAt(new Vector3D());
			
			var _md2:MD2 = new MD2();
			_md2.scaling = 5;
			_md2.material = new BitmapFileMaterial("assets/yellow.jpg");
			
			var _loader3D:Loader3D = new Loader3D();
			_loader3D.addEventListener(Loader3DEvent.LOAD_SUCCESS, onSuccess);
			_loader3D.loadGeometry("assets/10_box_still.md2", _md2);
			
			scene.addChild(_loader3D);
		}
		
		private function onSuccess(event:Loader3DEvent):void
		{
			var _model:MovieMesh = event.loader.handle as MovieMesh;
			_model.bothsides = true;
			_model.play();
		}
		
		override protected function onPreRender():void
		{
			scene.rotationY++;
		}
	}
}