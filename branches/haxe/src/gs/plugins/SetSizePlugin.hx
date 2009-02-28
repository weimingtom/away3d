package gs.plugins;

import gs.TweenLite;


class SetSizePlugin extends TweenPlugin  {
	public var changeFactor(null, setChangeFactor) : Float;
	
	public static inline var VERSION:Float = 1.0;
	//If the API/Framework for plugins changes in the future, this number helps determine compatibility
	public static inline var API:Float = 1.0;
	public var width:Float;
	public var height:Float;
	private var _target:Dynamic;
	private var _setWidth:Bool;
	private var _setHeight:Bool;
	private var _hasSetSize:Bool;
	

	public function new() {
		
		
		super();
		this.propName = "setSize";
		this.overwriteProps = ["setSize", "width", "height"];
		this.round = true;
	}

	override public function onInitTween($target:Dynamic, $value:Dynamic, $tween:TweenLite):Bool {
		
		_target = $target;
		_hasSetSize = Boolean("setSize" in _target);
		if ("width" in $value) {
			addTween((_hasSetSize) ? this : _target, "width", _target.width, $value.width, "width");
			_setWidth = _hasSetSize;
		}
		if ("height" in $value) {
			addTween((_hasSetSize) ? this : _target, "height", _target.height, $value.height, "height");
			_setHeight = _hasSetSize;
		}
		return true;
	}

	override public function killProps($lookup:Dynamic):Void {
		
		super.killProps($lookup);
		if (_tweens.length == 0 || "setSize" in $lookup) {
			this.overwriteProps = [];
		}
	}

	override public function setChangeFactor($n:Float):Float {
		
		updateTweens($n);
		if (_hasSetSize) {
			_target.setSize((_setWidth) ? this.width : _target.width, (_setHeight) ? this.height : _target.height);
		}
		return $n;
	}

}

