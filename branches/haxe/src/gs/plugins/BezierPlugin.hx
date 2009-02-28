package gs.plugins;

import gs.TweenLite;


class BezierPlugin extends TweenPlugin  {
	public var changeFactor(null, setChangeFactor) : Float;
	
	public static inline var VERSION:Float = 1.01;
	//If the API/Framework for plugins changes in the future, this number helps determine compatibility
	public static inline var API:Float = 1.0;
	//precalculate for speed
	private static inline var _RAD2DEG:Float = 180 / Math.PI;
	private var _target:Dynamic;
	private var _orientData:Array<Dynamic>;
	private var _orient:Bool;
	//used for orientToBezier projections
	private var _future:Dynamic;
	private var _beziers:Dynamic;
	

	public function new() {
		this._future = {};
		
		
		super();
		//name of the special property that the plugin should intercept/manage
		this.propName = "bezier";
		//will be populated in init()
		this.overwriteProps = [];
	}

	override public function onInitTween($target:Dynamic, $value:Dynamic, $tween:TweenLite):Bool {
		
		if (!(Std.is($value, Array<Dynamic>))) {
			return false;
		}
		init($tween, cast($value, Array<Dynamic>), false);
		return true;
	}

	private function init($tween:TweenLite, $beziers:Array<Dynamic>, $through:Bool):Void {
		
		_target = $tween.target;
		if ($tween.exposedVars.orientToBezier == true) {
			_orientData = [["x", "y", "rotation", 0]];
			_orient = true;
		} else if (Std.is($tween.exposedVars.orientToBezier, Array<Dynamic>)) {
			_orientData = $tween.exposedVars.orientToBezier;
			_orient = true;
		}
		var props:Dynamic = {};
		var i:Int;
		var p:String;
		i = 0;
		while (i < $beziers.length) {
			for (p in $beziers[i]) {
				if (Reflect.field(props, p) == undefined) {
					Reflect.setField(props, p, [Reflect.field($tween.target, p)]);
				}
				if (typeof($beziers[i][p]) == "number") {
					Reflect.field(props, p).push($beziers[i][p]);
				} else {
					Reflect.field(props, p).push(Reflect.field($tween.target, p) + ($beziers[i][p]));
				}
				
			}

			
			// update loop variables
			i++;
		}

		for (p in Reflect.fields(props)) {
			this.overwriteProps[this.overwriteProps.length] = p;
			if (Reflect.field($tween.exposedVars, p) != undefined) {
				if (typeof(Reflect.field($tween.exposedVars, p)) == "number") {
					Reflect.field(props, p).push(Reflect.field($tween.exposedVars, p));
				} else {
					Reflect.field(props, p).push(Reflect.field($tween.target, p) + (Reflect.field($tween.exposedVars, p)));
				}
				//prevent TweenLite from creating normal tweens of the bezier properties.
				Reflect.deleteField($tween.exposedVars, p);
				i = $tween.tweens.length - 1;
				while (i > -1) {
					if ($tween.tweens[i].name == p) {
						$tween.tweens.splice(i, 1);
					}
					
					// update loop variables
					i--;
				}

			}
			
		}

		_beziers = parseBeziers(props, $through);
	}

	//$props object should contain a property for each one you'd like bezier paths for. Each property should contain a single Array with the numeric point values (i.e. props.x = [12,50,80] and props.y = [50,97,158]). It'll return a new object with an array of values for each property. The first element in the array  is the start value, the second is the control point, and the 3rd is the end value. (i.e. returnObject.x = [[12, 32, 50}, [50, 65, 80]])
	public static function parseBeziers($props:Dynamic, ?$through:Bool=false):Dynamic {
		
		var i:Int;
		var a:Array<Dynamic>;
		var b:Dynamic;
		var p:String;
		var all:Dynamic = {};
		if ($through) {
			for (p in Reflect.fields($props)) {
				a = Reflect.field($props, p);
				Reflect.setField(all, p, b = []);
				if (a.length > 2) {
					Reflect.setField(b, b.length, [a[0], a[1] - ((a[2] - a[0]) / 4), a[1]]);
					i = 1;
					while (i < a.length - 1) {
						Reflect.setField(b, b.length, [a[i], a[i] + (a[i] - Reflect.field(b, i - 1)[1]), a[i + 1]]);
						
						// update loop variables
						i++;
					}

				} else {
					Reflect.setField(b, b.length, [a[0], (a[0] + a[1]) / 2, a[1]]);
				}
				
			}

		} else {
			for (p in Reflect.fields($props)) {
				a = Reflect.field($props, p);
				Reflect.setField(all, p, b = []);
				if (a.length > 3) {
					Reflect.setField(b, b.length, [a[0], a[1], (a[1] + a[2]) / 2]);
					i = 2;
					while (i < a.length - 2) {
						Reflect.setField(b, b.length, [Reflect.field(b, i - 2)[2], a[i], (a[i] + a[i + 1]) / 2]);
						
						// update loop variables
						i++;
					}

					Reflect.setField(b, b.length, [Reflect.field(b, b.length - 1)[2], a[a.length - 2], a[a.length - 1]]);
				} else if (a.length == 3) {
					Reflect.setField(b, b.length, [a[0], a[1], a[2]]);
				} else if (a.length == 2) {
					Reflect.setField(b, b.length, [a[0], (a[0] + a[1]) / 2, a[1]]);
				}
				
			}

		}
		return all;
	}

	override public function killProps($lookup:Dynamic):Void {
		
		var p:String;
		for (p in Reflect.fields(_beziers)) {
			if (p in $lookup) {
				Reflect.deleteField(_beziers, p);
			}
			
		}

		super.killProps($lookup);
	}

	override public function setChangeFactor($n:Float):Float {
		
		var i:Int;
		var p:String;
		var b:Dynamic;
		var t:Float;
		var segments:Int;
		var val:Float;
		var neg:Int;
		//to make sure the end values are EXACTLY what they need to be.
		if ($n == 1) {
			for (p in Reflect.fields(_beziers)) {
				i = Reflect.field(_beziers, p).length - 1;
				Reflect.setField(_target, p, Reflect.field(_beziers, p)[i][2]);
				
			}

		} else {
			for (p in Reflect.fields(_beziers)) {
				segments = Reflect.field(_beziers, p).length;
				if ($n < 0) {
					i = 0;
				} else if ($n >= 1) {
					i = segments - 1;
				} else {
					i = Std.int(segments * $n);
				}
				t = ($n - (i * (1 / segments))) * segments;
				b = Reflect.field(_beziers, p)[i];
				if (this.round) {
					val = Reflect.field(b, 0) + t * (2 * (1 - t) * (Reflect.field(b, 1) - Reflect.field(b, 0)) + t * (Reflect.field(b, 2) - Reflect.field(b, 0)));
					neg = (val < 0) ? -1 : 1;
					//twice as fast as Math.round()
					Reflect.setField(_target, p, ((val % 1) * neg > 0.5) ? Std.int(val) + neg : Std.int(val));
				} else {
					Reflect.setField(_target, p, Reflect.field(b, 0) + t * (2 * (1 - t) * (Reflect.field(b, 1) - Reflect.field(b, 0)) + t * (Reflect.field(b, 2) - Reflect.field(b, 0))));
				}
				
			}

		}
		if (_orient) {
			var oldTarget:Dynamic = _target;
			var oldRound:Bool = this.round;
			_target = _future;
			this.round = false;
			_orient = false;
			this.changeFactor = $n + 0.01;
			_target = oldTarget;
			this.round = oldRound;
			_orient = true;
			var dx:Float;
			var dy:Float;
			var cotb:Array<Dynamic>;
			var toAdd:Float;
			i = 0;
			while (i < _orientData.length) {
				cotb = _orientData[i];
				toAdd = (cotb[3] > 0) ? cotb[3] : 0;
				dx = Reflect.field(_future, cotb[0]) - Reflect.field(_target, cotb[0]);
				dy = Reflect.field(_future, cotb[1]) - Reflect.field(_target, cotb[1]);
				Reflect.setField(_target, cotb[2], Math.atan2(dy, dx) * _RAD2DEG + toAdd);
				
				// update loop variables
				i++;
			}

		}
		return $n;
	}

}

