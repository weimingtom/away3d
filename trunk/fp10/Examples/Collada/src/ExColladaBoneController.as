package
{
	import away3d.animators.SkinAnimation;
	import away3d.animators.skin.Bone;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.utils.Debug;
	import away3d.events.LoaderEvent;
	import away3d.loaders.Collada;
	import away3d.loaders.Object3DLoader;
	import away3d.loaders.data.AnimationData;
	import away3d.test.SimpleView;
	
	[SWF(backgroundColor="0xFFFFFF", frameRate="30", width="800", height="600")]
	
	/**
	 * 
	 * Away3D Collada Bone Controller
	 * @author katopz@sleepydesign.com
	 * 
	 */
	public class ExColladaBoneController extends SimpleView
	{
        private var skinAnimation:SkinAnimation;
      	private var bone:Bone;
        
        public function ExColladaBoneController()
        {
        	// just title
        	super("Bone","Collada Bone Controller Example by katopz");
        }
        
        override protected function create() : void
        {
			// for debug lover
			Debug.active = true;
			
			// load and wait...
			var loader:Object3DLoader = Collada.load("assets/Maya8.5/ColladaMaya3.05B/advance/10_skeleton_rigid_bone.dae");
			loader.addOnSuccess(onLoaderSuccess);
			view.scene.addChild(loader);
        }
        
		private function onLoaderSuccess(event:LoaderEvent):void
		{
			// camera auto lookAt target in simple view
			target = ObjectContainer3D(event.loader.handle);
            
            // zoom out abit
            view.camera.zoom = 4;
            
            // fun!
			start();
		}
		
        override protected function draw() : void
        {
        	// rotate around
        	view.scene.rotationY+=Math.PI/10;
        	view.camera.lookAt(target.position);
        	
        	// get neck bone
        	if(!bone)
        		bone = ObjectContainer3D(target).getBoneByName("neck");
        	
        	// try control
        	bone.jointRotationY += (mouseX - 320 - bone.jointRotationY) * .5;
        }
	}
}
