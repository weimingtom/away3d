package
{
	import away3dlite.animators.BonesAnimator;
	import away3dlite.cameras.*;
	import away3dlite.containers.*;
	import away3dlite.core.base.Object3D;
	import away3dlite.core.utils.*;
	import away3dlite.events.Loader3DEvent;
	import away3dlite.loaders.*;
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	import away3dlite.templates.BasicTemplate;

	import flash.display.*;
	import flash.events.*;
	import flash.filters.BlurFilter;
	import flash.geom.Vector3D;
	import flash.utils.*;

	[SWF(backgroundColor="#000000", frameRate="30", width="800", height="600")]

	/**
	 * Collada example.
	 */
	public class ExColladaAnimation extends BasicTemplate
	{
		private var collada:Collada;
		private var loader:Loader3D;
		private var loaded:Boolean = false;
		private var model:Object3D;
		private var skinAnimation:BonesAnimator;

		private function onSuccess(event:Loader3DEvent):void
		{
			loaded = true;
			model = loader.handle;
			model.layer = event.target.layer;

			var sphere:Sphere = new Sphere();
			scene.addChild(sphere);
			sphere.layer = model.layer;

			skinAnimation = model.animationLibrary.getAnimation("default").animation as BonesAnimator;
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

			collada = new Collada();
			collada.scaling = 25;

			loader = new Loader3D();
			scene.addChild(loader);
			loader.loadGeometry("assets/30_box_smooth_translate.dae", collada);
			loader.addEventListener(Loader3DEvent.LOAD_SUCCESS, onSuccess);

			loader.layer = new Sprite();
			view.addChild(loader.layer);
		}

		override protected function onPreRender():void
		{
			//update the collada animation
			if (skinAnimation)
				skinAnimation.update(getTimer() / 1000);

			scene.rotationY++;
		}
	}
}