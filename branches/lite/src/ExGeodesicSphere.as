package
{
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	import away3dlite.templates.*;

	public class ExGeodesicSphere extends BasicTemplate
	{
		private var _sphere:GeodesicSphere;
		
		override protected function onInit():void
		{
			//_sphere = new GeodesicSphere(new BitmapFileMaterial("assets/earth.jpg"), 100, 10);
			_sphere = new GeodesicSphere(new WireColorMaterial(), 100, 10);
			scene.addChild(_sphere);
		}
		
		override protected function onPreRender():void
		{
			scene.rotationY++;
		}
	}
}