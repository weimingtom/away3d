package
{
	import away3dlite.builders.MD2Builder;
	import away3dlite.core.base.Mesh;
	import away3dlite.core.base.Object3D;
	import away3dlite.core.utils.Debug;
	import away3dlite.events.Loader3DEvent;
	import away3dlite.loaders.Loader3D;
	import away3dlite.loaders.MD2;
	import away3dlite.materials.BitmapFileMaterial;
	import away3dlite.templates.BasicTemplate;
	
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.net.FileReference;
	import flash.utils.*;

	[SWF(backgroundColor="#CCCCCC", frameRate="30", width="800", height="600")]
	/**
	 * Example : MD2 Builder for stay still model no animation.
	 * @author katopz
	 */	
	public class ExMD2toMD2 extends BasicTemplate
	{
		private var _md2Builder:MD2Builder;

		override protected function onInit():void
		{
			title = "Click to save |";
			
			// behide the scene
			Debug.active = true;

			// better view angle
			camera.y = -500;
			camera.lookAt(new Vector3D());

			// some collada with animation
			var _md2:MD2 = new MD2();
			_md2.scaling = 5;

			// load target model
			var _loader3D:Loader3D = new Loader3D();
			_loader3D.loadGeometry("assets/plane.md2", _md2);
			_loader3D.addEventListener(Loader3DEvent.LOAD_SUCCESS, onSuccess);
		}

		private function onSuccess(event:Loader3DEvent):void
		{
			// preview
			var _model:Object3D = event.target.handle;
			scene.addChild(_model);
			_model.x = 100;
			
			// add some material
			Mesh(_model).material = new BitmapFileMaterial("assets/yellow.jpg");
			
			// this texture name will add to MD2 header
			BitmapFileMaterial(Mesh(_model).material).name = "yellow.jpg";

			// build as MD2
			_md2Builder = new MD2Builder();
			_md2Builder.scaling = 5;

			// bring it on
			scene.addChild(_md2Builder.convert(_model)[0]);
			
			// click to save
			stage.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick(event:MouseEvent):void
		{
			// save as md2 file
			new FileReference().save(_md2Builder.getMD2(), "untitled.md2");
		}

		override protected function onPreRender():void
		{
			// show time
			scene.rotationY++;
		}
	}
}