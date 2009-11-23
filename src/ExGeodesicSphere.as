package
{
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	import away3dlite.templates.*;
	
	[SWF(backgroundColor="0xEEEEEE",frameRate="30",width="800",height="600")]
	public class ExGeodesicSphere extends BasicTemplate
	{
		private var _sphere:GeodesicSphere;
		
		override protected function onInit():void
		{
			view.setSize(800, 600);
			view.x = 800/2;
			view.y = 600/2;
			
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