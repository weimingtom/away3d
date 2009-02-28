package gs.plugins;

import flash.filters.DropShadowFilter;
import gs.TweenLite;


class DropShadowFilterPlugin extends FilterPlugin  {
	
	public static inline var VERSION:Float = 1.0;
	//If the API/Framework for plugins changes in the future, this number helps determine compatibility
	public static inline var API:Float = 1.0;
	

	public function new() {
		
		
		super();
		this.propName = "dropShadowFilter";
		this.overwriteProps = ["dropShadowFilter"];
	}

	override public function onInitTween($target:Dynamic, $value:Dynamic, $tween:TweenLite):Bool {
		
		_target = $target;
		_type = DropShadowFilter;
		initFilter($value, new DropShadowFilter(0, 45, 0x000000, 0, 0, 0, 1, ($value.quality > 0) ? $value.quality : 2, $value.inner, $value.knockout, $value.hideObject));
		return true;
	}

}

