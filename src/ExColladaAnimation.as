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
	import flash.utils.*;
	
	[SWF(backgroundColor="#000000", frameRate="30", quality="MEDIUM", width="800", height="600")]

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
			skinAnimation = model.animationLibrary.getAnimation("default").animation as BonesAnimator;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function onInit():void
		{
			title += " : Collada Example.";
			Debug.active = true;
			camera.y = -500;
			camera.z = -2000;
			
			collada = new Collada();
			collada.scaling = 100;
			//collada.centerMeshes = true;
			
			loader = new Loader3D();
			loader.loadGeometry("nemuvine/nemuvine.dae", collada);
			loader.addEventListener(Loader3DEvent.LOAD_SUCCESS, onSuccess);
			scene.addChild(loader);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function onPreRender():void
		{
			//update the collada animation
			//if(skinAnimation)
			//	skinAnimation.update(getTimer()*2/1000);
			
			scene.rotationY++;
		}
	}
}