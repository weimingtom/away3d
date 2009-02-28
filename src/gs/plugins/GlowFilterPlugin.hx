package gs.plugins;

import gs.TweenLite;
import flash.filters.GlowFilter;


class GlowFilterPlugin extends FilterPlugin  {
	
	public static inline var VERSION:Float = 1.0;
	//If the API/Framework for plugins changes in the future, this number helps determine compatibility
	public static inline var API:Float = 1.0;
	

	public function new() {
		
		
		super();
		this.propName = "glowFilter";
		this.overwriteProps = ["glowFilter"];
	}

	override public function onInitTween($target:Dynamic, $value:Dynamic, $tween:TweenLite):Bool {
		
		_target = $target;
		_type = GlowFilter;
		initFilter($value, new GlowFilter(0xFFFFFF, 0, 0, 0, ($value.strength > 0) ? $value.strength : 1, ($value.quality > 0) ? $value.quality : 2, $value.inner, $value.knockout));
		return true;
	}

}

