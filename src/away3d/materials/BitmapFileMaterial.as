package away3d.materials
{
	
	import away3d.events.*;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.geom.*;
	import flash.net.URLRequest;

    /** File bitmap texture material */
    public class BitmapFileMaterial extends TransformBitmapMaterial implements ITriangleMaterial, IUVMaterial
    {
       
		private var loader:Loader;
		
		public function BitmapFileMaterial( url :String="", init:Object = null)
        {
            super(new BitmapData(100,100), init);
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			loader.load(new URLRequest(url));
        }
        
		private var materialresize:MaterialEvent;
		
		private function onComplete(e:Event):void
		{
			_renderBitmap = _bitmap = Bitmap(loader.content).bitmapData;
			
			if (materialresize == null)
				materialresize = new MaterialEvent(MaterialEvent.RESIZED, this);
			
			dispatchEvent(materialresize);
		}

    }
}