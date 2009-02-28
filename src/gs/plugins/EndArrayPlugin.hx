package gs.plugins;

import gs.utils.tween.ArrayTweenInfo;
import gs.TweenLite;


class EndArrayPlugin extends TweenPlugin  {
	public var changeFactor(null, setChangeFactor) : Float;
	
	public static inline var VERSION:Float = 1.01;
	//If the API/Framework for plugins changes in the future, this number helps determine compatibility
	public static inline var API:Float = 1.0;
	private var _a:Array<Dynamic>;
	private var _info:Array<Dynamic>;
	

	public function new() {
		this._info = [];
		
		
		super();
		//name of the special property that the plugin should intercept/manage
		this.propName = "endArray";
		this.overwriteProps = ["endArray"];
	}

	override public function onInitTween($target:Dynamic, $value:Dynamic, $tween:TweenLite):Bool {
		
		if (!(Std.is($target, Array<Dynamic>)) || !(Std.is($value, Array<Dynamic>))) {
			return false;
		}
		init(cast($target, Array<Dynamic>), $value);
		return true;
	}

	public function init($start:Array<Dynamic>, $end:Array<Dynamic>):Void {
		
		_a = $start;
		var i:Int = $end.length - 1;
		while (i > -1) {
			if ($start[i] != $end[i] && $start[i] != null) {
				_info[_info.length] = new ArrayTweenInfo(i, _a[i], $end[i] - _a[i]);
			}
			
			// update loop variables
			i--;
		}

	}

	override public function setChangeFactor($n:Float):Float {
		
		var i:Int;
		var ti:ArrayTweenInfo;
		if (this.round) {
			var val:Float;
			var neg:Int;
			i = _info.length - 1;
			while (i > -1) {
				ti = _info[i];
				val = ti.start + (ti.change * $n);
				neg = (val < 0) ? -1 : 1;
				//twice as fast as Math.round()
				_a[ti.index] = ((val % 1) * neg > 0.5) ? Std.int(val) + neg : Std.int(val);
				
				// update loop variables
				i--;
			}

		} else {
			i = _info.length - 1;
			while (i > -1) {
				ti = _info[i];
				_a[ti.index] = ti.start + (ti.change * $n);
				
				// update loop variables
				i--;
			}

		}
		return $n;
	}

}

