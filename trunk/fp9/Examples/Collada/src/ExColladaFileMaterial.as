package
{
	import away3d.animators.SkinAnimation;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.utils.Debug;
	import away3d.events.Loader3DEvent;
	import away3d.loaders.Collada;
	import away3d.loaders.Loader3D;
	import away3d.loaders.data.MaterialData;
	import away3d.materials.BitmapFileMaterial;
	import away3d.test.SimpleView;

	[SWF(backgroundColor="0xFFFFFF", frameRate="30", width="800", height="600")]
	
	/**
	 * 
	 * Away3D Collada Custom Material
	 * @author katopz@sleepydesign.com
	 * 
	 */
	public class ExColladaFileMaterial extends SimpleView
	{
        public function ExColladaFileMaterial()
        {
        	// just title
        	super("Material","Collada Custom Material Example by katopz");
        }
        
        override protected function create() : void
        {
			// for debug lover
			Debug.active = true;
			
			// load and wait...
			var loader:Loader3D = Collada.load("assets/Maya8.5/ColladaMaya3.05B/basic/10_box_still.dae");
			loader.addOnSuccess(onLoaderSuccess);
			view.scene.addChild(loader);
        }
        
		private function onLoaderSuccess(event:Loader3DEvent):void
		{
			// camera auto lookAt target in simple view
			target = ObjectContainer3D(event.loader.handle);
			target.scale(100);
            
            // try change "lambert1" material
            var targetMaterial:MaterialData = target.materialLibrary.getMaterial("lambert1");
            targetMaterial.material = new BitmapFileMaterial("assets/Maya8.5/ColladaMaya3.05B/advance/10_skeleton.png");
            
            // fun!
			start();
		}
		
        override protected function draw() : void
        {
        	// rotate around
        	view.scene.rotationY+=Math.PI/10;
        	view.camera.lookAt(target.position);
        }
	}
}
