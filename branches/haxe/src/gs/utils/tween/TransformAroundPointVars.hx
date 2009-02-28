package gs.utils.tween;

import flash.geom.Point;


class TransformAroundPointVars extends SubVars  {
	public var point(getPoint, setPoint) : Point;
	public var scaleX(getScaleX, setScaleX) : Float;
	public var scaleY(getScaleY, setScaleY) : Float;
	public var scale(getScale, setScale) : Float;
	public var rotation(getRotation, setRotation) : Float;
	public var width(getWidth, setWidth) : Float;
	public var height(getHeight, setHeight) : Float;
	public var shortRotation(getShortRotation, setShortRotation) : Dynamic;
	public var x(getX, setX) : Float;
	public var y(getY, setY) : Float;
	
	

	public function new(?$point:Point=null, ?$scaleX:Float=Math.NaN, ?$scaleY:Float=Math.NaN, ?$rotation:Float=Math.NaN, ?$width:Float=Math.NaN, ?$height:Float=Math.NaN, ?$shortRotation:Dynamic=null, ?$x:Float=Math.NaN, ?$y:Float=Math.NaN) {
		
		
		super();
		if ($point != null) {
			this.point = $point;
		}
		if (!Math.isNaN($scaleX)) {
			this.scaleX = $scaleX;
		}
		if (!Math.isNaN($scaleY)) {
			this.scaleY = $scaleY;
		}
		if (!Math.isNaN($rotation)) {
			this.rotation = $rotation;
		}
		if (!Math.isNaN($width)) {
			this.width = $width;
		}
		if (!Math.isNaN($height)) {
			this.height = $height;
		}
		if ($shortRotation != null) {
			this.shortRotation = $shortRotation;
		}
		if (!Math.isNaN($x)) {
			this.x = $x;
		}
		if (!Math.isNaN($y)) {
			this.y = $y;
		}
	}

	//for parsing values that are passed in as generic Objects, like blurFilter:{blurX:5, blurY:3} (typically via the constructor)
	public static function createFromGeneric($vars:Dynamic):TransformAroundPointVars {
		
		if (Std.is($vars, TransformAroundPointVars)) {
			return cast($vars, TransformAroundPointVars);
		}
		return new TransformAroundPointVars($vars.point, $vars.scaleX, $vars.scaleY, $vars.rotation, $vars.width, $vars.height, $vars.shortRotation, $vars.x, $vars.y);
	}

	//---- GETTERS / SETTERS ------------------------------------------------------------------------------
	public function setPoint($p:Point):Point {
		
		this.exposedVars.point = $p;
		return $p;
	}

	public function getPoint():Point {
		
		return this.exposedVars.point;
	}

	public function setScaleX($n:Float):Float {
		
		this.exposedVars.scaleX = $n;
		return $n;
	}

	public function getScaleX():Float {
		
		return (this.exposedVars.scaleX);
	}

	public function setScaleY($n:Float):Float {
		
		this.exposedVars.scaleY = $n;
		return $n;
	}

	public function getScaleY():Float {
		
		return (this.exposedVars.scaleY);
	}

	public function setScale($n:Float):Float {
		
		this.exposedVars.scale = $n;
		return $n;
	}

	public function getScale():Float {
		
		return (this.exposedVars.scale);
	}

	public function setRotation($n:Float):Float {
		
		this.exposedVars.rotation = $n;
		return $n;
	}

	public function getRotation():Float {
		
		return (this.exposedVars.rotation);
	}

	public function setWidth($n:Float):Float {
		
		this.exposedVars.width = $n;
		return $n;
	}

	public function getWidth():Float {
		
		return (this.exposedVars.width);
	}

	public function setHeight($n:Float):Float {
		
		this.exposedVars.height = $n;
		return $n;
	}

	public function getHeight():Float {
		
		return (this.exposedVars.height);
	}

	public function setShortRotation($o:Dynamic):Dynamic {
		
		this.exposedVars.shortRotation = $o;
		return $o;
	}

	public function getShortRotation():Dynamic {
		
		return this.exposedVars.shortRotation;
	}

	public function setX($n:Float):Float {
		
		this.exposedVars.x = $n;
		return $n;
	}

	public function getX():Float {
		
		return (this.exposedVars.x);
	}

	public function setY($n:Float):Float {
		
		this.exposedVars.y = $n;
		return $n;
	}

	public function getY():Float {
		
		return (this.exposedVars.y);
	}

}

