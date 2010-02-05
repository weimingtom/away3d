package
{
	import away3dlite.animators.BonesAnimator;
	import away3dlite.cameras.*;
	import away3dlite.cameras.lenses.PerspectiveLens;
	import away3dlite.containers.*;
	import away3dlite.core.base.Object3D;
	import away3dlite.core.utils.*;
	import away3dlite.events.*;
	import away3dlite.loaders.*;
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	import away3dlite.templates.BasicTemplate;
	
	import deng.fzip.FZip;
	import deng.fzip.FZipFile;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.*;
	
	[SWF(backgroundColor="#804000", frameRate="30", quality="MEDIUM", width="800", height="360")]

	/**
	 * Unzip & Load Collada example with texture bitmaps being preloaded as ByteArray (for example: for being able to decrypt them).
	 */
	public class ExUnzipColladaAndDecryptBitmaps extends BasicTemplate
	{
		private var collada:Collada;
		private var loader:Loader3D;
		private var loaded:Boolean = false;
		private var model:Object3D;
		private var skinAnimation:BonesAnimator;
		
		private function onSuccess(event:Loader3DEvent):void
		{
			loaded = true;
			model = loader.handle;
			model.layer = new Sprite();
			view.addChild(model.layer);

			// Apply some change to object to make it appear as I want
			model.transform.matrix3D.identity();
			model.transform.matrix3D.appendRotation( 90, new Vector3D(1,0,0));
			model.transform.matrix3D.appendRotation(180, new Vector3D(0,1,0));
			model.transform.matrix3D.appendTranslation(
				-((-0.7685800194740295) + (0.7679924368858337))*0.5,
				-((-1.0577828884124756) + (0.767961859703064 ))*0.5,
				-(-0.05018693208694458)
			);
			model.transform.matrix3D.appendScale(9, 9, 9);
			
			var pose4x4 : Vector.<Number> = new Vector.<Number>(16);
			pose4x4[ 0] = 0.9983117580413818
			pose4x4[ 1] = -0.052813105285167694;
			pose4x4[ 2] = -0.024173574522137642;
			pose4x4[ 3] = 0;
			pose4x4[ 4] = -0.027764596045017242;
			pose4x4[ 5] = -0.7994808554649353;
			pose4x4[ 6] = 0.6000495553016663;
			pose4x4[ 7] = 0;
			pose4x4[ 8] = -0.05101679265499115;
			pose4x4[ 9] = -0.5983654260635376;
			pose4x4[10] = -0.7995975017547607;
			pose4x4[11] = 0;
			pose4x4[12] = -0.01358937006443739;
			pose4x4[13] = 4.1685357093811035;
			pose4x4[14] = 19.230161666870117;
			pose4x4[15] = 1;				
			scene.transform.matrix3D.rawData = pose4x4;
			camera.transform.matrix3D.identity();
			
			skinAnimation = model.animationLibrary.getAnimation("default").animation as BonesAnimator;
		}
	
		/**
		 * @inheritDoc
		 */
		override protected function onInit():void
		{
			title += " : Unzip & Load Collada Example | ";
			Debug.active = true;
			
			preloadZipped3DScene();
		}
	
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// IMPORTANT NOTE (from FZip website):
		// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		//
		//   Limitations:
		//   ------------
		// * When run in the Flash Player browser plugin, FZip can't uncompress compressed files in ZIPs.
		//   See Checksum Patch below to workaround this. This doesn't apply when FZip runs in AIR, or
		//   when files are stored uncompressed.
		// * FZip generally can't read ZIPs that make use of Data Descriptors. Examples of such ZIPs are
		//   those created by the Mac OS X Archiver utility, SWCs, JARs, etc.
		//
		//   Checksum Patch:
		//   ---------------
		// In order to be able to decompress compressed files in a ZIP archive, FZip requires the
		// presence of an Adler32 checksum in addition to the standard CRC32 checksums contained
		// in ZIP archives.
		//
		// We provide a Python script that unobtrusively injects Adler32 checksums into ZIP archives.
		// It is included in the FZip distribution under the 'tools' directory. In order to use this
		// script, Python needs to be installed.
		//
		// This patch is not required if FZip runs in the Adobe AIR runtime, or if the files in the
		// ZIP archive are stored uncompressed (formats such as GIF, JPEG, PNG or SWF for example
		// are already compressed and do not need to be recompressed).
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		
		// So the zipped file must be constructed by following two steps:
		//  - Zip your file(s) into a zip file (with WinZip or WinRar for example)
		//  - Apply the python script to patch the zip file:
		//       python.exe C:\Away3D\lite\libs\deng\tools\fzip-prepare.py <input.zip>
		private var zipLoader:URLLoader;
		private var filepath:String     = "assets/";
		private var fileBaseName:String = "Total_Immersion_Anim_Object2_matrix_keys";
		private var fileExtName:String  = "dae";
		
		private var colladaData:ByteArray;
		
		private function preloadZipped3DScene():void
		{
			var url:URLRequest = new URLRequest(filepath + fileBaseName + ".zip");
			zipLoader =  new URLLoader(url);
			zipLoader.dataFormat = URLLoaderDataFormat.BINARY;
			zipLoader.addEventListener(Event.COMPLETE, onLoadedZipFile);
			zipLoader.load(url);
		}
		
		private function onLoadedZipFile(event:Event):void
		{
			zipLoader.removeEventListener(Event.COMPLETE, onLoadedZipFile);
			
			var zippedData:ByteArray = (zipLoader.data) as ByteArray;
			colladaData = UnZipData(zippedData);
			zipLoader == null;
			
			//trace(colladaData);
			
			preLoadSceneBitmaps();
		}

		private var encryptedBitmap1Loader:URLLoader;
		private var encryptedBitmap2Loader:URLLoader;

		private var bitmap1Name:String = "shadow01.png";
		private var bitmap1Data:ByteArray = null;
		
		private var bitmap2Name:String = "textureTI.jpg";
		private var bitmap2Data:ByteArray = null;
		
		private function preLoadSceneBitmaps():void
		{
			var url1:URLRequest = new URLRequest(filepath + bitmap1Name);
			encryptedBitmap1Loader =  new URLLoader(url1);
			encryptedBitmap1Loader.dataFormat = URLLoaderDataFormat.BINARY;
			encryptedBitmap1Loader.addEventListener(Event.COMPLETE, onLoadedSceneBitmaps);
			encryptedBitmap1Loader.load(url1);

			var url2:URLRequest = new URLRequest(filepath + bitmap2Name);
			encryptedBitmap2Loader =  new URLLoader(url2);
			encryptedBitmap2Loader.dataFormat = URLLoaderDataFormat.BINARY;
			encryptedBitmap2Loader.addEventListener(Event.COMPLETE, onLoadedSceneBitmaps);
			encryptedBitmap2Loader.load(url2);
		}
		
		private function onLoadedSceneBitmaps(event:Event):void
		{
			(event.target).removeEventListener(Event.COMPLETE, onLoadedSceneBitmaps);
			
			var cryptedData:ByteArray = ((event.target).data) as ByteArray;
			if ((event.target) == encryptedBitmap1Loader)
			{
				bitmap1Data = DecryptData(cryptedData);
				encryptedBitmap1Loader = null;
			}
			else
			{
				bitmap2Data = DecryptData(cryptedData);
				encryptedBitmap2Loader = null;
			}
			
			if ((bitmap1Data != null) && (bitmap2Data != null)) 
				Init3DScene();
		}
		
		private function DecryptData(encryptedData:ByteArray):ByteArray
		{
			// Here we should/could decrypt data
			return encryptedData;
		}
			
		private function Init3DScene():void
		{
			// init camera
			var FOCAL_VALUE:Number = 415.69220099999995;  
			var focus:Number = 1;
			var zoom:Number = FOCAL_VALUE/focus;
			camera.lens = new PerspectiveLens();
			camera.zoom = zoom;
			camera.focus = focus;
			camera.z=0;

			renderer.useFloatZSort = true;
			
			collada = new Collada();
			collada.scaling = 1.5;

			loader = new Loader3D();
			loader.loadGeometryFromByteArray(colladaData, collada, filepath, accessByteArrayTextureFromName);
			//loader.loadXML(Cast.xml(colladaData), collada, filepath);
			loader.addEventListener(Loader3DEvent.LOAD_SUCCESS, onSuccess);
			scene.addChild(loader);
		}
		
		private function accessByteArrayTextureFromName(name:String) : ByteArray
		{
			if (name == (filepath + bitmap1Name))
				return bitmap1Data;
			return bitmap2Data;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function onPreRender():void
		{
			//update the collada animation
			if(skinAnimation)
				skinAnimation.update(getTimer()/1000);
			
			//scene.rotationY++;
		}
		
		private var zip:FZip;

		private function UnZipData(data:ByteArray):ByteArray
		{
			if (data == null)
				return null;
				
			// load zip
			zip = new FZip();
			zip.loadBytes(data);

			var nb:int = zip.getFileCount();
			for (var index:int = 0 ; index < nb ; index++)
			{
				// yeah, get it
				var file:FZipFile = zip.getFileAt(index);
				
				// is this the file we want?
				if(file.filename == (fileBaseName + "." + fileExtName))
				{
					zip = null;
					return (file.content);
				}
			}
			
			zip = null;
			
			return null;
		}
	}
}