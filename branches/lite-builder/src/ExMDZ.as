package
{
	import away3dlite.animators.MovieMesh;
	import away3dlite.animators.MovieMeshContainer3D;
	import away3dlite.containers.ObjectContainer3D;
	import away3dlite.events.Loader3DEvent;
	import away3dlite.loaders.Loader3D;
	import away3dlite.loaders.MDZ;
	import away3dlite.materials.BitmapFileMaterial;
	import away3dlite.templates.BasicTemplate;
	
	import flash.geom.Vector3D;
	import flash.utils.*;

	[SWF(backgroundColor="#CCCCCC", frameRate="30", width="800", height="600")]
	/**
	 * Example : MDZ load and play.
	 * @author katopz
	 */	
	public class ExMDZ extends BasicTemplate
	{
		private var _meshes:MovieMeshContainer3D;

		override protected function onInit():void
		{
			// better view angle
			camera.y = -500;
			camera.lookAt(new Vector3D());
			
			var _mdz:MDZ = new MDZ();

			var _loader3D:Loader3D = new Loader3D();
			_loader3D.loadGeometry("nemuvine/nemuvine.mdz", _mdz);
			scene.addChild(_loader3D);
		}

		override protected function onPreRender():void
		{
			// play animation
			if (_meshes)
				_meshes.play();

			scene.rotationY++;
		}
	}
}