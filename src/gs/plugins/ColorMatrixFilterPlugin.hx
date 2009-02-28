package gs.plugins;

import gs.TweenLite;
import flash.filters.ColorMatrixFilter;
import flash.filters.BitmapFilter;


class ColorMatrixFilterPlugin extends FilterPlugin  {
	public var changeFactor(null, setChangeFactor) : Float;
	
	public static inline var VERSION:Float = 1.01;
	//If the API/Framework for plugins changes in the future, this number helps determine compatibility
	public static inline var API:Float = 1.0;
	private static var _idMatrix:Array<Dynamic> = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
	//Red constant - used for a few color matrix filter functions
	private static var _lumR:Float = 0.212671;
	//Green constant - used for a few color matrix filter functions
	private static var _lumG:Float = 0.715160;
	//Blue constant - used for a few color matrix filter functions
	private static var _lumB:Float = 0.072169;
	private var _matrix:Array<Dynamic>;
	private var _matrixTween:EndArrayPlugin;
	

	public function new() {
		
		
		super();
		this.propName = "colorMatrixFilter";
		this.overwriteProps = ["colorMatrixFilter"];
	}

	override public function onInitTween($target:Dynamic, $value:Dynamic, $tween:TweenLite):Bool {
		
		_target = $target;
		_type = ColorMatrixFilter;
		var cmf:Dynamic = $value;
		initFilter({}, new ColorMatrixFilter(_idMatrix.slice()));
		_matrix = ColorMatrixFilter(_filter).matrix;
		var endMatrix:Array<Dynamic> = [];
		if (cmf.matrix != null && (Std.is(cmf.matrix, Array<Dynamic>))) {
			endMatrix = cmf.matrix;
		} else {
			if (cmf.relative == true) {
				endMatrix = _matrix.slice();
			} else {
				endMatrix = _idMatrix.slice();
			}
			endMatrix = setBrightness(endMatrix, cmf.brightness);
			endMatrix = setContrast(endMatrix, cmf.contrast);
			endMatrix = setHue(endMatrix, cmf.hue);
			endMatrix = setSaturation(endMatrix, cmf.saturation);
			endMatrix = setThreshold(endMatrix, cmf.threshold);
			if (!Math.isNaN(cmf.colorize)) {
				endMatrix = colorize(endMatrix, cmf.colorize, cmf.amount);
			}
		}
		_matrixTween = new EndArrayPlugin();
		_matrixTween.init(_matrix, endMatrix);
		return true;
	}

	override public function setChangeFactor($n:Float):Float {
		
		_matrixTween.changeFactor = $n;
		ColorMatrixFilter(_filter).matrix = _matrix;
		super.changeFactor = $n;
		return $n;
	}

	//---- MATRIX OPERATIONS --------------------------------------------------------------------------------
	public static function colorize($m:Array<Dynamic>, $color:Float, ?$amount:Float=1):Array<Dynamic> {
		
		if (Math.isNaN($color)) {
			return $m;
		} else if (Math.isNaN($amount)) {
			$amount = 1;
		}
		var r:Float = (($color >> 16) & 0xff) / 255;
		var g:Float = (($color >> 8) & 0xff) / 255;
		var b:Float = ($color & 0xff) / 255;
		var inv:Float = 1 - $amount;
		var temp:Array<Dynamic> = [inv + $amount * r * _lumR, $amount * r * _lumG, $amount * r * _lumB, 0, 0, $amount * g * _lumR, inv + $amount * g * _lumG, $amount * g * _lumB, 0, 0, $amount * b * _lumR, $amount * b * _lumG, inv + $amount * b * _lumB, 0, 0, 0, 0, 0, 1, 0];
		return applyMatrix(temp, $m);
	}

	public static function setThreshold($m:Array<Dynamic>, $n:Float):Array<Dynamic> {
		
		if (Math.isNaN($n)) {
			return $m;
		}
		var temp:Array<Dynamic> = [_lumR * 256, _lumG * 256, _lumB * 256, 0, -256 * $n, _lumR * 256, _lumG * 256, _lumB * 256, 0, -256 * $n, _lumR * 256, _lumG * 256, _lumB * 256, 0, -256 * $n, 0, 0, 0, 1, 0];
		return applyMatrix(temp, $m);
	}

	public static function setHue($m:Array<Dynamic>, $n:Float):Array<Dynamic> {
		
		if (Math.isNaN($n)) {
			return $m;
		}
		$n *= Math.PI / 180;
		var c:Float = Math.cos($n);
		var s:Float = Math.sin($n);
		var temp:Array<Dynamic> = [(_lumR + (c * (1 - _lumR))) + (s * (-_lumR)), (_lumG + (c * (-_lumG))) + (s * (-_lumG)), (_lumB + (c * (-_lumB))) + (s * (1 - _lumB)), 0, 0, (_lumR + (c * (-_lumR))) + (s * 0.143), (_lumG + (c * (1 - _lumG))) + (s * 0.14), (_lumB + (c * (-_lumB))) + (s * -0.283), 0, 0, (_lumR + (c * (-_lumR))) + (s * (-(1 - _lumR))), (_lumG + (c * (-_lumG))) + (s * _lumG), (_lumB + (c * (1 - _lumB))) + (s * _lumB), 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1];
		return applyMatrix(temp, $m);
	}

	public static function setBrightness($m:Array<Dynamic>, $n:Float):Array<Dynamic> {
		
		if (Math.isNaN($n)) {
			return $m;
		}
		$n = ($n * 100) - 100;
		return applyMatrix([1, 0, 0, 0, $n, 0, 1, 0, 0, $n, 0, 0, 1, 0, $n, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1], $m);
	}

	public static function setSaturation($m:Array<Dynamic>, $n:Float):Array<Dynamic> {
		
		if (Math.isNaN($n)) {
			return $m;
		}
		var inv:Float = 1 - $n;
		var r:Float = inv * _lumR;
		var g:Float = inv * _lumG;
		var b:Float = inv * _lumB;
		var temp:Array<Dynamic> = [r + $n, g, b, 0, 0, r, g + $n, b, 0, 0, r, g, b + $n, 0, 0, 0, 0, 0, 1, 0];
		return applyMatrix(temp, $m);
	}

	public static function setContrast($m:Array<Dynamic>, $n:Float):Array<Dynamic> {
		
		if (Math.isNaN($n)) {
			return $m;
		}
		$n += 0.01;
		var temp:Array<Dynamic> = [$n, 0, 0, 0, 128 * (1 - $n), 0, $n, 0, 0, 128 * (1 - $n), 0, 0, $n, 0, 128 * (1 - $n), 0, 0, 0, 1, 0];
		return applyMatrix(temp, $m);
	}

	public static function applyMatrix($m:Array<Dynamic>, $m2:Array<Dynamic>):Array<Dynamic> {
		
		if (!(Std.is($m, Array<Dynamic>)) || !(Std.is($m2, Array<Dynamic>))) {
			return $m2;
		}
		var temp:Array<Dynamic> = [];
		var i:Int = 0;
		var z:Int = 0;
		var y:Int;
		var x:Int;
		y = 0;
		while (y < 4) {
			x = 0;
			while (x < 5) {
				if (x == 4) {
					z = $m[i + 4];
				} else {
					z = 0;
				}
				temp[i + x] = $m[i] * $m2[x] + $m[i + 1] * $m2[x + 5] + $m[i + 2] * $m2[x + 10] + $m[i + 3] * $m2[x + 15] + z;
				
				// update loop variables
				x++;
			}

			i += 5;
			
			// update loop variables
			y++;
		}

		return temp;
	}

}

