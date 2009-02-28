package gs.plugins;

import flash.media.SoundTransform;
import gs.TweenLite;


class VolumePlugin extends TweenPlugin  {
	public var changeFactor(null, setChangeFactor) : Float;
	
	public static inline var VERSION:Float = 1.0;
	//If the API/Framework for plugins changes in the future, this number helps determine compatibility
	public static inline var API:Float = 1.0;
	private var _target:Dynamic;
	private var _st:SoundTransform;
	

	public function new() {
		
		
		super();
		this.propName = "volume";
		this.overwriteProps = ["volume"];
	}

	override public function onInitTween($target:Dynamic, $value:Dynamic, $tween:TweenLite):Bool {
		
		if (Math.isNaN($value) || !Reflect.hasField($target, "soundTransform")) {
			return false;
		}
		_target = $target;
		_st = _target.soundTransform;
		addTween(_st, "volume", _st.volume, $value, "volume");
		return Boolean(_tweens.length != 0);
	}

	override public function setChangeFactor($n:Float):Float {
		
		updateTweens($n);
		_target.soundTransform = _st;
		return $n;
	}

}

