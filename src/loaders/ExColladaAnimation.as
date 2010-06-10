package loaders
{
	import away3dlite.animators.BonesAnimator;
	import away3dlite.core.base.Object3D;
	import away3dlite.core.utils.*;
	import away3dlite.events.Loader3DEvent;
	import away3dlite.loaders.*;
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	import away3dlite.templates.BasicTemplate;

	import flash.display.*;
	import flash.geom.Vector3D;
	import flash.utils.*;

	[SWF(backgroundColor="#000000", frameRate="30", width="800", height="600")]

	/**
	 * Collada Animation example.
	 */
	public class ExColladaAnimation extends BasicTemplate
	{
		private var _collada:Collada;
		private var _bonesAnimator:BonesAnimator;

		private function onSuccess(event:Loader3DEvent):void
		{
			var _model:Object3D = event.target["handle"];
			_model.layer = event.target["layer"];

			var sphere:Sphere = new Sphere();
			scene.addChild(sphere);
			sphere.layer = _model.layer;

			_bonesAnimator = _model.animationLibrary.getAnimation("default").animation as BonesAnimator;
		}

		override protected function onInit():void
		{
			title += " : Collada Example.";
			Debug.active = true;
			camera.y = -500;
			camera.lookAt(new Vector3D());

			var plane:Plane = new Plane(new WireColorMaterial, 500, 500);
			scene.addChild(plane);
			plane.layer = new Sprite();
			view.addChild(plane.layer);

			_collada = new Collada();
			_collada.scaling = 25;

			var _loader3D:Loader3D = new Loader3D();
			scene.addChild(_loader3D);
			_loader3D.loadGeometry("../src/loaders/assets/dae/30_box_smooth_translate.dae", _collada);
			_loader3D.addEventListener(Loader3DEvent.LOAD_SUCCESS, onSuccess);

			_loader3D.layer = new Sprite();
			view.addChild(_loader3D.layer);
		}

		override protected function onPreRender():void
		{
			//update the collada animation
			if (_bonesAnimator)
				_bonesAnimator.update(getTimer() / 1000);

			scene.rotationY++;
		}
	}
}