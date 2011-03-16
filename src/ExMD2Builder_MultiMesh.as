package
{
	import away3dlite.animators.BonesAnimator;
	import away3dlite.animators.MovieMesh;
	import away3dlite.builders.MD2Builder;
	import away3dlite.core.base.Mesh;
	import away3dlite.core.base.Object3D;
	import away3dlite.core.utils.Debug;
	import away3dlite.events.Loader3DEvent;
	import away3dlite.loaders.Collada;
	import away3dlite.loaders.Loader3D;
	import away3dlite.materials.BitmapFileMaterial;
	import away3dlite.materials.BitmapMaterial;
	import away3dlite.templates.BasicTemplate;

	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.net.FileReference;
	import flash.utils.*;

	[SWF(backgroundColor="#CCCCCC", frameRate="30", width="800", height="600")]
	/**
	 * Example : MD2Builder with multi mesh, in this case is Collada :)
	 * @author katopz
	 */
	public class ExMD2Builder_MultiMesh extends BasicTemplate
	{
		private var _bonesAnimator:BonesAnimator;
		private var _md2Builder:MD2Builder;
		private var _meshes:Vector.<MovieMesh>;

		override protected function onInit():void
		{
			title = "Click to save |";

			// behide the scene
			Debug.active = true;

			// better view angle
			camera.y = -500;
			camera.lookAt(new Vector3D());

			// some collada with animation
			var _collada:Collada = new Collada();
			_collada.scaling = 20;
			_collada.bothsides = false;

			// load target model
			var _loader3D:Loader3D = new Loader3D();
			_loader3D.loadGeometry("nemuvine/nemuvine.dae", _collada);
			_loader3D.addEventListener(Loader3DEvent.LOAD_SUCCESS, onSuccess);
		}

		private function onSuccess(event:Loader3DEvent):void
		{
			// preview
			var _model:Object3D = event.target.handle;
			scene.addChild(_model);
			_model.x = 100;

			// test animation
			try
			{
				_bonesAnimator = _model.animationLibrary.getAnimation("default").animation as BonesAnimator;
			}
			catch (e:*)
			{
			}

			// build as MD2
			_md2Builder = new MD2Builder();

			// convert to meshes
			_meshes = _md2Builder.convert(_model);

			// bring it on one by one
			for each (var _mesh:MovieMesh in _meshes)
			{
				scene.addChild(_mesh);
				_mesh.play();
			}

			// define material name
			BitmapMaterial(_meshes[0].material).url = "book_blue.png";

			// click to save
			stage.addEventListener(MouseEvent.CLICK, onClick);
		}

		private function onClick(event:MouseEvent):void
		{
			// save the 1st one as .md2 file
			new FileReference().save(_md2Builder.getMD2(_meshes[0]), _meshes[0].name + ".md2");
		}

		override protected function onPreRender():void
		{
			// update the collada animation
			if (_bonesAnimator)
				_bonesAnimator.update(getTimer() / 1000);

			// show time
			scene.rotationY++;
		}
	}
}