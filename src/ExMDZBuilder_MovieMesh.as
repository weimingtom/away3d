package
{
	import away3dlite.animators.BonesAnimator;
	import away3dlite.animators.MovieMesh;
	import away3dlite.builders.MDZBuilder;
	import away3dlite.core.base.Object3D;
	import away3dlite.core.utils.Debug;
	import away3dlite.events.Loader3DEvent;
	import away3dlite.events.MaterialEvent;
	import away3dlite.loaders.Collada;
	import away3dlite.loaders.Loader3D;
	import away3dlite.loaders.MD2;
	import away3dlite.loaders.data.MaterialData;
	import away3dlite.materials.BitmapFileMaterial;
	import away3dlite.materials.BitmapMaterial;
	import away3dlite.templates.BasicTemplate;

	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.net.FileReference;
	import flash.utils.*;

	[SWF(backgroundColor="#CCCCCC", frameRate="30", width="800", height="600")]
	/**
	 * Example : MDZ build from DAE and save as MDZ with some external MD2.
	 * @author katopz
	 */
	public class ExMDZBuilder_MovieMesh extends BasicTemplate
	{
		private var _bonesAnimator:BonesAnimator;
		private var _mdzBuilder:MDZBuilder;
		private var _meshes:Vector.<MovieMesh>;

		private var _otherMesh:MovieMesh;

		override protected function onInit():void
		{
			title = "Click to save |";

			// behide the scene
			Debug.active = true;

			// better view angle
			camera.y = -500;
			camera.lookAt(new Vector3D());

			var _material:BitmapFileMaterial = new BitmapFileMaterial("assets/yellow.jpg");
			_material.addEventListener(MaterialEvent.LOAD_SUCCESS, onMaterailSuccess);
		}

		private function onMaterailSuccess(event:MaterialEvent):void
		{
			var _md2:MD2 = new MD2();
			_md2.scaling = 2;
			_md2.material = event.material;

			var _loader3D:Loader3D = new Loader3D();
			_loader3D.addEventListener(Loader3DEvent.LOAD_SUCCESS, onOtherSuccess);
			_loader3D.loadGeometry("assets/30_box_smooth_translate.md2", _md2);
		}

		private function onOtherSuccess(event:Loader3DEvent):void
		{
			// temporary keep it
			_otherMesh = event.loader.handle as MovieMesh;

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
			_mdzBuilder = new MDZBuilder();

			// add other mesh
			_model.addChild(_otherMesh);

			// add material info, we need this while packing
			var _materialData:MaterialData = _model.materialLibrary.addMaterial("yellow");
			_materialData.material = _otherMesh.material;

			// TODO : sync external MD2 to existing animation somehow, it's must be same length or...maybe not

			// convert to meshes
			_meshes = _mdzBuilder.convert(_model);

			// bring it on one by one
			for each (var _mesh:MovieMesh in _meshes)
			{
				// add to scene
				scene.addChild(_mesh);

				// and play it
				_mesh.play();
			}

			// click to save
			stage.addEventListener(MouseEvent.CLICK, onClick);
		}

		private function onClick(event:MouseEvent):void
		{
			// save all as .mdz file
			new FileReference().save(_mdzBuilder.getMDZ(_meshes).byteArray, "nemuvine.mdz");
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