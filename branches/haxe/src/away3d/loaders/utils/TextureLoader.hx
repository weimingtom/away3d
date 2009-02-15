package away3d.loaders.utils;

import flash.display.Loader;
import flash.net.URLRequest;
import flash.system.LoaderContext;


/**
 * Used to store the name and loader reference of an external texture image.
 */
class TextureLoader extends Loader  {
	public var filename(getFilename, null) : String;
	
	private var _filename:String;
	

	public function new() {
		
		
		super();
	}

	public function getFilename():String {
		
		return _filename;
	}

	override public function load(request:URLRequest, ?context:LoaderContext=null):Void {
		
		_filename = request.url;
		super.load(request, context);
	}

}

