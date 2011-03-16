package
{
	import away3dlite.animators.BonesAnimator;
	import away3dlite.animators.MovieMesh;
	import away3dlite.builders.MDJBuilder;
	import away3dlite.core.base.Object3D;
	import away3dlite.core.utils.Debug;
	import away3dlite.events.Loader3DEvent;
	import away3dlite.loaders.Collada;
	import away3dlite.loaders.Loader3D;
	import away3dlite.loaders.data.AnimationData;
	import away3dlite.templates.BasicTemplate;

	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.net.FileReference;
	import flash.utils.*;

	[SWF(backgroundColor="#CCCCCC", frameRate="30", width="800", height="600")]
	/**
	 * Example : MDJ build from DAE and save as MDJ.
	 * @author katopz
	 */
	public class ExMDJBuilder_AnimationData extends BasicTemplate
	{
		private var _bonesAnimator:BonesAnimator;
		private var _mdjBuilder:MDJBuilder;
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
			_collada.scaling = 10;
			_collada.bothsides = false;

			// load target model
			var _loader3D:Loader3D = new Loader3D();
			_loader3D.loadGeometry("assets/30_box_smooth_translate.dae", _collada);
			_loader3D.addEventListener(Loader3DEvent.LOAD_SUCCESS, onSuccess);
		}

		private function onSuccess(event:Loader3DEvent):void
		{
			// preview
			var _model:Object3D = event.target.handle;
			//scene.addChild(_model);
			//_model.x = 100;

			// test animation
			try
			{
				_bonesAnimator = _model.animationLibrary.getAnimation("default").animation as BonesAnimator;
			}
			catch (e:*)
			{
			}

			// build as MD2
			_mdjBuilder = new MDJBuilder();
			_mdjBuilder.isInterpolateFrame = true;

			// add custom frame label
			var _animationDatas:Vector.<AnimationData> = new Vector.<AnimationData>(2, true);

			// define left e.g : left000, left001, left002, ...., left032  
			_animationDatas[0] = new AnimationData();
			_animationDatas[0].name = "left";
			_animationDatas[0].start = 0;
			_animationDatas[0].end = 30;

			// define right e.g : right000, right001, right002, ...., right032
			_animationDatas[1] = new AnimationData();
			_animationDatas[1].name = "right";
			_animationDatas[1].start = 30;
			_animationDatas[1].end = 60;

			// convert to meshes
			_meshes = _mdjBuilder.convert(_model, _animationDatas);

			// bring it on one by one
			for each (var _mesh:MovieMesh in _meshes)
			{
				// add to scene
				scene.addChild(_mesh);

				// and play it
				_mesh.gotoAndPlay("left");
			}

			// click to save
			stage.addEventListener(MouseEvent.CLICK, onClick);
		}

		private function onClick(event:MouseEvent):void
		{
			// save all as .mdj file
			new FileReference().save(_mdjBuilder.getMDJ(_meshes), "20_cat_smooth_bake_channel.mdj");
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