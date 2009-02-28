package gs;

import flash.utils.Timer;
import flash.utils.Dictionary;
import flash.events.Event;
import gs.plugins.VisiblePlugin;
import gs.plugins.FramePlugin;
import gs.utils.tween.TweenInfo;
import gs.plugins.RemoveTintPlugin;
import gs.plugins.VolumePlugin;
import gs.plugins.AutoAlphaPlugin;
import flash.events.TimerEvent;
import flash.display.DisplayObject;
import gs.plugins.TweenPlugin;
import gs.plugins.EndArrayPlugin;
import flash.display.Sprite;
import gs.plugins.TintPlugin;


class TweenLite  {
	public var enabled(getEnabled, setEnabled) : Bool;
	
	public static inline var version:Float = 10.06;
	public static var plugins:Dynamic = {};
	public static var killDelayedCallsTo:Dynamic = TweenLite.killTweensOf;
	public static var defaultEase:Dynamic = TweenLite.easeOut;
	//makes it possible to integrate the gs.utils.tween.OverwriteManager for adding autoOverwrite capabilities
	public static var overwriteManager:Dynamic;
	public static var currentTime:Int;
	//Holds references to all our instances.
	public static var masterList:Dictionary = new Dictionary(false);
	//A reference to the sprite that we use to drive all our ENTER_FRAME events.
	public static var timingSprite:Sprite = new Sprite();
	//TweenLite class initted
	private static var _tlInitted:Bool;
	private static var _timer:Timer = new Timer(2000);
	private static var _reservedProps:Dynamic = {ease:1, delay:1, overwrite:1, onComplete:1, onCompleteParams:1, runBackwards:1, startAt:1, onUpdate:1, onUpdateParams:1, roundProps:1, onStart:1, onStartParams:1, persist:1, renderOnStart:1, proxiedEase:1, easeParams:1, yoyo:1, loop:1, onCompleteListener:1, onUpdateListener:1, onStartListener:1, orientToBezier:1};
	//Duration (in seconds)
	public var duration:Float;
	//Variables (holds things like alpha or y or whatever we're tweening)
	public var vars:Dynamic;
	//Delay (in seconds)
	public var delay:Float;
	//Start time
	public var startTime:Float;
	//Time of initialization. Remember, we can build in delays so this property tells us when the frame action was born, not when it actually started doing anything.
	public var initTime:Float;
	//Contains parsed data for each property that's being tweened (target, property, start, change, name, and isPlugin).
	public var tweens:Array<Dynamic>;
	//Target object
	public var target:Dynamic;
	public var active:Bool;
	public var ease:Dynamic;
	public var initted:Bool;
	//even though TweenLite doesn't use this variable TweenMax does and it optimized things to store it here, particularly for TweenGroup
	public var combinedTimeScale:Float;
	//flagged for garbage collection
	public var gc:Bool;
	public var started:Bool;
	//Helps when using TweenLiteVars and TweenMaxVars utility classes because certain properties are only exposed via vars.exposedVars (for example, the "visible" property is Boolean, so we cannot normally check to see if it's undefined)
	public var exposedVars:Dynamic;
	//if there are TweenPlugins in the tweens Array, we set this to true - it helps speed things up in onComplete
	private var _hasPlugins:Bool;
	//has onUpdate. Tracking this as a Boolean value is faster than checking this.vars.onUpdate == null.
	private var _hasUpdate:Bool;
	

	public function new($target:Dynamic, $duration:Float, $vars:Dynamic) {
		
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
		
		if ($target == null) {
			return;
		}
		if (!_tlInitted) {
			TweenPlugin.activate([TintPlugin, RemoveTintPlugin, FramePlugin, AutoAlphaPlugin, VisiblePlugin, VolumePlugin, EndArrayPlugin]);
			currentTime = flash.Lib.getTimer();
			timingSprite.addEventListener(Event.ENTER_FRAME, updateAll, false, 0, true);
			if (overwriteManager == null) {
				overwriteManager = {mode:1, enabled:false};
			}
			_timer.addEventListener("timer", killGarbage, false, 0, true);
			_timer.start();
			_tlInitted = true;
		}
		this.vars = $vars;
		//easing equations don't work when the duration is zero.
		this.duration = ($duration > 0) ? $duration : 0.001;
		this.delay = ($vars.delay > 0) ? $vars.delay : 0;
		this.combinedTimeScale = ($vars.timeScale > 0) ? $vars.timeScale : 1;
		this.active = Boolean($duration == 0 && this.delay == 0);
		this.target = $target;
		if (typeof(this.vars.ease) != "function") {
			this.vars.ease = defaultEase;
		}
		if (this.vars.easeParams != null) {
			this.vars.proxiedEase = this.vars.ease;
			this.vars.ease = easeProxy;
		}
		this.ease = this.vars.ease;
		//for TweenLiteVars and TweenMaxVars (we need an object with enumerable properties)
		this.exposedVars = (this.vars.isTV == true) ? this.vars.exposedVars : this.vars;
		this.tweens = [];
		this.initTime = currentTime;
		this.startTime = this.initTime + (this.delay * 1000);
		var mode:Int = ($vars.overwrite == undefined || (!overwriteManager.enabled && $vars.overwrite > 1)) ? overwriteManager.mode : Std.int($vars.overwrite);
		if (!($target in masterList) || mode == 1) {
			masterList[untyped $target] = [this];
		} else {
			masterList[untyped $target].push(this);
		}
		if ((this.vars.runBackwards == true && this.vars.renderOnStart != true) || this.active) {
			initTweenVals();
			//Means duration is zero and delay is zero, so render it now, but add one to the startTime because this.duration is always forced to be at least 0.001 since easing equations can't handle zero.
			if (this.active) {
				render(this.startTime + 1);
			} else {
				render(this.startTime);
			}
			if (this.exposedVars.visible != null && this.vars.runBackwards == true && (Std.is(this.target, DisplayObject))) {
				this.target.visible = this.exposedVars.visible;
			}
		}
	}

	public function initTweenVals():Void {
		
		var p:String;
		var i:Int;
		var plugin:Dynamic;
		for (p in Reflect.fields(this.exposedVars)) {
			if (p in _reservedProps) {
			} else if (p in plugins) {
				plugin = Type.createInstance(Reflect.field(plugins, p), []);
				if (plugin.onInitTween(this.target, this.exposedVars[p], this) == false) {
					this.tweens[this.tweens.length] = new TweenInfo(this.target, p, this.target[p], (typeof(this.exposedVars[p]) == "number") ? this.exposedVars[p] - this.target[p] : (this.exposedVars[p]), p, false);
				} else {
					this.tweens[this.tweens.length] = new TweenInfo(plugin, "changeFactor", 0, 1, (plugin.overwriteProps.length == 1) ? plugin.overwriteProps[0] : "_MULTIPLE_", true);
					_hasPlugins = true;
				}
			} else {
				this.tweens[this.tweens.length] = new TweenInfo(this.target, p, this.target[p], (typeof(this.exposedVars[p]) == "number") ? this.exposedVars[p] - this.target[p] : (this.exposedVars[p]), p, false);
			}
			
		}

		if (this.vars.runBackwards == true) {
			var ti:TweenInfo;
			i = this.tweens.length - 1;
			while (i > -1) {
				ti = this.tweens[i];
				ti.start += ti.change;
				ti.change = -ti.change;
				
				// update loop variables
				i--;
			}

		}
		if (this.vars.onUpdate != null) {
			_hasUpdate = true;
		}
		if (TweenLite.overwriteManager.enabled && this.target in masterList) {
			overwriteManager.manageOverwrites(this, masterList[untyped this.target]);
		}
		this.initted = true;
	}

	public function activate():Void {
		
		this.started = this.active = true;
		if (!this.initted) {
			initTweenVals();
		}
		if (this.vars.onStart != null) {
			this.vars.onStart.apply(null, this.vars.onStartParams);
		}
		//In the constructor, if the duration is zero, we shift it to 0.001 because the easing functions won't work otherwise. We need to offset the this.startTime to compensate too.
		if (this.duration == 0.001) {
			this.startTime -= 1;
		}
	}

	public function render($t:Int):Void {
		
		var time:Float = ($t - this.startTime) * 0.001;
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
			Reflect.setField(ti.target, ti.property, ti.start + (factor * ti.change));
			
			// update loop variables
			i--;
		}

		if (_hasUpdate) {
			this.vars.onUpdate.apply(null, this.vars.onUpdateParams);
		}
		if (time == this.duration) {
			complete(true);
		}
	}

	public function complete(?$skipRender:Bool=false):Void {
		
		if (!$skipRender) {
			if (!this.initted) {
				initTweenVals();
			}
			this.startTime = currentTime - (this.duration * 1000) / this.combinedTimeScale;
			//Just to force the final render
			render(currentTime);
			return;
		}
		if (_hasPlugins) {
			var i:Int = this.tweens.length - 1;
			while (i > -1) {
				if (this.tweens[i].isPlugin && this.tweens[i].target.onComplete != null) {
					this.tweens[i].target.onComplete();
				}
				
				// update loop variables
				i--;
			}

		}
		if (this.vars.persist != true) {
			this.enabled = false;
		}
		if (this.vars.onComplete != null) {
			this.vars.onComplete.apply(null, this.vars.onCompleteParams);
		}
	}

	public function clear():Void {
		
		this.tweens = [];
		//just to avoid potential errors if someone tries to set the progress on a reversed tween that has been killed (unlikely, I know);
		this.vars = this.exposedVars = {ease:this.vars.ease};
		_hasUpdate = false;
	}

	public function killVars($vars:Dynamic):Void {
		
		if (overwriteManager.enabled) {
			overwriteManager.killVars($vars, this.exposedVars, this.tweens);
		}
	}

	//---- STATIC FUNCTIONS -------------------------------------------------------------------------
	public static function to($target:Dynamic, $duration:Float, $vars:Dynamic):TweenLite {
		
		return new TweenLite($target, $duration, $vars);
	}

	public static function from($target:Dynamic, $duration:Float, $vars:Dynamic):TweenLite {
		
		$vars.runBackwards = true;
		return new TweenLite($target, $duration, $vars);
	}

	public static function delayedCall($delay:Float, $onComplete:Dynamic, ?$onCompleteParams:Array<Dynamic>=null):TweenLite {
		
		return new TweenLite($onComplete, 0, {delay:$delay, onComplete:$onComplete, onCompleteParams:$onCompleteParams, overwrite:0});
	}

	public static function updateAll(?$e:Event=null):Void {
		
		var time:Int = currentTime = flash.Lib.getTimer();
		var ml:Dictionary = masterList;
		var a:Array<Dynamic>;
		var i:Int;
		var tween:TweenLite;
		var __keys:Iterator<Dynamic> = untyped (__keys__(ml)).iterator();
		for (__key in __keys) {
			a = ml[untyped __key];

			if (a != null) {
				i = a.length - 1;
				while (i > -1) {
					tween = a[i];
					if (tween.active) {
						tween.render(time);
					} else if (tween.gc) {
						a.splice(i, 1);
					} else if (time >= tween.startTime) {
						tween.activate();
						tween.render(time);
					}
					
					// update loop variables
					i--;
				}

			}
		}

	}

	public static function removeTween($tween:TweenLite, ?$clear:Bool=true):Void {
		
		if ($tween != null) {
			if ($clear) {
				$tween.clear();
			}
			$tween.enabled = false;
		}
	}

	public static function killTweensOf(?$target:Dynamic=null, ?$complete:Bool=false):Void {
		
		if ($target != null && $target in masterList) {
			var a:Array<Dynamic> = masterList[untyped $target];
			var i:Int;
			var tween:TweenLite;
			i = a.length - 1;
			while (i > -1) {
				tween = a[i];
				if ($complete && !tween.gc) {
					tween.complete(false);
				}
				//prevents situations where a tween is killed but is still referenced elsewhere and put back in the render queue, like if a TweenLiteGroup is paused, then the tween is removed, then the group is unpaused.
				tween.clear();
				
				// update loop variables
				i--;
			}

			masterList[untyped $target] = null;
		}
	}

	private static function killGarbage($e:TimerEvent):Void {
		
		var ml:Dictionary = masterList;
		var tgt:Dynamic;
		var __keys:Iterator<Dynamic> = untyped (__keys__(ml)).iterator();
		for (tgt in __keys) {
			if (ml[untyped tgt].length == 0) {
				ml[untyped tgt] = null;
			}
			
		}

	}

	public static function easeOut($t:Float, $b:Float, $c:Float, $d:Float):Float {
		
		return -$c * ($t /= $d) * ($t - 2) + $b;
	}

	//---- PROXY FUNCTIONS ------------------------------------------------------------------------
	//Just for when easeParams are passed in via the vars object.
	private function easeProxy($t:Float, $b:Float, $c:Float, $d:Float):Float {
		
		return this.vars.proxiedEase.apply(null, arguments.concat(this.vars.easeParams));
	}

	//---- GETTERS / SETTERS -----------------------------------------------------------------------
	public function getEnabled():Bool {
		
		return (this.gc) ? false : true;
	}

	public function setEnabled($b:Bool):Bool {
		
		if ($b) {
			if (!(this.target in masterList)) {
				masterList[untyped this.target] = [this];
			} else {
				var a:Array<Dynamic> = masterList[untyped this.target];
				var found:Bool;
				var i:Int;
				i = a.length - 1;
				while (i > -1) {
					if (a[i] == this) {
						found = true;
						break;
					}
					
					// update loop variables
					i--;
				}

				if (!found) {
					a[a.length] = this;
				}
			}
		}
		this.gc = ($b) ? false : true;
		if (this.gc) {
			this.active = false;
		} else {
			this.active = this.started;
		}
		return $b;
	}

}

