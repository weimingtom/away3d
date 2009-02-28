package gs.plugins;

import gs.TweenLite;


class HexColorsPlugin extends TweenPlugin  {
	public var changeFactor(null, setChangeFactor) : Float;
	
	public static inline var VERSION:Float = 1.0;
	//If the API/Framework for plugins changes in the future, this number helps determine compatibility
	public static inline var API:Float = 1.0;
	private var _colors:Array<Dynamic>;
	

	public function new() {
		
		
		super();
		this.propName = "hexColors";
		this.overwriteProps = [];
	}

	override public function onInitTween($target:Dynamic, $value:Dynamic, $tween:TweenLite):Bool {
		
		var p:String;
		for (p in $value) {
			initColor($target, p, Std.int(Reflect.field($target, p)), Std.int(Reflect.field($value, p)));
			
		}

		return true;
	}

	public function initColor($target:Dynamic, $propName:String, $start:Int, $end:Int):Void {
		
		if ($start != $end) {
			if (_colors == null) {
				_colors = [];
			}
			var r:Float = $start >> 16;
			var g:Float = ($start >> 8) & 0xff;
			var b:Float = $start & 0xff;
			_colors[_colors.length] = [$target, $propName, r, ($end >> 16) - r, g, (($end >> 8) & 0xff) - g, b, ($end & 0xff) - b];
			this.overwriteProps[this.overwriteProps.length] = $propName;
		}
	}

	override public function killProps($lookup:Dynamic):Void {
		
		var i:Int = _colors.length - 1;
		while (i > -1) {
			if (Reflect.field($lookup, _colors[i][1]) != undefined) {
				_colors.splice(i, 1);
			}
			
			// update loop variables
			i--;
		}

		super.killProps($lookup);
	}

	override public function setChangeFactor($n:Float):Float {
		
		var i:Int;
		var a:Array<Dynamic>;
		i = _colors.length - 1;
		while (i > -1) {
			a = _colors[i];
			a[0][a[1]] = ((a[2] + ($n * a[3])) << 16 | (a[4] + ($n * a[5])) << 8 | (a[6] + ($n * a[7])));
			
			// update loop variables
			i--;
		}

		return $n;
	}

}

