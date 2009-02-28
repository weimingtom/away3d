package gs.plugins;

import gs.TweenLite;


class TweenPlugin  {
	public var changeFactor(getChangeFactor, setChangeFactor) : Float;
	
	public static inline var VERSION:Float = 1.03;
	//If the API/Framework for plugins changes in the future, this number helps determine compatibility
	public static inline var API:Float = 1.0;
	/**
	 * Name of the special property that the plugin should intercept/handle 
	 */
	public var propName:String;
	/**
	 * Array containing the names of the properties that should be overwritten in OverwriteManager's 
	 * AUTO mode. Typically the only value in this Array is the propName, but there are cases when it may 
	 * be different. For example, a bezier tween's propName is "bezier" but it can manage many different properties 
	 * like x, y, etc. depending on what's passed in to the tween.
	 */
	public var overwriteProps:Array<Dynamic>;
	/**
	 * If the values should be rounded to the nearest integer, set this to true. 
	 */
	public var round:Bool;
	/**
	 * Called when the tween is complete.
	 */
	public var onComplete:Dynamic;
	private var _tweens:Array<Dynamic>;
	private var _changeFactor:Float;
	

	public function new() {
		this._tweens = [];
		this._changeFactor = 0;
		
		//constructor
		
	}

	/**
	 * Gets called when any tween of the special property begins. Store any initial values
	 * and/or variables that will be used in the "changeFactor" setter when this method runs. 
	 * 
	 * @param $target target object of the TweenLite instance using this plugin
	 * @param $value The value that is passed in through the special property in the tween. 
	 * @param $tween The TweenLite or TweenMax instance using this plugin.
	 * @return If the initialization failed, it returns false. Otherwise true. It may fail if, for example, the plugin requires that the target be a DisplayObject or has some other unmet criteria in which case the plugin is skipped and a normal property tween is used inside TweenLite
	 */
	public function onInitTween($target:Dynamic, $value:Dynamic, $tween:TweenLite):Bool {
		
		addTween($target, this.propName, Reflect.field($target, this.propName), $value, this.propName);
		return true;
	}

	/**
	 * Offers a simple way to add tweening values to the plugin. You don't need to use this,
	 * but it is convenient because the tweens get updated in the updateTweens() method which also 
	 * handles rounding. killProps() nicely integrates with most tweens added via addTween() as well,
	 * but if you prefer to handle this manually in your plugin, you're welcome to.
	 *  
	 * @param $object target object whose property you'd like to tween. (i.e. myClip)
	 * @param $propName the property name that should be tweened. (i.e. "x")
	 * @param $start starting value
	 * @param $end end value (can be either numeric or a string value. If it's a string, it will be interpreted as relative to the starting value)
	 * @param $overwriteProp name of the property that should be associated with the tween for overwriting purposes. Normally, it's the same as $propName, but not always. For example, you may tween the "changeFactor" property of a VisiblePlugin, but the property that it's actually controling in the end is "visible", so if a new overlapping tween of the target object is created that affects its "visible" property, this allows the plugin to kill the appropriate tween(s) when killProps() is called. 
	 */
	private function addTween($object:Dynamic, $propName:String, $start:Float, $end:Dynamic, ?$overwriteProp:String=null):Void {
		
		if ($end != null) {
			var change:Float = (typeof($end) == "number") ? $end - $start : ($end);
			//don't tween values that aren't changing! It's a waste of CPU cycles
			if (change != 0) {
				_tweens[_tweens.length] = Type.createInstance(TweenInfo, []);
			}
		}
	}

	/**
	 * Updates all the tweens in the _tweens Array. 
	 *  
	 * @param $changeFactor Multiplier describing the amount of change that should be applied. It will be zero at the beginning of the tween and 1 at the end, but inbetween it could be any value based on the ease applied (for example, an Elastic tween would cause the value to shoot past 1 and back again before the end of the tween) 
	 */
	private function updateTweens($changeFactor:Float):Void {
		
		var i:Int;
		var ti:TweenInfo;
		if (this.round) {
			var val:Float;
			var neg:Int;
			i = _tweens.length - 1;
			while (i > -1) {
				ti = _tweens[i];
				val = ti.start + (ti.change * $changeFactor);
				neg = (val < 0) ? -1 : 1;
				//twice as fast as Math.round()
				ti.target[ti.property] = ((val % 1) * neg > 0.5) ? Std.int(val) + neg : Std.int(val);
				
				// update loop variables
				i--;
			}

		} else {
			i = _tweens.length - 1;
			while (i > -1) {
				ti = _tweens[i];
				ti.target[ti.property] = ti.start + (ti.change * $changeFactor);
				
				// update loop variables
				i--;
			}

		}
	}

	/**
	 * In most cases, your custom updating code should go here. The changeFactor value describes the amount 
	 * of change based on how far along the tween is and the ease applied. It will be zero at the beginning
	 * of the tween and 1 at the end, but inbetween it could be any value based on the ease applied (for example, 
	 * an Elastic tween would cause the value to shoot past 1 and back again before the end of the tween) 
	 * This value gets updated on every frame during the course of the tween.
	 * 
	 * @param $n Multiplier describing the amount of change that should be applied. It will be zero at the beginning of the tween and 1 at the end, but inbetween it could be any value based on the ease applied (for example, an Elastic tween would cause the value to shoot past 1 and back again before the end of the tween) 
	 */
	public function setChangeFactor($n:Float):Float {
		
		updateTweens($n);
		_changeFactor = $n;
		return $n;
	}

	public function getChangeFactor():Float {
		
		return _changeFactor;
	}

	/**
	 * Gets called on plugins that have multiple overwritable properties by OverwriteManager when 
	 * in AUTO mode. Basically, it instructs the plugin to overwrite certain properties. For example,
	 * if a bezier tween is affecting x, y, and width, and then a new tween is created while the 
	 * bezier tween is in progress, and the new tween affects the "x" property, we need a way
	 * to kill just the "x" part of the bezier tween. 
	 * 
	 * @param $lookup An object containing properties that should be overwritten. We don't pass in an Array because looking up properties on the object is usually faster because it gives us random access. So to overwrite the "x" and "y" properties, a {x:true, y:true} object would be passed in. 
	 */
	public function killProps($lookup:Dynamic):Void {
		
		var i:Int;
		i = this.overwriteProps.length - 1;
		while (i > -1) {
			if (this.overwriteProps[i] in $lookup) {
				this.overwriteProps.splice(i, 1);
			}
			
			// update loop variables
			i--;
		}

		i = _tweens.length - 1;
		while (i > -1) {
			if (_tweens[i].name in $lookup) {
				_tweens.splice(i, 1);
			}
			
			// update loop variables
			i--;
		}

	}

	/**
	 * Handles integrating the plugin into the GreenSock tweening platform. 
	 * 
	 * @param $plugin An Array of Plugin classes (that all extend TweenPlugin) to be activated. For example, TweenPlugin.activate([FrameLabelPlugin, ShortRotationPlugin, TintPlugin]);
	 */
	public static function activate($plugins:Array<Dynamic>):Bool {
		
		var i:Int;
		var instance:Dynamic;
		i = $plugins.length - 1;
		while (i > -1) {
			instance = Type.createInstance($plugins[i], []);
			TweenLite.plugins[instance.propName] = $plugins[i];
			
			// update loop variables
			i--;
		}

		return true;
	}

}

