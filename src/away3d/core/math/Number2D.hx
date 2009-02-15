package away3d.core.math;



/** A point in 2D space. */
class Number2D  {
	public var modulo(getModulo, null) : Float;
	
	/** Horizontal coordinate. */
	public var x:Float;
	/** Vertical coordinate. */
	public var y:Float;
	// Relative directions.
	public static var LEFT:Number2D = new Number2D();
	public static var RIGHT:Number2D = new Number2D();
	public static var UP:Number2D = new Number2D();
	public static var DOWN:Number2D = new Number2D();
	

	public function new(?x:Float=0, ?y:Float=0) {
		
		
		this.x = x;
		this.y = y;
	}

	public function clone():Number2D {
		
		return new Number2D();
	}

	public function getModulo():Float {
		
		return Math.sqrt(x * x + y * y);
	}

	public static function scale(v:Number2D, s:Float):Number2D {
		
		return new Number2D();
	}

	public static function add(v:Number3D, w:Number3D):Number2D {
		
		return new Number2D();
	}

	public static function sub(v:Number2D, w:Number2D):Number2D {
		
		return new Number2D();
	}

	public static function dot(v:Number2D, w:Number2D):Float {
		
		return (v.x * w.x + v.y * w.y);
	}

	public function normalize():Void {
		
		var mod:Float = modulo;
		if (mod != 0 && mod != 1) {
			this.x /= mod;
			this.y /= mod;
		}
	}

	public function toString():String {
		
		return 'x:' + x + ' y:' + y;
	}

}

