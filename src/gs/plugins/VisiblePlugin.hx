package gs.plugins;

import gs.TweenLite;


class VisiblePlugin extends TweenPlugin  {
	public var changeFactor(null, setChangeFactor) : Float;
	
	public static inline var VERSION:Float = 1.0;
	//If the API/Framework for plugins changes in the future, this number helps determine compatibility
	public static inline var API:Float = 1.0;
	private var _target:Dynamic;
	private var _tween:TweenLite;
	private var _visible:Bool;
	

	public function new() {
		
		
		super();
		this.propName = "visible";
		this.overwriteProps = ["visible"];
		this.onComplete = onCompleteTween;
	}

	override public function onInitTween($target:Dynamic, $value:Dynamic, $tween:TweenLite):Bool {
		
		_target = $target;
		_tween = $tween;
		_visible = Boolean($value);
		return true;
	}

	public function onCompleteTween():Void {
		//_tween.ease == _tween.vars.ease checks to make sure the tween wasn't reversed with a TweenGroup
		
		if (_tween.vars.runBackwards != true && _tween.ease == _tween.vars.ease) {
			_target.visible = _visible;
		}
	}

	override public function setChangeFactor($n:Float):Float {
		
		if (_target.visible != true) {
			_target.visible = true;
		}
		return $n;
	}

}

