package
{
	import away3d.animators.SkinAnimation;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.utils.Debug;
	import away3d.events.Loader3DEvent;
	import away3d.loaders.Collada;
	import away3d.loaders.Loader3D;
	import away3d.loaders.data.AnimationData;
	import away3d.test.SimpleView;
	
	import flash.utils.getTimer;

	[SWF(backgroundColor="0xFFFFFF",frameRate="30",width="800",height="600")]

	/**
	 * 
	 * Away3D Collada Animation Examples
	 * @author katopz@sleepydesign.com
	 * 
	 */
	public class ExColladaAnimation extends SimpleView
	{
		private var skinAnimation:SkinAnimation;

		public function ExColladaAnimation()
		{
			// just title
			super("Material", "Simple Collada Animation Example by katopz");
		}

		override protected function create():void
		{
			// for debug lover
			Debug.active = true;

			// pick one!
			
			// ---------------------------- Maya8.5 Collada Maya 3.05B ---------------------------- 
			
			var loader:Loader3D = Collada.load("assets/Maya8.5/ColladaMaya3.05B/basic/30_box_smooth_translate.dae");
			//var loader:Loader3D = Collada.load("assets/Maya8.5/ColladaMaya3.05B/basic/40_box_smooth_rotate.dae");
			//var loader:Loader3D = Collada.load("assets/Maya8.5/ColladaMaya3.05B/basic/41_box_rigid_rotate.dae");
			//var loader:Loader3D = Collada.load("assets/Maya8.5/ColladaMaya3.05B/basic/42_box_rigid_member_rotate.dae");
			//var loader:Loader3D = Collada.load("assets/Maya8.5/ColladaMaya3.05B/basic/50_box_smooth_scale.dae");
			
			//scale = 100
			
			// ---------------------------- 3dsMax11 11.008 ---------------------------- 
			
			// scale 10
			//var loader:Loader3D = Collada.load("assets/3dsMax11/ColladaMax3.05B/advance/30_transforms.dae");
			
			// ---------------------------- 3dsMax2009 COLLADAMax NextGen v1.1.0---------------------------- 
			
			//only work with 1 sampler
			
			//var loader:Loader3D = Collada.load("assets/3dsMax2009/COLLADAMaxNextGen1.1.0/basic/10_box_still.dae");
			//TODO//var loader:Loader3D = Collada.load("assets/3dsMax2009/COLLADAMaxNextGen1.1.0/20_box_still_bone.dae");
			//TODO//var loader:Loader3D = Collada.load("assets/3dsMax2009/COLLADAMaxNextGen1.1.0/basic/30_box_smooth_translate.dae");
			//TODO//var loader:Loader3D = Collada.load("assets/3dsMax2009/COLLADAMaxNextGen1.1.0/basic/40_box_smooth_rotate.dae");
			//TODO//var loader:Loader3D = Collada.load("assets/3dsMax2009/COLLADAMaxNextGen1.1.0/basic/41_box_rigid_rotate.dae");
			//TODO//var loader:Loader3D = Collada.load("assets/3dsMax2009/COLLADAMaxNextGen1.1.0/basic/42_box_rigid_member_rotate.dae");
			//TODO//var loader:Loader3D = Collada.load("assets/3dsMax2009/COLLADAMaxNextGen1.1.0/basic/50_box_smooth_scale.dae");
			
			//scale = 10
			
			// ---------------------------- Cinema4D 11.008 ---------------------------- 
			
			//var loader:Loader3D = Collada.load("assets/Cinema4D11.008/basic/30_box_smooth_translate.dae");
			//var loader:Loader3D = Collada.load("assets/Cinema4D11.008/basic/40_box_smooth_rotate.dae");
			//var loader:Loader3D = Collada.load("assets/Cinema4D11.008/basic/41_box_rigid_rotate.dae");
			//var loader:Loader3D = Collada.load("assets/Cinema4D11.008/basic/42_box_rigid_member_rotate.dae");
			//var loader:Loader3D = Collada.load("assets/Cinema4D11.008/basic/50_box_smooth_scale.dae");
			
			//scale = 10000
			
			loader.addOnSuccess(onLoaderSuccess);
			view.scene.addChild(loader);
		}

		private function onLoaderSuccess(event:Loader3DEvent):void
		{
			// camera auto lookAt target in simple view
			target = ObjectContainer3D(event.loader.handle);
			target.scale(100);

			if (target.animationLibrary["default"] as AnimationData)
				skinAnimation = (target.animationLibrary["default"] as AnimationData).animation as SkinAnimation;

			// fun!
			start();
		}

		override protected function draw():void
		{
			// rotate around
			view.scene.rotationY += Math.PI / 10;
			view.camera.lookAt(target.position);

			// update animation
			if (skinAnimation)
			{
				// Cinema4D 11.008 
				//skinAnimation.update(getTimer() / 1000, false);

				// Maya8.5 Collada Maya 3.05B
				skinAnimation.update(getTimer() / 1000);
			}
		}
	}
}