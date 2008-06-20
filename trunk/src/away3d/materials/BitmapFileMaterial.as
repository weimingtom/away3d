package away3d.materials
{
	import away3d.core.*;
	import away3d.events.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;

    /**
    * Bitmap material that loads it's texture from an external bitmapasset file.
    */
    public class BitmapFileMaterial extends TransformBitmapMaterial implements ITriangleMaterial, IUVMaterial
    {
    	use namespace arcane;
    	
		private var _loader:Loader;
		private var _materialresize:MaterialEvent;
		private var _materialloaderror:MaterialEvent;
		private var _materialloadprogress:MaterialEvent;
		private var _materialloadsuccess:MaterialEvent;
		
		private function onError(e:IOErrorEvent):void
		{			
			if (!_materialloaderror)
				_materialloaderror = new MaterialEvent(MaterialEvent.LOAD_ERROR, this);
			
            dispatchEvent(_materialloaderror);
		}
		
		private function onProgress(e:ProgressEvent):void
		{
			if (!_materialloadprogress)
				_materialloadprogress = new MaterialEvent(MaterialEvent.LOAD_PROGRESS, this);
			
            dispatchEvent(_materialloadprogress);
		}
		
		private function onComplete(e:Event):void
		{
			_renderBitmap = _bitmap = Bitmap(_loader.content).bitmapData;
			
			if (_materialresize == null)
				_materialresize = new MaterialEvent(MaterialEvent.RESIZED, this);
			
			dispatchEvent(_materialresize);
			
			if (!_materialloadsuccess)
				_materialloadsuccess = new MaterialEvent(MaterialEvent.LOAD_SUCCESS, this);
			
            dispatchEvent(_materialloadsuccess);
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
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
            _loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			_loader.load(new URLRequest(url));
        }
        
		/**
		 * Default method for adding a materialloadsuccess event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnSuccess(listener:Function):void
        {
            addEventListener(MaterialEvent.LOAD_SUCCESS, listener, false, 0, true);
        }
		
		/**
		 * Default method for removing a materialloadsuccess event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnSuccess(listener:Function):void
        {
            removeEventListener(MaterialEvent.LOAD_SUCCESS, listener, false);
        }
		
		/**
		 * Default method for adding a materialloadprogress event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnProgress(listener:Function):void
        {
            addEventListener(MaterialEvent.LOAD_PROGRESS, listener, false, 0, true);
        }
		
		/**
		 * Default method for removing a materialloadprogress event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnProgress(listener:Function):void
        {
            removeEventListener(MaterialEvent.LOAD_PROGRESS, listener, false);
        }	
        	
		/**
		 * Default method for adding a materialloaderror event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnError(listener:Function):void
        {
            addEventListener(MaterialEvent.LOAD_ERROR, listener, false, 0, true);
        }
		
		/**
		 * Default method for removing a materialloaderror event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnError(listener:Function):void
        {
            removeEventListener(MaterialEvent.LOAD_ERROR, listener, false);
        }
    }
}