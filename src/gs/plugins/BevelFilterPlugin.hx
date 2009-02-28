package gs.plugins;

import flash.filters.BevelFilter;
import gs.TweenLite;


class BevelFilterPlugin extends FilterPlugin  {
	
	public static inline var VERSION:Float = 1.0;
	//If the API/Framework for plugins changes in the future, this number helps determine compatibility
	public static inline var API:Float = 1.0;
	

	public function new() {
		
		
		super();
		this.propName = "bevelFilter";
		this.overwriteProps = ["bevelFilter"];
	}

	override public function onInitTween($target:Dynamic, $value:Dynamic, $tween:TweenLite):Bool {
		
		_target = $target;
		_type = BevelFilter;
		initFilter($value, new BevelFilter(0, 0, 0xFFFFFF, 0.5, 0x000000, 0.5, 2, 2, 0, ($value.quality > 0) ? $value.quality : 2));
		return true;
	}

}

