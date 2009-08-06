package
{
	import away3d.animators.SkinAnimation;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.utils.Debug;
	import away3d.events.LoaderEvent;
	import away3d.loaders.Collada;
	import away3d.loaders.Object3DLoader;
	import away3d.loaders.data.AnimationData;
	import away3d.test.SimpleView;
	
	import flash.utils.getTimer;
	
	[SWF(backgroundColor="0xFFFFFF", frameRate="30", width="800", height="600")]
	
	/**
	 * 
	 * Away3D Collada Animation
	 * @author katopz@sleepydesign.com
	 * 
	 */
	public class ExColladaAnimation extends SimpleView
	{
        private var skinAnimation:SkinAnimation;
        
        public function ExColladaAnimation()
        {
        	// just title
        	super("Animation","Collada Animation Example by katopz");
        }
        
        override protected function create() : void
        {
			// for debug lover
			Debug.active = true;
			
			// load and wait...
			var loader:Object3DLoader = Collada.load("assets/Maya8.5/ColladaMaya3.05B/basic/30_box_smooth_translate.dae");
			loader.addOnSuccess(onLoaderSuccess);
			view.scene.addChild(loader);
        }
        
		private function onLoaderSuccess(event:LoaderEvent):void
		{
			// camera auto lookAt target in simple view
			target = ObjectContainer3D(event.loader.handle);
            skinAnimation = (target.animationLibrary["default"] as AnimationData).animation as SkinAnimation;
            
            // fun!
			start();
		}
		
        override protected function draw() : void
        {
        	// rotate around
        	view.scene.rotationY+=Math.PI/10;
        	view.camera.lookAt(target.position);
        	
        	// update animation
        	skinAnimation.update(getTimer()/1000);
        }
	}
}
