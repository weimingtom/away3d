package gs.plugins;

import gs.TweenLite;


class QuaternionsPlugin extends TweenPlugin  {
	public var changeFactor(null, setChangeFactor) : Float;
	
	public static inline var VERSION:Float = 1.0;
	//If the API/Framework for plugins changes in the future, this number helps determine compatibility
	public static inline var API:Float = 1.0;
	//precalculate for speed
	private static inline var _RAD2DEG:Float = 180 / Math.PI;
	private var _target:Dynamic;
	private var _quaternions:Array<Dynamic>;
	

	public function new() {
		this._quaternions = [];
		
		
		super();
		//name of the special property that the plugin should intercept/manage
		this.propName = "quaternions";
		this.overwriteProps = [];
	}

	override public function onInitTween($target:Dynamic, $value:Dynamic, $tween:TweenLite):Bool {
		
		if ($value == null) {
			return false;
		}
		var p:String;
		for (p in $value) {
			initQuaternion(Reflect.field($target, p), Reflect.field($value, p), p);
			
		}

		return true;
	}

	public function initQuaternion($start:Dynamic, $end:Dynamic, $propName:String):Void {
		
		var angle:Float;
		var q1:Dynamic;
		var q2:Dynamic;
		var x1:Float;
		var x2:Float;
		var y1:Float;
		var y2:Float;
		var z1:Float;
		var z2:Float;
		var w1:Float;
		var w2:Float;
		var theta:Float;
		q1 = $start;
		q2 = $end;
		x1 = q1.x;
		x2 = q2.x;
		y1 = q1.y;
		y2 = q2.y;
		z1 = q1.z;
		z2 = q2.z;
		w1 = q1.w;
		w2 = q2.w;
		angle = x1 * x2 + y1 * y2 + z1 * z2 + w1 * w2;
		if (angle < 0) {
			x1 *= -1;
			y1 *= -1;
			z1 *= -1;
			w1 *= -1;
			angle *= -1;
		}
		if ((angle + 1) < 0.000001) {
			y2 = -y1;
			x2 = x1;
			w2 = -w1;
			z2 = z1;
		}
		theta = Math.acos(angle);
		_quaternions[_quaternions.length] = [q1, $propName, x1, x2, y1, y2, z1, z2, w1, w2, angle, theta, 1 / Math.sin(theta)];
		this.overwriteProps[this.overwriteProps.length] = $propName;
	}

	override public function killProps($lookup:Dynamic):Void {
		
		var i:Int = _quaternions.length - 1;
		while (i > -1) {
			if (Reflect.field($lookup, _quaternions[i][1]) != undefined) {
				_quaternions.splice(i, 1);
			}
			
			// update loop variables
			i--;
		}

		super.killProps($lookup);
	}

	override public function setChangeFactor($n:Float):Float {
		
		var i:Int;
		var q:Array<Dynamic>;
		var scale:Float;
		var invScale:Float;
		i = _quaternions.length - 1;
		while (i > -1) {
			q = _quaternions[i];
			if ((q[10] + 1) > 0.000001) {
				if ((1 - q[10]) >= 0.000001) {
					scale = Math.sin(q[11] * (1 - $n)) * q[12];
					invScale = Math.sin(q[11] * $n) * q[12];
				} else {
					scale = 1 - $n;
					invScale = $n;
				}
			} else {
				scale = Math.sin(Math.PI * (0.5 - $n));
				invScale = Math.sin(Math.PI * $n);
			}
			q[0].x = scale * q[2] + invScale * q[3];
			q[0].y = scale * q[4] + invScale * q[5];
			q[0].z = scale * q[6] + invScale * q[7];
			q[0].w = scale * q[8] + invScale * q[9];
			
			// update loop variables
			i--;
		}

		/*
		 Array access is faster (though less readable). Here is the key:
		 0 - target
		 1 = propName
		 2 = x1
		 3 = x2
		 4 = y1
		 5 = y2
		 6 = z1
		 7 = z2
		 8 = w1
		 9 = w2
		 10 = angle
		 11 = theta
		 12 = invTheta
		 */
		
		return $n;
	}

}

