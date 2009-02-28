package gs.plugins;

import gs.TweenLite;
import flash.display.DisplayObject;


class FastTransformPlugin extends TweenPlugin  {
	public var changeFactor(null, setChangeFactor) : Float;
	
	public static inline var VERSION:Float = 1.01;
	//If the API/Framework for plugins changes in the future, this number helps determine compatibility
	public static inline var API:Float = 1.0;
	private var _target:DisplayObject;
	private var xStart:Float;
	private var xChange:Float;
	private var yStart:Float;
	private var yChange:Float;
	private var widthStart:Float;
	private var widthChange:Float;
	private var heightStart:Float;
	private var heightChange:Float;
	private var scaleXStart:Float;
	private var scaleXChange:Float;
	private var scaleYStart:Float;
	private var scaleYChange:Float;
	private var rotationStart:Float;
	private var rotationChange:Float;
	

	public function new() {
		this.xChange = 0;
		this.yChange = 0;
		this.widthChange = 0;
		this.heightChange = 0;
		this.scaleXChange = 0;
		this.scaleYChange = 0;
		this.rotationChange = 0;
		
		
		super();
		this.propName = "fastTransform";
		this.overwriteProps = [];
	}

	override public function onInitTween($target:Dynamic, $value:Dynamic, $tween:TweenLite):Bool {
		
		_target = cast($target, DisplayObject);
		if ("x" in $value) {
			xStart = _target.x;
			xChange = (typeof($value.x) == "number") ? $value.x - _target.x : ($value.x);
			this.overwriteProps[this.overwriteProps.length] = "x";
		}
		if ("y" in $value) {
			yStart = _target.y;
			yChange = (typeof($value.y) == "number") ? $value.y - _target.y : ($value.y);
			this.overwriteProps[this.overwriteProps.length] = "y";
		}
		if ("width" in $value) {
			widthStart = _target.width;
			widthChange = (typeof($value.width) == "number") ? $value.width - _target.width : ($value.width);
			this.overwriteProps[this.overwriteProps.length] = "width";
		}
		if ("height" in $value) {
			heightStart = _target.height;
			heightChange = (typeof($value.height) == "number") ? $value.height - _target.height : ($value.height);
			this.overwriteProps[this.overwriteProps.length] = "height";
		}
		if ("scaleX" in $value) {
			scaleXStart = _target.scaleX;
			scaleXChange = (typeof($value.scaleX) == "number") ? $value.scaleX - _target.scaleX : ($value.scaleX);
			this.overwriteProps[this.overwriteProps.length] = "scaleX";
		}
		if ("scaleY" in $value) {
			scaleYStart = _target.scaleY;
			scaleYChange = (typeof($value.scaleY) == "number") ? $value.scaleY - _target.scaleY : ($value.scaleY);
			this.overwriteProps[this.overwriteProps.length] = "scaleY";
		}
		if ("rotation" in $value) {
			rotationStart = _target.rotation;
			rotationChange = (typeof($value.rotation) == "number") ? $value.rotation - _target.rotation : ($value.rotation);
			this.overwriteProps[this.overwriteProps.length] = "rotation";
		}
		return true;
	}

	override public function killProps($lookup:Dynamic):Void {
		
		var p:String;
		for (p in Reflect.fields($lookup)) {
			if (!Math.isNaN(this[p + "Change"])) {
				this[p + "Change"] = 0;
			}
			
		}

		super.killProps($lookup);
	}

	override public function setChangeFactor($n:Float):Float {
		
		if (xChange != 0) {
			_target.x = xStart + ($n * xChange);
		}
		if (yChange != 0) {
			_target.y = yStart + ($n * yChange);
		}
		if (widthChange != 0) {
			_target.width = widthStart + ($n * widthChange);
		}
		if (heightChange != 0) {
			_target.height = heightStart + ($n * heightChange);
		}
		if (scaleXChange != 0) {
			_target.scaleX = scaleXStart + ($n * scaleXChange);
		}
		if (scaleYChange != 0) {
			_target.scaleY = scaleYStart + ($n * scaleYChange);
		}
		if (rotationChange != 0) {
			_target.rotation = rotationStart + ($n * rotationChange);
		}
		return $n;
	}

}

