package gs.plugins;

import gs.TweenLite;


class AutoAlphaPlugin extends TweenPlugin  {
	public var changeFactor(null, setChangeFactor) : Float;
	
	public static inline var VERSION:Float = 1.0;
	//If the API/Framework for plugins changes in the future, this number helps determine compatibility
	public static inline var API:Float = 1.0;
	private var _tweenVisible:Bool;
	private var _visible:Bool;
	private var _tween:TweenLite;
	private var _target:Dynamic;
	

	public function new() {
		
		OPPOSITE_OR[X | X] = N;
		OPPOSITE_OR[XY | X] = Y;
		OPPOSITE_OR[XZ | X] = Z;
		OPPOSITE_OR[XYZ | X] = YZ;
		OPPOSITE_OR[Y | Y] = N;
		OPPOSITE_OR[XY | Y] = X;
		OPPOSITE_OR[XYZ | Y] = XZ;
		OPPOSITE_OR[YZ | Y] = Z;
		OPPOSITE_OR[Z | Z] = N;
		OPPOSITE_OR[XZ | Z] = X;
		OPPOSITE_OR[XYZ | Z] = XY;
		OPPOSITE_OR[YZ | Z] = Y;
		SCALINGS[1] = [1, 1, 1];
		SCALINGS[2] = [-1, 1, 1];
		SCALINGS[4] = [-1, 1, -1];
		SCALINGS[8] = [1, 1, -1];
		SCALINGS[16] = [1, -1, 1];
		SCALINGS[32] = [-1, -1, 1];
		SCALINGS[64] = [-1, -1, -1];
		SCALINGS[128] = [1, -1, -1];
		
		super();
		this.propName = "autoAlpha";
		this.overwriteProps = ["alpha", "visible"];
		this.onComplete = onCompleteTween;
	}

	override public function onInitTween($target:Dynamic, $value:Dynamic, $tween:TweenLite):Bool {
		
		_target = $target;
		_tween = $tween;
		_visible = Boolean($value != 0);
		_tweenVisible = true;
		addTween($target, "alpha", $target.alpha, $value, "alpha");
		return true;
	}

	override public function killProps($lookup:Dynamic):Void {
		
		super.killProps($lookup);
		_tweenVisible = !Boolean("visible" in $lookup);
	}

	public function onCompleteTween():Void {
		//_tween.ease == _tween.vars.ease checks to make sure the tween wasn't reversed with a TweenGroup
		
		if (_tweenVisible && _tween.vars.runBackwards != true && _tween.ease == _tween.vars.ease) {
			_target.visible = _visible;
		}
	}

	override public function setChangeFactor($n:Float):Float {
		
		updateTweens($n);
		if (_target.visible != true && _tweenVisible) {
			_target.visible = true;
		}
		return $n;
	}

}

