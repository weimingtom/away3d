package gs.plugins;

import gs.TweenLite;


class BezierThroughPlugin extends BezierPlugin  {
	
	public static inline var VERSION:Float = 1.0;
	//If the API/Framework for plugins changes in the future, this number helps determine compatibility
	public static inline var API:Float = 1.0;
	

	public function new() {
		
		
		super();
		//name of the special property that the plugin should intercept/manage
		this.propName = "bezierThrough";
	}

	override public function onInitTween($target:Dynamic, $value:Dynamic, $tween:TweenLite):Bool {
		
		if (!(Std.is($value, Array<Dynamic>))) {
			return false;
		}
		init($tween, cast($value, Array<Dynamic>), true);
		return true;
	}

}

