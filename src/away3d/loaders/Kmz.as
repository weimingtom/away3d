package away3d.loaders
{
    import away3d.containers.*;
    import away3d.materials.*;
    import away3d.core.base.*;
    import away3d.core.utils.*;
    import away3d.loaders.data.ContainerData;
    import away3d.loaders.data.MaterialData;
    
    import flash.display.Bitmap;
    import flash.display.Loader;
    import flash.events.Event;
    import flash.utils.ByteArray;
    
    import nochump.util.zip.*;

    /** Kmz file format loader (export from google sketchup) */
    public class Kmz
    {
    	public var container:ObjectContainer3D;
    	public var materialLibrary:MaterialLibrary;
        public var containerData:ContainerData;
        public var collada:XML;
        
        public function Kmz(datastream:ByteArray, init:Object = null)
        {
			//parse the kmz file
            parseKmz(datastream, init);
        }

        public static function parse(data:*, init:Object = null, loader:Object3DLoader = null):ObjectContainer3D
        {
            return new Kmz(Cast.bytearray(data), init).container;
        }
    
        public static function load(url:String, init:Object = null):Object3DLoader
        {
            return Object3DLoader.loadGeometry(url, parse, true, init);
        }
    
        private function parseKmz(datastream:ByteArray, init:Object):void
        {
        	
            var kmzFile:ZipFile = new ZipFile(datastream);
			var totalMaterials:int = kmzFile.entries.join("@").split(".jpg").length;
			for(var i:int = 0; i < kmzFile.entries.length; i++) {
				var entry:ZipEntry = kmzFile.entries[i];
				var data:ByteArray = kmzFile.getInput(entry);
				if(entry.name.indexOf(".dae")>-1 && entry.name.indexOf("models/")>-1) {
					collada = new XML(data.toString());
					container = Collada.parse(collada, init, this);
					materialLibrary.loadRequired = false;
				} else if((entry.name.indexOf(".jpg")>-1 || entry.name.indexOf(".png")>-1) && entry.name.indexOf("images/")>-1) {
					var _loader:Loader = new Loader();
					_loader.name = "../" + entry;
					_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadBitmapCompleteHandler);
					_loader.loadBytes(data);
				};	  
			};
        }
        
        private var _materialData:MaterialData;
        private var _face:Face;
        
        private function loadBitmapCompleteHandler(e:Event):void {
			var loader:Loader = Loader(e.target.loader);
			
			//pass material instance to correct materialData
			for each (_materialData in materialLibrary) {
				if (_materialData.textureFileName == loader.name) {
					_materialData.textureBitmap = Bitmap(loader.content).bitmapData;
					_materialData.material = new BitmapMaterial(_materialData.textureBitmap);
					for each(_face in _materialData.faces)
						_face.material = _materialData.material;
				}
			}
		}
		
    }
}
