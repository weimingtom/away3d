package away3d.loaders.utils;

import flash.net.URLRequest;
import away3d.loaders.utils.TextureLoader;
import flash.display.Loader;


class LoaderAndRequest  {
	
	public var loader:TextureLoader;
	public var request:URLRequest;
	

	public function new(loader:TextureLoader, request:URLRequest) {
		
		
		this.loader = loader;
		this.request = request;
	}

}

