package gs.plugins;

import flash.filters.BlurFilter;
import gs.TweenLite;


class BlurFilterPlugin extends FilterPlugin  {
	
	public static inline var VERSION:Float = 1.0;
	//If the API/Framework for plugins changes in the future, this number helps determine compatibility
	public static inline var API:Float = 1.0;
	

	public function new() {
		
		
		super();
		this.propName = "blurFilter";
		this.overwriteProps = ["blurFilter"];
	}

	override public function onInitTween($target:Dynamic, $value:Dynamic, $tween:TweenLite):Bool {
		
		_target = $target;
		_type = BlurFilter;
		initFilter($value, new BlurFilter(0, 0, ($value.quality > 0) ? $value.quality : 2));
		return true;
	}

}

