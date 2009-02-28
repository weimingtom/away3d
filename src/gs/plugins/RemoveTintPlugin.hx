package gs.plugins;

import flash.geom.ColorTransform;


class RemoveTintPlugin extends TintPlugin  {
	
	public static inline var VERSION:Float = 1.01;
	//If the API/Framework for plugins changes in the future, this number helps determine compatibility
	public static inline var API:Float = 1.0;
	

	public function new() {
		
		
		super();
		this.propName = "removeTint";
	}

}

