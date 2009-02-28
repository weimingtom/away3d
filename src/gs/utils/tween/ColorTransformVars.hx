package gs.utils.tween;



class ColorTransformVars extends SubVars  {
	public var tint(getTint, setTint) : Float;
	public var tintAmount(getTintAmount, setTintAmount) : Float;
	public var exposure(getExposure, setExposure) : Float;
	public var brightness(getBrightness, setBrightness) : Float;
	public var redMultiplier(getRedMultiplier, setRedMultiplier) : Float;
	public var greenMultiplier(getGreenMultiplier, setGreenMultiplier) : Float;
	public var blueMultiplier(getBlueMultiplier, setBlueMultiplier) : Float;
	public var alphaMultiplier(getAlphaMultiplier, setAlphaMultiplier) : Float;
	public var redOffset(getRedOffset, setRedOffset) : Float;
	public var greenOffset(getGreenOffset, setGreenOffset) : Float;
	public var blueOffset(getBlueOffset, setBlueOffset) : Float;
	public var alphaOffset(getAlphaOffset, setAlphaOffset) : Float;
	
	

	public function new(?$tint:Float=Math.NaN, ?$tintAmount:Float=Math.NaN, ?$exposure:Float=Math.NaN, ?$brightness:Float=Math.NaN, ?$redMultiplier:Float=Math.NaN, ?$greenMultiplier:Float=Math.NaN, ?$blueMultiplier:Float=Math.NaN, ?$alphaMultiplier:Float=Math.NaN, ?$redOffset:Float=Math.NaN, ?$greenOffset:Float=Math.NaN, ?$blueOffset:Float=Math.NaN, ?$alphaOffset:Float=Math.NaN) {
		
		
		super();
		if (!Math.isNaN($tint)) {
			this.tint = Std.int($tint);
		}
		if (!Math.isNaN($tintAmount)) {
			this.tintAmount = $tintAmount;
		}
		if (!Math.isNaN($exposure)) {
			this.exposure = $exposure;
		}
		if (!Math.isNaN($brightness)) {
			this.brightness = $brightness;
		}
		if (!Math.isNaN($redMultiplier)) {
			this.redMultiplier = $redMultiplier;
		}
		if (!Math.isNaN($greenMultiplier)) {
			this.greenMultiplier = $greenMultiplier;
		}
		if (!Math.isNaN($blueMultiplier)) {
			this.blueMultiplier = $blueMultiplier;
		}
		if (!Math.isNaN($alphaMultiplier)) {
			this.alphaMultiplier = $alphaMultiplier;
		}
		if (!Math.isNaN($redOffset)) {
			this.redOffset = $redOffset;
		}
		if (!Math.isNaN($greenOffset)) {
			this.greenOffset = $greenOffset;
		}
		if (!Math.isNaN($blueOffset)) {
			this.blueOffset = $blueOffset;
		}
		if (!Math.isNaN($alphaOffset)) {
			this.alphaOffset = $alphaOffset;
		}
	}

	//for parsing values that are passed in as generic Objects, like blurFilter:{blurX:5, blurY:3} (typically via the constructor)
	public static function createFromGeneric($vars:Dynamic):ColorTransformVars {
		
		if (Std.is($vars, ColorTransformVars)) {
			return cast($vars, ColorTransformVars);
		}
		return new ColorTransformVars($vars.tint, $vars.tintAmount, $vars.exposure, $vars.brightness, $vars.redMultiplier, $vars.greenMultiplier, $vars.blueMultiplier, $vars.alphaMultiplier, $vars.redOffset, $vars.greenOffset, $vars.blueOffset, $vars.alphaOffset);
	}

	//---- GETTERS / SETTERS ------------------------------------------------------------------------------
	public function setTint($n:Float):Float {
		
		this.exposedVars.tint = $n;
		return $n;
	}

	public function getTint():Float {
		
		return (this.exposedVars.tint);
	}

	public function setTintAmount($n:Float):Float {
		
		this.exposedVars.tintAmount = $n;
		return $n;
	}

	public function getTintAmount():Float {
		
		return (this.exposedVars.tintAmount);
	}

	public function setExposure($n:Float):Float {
		
		this.exposedVars.exposure = $n;
		return $n;
	}

	public function getExposure():Float {
		
		return (this.exposedVars.exposure);
	}

	public function setBrightness($n:Float):Float {
		
		this.exposedVars.brightness = $n;
		return $n;
	}

	public function getBrightness():Float {
		
		return (this.exposedVars.brightness);
	}

	public function setRedMultiplier($n:Float):Float {
		
		this.exposedVars.redMultiplier = $n;
		return $n;
	}

	public function getRedMultiplier():Float {
		
		return (this.exposedVars.redMultiplier);
	}

	public function setGreenMultiplier($n:Float):Float {
		
		this.exposedVars.greenMultiplier = $n;
		return $n;
	}

	public function getGreenMultiplier():Float {
		
		return (this.exposedVars.greenMultiplier);
	}

	public function setBlueMultiplier($n:Float):Float {
		
		this.exposedVars.blueMultiplier = $n;
		return $n;
	}

	public function getBlueMultiplier():Float {
		
		return (this.exposedVars.blueMultiplier);
	}

	public function setAlphaMultiplier($n:Float):Float {
		
		this.exposedVars.alphaMultiplier = $n;
		return $n;
	}

	public function getAlphaMultiplier():Float {
		
		return (this.exposedVars.alphaMultiplier);
	}

	public function setRedOffset($n:Float):Float {
		
		this.exposedVars.redOffset = $n;
		return $n;
	}

	public function getRedOffset():Float {
		
		return (this.exposedVars.redOffset);
	}

	public function setGreenOffset($n:Float):Float {
		
		this.exposedVars.greenOffset = $n;
		return $n;
	}

	public function getGreenOffset():Float {
		
		return (this.exposedVars.greenOffset);
	}

	public function setBlueOffset($n:Float):Float {
		
		this.exposedVars.blueOffset = $n;
		return $n;
	}

	public function getBlueOffset():Float {
		
		return (this.exposedVars.blueOffset);
	}

	public function setAlphaOffset($n:Float):Float {
		
		this.exposedVars.alphaOffset = $n;
		return $n;
	}

	public function getAlphaOffset():Float {
		
		return (this.exposedVars.alphaOffset);
	}

}

