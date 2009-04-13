package away3d.animators.utils;



class AWTweener  {
	
	

	function new() {
		
		
	}

	private static function tweenVal(t:Float, b:Float, endvalue:Float, d:Float, easeIn:Bool, easeOut:Bool):Float {
		
		var c:Float = endvalue - b;
		var pwease:Bool;
		if (!easeOut) {
			pwease = easeIn;
		} else if (easeIn) {
			pwease = easeOut;
			t = d - t;
			b = b + c;
			c = -c;
		} else {
			if (t < d * .5) {
				pwease = true;
			} else {
				pwease = true;
				t = d - t;
				b = b + c;
				c = -c;
			}
			c *= .5;
			d *= .5;
		}
		var diff:Float;
		if (pwease) {
			diff = Math.pow(t / d, 2);
		} else {
			diff = t / d;
		}
		return b + c * diff;
	}

	/**
	 * precalculates the numerical tween, returns steps as array
	 * 
	 * @param	 	fps						Number. Frame rate per second. Default = 30.
	 * @param	 	startval					Number. Start value. Default = 0.
	 * @param	 	endval					Number. End value. Default = 1.
	 * @param	 	duration					Number. Duration in millisec. Default = 250.
	 * @param	 	easeIn					Boolean. If the values are tweened with an ease in. Default = false.
	 * @param	 	easeOut					Boolean. If the values are tweened with an ease out. Default = false.
	 * 
	 * @return Array	Returns an array contatining the tweened values
	 */
	public static function calculate(?fps:Float=30, ?startval:Float=0, ?endval:Float=1, ?duration:Float=250, ?easeIn:Bool=false, ?easeOut:Bool=false):Array<Float> {
		
		var aTween:Array<Float> = new Array<Float>();
		var elapT:Float = fps;
		while (elapT < duration) {
			aTween.push(AWTweener.tweenVal(elapT, startval, endval, duration, easeIn, easeOut));
			elapT += fps;
		}

		aTween.push(endval);
		return aTween;
	}

}

