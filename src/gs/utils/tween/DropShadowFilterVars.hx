package gs.utils.tween;



class DropShadowFilterVars extends FilterVars  {
	public var distance(getDistance, setDistance) : Float;
	public var blurX(getBlurX, setBlurX) : Float;
	public var blurY(getBlurY, setBlurY) : Float;
	public var alpha(getAlpha, setAlpha) : Float;
	public var angle(getAngle, setAngle) : Float;
	public var color(getColor, setColor) : Int;
	public var strength(getStrength, setStrength) : Float;
	public var inner(getInner, setInner) : Bool;
	public var knockout(getKnockout, setKnockout) : Bool;
	public var hideObject(getHideObject, setHideObject) : Bool;
	public var quality(getQuality, setQuality) : Int;
	
	private var _distance:Float;
	private var _blurX:Float;
	private var _blurY:Float;
	private var _alpha:Float;
	private var _angle:Float;
	private var _color:Int;
	private var _strength:Float;
	private var _inner:Bool;
	private var _knockout:Bool;
	private var _hideObject:Bool;
	private var _quality:Int;
	

	public function new(?$distance:Float=4, ?$blurX:Float=4, ?$blurY:Float=4, ?$alpha:Float=1, ?$angle:Float=45, ?$color:Int=0x000000, ?$strength:Float=2, ?$inner:Bool=false, ?$knockout:Bool=false, ?$hideObject:Bool=false, ?$quality:Int=2, ?$remove:Bool=false, ?$index:Int=-1, ?$addFilter:Bool=false) {
		
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
		
		super($remove, $index, $addFilter);
		this.distance = $distance;
		this.blurX = $blurX;
		this.blurY = $blurY;
		this.alpha = $alpha;
		this.angle = $angle;
		this.color = $color;
		this.strength = $strength;
		this.inner = $inner;
		this.knockout = $knockout;
		this.hideObject = $hideObject;
		this.quality = $quality;
	}

	//for parsing values that are passed in as generic Objects, like blurFilter:{blurX:5, blurY:3} (typically via the constructor)
	public static function createFromGeneric($vars:Dynamic):DropShadowFilterVars {
		
		if (Std.is($vars, DropShadowFilterVars)) {
			return cast($vars, DropShadowFilterVars);
		}
		return new DropShadowFilterVars(($vars.distance > 0) ? $vars.distance : 0, ($vars.blurX > 0) ? $vars.blurX : 0, ($vars.blurY > 0) ? $vars.blurY : 0, ($vars.alpha > 0) ? $vars.alpha : 0, ($vars.angle == null) ? 45 : $vars.angle, ($vars.color == null) ? 0x000000 : $vars.color, ($vars.strength == null) ? 2 : $vars.strength, Boolean($vars.inner), Boolean($vars.knockout), Boolean($vars.hideObject), ($vars.quality > 0) ? $vars.quality : 2, $vars.remove || false, ($vars.index == null) ? -1 : $vars.index, $vars.addFilter);
	}

	//---- GETTERS / SETTERS --------------------------------------------------------------------------------------------
	public function setDistance($n:Float):Float {
		
		_distance = this.exposedVars.distance = $n;
		return $n;
	}

	public function getDistance():Float {
		
		return _distance;
	}

	public function setBlurX($n:Float):Float {
		
		_blurX = this.exposedVars.blurX = $n;
		return $n;
	}

	public function getBlurX():Float {
		
		return _blurX;
	}

	public function setBlurY($n:Float):Float {
		
		_blurY = this.exposedVars.blurY = $n;
		return $n;
	}

	public function getBlurY():Float {
		
		return _blurY;
	}

	public function setAlpha($n:Float):Float {
		
		_alpha = this.exposedVars.alpha = $n;
		return $n;
	}

	public function getAlpha():Float {
		
		return _alpha;
	}

	public function setAngle($n:Float):Float {
		
		_angle = this.exposedVars.angle = $n;
		return $n;
	}

	public function getAngle():Float {
		
		return _angle;
	}

	public function setColor($n:Int):Int {
		
		_color = this.exposedVars.color = $n;
		return $n;
	}

	public function getColor():Int {
		
		return _color;
	}

	public function setStrength($n:Float):Float {
		
		_strength = this.exposedVars.strength = $n;
		return $n;
	}

	public function getStrength():Float {
		
		return _strength;
	}

	public function setInner($b:Bool):Bool {
		
		_inner = this.exposedVars.inner = $b;
		return $b;
	}

	public function getInner():Bool {
		
		return _inner;
	}

	public function setKnockout($b:Bool):Bool {
		
		_knockout = this.exposedVars.knockout = $b;
		return $b;
	}

	public function getKnockout():Bool {
		
		return _knockout;
	}

	public function setHideObject($b:Bool):Bool {
		
		_hideObject = this.exposedVars.hideObject = $b;
		return $b;
	}

	public function getHideObject():Bool {
		
		return _hideObject;
	}

	public function setQuality($n:Int):Int {
		
		_quality = this.exposedVars.quality = $n;
		return $n;
	}

	public function getQuality():Int {
		
		return _quality;
	}

}

