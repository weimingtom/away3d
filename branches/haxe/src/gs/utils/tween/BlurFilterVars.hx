package gs.utils.tween;



class BlurFilterVars extends FilterVars  {
	public var blurX(getBlurX, setBlurX) : Float;
	public var blurY(getBlurY, setBlurY) : Float;
	public var quality(getQuality, setQuality) : Int;
	
	private var _blurX:Float;
	private var _blurY:Float;
	private var _quality:Int;
	

	public function new(?$blurX:Float=10, ?$blurY:Float=10, ?$quality:Int=2, ?$remove:Bool=false, ?$index:Int=-1, ?$addFilter:Bool=false) {
		
		
		super($remove, $index, $addFilter);
		this.blurX = $blurX;
		this.blurY = $blurY;
		this.quality = $quality;
	}

	//for parsing values that are passed in as generic Objects, like blurFilter:{blurX:5, blurY:3} (typically via the constructor)
	public static function createFromGeneric($vars:Dynamic):BlurFilterVars {
		
		if (Std.is($vars, BlurFilterVars)) {
			return cast($vars, BlurFilterVars);
		}
		return new BlurFilterVars(($vars.blurX > 0) ? $vars.blurX : 0, ($vars.blurY > 0) ? $vars.blurY : 0, ($vars.quality > 0) ? $vars.quality : 2, $vars.remove || false, ($vars.index == null) ? -1 : $vars.index, $vars.addFilter || false);
	}

	//---- GETTERS / SETTERS ------------------------------------------------------------------------------
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

	public function setQuality($n:Int):Int {
		
		_quality = this.exposedVars.quality = $n;
		return $n;
	}

	public function getQuality():Int {
		
		return _quality;
	}

}

