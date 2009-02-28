package gs.plugins;

import flash.display.MovieClip;
import gs.TweenLite;


class FramePlugin extends TweenPlugin  {
	public var changeFactor(null, setChangeFactor) : Float;
	
	public static inline var VERSION:Float = 1.0;
	//If the API/Framework for plugins changes in the future, this number helps determine compatibility
	public static inline var API:Float = 1.0;
	public var frame:Int;
	private var _target:MovieClip;
	

	public function new() {
		
		
		super();
		this.propName = "frame";
		this.overwriteProps = ["frame"];
		this.round = true;
	}

	override public function onInitTween($target:Dynamic, $value:Dynamic, $tween:TweenLite):Bool {
		
		if (!(Std.is($target, MovieClip)) || Math.isNaN($value)) {
			return false;
		}
		_target = cast($target, MovieClip);
		addTween(this, "frame", _target.currentFrame, $value, "frame");
		return true;
	}

	override public function setChangeFactor($n:Float):Float {
		
		updateTweens($n);
		_target.gotoAndStop(this.frame);
		return $n;
	}

}

