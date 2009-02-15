package gs.utils.tween;

import gs.TweenLite;


class TweenLiteVars  {
	public var exposedVars(getExposedVars, null) : Dynamic;
	public var autoAlpha(getAutoAlpha, setAutoAlpha) : Float;
	public var endArray(getEndArray, setEndArray) : Array<Dynamic>;
	public var removeTint(getRemoveTint, setRemoveTint) : Bool;
	public var visible(getVisible, setVisible) : Bool;
	public var frame(getFrame, setFrame) : Int;
	public var frameLabel(getFrameLabel, setFrameLabel) : String;
	public var tint(getTint, setTint) : Int;
	public var volume(getVolume, setVolume) : Float;
	public var bevelFilter(getBevelFilter, setBevelFilter) : BevelFilterVars;
	public var bezier(getBezier, setBezier) : Array<Dynamic>;
	public var bezierThrough(getBezierThrough, setBezierThrough) : Array<Dynamic>;
	public var blurFilter(getBlurFilter, setBlurFilter) : BlurFilterVars;
	public var colorMatrixFilter(getColorMatrixFilter, setColorMatrixFilter) : ColorMatrixFilterVars;
	public var colorTransform(getColorTransform, setColorTransform) : ColorTransformVars;
	public var dropShadowFilter(getDropShadowFilter, setDropShadowFilter) : DropShadowFilterVars;
	public var glowFilter(getGlowFilter, setGlowFilter) : GlowFilterVars;
	public var hexColors(getHexColors, setHexColors) : Dynamic;
	public var orientToBezier(getOrientToBezier, setOrientToBezier) : Dynamic;
	public var quaternions(getQuaternions, setQuaternions) : Dynamic;
	public var setSize(getSetSize, setSetSize) : Dynamic;
	public var shortRotation(getShortRotation, setShortRotation) : Dynamic;
	public var transformAroundCenter(getTransformAroundCenter, setTransformAroundCenter) : TransformAroundCenterVars;
	public var transformAroundPoint(getTransformAroundPoint, setTransformAroundPoint) : TransformAroundPointVars;
	
	public static inline var version:Float = 2.03;
	// (stands for "isTweenVars") - Just gives us a way to check inside TweenLite to see if the Object is a TweenLiteVars without having to embed the class. This is helpful when handling tint, visible, and other properties that the user didn't necessarily define, but this utility class forces to be present.
	public static inline var isTV:Bool = true;
	/**
	 * The number of seconds to delay before the tween begins.
	 */
	public var delay:Float;
	/**
	 * An easing function (i.e. fl.motion.easing.Elastic.easeOut) The default is Regular.easeOut. 
	 */
	public var ease:Dynamic;
	/**
	 * An Array of extra parameter values to feed the easing equation (beyond the standard 4). This can be useful with easing equations like Elastic that accept extra parameters like the amplitude and period. Most easing equations, however, don't require extra parameters so you won't need to pass in any easeParams. 
	 */
	public var easeParams:Array<Dynamic>;
	/**
	 * A function to call when the tween begins. This can be useful when there's a delay and you want something to happen just as the tween begins. 
	 */
	public var onStart:Dynamic;
	/**
	 * An Array of parameters to pass the onStart function. 
	 */
	public var onStartParams:Array<Dynamic>;
	/**
	 * A function to call whenever the tweening values are updated (on every frame during the time the tween is active). 
	 */
	public var onUpdate:Dynamic;
	/**
	 * An Array of parameters to pass the onUpdate function 
	 */
	public var onUpdateParams:Array<Dynamic>;
	/**
	 * A function to call when the tween has completed.  
	 */
	public var onComplete:Dynamic;
	/**
	 * An Array of parameters to pass the onComplete function 
	 */
	public var onCompleteParams:Array<Dynamic>;
	/**
	 * NONE = 0, ALL = 1, AUTO* = 2, CONCURRENT* = 3  *Only available with the optional OverwriteManager add-on class which must be initted once for TweenLite or TweenFilterLite, like OverwriteManager.init(). TweenMax automatically inits OverwriteManager.
	 */
	public var overwrite:Int;
	/**
	 * To prevent a tween from getting garbage collected after it completes, set persist to true. This does NOT, however, prevent teh tween from getting overwritten by other tweens of the same target.
	 */
	public var persist:Bool;
	/**
	 * If you're using TweenLite.from() with a delay and you want to prevent the tween from rendering until it actually begins, set this special property to true. By default, it's false which causes TweenLite.from() to render its values immediately, even before the delay has expired. 
	 */
	public var renderOnStart:Bool;
	/**
	 * Primarily used in from() calls - forces the values to get flipped. 
	 */
	public var runBackwards:Bool;
	/**
	 * Defines starting values for the tween (by default, the target's current values at the time the tween begins are used)
	 */
	public var startAt:TweenLiteVars;
	// Gives us a way to make certain non-dynamic properties enumerable.
	private var _exposedVars:Dynamic;
	private var _autoAlpha:Float;
	private var _endArray:Array<Dynamic>;
	private var _frame:Int;
	private var _frameLabel:String;
	private var _removeTint:Bool;
	private var _tint:Int;
	private var _visible:Bool;
	private var _volume:Float;
	private var _bevelFilter:BevelFilterVars;
	private var _bezier:Array<Dynamic>;
	private var _bezierThrough:Array<Dynamic>;
	private var _blurFilter:BlurFilterVars;
	private var _colorMatrixFilter:ColorMatrixFilterVars;
	private var _dropShadowFilter:DropShadowFilterVars;
	private var _glowFilter:GlowFilterVars;
	private var _hexColors:Dynamic;
	private var _orientToBezier:Array<Dynamic>;
	private var _quaternions:Dynamic;
	private var _setSize:Dynamic;
	private var _shortRotation:Dynamic;
	private var _transformAroundPoint:TransformAroundPointVars;
	private var _transformAroundCenter:TransformAroundCenterVars;
	private var _colorTransform:ColorTransformVars;
	

	/**
	 * @param $vars An Object containing properties that correspond to the properties you'd like to add to this TweenLiteVars Object. For example, TweenLiteVars({x:300, onComplete:myFunction})
	 */
	public function new(?$vars:Dynamic=null) {
		this.delay = 0;
		this.overwrite = 2;
		this.persist = false;
		this.renderOnStart = false;
		this.runBackwards = false;
		this._visible = true;
		
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
		
		_exposedVars = {};
		if ($vars != null) {
			var p:String;
			for (p in Reflect.fields($vars)) {
				if (p == "blurFilter" || p == "glowFilter" || p == "colorMatrixFilter" || p == "bevelFilter" || p == "dropShadowFilter" || p == "transformAroundPoint" || p == "transformAroundCenter" || p == "colorTransform") {
				} else if (p != "protectedVars") {
					this[p] = Reflect.field($vars, p);
				}
				
			}

			if ($vars.blurFilter != null) {
				this.blurFilter = BlurFilterVars.createFromGeneric($vars.blurFilter);
			}
			if ($vars.bevelFilter != null) {
				this.bevelFilter = BevelFilterVars.createFromGeneric($vars.bevelFilter);
			}
			if ($vars.colorMatrixFilter != null) {
				this.colorMatrixFilter = ColorMatrixFilterVars.createFromGeneric($vars.colorMatrixFilter);
			}
			if ($vars.dropShadowFilter != null) {
				this.dropShadowFilter = DropShadowFilterVars.createFromGeneric($vars.dropShadowFilter);
			}
			if ($vars.glowFilter != null) {
				this.glowFilter = GlowFilterVars.createFromGeneric($vars.glowFilter);
			}
			if ($vars.transformAroundPoint != null) {
				this.transformAroundPoint = TransformAroundPointVars.createFromGeneric($vars.transformAroundPoint);
			}
			if ($vars.transformAroundCenter != null) {
				this.transformAroundCenter = TransformAroundCenterVars.createFromGeneric($vars.transformAroundCenter);
			}
			if ($vars.colorTransform != null) {
				this.colorTransform = ColorTransformVars.createFromGeneric($vars.colorTransform);
			}
			//used for clone()-ing protected vars
			if ($vars.protectedVars != null) {
				var pv:Dynamic = $vars.protectedVars;
				for (p in Reflect.fields(pv)) {
					this[p] = Reflect.field(pv, p);
					
				}

			}
		}
		if (TweenLite.version < 10.05) {
			trace("TweenLiteVars error! Please update your TweenLite class or try deleting your ASO files. TweenLiteVars requires a more recent version. Download updates at http://www.TweenLite.com.");
		}
	}

	/**
	 * Adds a dynamic property for tweening and allows you to set whether the end value is relative or not
	 * 
	 * @param $name Property name
	 * @param $value Numeric end value (or beginning value for from() calls)
	 * @param $relative If true, the value will be relative to the target's current value. For example, if my_mc.x is currently 300 and you do addProp("x", 200, true), the end value will be 500.
	 */
	public function addProp($name:String, $value:Float, ?$relative:Bool=false):Void {
		
		if ($relative) {
			this[$name] = Std.string($value);
		} else {
			this[$name] = $value;
		}
	}

	/**
	 * Adds up to 15 dynamic properties at once (just like doing addProp() multiple times). Saves time and reduces code.
	 */
	public function addProps($name1:String, $value1:Float, ?$relative1:Bool=false, ?$name2:String=null, ?$value2:Float=0, ?$relative2:Bool=false, ?$name3:String=null, ?$value3:Float=0, ?$relative3:Bool=false, ?$name4:String=null, ?$value4:Float=0, ?$relative4:Bool=false, ?$name5:String=null, ?$value5:Float=0, ?$relative5:Bool=false, ?$name6:String=null, ?$value6:Float=0, ?$relative6:Bool=false, ?$name7:String=null, ?$value7:Float=0, ?$relative7:Bool=false, ?$name8:String=null, ?$value8:Float=0, ?$relative8:Bool=false, ?$name9:String=null, ?$value9:Float=0, ?$relative9:Bool=false, ?$name10:String=null, ?$value10:Float=0, ?$relative10:Bool=false, ?$name11:String=null, ?$value11:Float=0, ?$relative11:Bool=false, ?$name12:String=null, ?$value12:Float=0, ?$relative12:Bool=false, ?$name13:String=null, ?$value13:Float=0, ?$relative13:Bool=false, ?$name14:String=null, ?$value14:Float=0, ?$relative14:Bool=false, ?$name15:String=null, ?$value15:Float=0, ?$relative15:Bool=false):Void {
		
		addProp($name1, $value1, $relative1);
		if ($name2 != null) {
			addProp($name2, $value2, $relative2);
		}
		if ($name3 != null) {
			addProp($name3, $value3, $relative3);
		}
		if ($name4 != null) {
			addProp($name4, $value4, $relative4);
		}
		if ($name5 != null) {
			addProp($name5, $value5, $relative5);
		}
		if ($name6 != null) {
			addProp($name6, $value6, $relative6);
		}
		if ($name7 != null) {
			addProp($name7, $value7, $relative7);
		}
		if ($name8 != null) {
			addProp($name8, $value8, $relative8);
		}
		if ($name9 != null) {
			addProp($name9, $value9, $relative9);
		}
		if ($name10 != null) {
			addProp($name10, $value10, $relative10);
		}
		if ($name11 != null) {
			addProp($name11, $value11, $relative11);
		}
		if ($name12 != null) {
			addProp($name12, $value12, $relative12);
		}
		if ($name13 != null) {
			addProp($name13, $value13, $relative13);
		}
		if ($name14 != null) {
			addProp($name14, $value14, $relative14);
		}
		if ($name15 != null) {
			addProp($name15, $value15, $relative15);
		}
	}

	/**
	 * Clones the TweenLiteVars object.
	 */
	public function clone():TweenLiteVars {
		
		var vars:Dynamic = {protectedVars:{}};
		appendCloneVars(vars, vars.protectedVars);
		return new TweenLiteVars();
	}

	/**
	 * Works with clone() to copy all the necessary properties. Split apart from clone() to take advantage of inheritence for TweenMaxVars
	 */
	private function appendCloneVars($vars:Dynamic, $protectedVars:Dynamic):Void {
		
		var props:Array<Dynamic>;
		var special:Array<Dynamic>;
		var i:Int;
		var p:String;
		props = ["delay", "ease", "easeParams", "onStart", "onStartParams", "onUpdate", "onUpdateParams", "onComplete", "onCompleteParams", "overwrite", "persist", "renderOnStart", "runBackwards", "startAt"];
		i = props.length - 1;
		while (i > -1) {
			Reflect.setField($vars, props[i], this[props[i]]);
			
			// update loop variables
			i--;
		}

		special = ["_autoAlpha", "_bevelFilter", "_bezier", "_bezierThrough", "_blurFilter", "_colorMatrixFilter", "_colorTransform", "_dropShadowFilter", "_endArray", "_frame", "_frameLabel", "_glowFilter", "_hexColors", "_orientToBezier", "_quaternions", "_removeTint", "_setSize", "_shortRotation", "_tint", "_transformAroundCenter", "_transformAroundPoint", "_visible", "_volume", "_exposedVars"];
		i = special.length - 1;
		while (i > -1) {
			Reflect.setField($protectedVars, special[i], this[special[i]]);
			
			// update loop variables
			i--;
		}

		for (p in Reflect.fields(this)) {
			Reflect.setField($vars, p, this[p]);
			
		}

	}

	//---- GETTERS / SETTERS -------------------------------------------------------------------------------------------------------------
	/**
	 * @return Exposes enumerable properties.
	 */
	public function getExposedVars():Dynamic {
		
		var o:Dynamic = {};
		var p:String;
		for (p in Reflect.fields(_exposedVars)) {
			Reflect.setField(o, p, Reflect.field(_exposedVars, p));
			
		}

		for (p in Reflect.fields(this)) {
			Reflect.setField(o, p, this[p]);
			
		}

		return o;
	}

	/**
	 * @param $n Same as changing the "alpha" property but with the additional feature of toggling the "visible" property to false when alpha is 0.
	 */
	public function setAutoAlpha($n:Float):Float {
		
		_autoAlpha = _exposedVars.autoAlpha = $n;
		return $n;
	}

	public function getAutoAlpha():Float {
		
		return _autoAlpha;
	}

	/**
	 * @param $a An Array containing numeric end values of the target Array. Keep in mind that the target of the tween must be an Array with at least the same length as the endArray. 
	 */
	public function setEndArray($a:Array<Dynamic>):Array<Dynamic> {
		
		_endArray = _exposedVars.endArray = $a;
		return $a;
	}

	public function getEndArray():Array<Dynamic> {
		
		return _endArray;
	}

	/**
	 * @param $b To remove the tint from a DisplayObject, set removeTint to true. 
	 */
	public function setRemoveTint($b:Bool):Bool {
		
		_removeTint = _exposedVars.removeTint = $b;
		return $b;
	}

	public function getRemoveTint():Bool {
		
		return _removeTint;
	}

	/**
	 * @param $b To set a DisplayObject's "visible" property at the end of the tween, use this special property.
	 */
	public function setVisible($b:Bool):Bool {
		
		_visible = _exposedVars.visible = $b;
		return $b;
	}

	public function getVisible():Bool {
		
		return _visible;
	}

	/**
	 * @param $n Tweens a MovieClip to a particular frame.
	 */
	public function setFrame($n:Int):Int {
		
		_frame = _exposedVars.frame = $n;
		return $n;
	}

	public function getFrame():Int {
		
		return _frame;
	}

	/**
	 * @param $n Tweens a MovieClip to a particular frame.
	 */
	public function setFrameLabel($s:String):String {
		
		_frameLabel = _exposedVars.frameLabel = $s;
		return $s;
	}

	public function getFrameLabel():String {
		
		return _frameLabel;
	}

	/**
	 * @param $n To change a DisplayObject's tint, set this to the hex value of the color you'd like the DisplayObject to end up at(or begin at if you're using TweenLite.from()). An example hex value would be 0xFF0000. If you'd like to remove the tint from a DisplayObject, use the removeTint special property.
	 */
	public function setTint($n:Int):Int {
		
		_tint = _exposedVars.tint = $n;
		return $n;
	}

	public function getTint():Int {
		
		return _tint;
	}

	/**
	 * @param $n To change a MovieClip's (or SoundChannel's) volume, just set this to the value you'd like the MovieClip to end up at (or begin at if you're using TweenLite.from()).
	 */
	public function setVolume($n:Float):Float {
		
		_volume = _exposedVars.volume = $n;
		return $n;
	}

	public function getVolume():Float {
		
		return _volume;
	}

	/**
	 * @param $f Applies a BevelFilter tween (use the BevelFilterVars utility class to define the values).
	 */
	public function setBevelFilter($f:BevelFilterVars):BevelFilterVars {
		
		_bevelFilter = _exposedVars.bevelFilter = $f;
		return $f;
	}

	public function getBevelFilter():BevelFilterVars {
		
		return _bevelFilter;
	}

	/**
	 * @param $a Array of Objects, one for each "control point" (see documentation on Flash's curveTo() drawing method for more about how control points work). In this example, let's say the control point would be at x/y coordinates 250,50. Just make sure your my_mc is at coordinates 0,0 and then do: TweenMax.to(my_mc, 3, {_x:500, _y:0, bezier:[{_x:250, _y:50}]});
	 */
	public function setBezier($a:Array<Dynamic>):Array<Dynamic> {
		
		_bezier = _exposedVars.bezier = $a;
		return $a;
	}

	public function getBezier():Array<Dynamic> {
		
		return _bezier;
	}

	/**
	 * @param $a Identical to bezier except that instead of passing Bezier control point values, you pass values through which the Bezier values should move. This can be more intuitive than using control points.
	 */
	public function setBezierThrough($a:Array<Dynamic>):Array<Dynamic> {
		
		_bezierThrough = _exposedVars.bezierThrough = $a;
		return $a;
	}

	public function getBezierThrough():Array<Dynamic> {
		
		return _bezierThrough;
	}

	/**
	 * @param $f Applies a BlurFilter tween (use the BlurFilterVars utility class to define the values).
	 */
	public function setBlurFilter($f:BlurFilterVars):BlurFilterVars {
		
		_blurFilter = _exposedVars.blurFilter = $f;
		return $f;
	}

	public function getBlurFilter():BlurFilterVars {
		
		return _blurFilter;
	}

	/**
	 * @param $f Applies a ColorMatrixFilter tween (use the ColorMatrixFilterVars utility class to define the values).
	 */
	public function setColorMatrixFilter($f:ColorMatrixFilterVars):ColorMatrixFilterVars {
		
		_colorMatrixFilter = _exposedVars.colorMatrixFilter = $f;
		return $f;
	}

	public function getColorMatrixFilter():ColorMatrixFilterVars {
		
		return _colorMatrixFilter;
	}

	/**
	 * @param $ct Applies a ColorTransform tween (use the ColorTransformVars utility class to define the values).
	 */
	public function setColorTransform($ct:ColorTransformVars):ColorTransformVars {
		
		_colorTransform = _exposedVars.colorTransform = $ct;
		return $ct;
	}

	public function getColorTransform():ColorTransformVars {
		
		return _colorTransform;
	}

	/**
	 * @param $f Applies a DropShadowFilter tween (use the DropShadowFilterVars utility class to define the values).
	 */
	public function setDropShadowFilter($f:DropShadowFilterVars):DropShadowFilterVars {
		
		_dropShadowFilter = _exposedVars.dropShadowFilter = $f;
		return $f;
	}

	public function getDropShadowFilter():DropShadowFilterVars {
		
		return _dropShadowFilter;
	}

	/**
	 * @param $f Applies a GlowFilter tween (use the GlowFilterVars utility class to define the values).
	 */
	public function setGlowFilter($f:GlowFilterVars):GlowFilterVars {
		
		_glowFilter = _exposedVars.glowFilter = $f;
		return $f;
	}

	public function getGlowFilter():GlowFilterVars {
		
		return _glowFilter;
	}

	/**
	 * @param $o Although hex colors are technically numbers, if you try to tween them conventionally, you'll notice that they don't tween smoothly. To tween them properly, the red, green, and blue components must be extracted and tweened independently. TweenMax makes it easy. To tween a property of your object that's a hex color to another hex color, use this special hexColors property of TweenMax. It must be an OBJECT with properties named the same as your object's hex color properties. For example, if your my_obj object has a "myHexColor" property that you'd like to tween to red (0xFF0000) over the course of 2 seconds, do: TweenMax.to(my_obj, 2, {hexColors:{myHexColor:0xFF0000}}); You can pass in any number of hexColor properties.
	 */
	public function setHexColors($o:Dynamic):Dynamic {
		
		_hexColors = _exposedVars.hexColors = $o;
		return $o;
	}

	public function getHexColors():Dynamic {
		
		return _hexColors;
	}

	/**
	 * @param $a A common effect that designers/developers want is for a MovieClip/Sprite to orient itself in the direction of a Bezier path (alter its rotation). orientToBezier makes it easy. In order to alter a rotation property accurately, TweenMax needs 4 pieces of information:
	 * 
	 * 1. Position property 1 (typically "x")
	 * 2. Position property 2 (typically "y")
	 * 3. Rotational property (typically "rotation")
	 * 4. Number of degrees to add (optional - makes it easy to orient your MovieClip/Sprite properly)
	 * 
	 * The orientToBezier property should be an Array containing one Array for each set of these values. For maximum flexibility, you can pass in any number of Arrays inside the container Array, one for each rotational property. This can be convenient when working in 3D because you can rotate on multiple axis. If you're doing a standard 2D x/y tween on a bezier, you can simply pass in a boolean value of true and TweenMax will use a typical setup, [["x", "y", "rotation", 0]]. Hint: Don't forget the container Array (notice the double outer brackets)  
	 */
	public function setOrientToBezier($a:Dynamic):Dynamic {
		
		if (Std.is($a, Array<Dynamic>)) {
			_orientToBezier = _exposedVars.orientToBezier = $a;
		} else if ($a == true) {
			_orientToBezier = _exposedVars.orientToBezier = [["x", "y", "rotation", 0]];
		} else {
			_orientToBezier = null;
			_exposedVars.orientToBezier = null;
		}
		return $a;
	}

	public function getOrientToBezier():Dynamic {
		
		return _orientToBezier;
	}

	/**
	 * @param $q An object with properties that correspond to the quaternion properties of the target object. For example, if your my3DObject has "orientation" and "childOrientation" properties that contain quaternions, and you'd like to tween them both, you'd do: {orientation:myTargetQuaternion1, childOrientation:myTargetQuaternion2}. Quaternions must have the following properties: x, y, z, and w.
	 */
	public function setQuaternions($q:Dynamic):Dynamic {
		
		_quaternions = _exposedVars.quaternions = $q;
		return $q;
	}

	public function getQuaternions():Dynamic {
		
		return _quaternions;
	}

	/**
	 * @param $o An object containing a "width" and/or "height" property which will be tweened over time and applied using setSize() on every frame during the course of the tween.
	 */
	public function setSetSize($o:Dynamic):Dynamic {
		
		_setSize = _exposedVars.setSize = $o;
		return $o;
	}

	public function getSetSize():Dynamic {
		
		return _setSize;
	}

	/**
	 * @param $o To tween any rotation property (even multiple properties) of the target object in the shortest direction, use shortRotation. For example, if myObject.rotation is currently 170 degrees and you want to tween it to -170 degrees, a normal rotation tween would travel a total of 340 degrees in the counter-clockwise direction, but if you use shortRotation, it would travel 20 degrees in the clockwise direction instead. Pass in an object in with properties that correspond to the rotation values of the target, like {rotation:-170} or {rotationX:-170, rotationY:50}
	 */
	public function setShortRotation($o:Dynamic):Dynamic {
		
		_shortRotation = _exposedVars.shortRotation = $o;
		return $o;
	}

	public function getShortRotation():Dynamic {
		
		return _shortRotation;
	}

	/**
	 * @param $tp Applies a transformAroundCenter tween (use the TransformAroundCenterVars utility class to define the values).
	 */
	public function setTransformAroundCenter($tp:TransformAroundCenterVars):TransformAroundCenterVars {
		
		_transformAroundCenter = _exposedVars.transformAroundCenter = $tp;
		return $tp;
	}

	public function getTransformAroundCenter():TransformAroundCenterVars {
		
		return _transformAroundCenter;
	}

	/**
	 * @param $tp Applies a transformAroundPoint tween (use the TransformAroundPointVars utility class to define the values).
	 */
	public function setTransformAroundPoint($tp:TransformAroundPointVars):TransformAroundPointVars {
		
		_transformAroundPoint = _exposedVars.transformAroundPoint = $tp;
		return $tp;
	}

	public function getTransformAroundPoint():TransformAroundPointVars {
		
		return _transformAroundPoint;
	}

}

