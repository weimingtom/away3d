/*

Basic MD2 loading in Away3dLite

Demonstrates:

How to load an md2 file.
How to load a texture from an external image.
How to animate an md2 file.

Code by Rob Bateman & Katopz
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk
katopz@sleepydesign.com
http://sleepydesign.com/

This code is distributed under the MIT License

Copyright (c)  

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

package;
import away3dlite.animators.MovieMesh;
import away3dlite.core.utils.Debug;
import away3dlite.events.Loader3DEvent;
import away3dlite.loaders.Loader3D;
import away3dlite.loaders.MD2;
import away3dlite.materials.BitmapFileMaterial;
import away3dlite.templates.FastTemplate;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import flash.display.StageQuality;
import haxe.Resource;


//[SWF(backgroundColor="#000000", frameRate="30", quality="MEDIUM", width="800", height="600")]

/**
 * MD2 example
 */
class ExMD2Cubic extends FastTemplate
{
	//signature swf
	//[Embed(source="assets/signature_lite_katopz.swf", symbol="Signature")]
	private static var SignatureSwf:Loader;
	
	//signature variables
	private var Signature:Sprite;
	private var SignatureBitmap:Bitmap;
	private static var filesToLoad:Int;
	
	private var loaded:Bool;
	
	public static function main()
	{
		Debug.redirectTraces = true;
		Debug.active = true;
		
		filesToLoad = 1;
		SignatureSwf = new Loader();
		loadResource(SignatureSwf, "signatureSwf");
	}
	
	private static function onLoadComplete(e:Event):Void 
	{
		if (--filesToLoad == 0)
			Lib.current.addChild(new ExMD2Cubic());
	}
	
	private static function loadResource(loader:Loader , resname:String)
	{
		loader.contentLoaderInfo.addEventListener("complete", onLoadComplete);
		loader.loadBytes(Resource.getBytes(resname).getData());
	}
	
	private function onSuccess(event:Loader3DEvent):Void
	{
		var model:MovieMesh = Lib.as(event.loader.handle, MovieMesh);
		model.play("walk");
		
		if (!loaded)
		{
			loaded = true;
			
			var amount:UInt = 3;
			var gap:Int = 240;
			
			var i = -1;
			while (i < amount)
			{
				var j = -1;
				while (++j < amount)
				{
					var k = -1;
					while (k < amount)
					{
						var model2 = model.clone();
						model2.x = gap*i - amount*gap/2 + 100;
						model2.y = gap*j - amount*gap/2 + 200;
						model2.z = gap * k - amount * gap / 2;
						
						//model2.play("walk");
						
						view.scene.addChild(model2);
					}
				}
			}
		}
	}
	
	/**
	 * @inheritDoc
	 */
	override private function onInit():Void
	{
		title += " : MD2 Example.";
		Debug.active = true;
		camera.z = -1500;
		
		var material:BitmapFileMaterial = new BitmapFileMaterial("assets/pg.png");
		material.smooth = true;
		
		var amount:UInt = 1;
		var gap:Int = 240;

		
		var i = -1;
		/*while (i < amount)
		{
			var j = -1;
			while (++j < amount)
			{
				var k = -1;
				while (k < amount)
				{*/
					var md2:MD2 = new MD2();
					md2.material = material;
					material.smooth = true;
					md2.scaling = 10;
					md2.centerMeshes = true;
					var loader:Loader3D = new Loader3D(); 
					loader.loadGeometry("assets/pg.md2", md2);
					loader.addEventListener(Loader3DEvent.LOAD_SUCCESS, onSuccess);
					
					/*
					loader.x = gap*i - amount*gap/2 + 100;
					loader.y = gap*j - amount*gap/2 + 200;
					loader.z = gap*k - amount*gap/2;
					*/
					view.scene.addChild(loader);
				/*}
			}
		}*/
		
		scene.rotationX = 30;
		
		//add signature
		Signature = Lib.as(SignatureSwf.content, Sprite);
		SignatureBitmap = new Bitmap(new BitmapData(Std.int(Signature.width), Std.int(Signature.height), true, 0));
		SignatureBitmap.y = stage.stageHeight - Signature.height;
		stage.quality = StageQuality.HIGH;
		SignatureBitmap.bitmapData.draw(Signature);
		stage.quality = StageQuality.MEDIUM;
		addChild(SignatureBitmap);
	}
	
	/**
	 * @inheritDoc
	 */
	override private function onPreRender():Void
	{
		scene.rotationX = (mouseX - stage.stageWidth / 2) / 5;
		scene.rotationZ = (mouseY - stage.stageHeight / 2) / 5;
		scene.rotationY++;
		view.render();
	}
}