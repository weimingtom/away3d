package gs;

import gs.events.TweenEvent;
import gs.plugins.BezierThroughPlugin;
import gs.plugins.BevelFilterPlugin;
import flash.events.IEventDispatcher;
import flash.events.EventDispatcher;
import gs.plugins.HexColorsPlugin;
import gs.plugins.BezierPlugin;
import flash.utils.Dictionary;
import flash.events.Event;
import gs.plugins.VisiblePlugin;
import gs.plugins.FramePlugin;
import gs.plugins.BlurFilterPlugin;
import gs.plugins.ShortRotationPlugin;
import gs.plugins.DropShadowFilterPlugin;
import gs.utils.tween.TweenInfo;
import gs.plugins.ColorMatrixFilterPlugin;
import gs.plugins.GlowFilterPlugin;
import gs.plugins.RemoveTintPlugin;
import gs.plugins.RoundPropsPlugin;
import gs.plugins.VolumePlugin;
import gs.plugins.AutoAlphaPlugin;
import gs.plugins.TweenPlugin;
import gs.plugins.EndArrayPlugin;
import gs.plugins.TintPlugin;


class TweenMax extends TweenLite, implements IEventDispatcher {
	public var paused(getPaused, setPaused) : Bool;
	public var reversed(getReversed, setReversed) : Bool;
	public var timeScale(getTimeScale, setTimeScale) : Float;
	public var enabled(null, setEnabled) : Bool;
	public var globalTimeScale(getGlobalTimeScale, setGlobalTimeScale) : Float;
	public var progress(getProgress, setProgress) : Float;
	
	public static inline var version:Float = 10.07;
	private static var _activatedPlugins:Bool = TweenPlugin.activate([TintPlugin, RemoveTintPlugin, FramePlugin, AutoAlphaPlugin, VisiblePlugin, VolumePlugin, EndArrayPlugin, HexColorsPlugin, BlurFilterPlugin, ColorMatrixFilterPlugin, BevelFilterPlugin, DropShadowFilterPlugin, GlowFilterPlugin, RoundPropsPlugin, BezierPlugin, BezierThroughPlugin, ShortRotationPlugin]);
	//activated in static var instead of constructor because otherwise if there's a from() tween, TweenLite's constructor would get called first and initTweenVals() would run before the plugins were activated.
	private static var _versionCheck:Bool = (TweenLite.version < 10.06) ? trace("TweenMax error! Please update your TweenLite class or try deleting your ASO files. TweenMax requires a more recent version. Download updates at http://www.TweenMax.com.") : true;
	//OverwriteManager is optional for TweenLite and TweenFilterLite, but it is used by default in TweenMax.
	private static var _overwriteMode:Int = (OverwriteManager.enabled) ? OverwriteManager.mode : OverwriteManager.init();
	public static var killTweensOf:Dynamic = TweenLite.killTweensOf;
	public static var killDelayedCallsTo:Dynamic = TweenLite.killTweensOf;
	public static var removeTween:Dynamic = TweenLite.removeTween;
	//protects from garbage collection issues
	private static var _pausedTweens:Dictionary = new Dictionary(false);
	private static var _globalTimeScale:Float = 1;
	private var _dispatcher:EventDispatcher;
	//stores the original onComplete, onStart, and onUpdate Functions from the this.vars Object (we replace them if/when dispatching events)
	private var _callbacks:Dynamic;
	//number of times the tween has yoyo'd or loop'd.
	private var _repeatCount:Float;
	//Allows you to speed up or slow down a tween. Default is 1 (normal speed) 0.5 would be half-speed
	private var _timeScale:Float;
	public var pauseTime:Float;
	

	public function new($target:Dynamic, $duration:Float, $vars:Dynamic) {
		
		
		super($target, $duration, $vars);
		//in case the user is trying to tween the timeScale of another TweenFilterLite/TweenMax instance
		if (this.combinedTimeScale != 1 && Std.is(this.target, TweenMax)) {
			_timeScale = 1;
			this.combinedTimeScale = _globalTimeScale;
		} else {
			_timeScale = this.combinedTimeScale;
			//combining them speeds processing in important functions like render().
			this.combinedTimeScale *= _globalTimeScale;
		}
		if (this.combinedTimeScale != 1 && this.delay != 0) {
			this.startTime = this.initTime + (this.delay * (1000 / this.combinedTimeScale));
		}
		if (this.vars.onCompleteListener != null || this.vars.onUpdateListener != null || this.vars.onStartListener != null) {
			initDispatcher();
			if ($duration == 0 && this.delay == 0) {
				onUpdateDispatcher();
				onCompleteDispatcher();
			}
		}
		_repeatCount = 0;
		if (!Math.isNaN(this.vars.yoyo) || !Math.isNaN(this.vars.loop)) {
			this.vars.persist = true;
		}
	}

	override public function initTweenVals():Void {
		
		if (this.exposedVars.startAt != null) {
			this.exposedVars.startAt.overwrite = 0;
			new TweenMax(this.target, 0, this.exposedVars.startAt);
		}
		super.initTweenVals();
		//accommodate rounding if necessary...
		if (Std.is(this.exposedVars.roundProps, Array<Dynamic>) && TweenLite.plugins.roundProps != null) {
			var i:Int;
			var j:Int;
			var prop:String;
			var multiProps:String;
			var rp:Array<Dynamic> = this.exposedVars.roundProps;
			var plugin:Dynamic;
			var ti:TweenInfo;
			i = rp.length - 1;
			while (i > -1) {
				prop = rp[i];
				j = this.tweens.length - 1;
				while (j > -1) {
					ti = this.tweens[j];
					if (ti.name == prop) {
						if (ti.isPlugin) {
							ti.target.round = true;
						} else {
							if (plugin == null) {
								plugin = Type.createInstance(TweenLite.plugins.roundProps, []);
								plugin.add(ti.target, prop, ti.start, ti.change);
								_hasPlugins = true;
								this.tweens[j] = new TweenInfo(plugin, "changeFactor", 0, 1, prop, true);
							} else {
								plugin.add(ti.target, prop, ti.start, ti.change);
								this.tweens.splice(j, 1);
							}
						}
					} else if (ti.isPlugin && ti.name == "_MULTIPLE_" && !ti.target.round) {
						multiProps = " " + ti.target.overwriteProps.join(" ") + " ";
						if (multiProps.indexOf(" " + prop + " ") != -1) {
							ti.target.round = true;
						}
					}
					
					// update loop variables
					j--;
				}

				
				// update loop variables
				i--;
			}

		}
	}

	public function pause():Void {
		
		if (Math.isNaN(this.pauseTime)) {
			this.pauseTime = currentTime;
			//required for OverwriteManager
			this.startTime = 999999999999999;
			this.enabled = false;
			_pausedTweens[untyped this] = this;
		}
	}

	public function resume():Void {
		
		this.enabled = true;
		if (!Math.isNaN(this.pauseTime)) {
			this.initTime += currentTime - this.pauseTime;
			this.startTime = this.initTime + (this.delay * (1000 / this.combinedTimeScale));
			this.pauseTime = Math.NaN;
			if (!this.started && currentTime >= this.startTime) {
				activate();
			} else {
				this.active = this.started;
			}
			_pausedTweens[untyped this] = null;
			_pausedTweens[untyped this] = null;
		}
	}

	public function restart(?$includeDelay:Bool=false):Void {
		
		if ($includeDelay) {
			this.initTime = currentTime;
			this.startTime = currentTime + (this.delay * (1000 / this.combinedTimeScale));
		} else {
			this.startTime = currentTime;
			this.initTime = currentTime - (this.delay * (1000 / this.combinedTimeScale));
		}
		_repeatCount = 0;
		//protects delayedCall()s from being rendered.
		if (this.target != this.vars.onComplete) {
			render(this.startTime);
		}
		this.pauseTime = Math.NaN;
		_pausedTweens[untyped this] = null;
		_pausedTweens[untyped this] = null;
		this.enabled = true;
	}

	public function reverse(?$adjustDuration:Bool=true, ?$forcePlay:Bool=true):Void {
		
		this.ease = (this.vars.ease == this.ease) ? reverseEase : this.vars.ease;
		var p:Float = this.progress;
		if ($adjustDuration && p > 0) {
			this.startTime = currentTime - ((1 - p) * this.duration * 1000 / this.combinedTimeScale);
			this.initTime = this.startTime - (this.delay * (1000 / this.combinedTimeScale));
		}
		if ($forcePlay != false) {
			if (p < 1) {
				resume();
			} else {
				restart();
			}
		}
	}

	public function reverseEase($t:Float, $b:Float, $c:Float, $d:Float):Float {
		
		return this.vars.ease($d - $t, $b, $c, $d);
	}

	//forces the vars to be re-parsed and immediately re-rendered
	public function invalidate(?$adjustStartValues:Bool=true):Void {
		
		if (this.initted) {
			var p:Float = this.progress;
			if (!$adjustStartValues && p != 0) {
				this.progress = 0;
			}
			this.tweens = [];
			_hasPlugins = false;
			//for TweenLiteVars and TweenMaxVars
			this.exposedVars = (this.vars.isTV == true) ? this.vars.exposedProps : this.vars;
			initTweenVals();
			_timeScale = (this.vars.timeScale > 0) ? this.vars.timeScale : 1;
			this.combinedTimeScale = _timeScale * _globalTimeScale;
			this.delay = (this.vars.delay > 0) ? this.vars.delay : 0;
			if (Math.isNaN(this.pauseTime)) {
				this.startTime = this.initTime + (this.delay * 1000 / this.combinedTimeScale);
			}
			if (this.vars.onCompleteListener != null || this.vars.onUpdateListener != null || this.vars.onStartListener != null) {
				if (_dispatcher != null) {
					this.vars.onStart = _callbacks.onStart;
					this.vars.onUpdate = _callbacks.onUpdate;
					this.vars.onComplete = _callbacks.onComplete;
					_dispatcher = null;
				}
				initDispatcher();
			}
			if (p != 0) {
				if ($adjustStartValues) {
					adjustStartValues();
				} else {
					this.progress = p;
				}
			}
		}
	}

	public function setDestination($property:String, $value:Dynamic, ?$adjustStartValues:Bool=true):Void {
		
		var p:Float = this.progress;
		var i:Int;
		if (this.initted) {
			if (!$adjustStartValues && p != 0) {
				i = this.tweens.length - 1;
				while (i > -1) {
					if (this.tweens[i].name == $property) {
						this.tweens[i].target[this.tweens[i].property] = this.tweens[i].start;
					}
					
					// update loop variables
					i--;
				}

			}
			var varsOld:Dynamic = this.vars;
			var tweensOld:Array<Dynamic> = this.tweens;
			var hadPlugins:Bool = _hasPlugins;
			this.tweens = [];
			this.vars = this.exposedVars = {};
			this.vars[$property] = $value;
			initTweenVals();
			if (this.ease != reverseEase && Std.is(varsOld.ease, Dynamic)) {
				this.ease = varsOld.ease;
			}
			if ($adjustStartValues && p != 0) {
				adjustStartValues();
			}
			var addedTweens:Array<Dynamic> = this.tweens;
			this.vars = varsOld;
			this.tweens = tweensOld;
			var v:Dynamic = {};
			var j:Int;
			var overwriteProps:Array<Dynamic>;
			i = addedTweens.length - 1;
			while (i > -1) {
				if (addedTweens[i][4] == "_MULTIPLE_") {
					overwriteProps = addedTweens[i][0].overwriteProps;
					j = overwriteProps.length - 1;
					while (j > -1) {
						Reflect.setField(v, overwriteProps[j], true);
						
						// update loop variables
						j--;
					}

				} else {
					Reflect.setField(v, addedTweens[i][4], true);
				}
				
				// update loop variables
				i--;
			}

			killVars(v);
			this.tweens = this.tweens.concat(addedTweens);
			_hasPlugins = Boolean(hadPlugins || _hasPlugins);
		}
		this.vars[$property] = $value;
	}

	//adjusts the start values in the tweens so that the current progress and end values are maintained which prevents "skipping" when changing destination values mid-way through the tween.
	private function adjustStartValues():Void {
		
		var p:Float = this.progress;
		if (p != 0) {
			var factor:Float = this.ease(p, 0, 1, 1);
			var inv:Float = 1 / (1 - factor);
			var endValue:Float;
			var ti:TweenInfo;
			var i:Int;
			i = this.tweens.length - 1;
			while (i > -1) {
				ti = this.tweens[i];
				//[object, property, start, change, name, isPlugin]
				endValue = ti.start + ti.change;
				//can't read the "progress" value of a plugin, but we know what it is based on the factor (above)
				if (ti.isPlugin) {
					ti.change = (endValue - factor) * inv;
				} else {
					ti.change = (endValue - Reflect.field(ti.target, ti.property)) * inv;
				}
				ti.start = endValue - ti.change;
				
				// update loop variables
				i--;
			}

		}
	}

	public function killProperties($names:Array<Dynamic>):Void {
		
		var v:Dynamic = {};
		var i:Int;
		i = $names.length - 1;
		while (i > -1) {
			Reflect.setField(v, $names[i], true);
			
			// update loop variables
			i--;
		}

		killVars(v);
	}

	override public function render($t:Int):Void {
		
		var time:Float = ($t - this.startTime) * 0.001 * this.combinedTimeScale;
		var factor:Float;
		var ti:TweenInfo;
		var i:Int;
		if (time >= this.duration) {
			time = this.duration;
			//to accommodate TweenMax.reverse(). Without this, the last frame would render incorrectly
			factor = (this.ease == this.vars.ease || this.duration == 0.001) ? 1 : 0;
		} else {
			factor = this.ease(time, 0, 1, this.duration);
		}
		i = this.tweens.length - 1;
		while (i > -1) {
			ti = this.tweens[i];
			//tween index values: [object, property, start, change, name, isPlugin]
			Reflect.setField(ti.target, ti.property, ti.start + (factor * ti.change));
			
			// update loop variables
			i--;
		}

		if (_hasUpdate) {
			this.vars.onUpdate.apply(null, this.vars.onUpdateParams);
		}
		//Check to see if we're done
		if (time == this.duration) {
			complete(true);
		}
	}

	override public function complete(?$skipRender:Bool=false):Void {
		
		if ((!Math.isNaN(this.vars.yoyo) && (_repeatCount < this.vars.yoyo || this.vars.yoyo == 0)) || (!Math.isNaN(this.vars.loop) && (_repeatCount < this.vars.loop || this.vars.loop == 0))) {
			_repeatCount++;
			if (!Math.isNaN(this.vars.yoyo)) {
				this.ease = (this.vars.ease == this.ease) ? reverseEase : this.vars.ease;
			}
			//for more accurate results, add the duration to the startTime, otherwise a few milliseconds might be skipped. You can occassionally see this if you have two simultaneous looping tweens with different end times that move objects that are butted up against each other.
			this.startTime = ($skipRender) ? this.startTime + (this.duration * (1000 / this.combinedTimeScale)) : currentTime;
			this.initTime = this.startTime - (this.delay * (1000 / this.combinedTimeScale));
		} else if (this.vars.persist == true) {
			pause();
			//return;
			
		}
		super.complete($skipRender);
	}

	//---- EVENT DISPATCHING ----------------------------------------------------------------------------------------------------------
	private function initDispatcher():Void {
		
		if (_dispatcher == null) {
			_dispatcher = new EventDispatcher(this);
			//store the originals
			_callbacks = {onStart:this.vars.onStart, onUpdate:this.vars.onUpdate, onComplete:this.vars.onComplete};
			//For TweenLiteVars, TweenFilterLiteVars, and TweenMaxVars compatibility
			if (this.vars.isTV == true) {
				this.vars = this.vars.clone();
			} else {
				var v:Dynamic = {};
				var p:String;
				for (p in Reflect.fields(this.vars)) {
					Reflect.setField(v, p, this.vars[p]);
					
				}

				this.vars = v;
			}
			this.vars.onStart = onStartDispatcher;
			this.vars.onComplete = onCompleteDispatcher;
			if (Std.is(this.vars.onStartListener, Dynamic)) {
				_dispatcher.addEventListener(TweenEvent.START, this.vars.onStartListener, false, 0, true);
			}
			if (Std.is(this.vars.onUpdateListener, Dynamic)) {
				_dispatcher.addEventListener(TweenEvent.UPDATE, this.vars.onUpdateListener, false, 0, true);
				//To improve performance, we only want to add UPDATE dispatching if absolutely necessary.
				this.vars.onUpdate = onUpdateDispatcher;
				_hasUpdate = true;
			}
			if (Std.is(this.vars.onCompleteListener, Dynamic)) {
				_dispatcher.addEventListener(TweenEvent.COMPLETE, this.vars.onCompleteListener, false, 0, true);
			}
		}
	}

	private function onStartDispatcher(?$args:Array<Dynamic>):Void {
		if ($args == null) $args = new Array<Dynamic>();
		
		if (_callbacks.onStart != null) {
			_callbacks.onStart.apply(null, this.vars.onStartParams);
		}
		_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.START));
	}

	private function onUpdateDispatcher(?$args:Array<Dynamic>):Void {
		if ($args == null) $args = new Array<Dynamic>();
		
		if (_callbacks.onUpdate != null) {
			_callbacks.onUpdate.apply(null, this.vars.onUpdateParams);
		}
		_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.UPDATE));
	}

	private function onCompleteDispatcher(?$args:Array<Dynamic>):Void {
		if ($args == null) $args = new Array<Dynamic>();
		
		if (_callbacks.onComplete != null) {
			_callbacks.onComplete.apply(null, this.vars.onCompleteParams);
		}
		_dispatcher.dispatchEvent(new TweenEvent(TweenEvent.COMPLETE));
	}

	public function addEventListener($type:String, $listener:Dynamic, ?$useCapture:Bool=false, ?$priority:Int=0, ?$useWeakReference:Bool=false):Void {
		
		if (_dispatcher == null) {
			initDispatcher();
		}
		//To improve performance, we only want to add UPDATE dispatching if absolutely necessary.
		if ($type == TweenEvent.UPDATE && this.vars.onUpdate != onUpdateDispatcher) {
			this.vars.onUpdate = onUpdateDispatcher;
			_hasUpdate = true;
		}
		_dispatcher.addEventListener($type, $listener, $useCapture, $priority, $useWeakReference);
	}

	public function removeEventListener($type:String, $listener:Dynamic, ?$useCapture:Bool=false):Void {
		
		if (_dispatcher != null) {
			_dispatcher.removeEventListener($type, $listener, $useCapture);
		}
	}

	public function hasEventListener($type:String):Bool {
		
		if (_dispatcher == null) {
			return false;
		} else {
			return _dispatcher.hasEventListener($type);
		}
		
		// autogenerated
		return false;
	}

	public function willTrigger($type:String):Bool {
		
		if (_dispatcher == null) {
			return false;
		} else {
			return _dispatcher.willTrigger($type);
		}
		
		// autogenerated
		return false;
	}

	public function dispatchEvent($e:Event):Bool {
		
		if (_dispatcher == null) {
			return false;
		} else {
			return _dispatcher.dispatchEvent($e);
		}
		
		// autogenerated
		return false;
	}

	//---- STATIC FUNCTIONS -----------------------------------------------------------------------------------------------------------
	public static function to($target:Dynamic, $duration:Float, $vars:Dynamic):TweenMax {
		
		return new TweenMax($target, $duration, $vars);
	}

	public static function from($target:Dynamic, $duration:Float, $vars:Dynamic):TweenMax {
		
		$vars.runBackwards = true;
		return new TweenMax($target, $duration, $vars);
	}

	public static function delayedCall($delay:Float, $onComplete:Dynamic, ?$onCompleteParams:Array<Dynamic>=null, ?$persist:Bool=false):TweenMax {
		
		return new TweenMax($onComplete, 0, {delay:$delay, onComplete:$onComplete, onCompleteParams:$onCompleteParams, persist:$persist, overwrite:0});
	}

	public static function setGlobalTimeScale($scale:Float):Void {
		
		if ($scale < 0.00001) {
			$scale = 0.00001;
		}
		var ml:Dictionary = masterList;
		var i:Int;
		var a:Array<Dynamic>;
		_globalTimeScale = $scale;
		var __keys:Iterator<Dynamic> = untyped (__keys__(ml)).iterator();
		for (__key in __keys) {
			a = ml[untyped __key];

			if (a != null) {
				i = a.length - 1;
				while (i > -1) {
					if (Std.is(a[i], TweenMax)) {
						a[i].timeScale *= 1;
					}
					
					// update loop variables
					i--;
				}

			}
		}

	}

	public static function getTweensOf($target:Dynamic):Array<Dynamic> {
		
		var a:Array<Dynamic> = masterList[untyped $target];
		var toReturn:Array<Dynamic> = [];
		if (a != null) {
			var i:Int = a.length - 1;
			while (i > -1) {
				if (!a[i].gc) {
					toReturn[toReturn.length] = a[i];
				}
				
				// update loop variables
				i--;
			}

		}
		var __keys:Iterator<Dynamic> = untyped (__keys__(_pausedTweens)).iterator();
		for (__key in __keys) {
			var tween:TweenLite = _pausedTweens[untyped __key];

			if (tween != null) {
				if (tween.target == $target) {
					toReturn[toReturn.length] = tween;
				}
			}
		}

		return toReturn;
	}

	public static function isTweening($target:Dynamic):Bool {
		
		var a:Array<Dynamic> = getTweensOf($target);
		var i:Int = a.length - 1;
		while (i > -1) {
			if (a[i].active && !a[i].gc) {
				return true;
			}
			
			// update loop variables
			i--;
		}

		return false;
	}

	public static function getAllTweens():Array<Dynamic> {
		//speeds things up slightly
		
		var ml:Dictionary = masterList;
		var toReturn:Array<Dynamic> = [];
		var a:Array<Dynamic>;
		var i:Int;
		var tween:TweenLite;
		var __keys:Iterator<Dynamic> = untyped (__keys__(ml)).iterator();
		for (__key in __keys) {
			a = ml[untyped __key];

			if (a != null) {
				i = a.length - 1;
				while (i > -1) {
					if (!a[i].gc) {
						toReturn[toReturn.length] = a[i];
					}
					
					// update loop variables
					i--;
				}

			}
		}

		var __keys:Iterator<Dynamic> = untyped (__keys__(_pausedTweens)).iterator();
		for (__key in __keys) {
			tween = _pausedTweens[untyped __key];

			if (tween != null) {
				toReturn[toReturn.length] = tween;
			}
		}

		return toReturn;
	}

	public static function killAllTweens(?$complete:Bool=false):Void {
		
		killAll($complete, true, false);
	}

	public static function killAllDelayedCalls(?$complete:Bool=false):Void {
		
		killAll($complete, false, true);
	}

	public static function killAll(?$complete:Bool=false, ?$tweens:Bool=true, ?$delayedCalls:Bool=true):Void {
		
		var a:Array<Dynamic> = getAllTweens();
		var isDC:Bool;
		var i:Int;
		i = a.length - 1;
		while (i > -1) {
			isDC = (a[i].target == a[i].vars.onComplete);
			if (isDC == $delayedCalls || isDC != $tweens) {
				if ($complete) {
					a[i].complete(false);
					a[i].clear();
				} else {
					TweenLite.removeTween(a[i], true);
				}
			}
			
			// update loop variables
			i--;
		}

	}

	public static function pauseAll(?$tweens:Bool=true, ?$delayedCalls:Bool=false):Void {
		
		changePause(true, $tweens, $delayedCalls);
	}

	public static function resumeAll(?$tweens:Bool=true, ?$delayedCalls:Bool=false):Void {
		
		changePause(false, $tweens, $delayedCalls);
	}

	public static function changePause($pause:Bool, ?$tweens:Bool=true, ?$delayedCalls:Bool=false):Void {
		
		var a:Array<Dynamic> = getAllTweens();
		var isDC:Bool;
		var i:Int = a.length - 1;
		while (i > -1) {
			isDC = (a[i].target == a[i].vars.onComplete);
			if (Std.is(a[i], TweenMax) && (isDC == $delayedCalls || isDC != $tweens)) {
				a[i].paused = $pause;
			}
			
			// update loop variables
			i--;
		}

	}

	//---- GETTERS / SETTERS ----------------------------------------------------------------------------------------------------------
	public function getPaused():Bool {
		
		return !Math.isNaN(this.pauseTime);
	}

	public function setPaused($b:Bool):Bool {
		
		if ($b) {
			pause();
		} else {
			resume();
		}
		return $b;
	}

	public function getReversed():Bool {
		
		return (this.ease == reverseEase);
	}

	public function setReversed($b:Bool):Bool {
		
		if (this.reversed != $b) {
			reverse();
		}
		return $b;
	}

	public function getTimeScale():Float {
		
		return _timeScale;
	}

	public function setTimeScale($n:Float):Float {
		
		if ($n < 0.00001) {
			$n = _timeScale = 0.00001;
		} else {
			_timeScale = $n;
			//instead of doing _timeScale * _globalTimeScale in the render() and elsewhere, we improve performance by combining them here.
			$n *= _globalTimeScale;
		}
		this.initTime = currentTime - ((currentTime - this.initTime - (this.delay * (1000 / this.combinedTimeScale))) * this.combinedTimeScale * (1 / $n)) - (this.delay * (1000 / $n));
		//required for OverwriteManager (indicates a TweenMax instance that has been paused)
		if (this.startTime != 999999999999999) {
			this.startTime = this.initTime + (this.delay * (1000 / $n));
		}
		this.combinedTimeScale = $n;
		return $n;
	}

	override public function setEnabled($b:Bool):Bool {
		
		if (!$b) {
			_pausedTweens[untyped this] = null;
			_pausedTweens[untyped this] = null;
		}
		super.enabled = $b;
		if ($b) {
			this.combinedTimeScale = _timeScale * _globalTimeScale;
		}
		return $b;
	}

	public static function setGlobalTimeScale($n:Float):Float {
		
		setGlobalTimeScale($n);
		return $n;
	}

	public static function getGlobalTimeScale():Float {
		
		return _globalTimeScale;
	}

	public function getProgress():Float {
		
		var t:Float = (!Math.isNaN(this.pauseTime)) ? this.pauseTime : currentTime;
		var p:Float = (((t - this.initTime) * 0.001) - this.delay / this.combinedTimeScale) / this.duration * this.combinedTimeScale;
		if (p > 1) {
			return 1;
		} else if (p < 0) {
			return 0;
		} else {
			return p;
		}
		
		// autogenerated
		return 0;
	}

	public function setProgress($n:Float):Float {
		
		this.startTime = currentTime - ((this.duration * $n) * 1000);
		this.initTime = this.startTime - (this.delay * (1000 / this.combinedTimeScale));
		if (!this.started) {
			activate();
		}
		render(currentTime);
		if (!Math.isNaN(this.pauseTime)) {
			this.pauseTime = currentTime;
			//required for OverwriteManager
			this.startTime = 999999999999999;
			this.active = false;
		}
		return $n;
	}

}

