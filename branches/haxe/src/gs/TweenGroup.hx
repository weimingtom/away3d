package gs;

import away3d.haxeutils.Error;
import flash.events.IEventDispatcher;
import flash.events.EventDispatcher;
import flash.events.Event;
import flash.utils.Proxy;


class TweenGroup extends Proxy, implements IEventDispatcher {
	public var length(getLength, null) : Int;
	public var progress(getProgress, setProgress) : Float;
	public var progressWithDelay(getProgressWithDelay, setProgressWithDelay) : Float;
	public var duration(getDuration, null) : Float;
	public var durationWithDelay(getDurationWithDelay, null) : Float;
	public var paused(getPaused, setPaused) : Bool;
	public var reversed(getReversed, setReversed) : Bool;
	public var timeScale(getTimeScale, setTimeScale) : Float;
	public var align(getAlign, setAlign) : String;
	public var stagger(getStagger, setStagger) : Float;
	public var tweens(getTweens, null) : Array<Dynamic>;
	
	public static inline var version:Float = 1.02;
	public static inline var ALIGN_INIT:String = "init";
	public static inline var ALIGN_START:String = "start";
	public static inline var ALIGN_END:String = "end";
	public static inline var ALIGN_SEQUENCE:String = "sequence";
	public static inline var ALIGN_NONE:String = "none";
	//forces OverwriteManager to init() in AUTO mode (if it's not already initted) because AUTO overwriting is much more intuitive when working with sequences and groups. If you prefer to manage overwriting manually to save the 1kb, just comment this line out.
	private static var _overwriteMode:Int = (OverwriteManager.enabled) ? OverwriteManager.mode : OverwriteManager.init();
	private static var _TweenMax:Class<Dynamic>;
	private static var _classInitted:Bool;
	//TweenGroups that have not ended/expired yet (have endTimes in the future)
	private static var _unexpired:Array<Dynamic> = [];
	// records TweenLite.currentTime so that we can compare it on the checkExpiration() function to see if/when TweenGroups have completed.
	private static var _prevTime:Int = 0;
	public var onComplete:Dynamic;
	public var onCompleteParams:Array<Dynamic>;
	public var loop:Float;
	public var yoyo:Float;
	//time at which the last tween finishes (made it public for speed purposes)
	public var endTime:Float;
	public var expired:Bool;
	private var _tweens:Array<Dynamic>;
	private var _pauseTime:Float;
	//time at which the first tween in the group begins (AFTER any delay)
	private var _startTime:Float;
	//same as _startTime except it factors in the delay, so it's basically _startTime minus the first tween's delay.
	private var _initTime:Float;
	private var _reversed:Bool;
	private var _align:String;
	//time (in seconds) to stagger each tween in the group/sequence
	private var _stagger:Float;
	//number of times the group has yoyo'd or loop'd.
	private var _repeatCount:Float;
	private var _dispatcher:EventDispatcher;
	

	/**
	 * Constructor 
	 * 
	 * @param $tweens An Array of either TweenLite/TweenMax instances or Objects each containing at least a "target" and "time" property, like [{target:mc, time:2, x:300},{target:mc2, time:1, alpha:0.5}]
	 * @param $DefaultTweenClass Defines which tween class should be used when parsing objects that are not already TweenLite/TweenMax instances. Choices are TweenLite or TweenMax.
	 * @param $align Controls the alignment of the tweens within the group. Options are TweenGroup.ALIGN_SEQUENCE, TweenGroup.ALIGN_START, TweenGroup.ALIGN_END, TweenGroup.ALIGN_INIT, or TweenGroup.ALIGN_NONE
	 * @param $stagger Amount of time (in seconds) to offset each tween according to the current alignment. For example, if the align property is set to ALIGN_SEQUENCE and stagger is 0.5, this adds 0.5 seconds between each tween in the sequence. If align is set to ALIGN_START, it would add 0.5 seconds to the start time of each tween (0 for the first tween, 0.5 for the second, 1 for the third, etc.)
	 * */
	public function new(?$tweens:Array<Dynamic>=null, ?$DefaultTweenClass:Class<Dynamic>=null, ?$align:String="none", ?$stagger:Float=0) {
		
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
		
		super();
		if (!_classInitted) {
			if (TweenLite.version < 9.291) {
				trace("TweenGroup error! Please update your TweenLite class or try deleting your ASO files. TweenGroup requires a more recent version. Download updates at http://www.TweenLite.com.");
			}
			//Checking "if (tween is _TweenMax)" is twice as fast as "if (tween.hasOwnProperty("paused"))". Storing a reference to the class this way prevents us from having to import the whole TweenMax class, thus saves a lot of Kb.
			try {
				_TweenMax = (cast(Type.resolveClass("gs.TweenMax"), Class<Dynamic>));
			} catch ($e:Error) {
				_TweenMax = Array;
			}

			TweenLite.timingSprite.addEventListener(Event.ENTER_FRAME, checkExpiration, false, -1, true);
			_classInitted = true;
		}
		this.expired = true;
		_repeatCount = 0;
		_align = $align;
		_stagger = $stagger;
		_dispatcher = new EventDispatcher();
		if ($tweens != null) {
			_tweens = parse($tweens, $DefaultTweenClass);
			updateTimeSpan();
			realign();
		} else {
			_tweens = [];
			_initTime = _startTime = this.endTime = 0;
		}
	}

	//---- PROXY FUNCTIONS ------------------------------------------------------------------------------------------
	public override function callProperty($name:Dynamic, ?$args:Array<Dynamic>):Dynamic {
		
		var returnValue:Dynamic = _tweens[$name].apply(null, $args);
		realign();
		if (!Math.isNaN(_pauseTime)) {
			pause();
		}
		return returnValue;
	}

	public override function getProperty($prop:Dynamic):Dynamic {
		
		return _tweens[$prop];
	}

	public override function setProperty($prop:Dynamic, $value:Dynamic):Void {
		
		onSetProperty($prop, $value);
	}

	private function onSetProperty($prop:Dynamic, $value:Dynamic):Void {
		
		if (!Math.isNaN($prop) && !(Std.is($value, TweenLite))) {
			trace("TweenGroup error: an attempt was made to add a non-TweenLite element.");
		} else {
			_tweens[$prop] = $value;
			realign();
			if (!Math.isNaN(_pauseTime) && (Std.is($value, TweenLite))) {
				pauseTween(cast($value, TweenLite));
			}
		}
	}

	public override function hasProperty($name:Dynamic):Bool {
		
		var props:String = " progress progressWithDelay duration durationWithDelay paused reversed timeScale align stagger tweens ";
		if (Reflect.hasField(_tweens, $name)) {
			return true;
		} else if (props.indexOf(" " + $name + " ") != -1) {
			return true;
		} else {
			return false;
		}
		
		// autogenerated
		return false;
	}

	//---- EVENT DISPATCHING FUNCTIONS -----------------------------------------------------------------------------
	public function addEventListener($type:String, $listener:Dynamic, ?$useCapture:Bool=false, ?$priority:Int=0, ?$useWeakReference:Bool=false):Void {
		
		_dispatcher.addEventListener($type, $listener, $useCapture, $priority, $useWeakReference);
	}

	public function removeEventListener($type:String, $listener:Dynamic, ?$useCapture:Bool=false):Void {
		
		_dispatcher.removeEventListener($type, $listener, $useCapture);
	}

	public function hasEventListener($type:String):Bool {
		
		return _dispatcher.hasEventListener($type);
	}

	public function willTrigger($type:String):Bool {
		
		return _dispatcher.willTrigger($type);
	}

	public function dispatchEvent($e:Event):Bool {
		
		return _dispatcher.dispatchEvent($e);
	}

	//---- PUBLIC FUNCTIONS ----------------------------------------------------------------------------------------
	/**
	 * Pauses the entire group of tweens
	 */
	public function pause():Void {
		
		if (Math.isNaN(_pauseTime)) {
			_pauseTime = TweenLite.currentTime;
		}
		//this is outside the if() statement in case one (or more) tween is independently resumed() while the group is paused, and then the user wants to make sure all tweens in the group are paused.
		var i:Int = _tweens.length - 1;
		while (i > -1) {
			if (_tweens[i].startTime != 999999999999999) {
				pauseTween(_tweens[i]);
			}
			
			// update loop variables
			i--;
		}

	}

	/**
	 * Resumes the entire group of tweens
	 */
	public function resume():Void {
		
		var a:Array<Dynamic> = [];
		var i:Int;
		var time:Float = TweenLite.currentTime;
		i = _tweens.length - 1;
		while (i > -1) {
			if (_tweens[i].startTime == 999999999999999) {
				resumeTween(_tweens[i]);
				a[a.length] = _tweens[i];
			}
			if (_tweens[i].startTime >= time && !_tweens[i].enabled) {
				_tweens[i].enabled = true;
				_tweens[i].active = false;
			}
			
			// update loop variables
			i--;
		}

		if (!Math.isNaN(_pauseTime)) {
			var offset:Float = (TweenLite.currentTime - _pauseTime) / 1000;
			_pauseTime = Math.NaN;
			offsetTime(a, offset);
		}
	}

	/**
	 * Restarts the entire group of tweens, optionally including any delay from the first tween.
	 *  
	 * @param $includeDelay If true, any delay from the first tween (chronologically) is taken into account. 
	 */
	public function restart(?$includeDelay:Bool=false):Void {
		
		setProgress(0, $includeDelay);
		_repeatCount = 0;
		resume();
	}

	/**
	 * Reverses the entire group of tweens so that they appear to run backwards. If the group of tweens is partially finished when reverse() 
	 * is called, the timing is automatically adjusted so that no skips/jumps occur. For example, if the entire group of tweens would take 
	 * 10 seconds to complete (start to finish), and you call reverse() after 8 seconds, it will run the tweens backwards for another 8 seconds
	 * until the values are back to where they began. You may call reverse() as many times as you want and it will keep flipping the direction.
	 * So if you call reverse() twice, the group of tweens will be back to the original (forward) direction. 
	 * 
	 * @param $forcePlay Forces the group to resume() if it hasn't completed yet or restart() if it has.
	 */
	public function reverse(?$forcePlay:Bool=true):Void {
		
		_reversed = !_reversed;
		var i:Int;
		var tween:TweenLite;
		var proxy:ReverseProxy;
		var startTime:Float;
		var initTime:Float;
		var prog:Float;
		var tScale:Float;
		var timeOffset:Float = 0;
		var isFinished:Bool = false;
		var time:Float = (!Math.isNaN(_pauseTime)) ? _pauseTime : TweenLite.currentTime;
		if (this.endTime <= time) {
			timeOffset = Std.int(this.endTime - time) + 1;
			isFinished = true;
		}
		i = _tweens.length - 1;
		while (i > -1) {
			tween = _tweens[i];
			//TweenMax instances already have a "reverseEase()" function. I don't use "if (tween is TweenMax)" because it would bloat the file size by having to import TweenMax, so developers can just use this class with TweenLite to keep file size to a minimum if they so choose.
			if (Std.is(tween, _TweenMax)) {
				startTime = tween.startTime;
				initTime = tween.initTime;
				(cast(tween, Dynamic)).reverse(false, false);
				tween.startTime = startTime;
				tween.initTime = initTime;
			} else if (tween.ease != tween.vars.ease) {
				tween.ease = tween.vars.ease;
			} else {
				proxy = new ReverseProxy();
				tween.ease = proxy.reverseEase;
			}
			tScale = tween.combinedTimeScale;
			prog = (((time - tween.initTime) / 1000) - tween.delay / tScale) / tween.duration * tScale;
			startTime = Std.int(time - ((1 - prog) * tween.duration * 1000 / tScale) + timeOffset);
			tween.initTime = Std.int(startTime - (tween.delay * (1000 / tScale)));
			if (tween.startTime != 999999999999999) {
				tween.startTime = startTime;
			}
			//don't allow tweens with delays that haven't expired yet to be active
			if (tween.startTime > time) {
				tween.enabled = true;
				tween.active = false;
			}
			
			// update loop variables
			i--;
		}

		updateTimeSpan();
		if ($forcePlay) {
			if (isFinished) {
				setProgress(0, true);
			}
			resume();
		}
	}

	/**
	 * Provides an easy way to determine which tweens (if any) are currently active. Active tweens are not paused and are in the process of tweening values.
	 * 
	 * @return An Array of TweenLite/TweenMax instances from the group that are currently active (in the process of tweening)
	 */
	public function getActive():Array<Dynamic> {
		
		var a:Array<Dynamic> = [];
		if (Math.isNaN(_pauseTime)) {
			var i:Int;
			var time:Float = TweenLite.currentTime;
			i = _tweens.length - 1;
			while (i > -1) {
				if (_tweens[i].startTime <= time && getEndTime(_tweens[i]) >= time) {
					a[a.length] = _tweens[i];
				}
				
				// update loop variables
				i--;
			}

		}
		return a;
	}

	/**
	 * Merges (combines) two TweenGroups. You can even control the index at which the tweens are spliced in, or if you don't define one, the tweens will be added to the end.
	 * 
	 * @param $group The TweenGroup to add
	 * @param $startIndex The index at which to start splicing the tweens from the new TweenGroup. For example, if tweenGroupA has 3 elements, and you want to add tweenGroupB's tweens right after the first one, you'd call tweenGroupA.mergeGroup(tweenGroupB, 1);
	 */
	public function mergeGroup($group:TweenGroup, ?$startIndex:Float=Math.NaN):Void {
		
		if (Math.isNaN($startIndex) || $startIndex > _tweens.length) {
			$startIndex = _tweens.length;
		}
		var tweens:Array<Dynamic> = $group.tweens;
		var l:Int = tweens.length;
		var i:Int;
		i = 0;
		while (i < l) {
			_tweens.splice($startIndex + i, 0, tweens[i]);
			
			// update loop variables
			i++;
		}

		realign();
	}

	/**
	 * Removes all tweens from the group and kills the tweens using TweenLite.removeTween()
	 * 
	 * @param $killTweens Determines whether or not all of the tweens are killed (as opposed to simply being removed from this group but continuing to remain in the rendering queue)
	 */
	public function clear(?$killTweens:Bool=true):Void {
		
		var i:Int = _tweens.length - 1;
		while (i > -1) {
			if ($killTweens) {
				TweenLite.removeTween(_tweens[i], true);
			}
			_tweens[i] = null;
			_tweens.splice(i, 1);
			
			// update loop variables
			i--;
		}

		if (!this.expired) {
			i = _unexpired.length - 1;
			while (i > -1) {
				if (_unexpired[i] == this) {
					_unexpired.splice(i, 1);
					break;
				}
				
				// update loop variables
				i--;
			}

			this.expired = true;
		}
	}

	/** 
	 * Realigns all the tweens in the TweenGroup based on whatever the "align" property is set to. The only
	 * time you may need to call realign() is if you change a time-related property of an individual tween in the
	 * TweenGroup (like a tween's timeScale or duration). This is very uncommon.
	 */
	public function realign():Void {
		
		if (_align != ALIGN_NONE && _tweens.length > 1) {
			var l:Int = _tweens.length;
			var i:Int;
			var offset:Float = _stagger * 1000;
			var prog:Float;
			var rev:Bool = _reversed;
			if (rev) {
				prog = this.progressWithDelay;
				reverse();
				this.progressWithDelay = 0;
			}
			if (_align == ALIGN_SEQUENCE) {
				setTweenInitTime(_tweens[0], _initTime);
				i = 1;
				while (i < l) {
					setTweenInitTime(_tweens[i], getEndTime(_tweens[i - 1]) + offset);
					
					// update loop variables
					i++;
				}

			} else if (_align == ALIGN_INIT) {
				i = 0;
				while (i < l) {
					setTweenInitTime(_tweens[i], _initTime + (offset * i));
					
					// update loop variables
					i++;
				}

			} else if (_align == ALIGN_START) {
				i = 0;
				while (i < l) {
					setTweenStartTime(_tweens[i], _startTime + (offset * i));
					
					// update loop variables
					i++;
				}

				//ALIGN_END
				
			} else {
				i = 0;
				while (i < l) {
					setTweenInitTime(_tweens[i], this.endTime - ((_tweens[i].delay + _tweens[i].duration) * 1000 / _tweens[i].combinedTimeScale) - (offset * i));
					
					// update loop variables
					i++;
				}

			}
			if (rev) {
				reverse();
				this.progressWithDelay = prog;
			}
		}
		updateTimeSpan();
	}

	/** 
	 * Analyzes all of the tweens in the group and determines the overall init, start, and end times as well as the overall duration which 
	 * are necessary for accurate management. Normally a TweenGroup handles this internally, but if tweens are manipulated independently
	 * of TweenGroup or if a tween has its "loop" or "yoyo" special property set to true, it can cause these variables to become uncalibrated
	 * in which case you can use updateTimeSpan() to recalibrate. 
	 */
	public function updateTimeSpan():Void {
		
		if (_tweens.length == 0) {
			this.endTime = _startTime = _initTime = 0;
		} else {
			var i:Int;
			var start:Float;
			var init:Float;
			var end:Float;
			var tween:TweenLite;
			tween = _tweens[0];
			_initTime = tween.initTime;
			_startTime = _initTime + (tween.delay * (1000 / tween.combinedTimeScale));
			this.endTime = _startTime + (tween.duration * (1000 / tween.combinedTimeScale));
			i = _tweens.length - 1;
			while (i > 0) {
				tween = _tweens[i];
				init = tween.initTime;
				start = init + (tween.delay * (1000 / tween.combinedTimeScale));
				end = start + (tween.duration * (1000 / tween.combinedTimeScale));
				if (init < _initTime) {
					_initTime = init;
				}
				if (start < _startTime) {
					_startTime = start;
				}
				if (end > this.endTime) {
					this.endTime = end;
				}
				
				// update loop variables
				i--;
			}

			if (this.expired && this.endTime > TweenLite.currentTime) {
				this.expired = false;
				_unexpired[_unexpired.length] = this;
			}
		}
	}

	public function toString():String {
		
		return "TweenGroup( " + _tweens.toString() + " )";
	}

	//---- STATIC PUBLIC FUNCTIONS -----------------------------------------------------------------------------------
	/**
	 * Parses an Array that contains either TweenLite/TweenMax instances or Objects that are meant to define tween instances.
	 * Specifically, they must contain at LEAST "target" and "time" properties. For example: TweenGroup.parse([{target:mc1, time:2, x:300},{target:mc2, time:1, y:400}]);
	 *  
	 * @param $tweens An Array of either TweenLite/TweenMax instances or Objects that are meant to define tween instances. For example [{target:mc1, time:2, x:300},{target:mc2, time:1, y:400}]
	 * @param $BaseTweenClass Defines which tween class should be used when parsing objects that are not already TweenLite/TweenMax instances. Choices are TweenLite or TweenMax.
	 * @return An Array with only TweenLite/TweenMax instances
	 */
	public static function parse($tweens:Array<Dynamic>, ?$DefaultTweenClass:Class<Dynamic>=null):Array<Dynamic> {
		
		if ($DefaultTweenClass == null) {
			$DefaultTweenClass = TweenLite;
		}
		var a:Array<Dynamic> = [];
		var i:Int;
		var target:Dynamic;
		var duration:Float;
		i = 0;
		while (i < $tweens.length) {
			if (Std.is($tweens[i], TweenLite)) {
				a[a.length] = $tweens[i];
			} else {
				target = $tweens[i].target;
				duration = $tweens[i].time;
				$tweens[i].target = null;
				$tweens[i].time = null;
				a[a.length] = Type.createInstance($DefaultTweenClass, []);
			}
			
			// update loop variables
			i++;
		}

		return a;
	}

	/**
	 * Provides an easy way to tween multiple objects to the same values. It also accepts a few special properties, like "stagger" which 
	 * staggers the start time of each tween. For example, you might want to have 5 MovieClips move down 100 pixels while fading out, and stagger 
	 * the start times slightly by 0.2 seconds, you could do:  
	 * TweenGroup.allTo([mc1, mc2, mc3, mc4, mc5], 1, {y:"100", alpha:0, stagger:0.2});
	 * 
	 * @param $targets An Array of objects to tween.
	 * @param $duration Duration (in seconds) of the tween
	 * @param $vars An object containing the end values of all the properties you'd like to have tweened (or if you're using the TweenGroup.allFrom() method, these variables would define the BEGINNING values). Additional special properties: "stagger", "onCompleteAll", and "onCompleteAllParams"
	 * @param $DefaultTweenClass Defines which tween class to use. Choices are TweenLite or TweenMax.
	 * @return TweenGroup instance
	 */
	public static function allTo($targets:Array<Dynamic>, $duration:Float, $vars:Dynamic, ?$DefaultTweenClass:Class<Dynamic>=null):TweenGroup {
		
		if ($DefaultTweenClass == null) {
			$DefaultTweenClass = TweenLite;
		}
		var i:Int;
		var vars:Dynamic;
		var p:String;
		var group:TweenGroup = new TweenGroup();
		group.onComplete = $vars.onCompleteAll;
		group.onCompleteParams = $vars.onCompleteAllParams;
		$vars.stagger = null;
		$vars.onCompleteAll = null;
		$vars.onCompleteAllParams = null;
		i = 0;
		while (i < $targets.length) {
			vars = {};
			for (p in Reflect.fields($vars)) {
				Reflect.setField(vars, p, Reflect.field($vars, p));
				
			}

			Reflect.setField(group, group.length, Type.createInstance($DefaultTweenClass, []));
			
			// update loop variables
			i++;
		}

		if (group.stagger < 0) {
			group.progressWithDelay = 0;
		}
		return group;
	}

	/**
	 * Exactly the same as TweenGroup.allTo(), but instead of tweening the properties from where they're at currently to whatever you define, this tweens them the opposite way - from where you define TO where ever they are. This is handy for when things are set up on the stage the way they should end up and you just want to tween them into place.
	 * 
	 * @param $targets An Array of objects to tween.
	 * @param $duration Duration (in seconds) of the tween
	 * @param $vars An object containing the beginning values of all the properties you'd like to have tweened. Additional special properties: "stagger", "onCompleteAll", and "onCompleteAllParams"
	 * @param $DefaultTweenClass Defines which tween class to use. Choices are TweenLite or TweenMax.
	 * @return TweenGroup instance
	 */
	public static function allFrom($targets:Array<Dynamic>, $duration:Float, $vars:Dynamic, ?$DefaultTweenClass:Class<Dynamic>=null):TweenGroup {
		
		$vars.runBackwards = true;
		return allTo($targets, $duration, $vars, $DefaultTweenClass);
	}

	//---- PROTECTED STATIC FUNCTIONS -------------------------------------------------------------------------------
	private static function checkExpiration($e:Event):Void {
		
		var time:Int = TweenLite.currentTime;
		var a:Array<Dynamic> = _unexpired;
		var tg:TweenGroup;
		var i:Int;
		i = a.length - 1;
		while (i > -1) {
			tg = a[i];
			if (tg.endTime > _prevTime && tg.endTime <= time && !tg.paused) {
				a.splice(i, 1);
				tg.expired = true;
				tg.handleCompletion();
			}
			
			// update loop variables
			i--;
		}

		_prevTime = time;
	}

	//---- PROTECTED FUNCTIONS ---------------------------------------------------------------------------------------
	private function offsetTime($tweens:Array<Dynamic>, $offset:Float):Void {
		
		if ($tweens.length != 0) {
			var ms:Float = $offset * 1000;
			var time:Float = (Math.isNaN(_pauseTime)) ? TweenLite.currentTime : _pauseTime;
			var tweens:Array<Dynamic> = getRenderOrder($tweens, time);
			var isPaused:Bool;
			var tween:TweenLite;
			var render:Bool;
			var startTime:Float;
			var end:Float;
			var i:Int;
			var toRender:Array<Dynamic> = [];
			i = tweens.length - 1;
			while (i > -1) {
				tween = tweens[i];
				tween.initTime += ms;
				isPaused = Boolean(tween.startTime == 999999999999999);
				//this forces paused tweens with false start times to adjust to the normal one temporarily so that we can render it properly.
				startTime = tween.initTime + (tween.delay * (1000 / tween.combinedTimeScale));
				end = getEndTime(tween);
				//only render what's necessary
				render = ((startTime <= time || startTime - ms <= time) && (end >= time || end - ms >= time));
				if (Math.isNaN(_pauseTime) && end >= time) {
					tween.enabled = true;
				}
				if (!isPaused) {
					tween.startTime = startTime;
				}
				//don't allow tweens with delays that haven't expired yet to be active
				if (startTime >= time) {
					if (!tween.initted) {
						render = false;
					}
					tween.active = false;
				}
				if (render) {
					toRender[toRender.length] = tween;
				}
				
				// update loop variables
				i--;
			}

			i = toRender.length - 1;
			while (i > -1) {
				renderTween(toRender[i], time);
				
				// update loop variables
				i--;
			}

			this.endTime += ms;
			_startTime += ms;
			_initTime += ms;
			if (this.expired && this.endTime > time) {
				this.expired = false;
				_unexpired[_unexpired.length] = this;
			}
		}
	}

	private function renderTween($tween:TweenLite, $time:Float):Void {
		
		var end:Float = getEndTime($tween);
		var renderTime:Float;
		var isPaused:Bool;
		if ($tween.startTime == 999999999999999) {
			$tween.startTime = $tween.initTime + ($tween.delay * (1000 / $tween.combinedTimeScale));
			isPaused = true;
		}
		if (!$tween.initted) {
			var active:Bool = $tween.active;
			$tween.active = false;
			if (isPaused) {
				$tween.initTweenVals();
				if ($tween.vars.onStart != null) {
					$tween.vars.onStart.apply(null, $tween.vars.onStartParams);
				}
			} else {
				$tween.activate();
			}
			$tween.active = active;
		}
		//don't allow tweens with delays that haven't expired yet to be active
		if ($tween.startTime > $time) {
			renderTime = $tween.startTime;
		} else if (end < $time) {
			renderTime = end;
		} else {
			renderTime = $time;
		}
		//render time is uint, so it must be zero or greater.
		if (renderTime < 0) {
			var originalStart:Float = $tween.startTime;
			$tween.startTime -= renderTime;
			$tween.render(0);
			$tween.startTime = originalStart;
		} else {
			$tween.render(renderTime);
		}
		if (isPaused) {
			$tween.startTime = 999999999999999;
		}
	}

	/**
	 * If there are multiple tweens in the same group that control the same property of the same property, we need to make sure they're rendered in the correct
	 * order so that the one(s) closest in proximity to the current time is rendered last. Feed this function an Array of tweens and the time and it'll return
	 * an Array with them in the correct render order.
	 *  
	 * @param $tweens An Array of tweens to get in the correct render order
	 * @param $time Time (in milliseconds) which defines the proximity point for each tween (typically the render time)
	 * @return An Array with the tweens in the correct render order
	 */
	private function getRenderOrder($tweens:Array<Dynamic>, $time:Float):Array<Dynamic> {
		
		var i:Int;
		var startTime:Float;
		var postTweens:Array<Dynamic> = [];
		var preTweens:Array<Dynamic> = [];
		var a:Array<Dynamic> = [];
		i = $tweens.length - 1;
		while (i > -1) {
			startTime = getStartTime($tweens[i]);
			if (startTime >= $time) {
				postTweens[postTweens.length] = {start:startTime, tween:$tweens[i]};
			} else {
				preTweens[preTweens.length] = {end:getEndTime($tweens[i]), tween:$tweens[i]};
			}
			
			// update loop variables
			i--;
		}

		postTweens.sortOn("start", Array.NUMERIC);
		preTweens.sortOn("end", Array.NUMERIC);
		i = postTweens.length - 1;
		while (i > -1) {
			a[i] = postTweens[i].tween;
			
			// update loop variables
			i--;
		}

		i = preTweens.length - 1;
		while (i > -1) {
			a[a.length] = preTweens[i].tween;
			
			// update loop variables
			i--;
		}

		return a;
	}

	private function pauseTween($tween:TweenLite):Void {
		
		if (Std.is($tween, _TweenMax)) {
			(cast($tween, Dynamic)).pauseTime = _pauseTime;
		}
		//for OverwriteManager
		$tween.startTime = 999999999999999;
		$tween.enabled = false;
	}

	private function resumeTween($tween:TweenLite):Void {
		
		if (Std.is($tween, _TweenMax)) {
			(cast($tween, Dynamic)).pauseTime = Math.NaN;
		}
		$tween.startTime = $tween.initTime + ($tween.delay * (1000 / $tween.combinedTimeScale));
	}

	private function getEndTime($tween:TweenLite):Float {
		
		return $tween.initTime + (($tween.delay + $tween.duration) * (1000 / $tween.combinedTimeScale));
	}

	private function getStartTime($tween:TweenLite):Float {
		
		return $tween.initTime + ($tween.delay * 1000 / $tween.combinedTimeScale);
	}

	private function setTweenInitTime($tween:TweenLite, $initTime:Float):Void {
		
		var offset:Float = $initTime - $tween.initTime;
		$tween.initTime = $initTime;
		//required for OverwriteManager (indicates a tween has been paused)
		if ($tween.startTime != 999999999999999) {
			$tween.startTime += offset;
		}
	}

	private function setTweenStartTime($tween:TweenLite, $startTime:Float):Void {
		
		var offset:Float = $startTime - getStartTime($tween);
		$tween.initTime += offset;
		//required for OverwriteManager (indicates a tween has been paused)
		if ($tween.startTime != 999999999999999) {
			$tween.startTime = $startTime;
		}
	}

	private function getProgress(?$includeDelay:Bool=false):Float {
		
		if (_tweens.length == 0) {
			return 0;
		} else {
			var time:Float = (Math.isNaN(_pauseTime)) ? TweenLite.currentTime : _pauseTime;
			var min:Float = ($includeDelay) ? _initTime : _startTime;
			var p:Float = (time - min) / (this.endTime - min);
			if (p < 0) {
				return 0;
			} else if (p > 1) {
				return 1;
			} else {
				return p;
			}
		}
		
		// autogenerated
		return 0;
	}

	private function setProgress($progress:Float, ?$includeDelay:Bool=false):Void {
		
		if (_tweens.length != 0) {
			var time:Float = (Math.isNaN(_pauseTime)) ? TweenLite.currentTime : _pauseTime;
			var min:Float = ($includeDelay) ? _initTime : _startTime;
			offsetTime(_tweens, (time - (min + ((this.endTime - min) * $progress))) / 1000);
		}
	}

	public function handleCompletion():Void {
		
		if (!Math.isNaN(this.yoyo) && (_repeatCount < this.yoyo || this.yoyo == 0)) {
			_repeatCount++;
			reverse(true);
		} else if (!Math.isNaN(this.loop) && (_repeatCount < this.loop || this.loop == 0)) {
			_repeatCount++;
			setProgress(0, true);
		}
		if (this.onComplete != null) {
			this.onComplete.apply(null, this.onCompleteParams);
		}
		_dispatcher.dispatchEvent(new Event());
	}

	//---- GETTERS / SETTERS --------------------------------------------------------------------------------------------------
	/**
	 * @return Number of tweens in the group 
	 */
	public function getLength():Int {
		
		return _tweens.length;
	}

	/**
	 * @return Overall progress of the group of tweens (not including any initial delay) as represented numerically between 0 and 1 where 0 means the group hasn't started, 0.5 means it is halfway finished, and 1 means it has completed.
	 */
	public function getProgress():Float {
		
		return getProgress(false);
	}

	/**
	 * Controls the overall progress of the group of tweens (not including any initial delay) as represented numerically between 0 and 1.
	 * 
	 * @param $n Overall progress of the group of tweens (not including any initial delay) as represented numerically between 0 and 1 where 0 means the group hasn't started, 0.5 means it is halfway finished, and 1 means it has completed.
	 */
	public function setProgress($n:Float):Float {
		
		setProgress($n, false);
		return $n;
	}

	/**
	 * @return Overall progress of the group of tweens (including any initial delay) as represented numerically between 0 and 1 where 0 means the group hasn't started, 0.5 means it is halfway finished, and 1 means it has completed.
	 */
	public function getProgressWithDelay():Float {
		
		return getProgress(true);
	}

	/**
	 * Controls the overall progress of the group of tweens (including any initial delay) as represented numerically between 0 and 1.
	 * 
	 * @param $n Overall progress of the group of tweens (including any initial delay) as represented numerically between 0 and 1 where 0 means the group hasn't started, 0.5 means it is halfway finished, and 1 means it has completed.
	 */
	public function setProgressWithDelay($n:Float):Float {
		
		setProgress($n, true);
		return $n;
	}

	/**
	 * @return Duration (in seconds) of the group of tweens NOT including any initial delay
	 */
	public function getDuration():Float {
		
		if (_tweens.length == 0) {
			return 0;
		} else {
			return (this.endTime - _startTime) / 1000;
		}
		
		// autogenerated
		return 0;
	}

	/**
	 * @return Duration (in seconds) of the group of tweens including any initial delay
	 */
	public function getDurationWithDelay():Float {
		
		if (_tweens.length == 0) {
			return 0;
		} else {
			return (this.endTime - _initTime) / 1000;
		}
		
		// autogenerated
		return 0;
	}

	/**
	 * @return If the group of tweens is paused, this value will be true. Otherwise, it will be false.
	 */
	public function getPaused():Bool {
		
		return (!Math.isNaN(_pauseTime));
	}

	/**
	 * Sets the paused state of the group of tweens
	 * 
	 * @param $b Sets the paused state of the group of tweens.
	 */
	public function setPaused($b:Bool):Bool {
		
		if ($b) {
			pause();
		} else {
			resume();
		}
		return $b;
	}

	/**
	 * @return If the group of tweens is reversed, this value will be true. Otherwise, it will be false.
	 */
	public function getReversed():Bool {
		
		return _reversed;
	}

	/**
	 * Sets the reversed state of the group of tweens
	 * 
	 * @param $b Sets the reversed state of the group of tweens.
	 */
	public function setReversed($b:Bool):Bool {
		
		if (_reversed != $b) {
			reverse(true);
		}
		return $b;
	}

	/**
	 * @return timeScale property of the first TweenMax instance in the group (or 1 if there aren't any). Remember, timeScale edits do NOT affect TweenLite instances!
	 */
	public function getTimeScale():Float {
		
		var i:Int = 0;
		while (i < _tweens.length) {
			if (Std.is(_tweens[i], _TweenMax)) {
				return _tweens[i].timeScale;
			}
			
			// update loop variables
			i++;
		}

		return 1;
	}

	/**
	 * Changes the timeScale of all TweenMax instances in the TweenGroup. Remember, TweenLite instances are NOT affected by timeScale!
	 * 
	 * @param $n time scale for all TweenMax instances in the TweenGroup. 1 is normal speed, 0.5 is half speed, 2 is double speed, etc.
	 */
	public function setTimeScale($n:Float):Float {
		
		var i:Int = _tweens.length - 1;
		while (i > -1) {
			if (Std.is(_tweens[i], _TweenMax)) {
				_tweens[i].timeScale = $n;
			}
			
			// update loop variables
			i--;
		}

		updateTimeSpan();
		return $n;
	}

	/**
	 * @return Alignment of the tweens within the group. possible values are "sequence", "start", "end", "init", and "none"
	 */
	public function getAlign():String {
		
		return _align;
	}

	/**
	 * Controls the alignment of the tweens within the group. Typically it's best to use the constants TweenGroup.ALIGN_SEQUENCE, TweenGroup.ALIGN_START, TweenGroup.ALIGN_END, TweenGroup.ALIGN_INIT, or TweenGroup.ALIGN_NONE
	 * 
	 * @param $s Sets the alignment of the tweens within the group. Typically it's best to use the constants TweenGroup.ALIGN_SEQUENCE, TweenGroup.ALIGN_START, TweenGroup.ALIGN_END, TweenGroup.ALIGN_INIT, or TweenGroup.ALIGN_NONE
	 */
	public function setAlign($s:String):String {
		
		_align = $s;
		realign();
		return $s;
	}

	/**
	 * @return Amount of time (in seconds) to offset each tween according to the current alignment. For example, if the align property is set to ALIGN_SEQUENCE and stagger is 0.5, this adds 0.5 seconds between each tween in the sequence. If align is set to ALIGN_START, it would add 0.5 seconds to the start time of each tween (0 for the first tween, 0.5 for the second, 1 for the third, etc.)
	 */
	public function getStagger():Float {
		
		return _stagger;
	}

	/**
	 * Controls the amount of time (in seconds) to offset each tween according to the current alignment. For example, if the align property is set to ALIGN_SEQUENCE and stagger is 0.5, this adds 0.5 seconds between each tween in the sequence. If align is set to ALIGN_START, it would add 0.5 seconds to the start time of each tween (0 for the first tween, 0.5 for the second, 1 for the third, etc.)
	 * 
	 * @param $s Amount of time (in seconds) to offset each tween according to the current alignment. For example, if the align property is set to ALIGN_SEQUENCE and stagger is 0.5, this adds 0.5 seconds between each tween in the sequence. If align is set to ALIGN_START, it would add 0.5 seconds to the start time of each tween (0 for the first tween, 0.5 for the second, 1 for the third, etc.)
	 */
	public function setStagger($n:Float):Float {
		
		_stagger = $n;
		realign();
		return $n;
	}

	/**
	 * @return An Array of the tweens in this TweenGroup (this could be used to concat() with another TweenGroup for example) 
	 */
	public function getTweens():Array<Dynamic> {
		
		return _tweens.slice();
	}

}

