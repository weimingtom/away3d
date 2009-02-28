package gs.plugins;

import flash.geom.ColorTransform;
import gs.utils.tween.TweenInfo;
import gs.TweenLite;
import flash.display.DisplayObject;


class TintPlugin extends TweenPlugin  {
	public var changeFactor(null, setChangeFactor) : Float;
	
	public static inline var VERSION:Float = 1.01;
	//If the API/Framework for plugins changes in the future, this number helps determine compatibility
	public static inline var API:Float = 1.0;
	private static var _props:Array<Dynamic> = ["redMultiplier", "greenMultiplier", "blueMultiplier", "alphaMultiplier", "redOffset", "greenOffset", "blueOffset", "alphaOffset"];
	private var _target:DisplayObject;
	private var _ct:ColorTransform;
	

	public function new() {
		
		
		super();
		this.propName = "tint";
		this.overwriteProps = ["tint"];
	}

	override public function onInitTween($target:Dynamic, $value:Dynamic, $tween:TweenLite):Bool {
		
		if (!(Std.is($target, DisplayObject))) {
			return false;
		}
		var end:ColorTransform = new ColorTransform();
		if ($value != null && $tween.exposedVars.removeTint != true) {
			end.color = Std.int($value);
		}
		if ($tween.exposedVars.alpha != undefined || $tween.exposedVars.autoAlpha != undefined) {
			end.alphaMultiplier = ($tween.exposedVars.alpha != undefined) ? $tween.exposedVars.alpha : $tween.exposedVars.autoAlpha;
			$tween.killVars({alpha:1, autoAlpha:1});
		} else {
			end.alphaMultiplier = $target.alpha;
		}
		init(cast($target, DisplayObject), end);
		return true;
	}

	public function init($target:DisplayObject, $end:ColorTransform):Void {
		
		_target = $target;
		_ct = _target.transform.colorTransform;
		var i:Int;
		var p:String;
		i = _props.length - 1;
		while (i > -1) {
			p = _props[i];
			if (Reflect.field(_ct, p) != Reflect.field($end, p)) {
				_tweens[_tweens.length] = new TweenInfo(_ct, p, Reflect.field(_ct, p), Reflect.field($end, p) - Reflect.field(_ct, p), "tint", false);
			}
			
			// update loop variables
			i--;
		}

	}

	override public function setChangeFactor($n:Float):Float {
		
		updateTweens($n);
		_target.transform.colorTransform = _ct;
		return $n;
	}

}

