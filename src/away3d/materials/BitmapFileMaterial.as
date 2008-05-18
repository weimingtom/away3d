package away3d.materials
{
	import away3d.core.*;
	import away3d.events.*;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.net.URLRequest;

    /**
    * Bitmap material that loads it's texture from an external bitmapasset file.
    */
    public class BitmapFileMaterial extends TransformBitmapMaterial implements ITriangleMaterial, IUVMaterial
    {
    	use namespace arcane;
    	
		private var _loader:Loader;
		private var _materialresize:MaterialEvent;
		
		private function onComplete(e:Event):void
		{
			_renderBitmap = _bitmap = Bitmap(_loader.content).bitmapData;
			
			if (_materialresize == null)
				_materialresize = new MaterialEvent(MaterialEvent.RESIZED, this);
			
			dispatchEvent(_materialresize);
		}
    	
		/**
		 * Creates a new <code>BitmapFileMaterial</code> object.
		 *
		 * @param	url					The location of the bitmapasset to load.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
		public function BitmapFileMaterial( url :String="", init:Object = null)
        {
            super(new BitmapData(100,100), init);
			
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			_loader.load(new URLRequest(url));
        }
    }
}