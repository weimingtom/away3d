package gs.plugins;

import gs.utils.tween.TweenInfo;
import flash.filters.BitmapFilter;


class FilterPlugin extends TweenPlugin  {
	public var changeFactor(null, setChangeFactor) : Float;
	
	public static inline var VERSION:Float = 1.03;
	//If the API/Framework for plugins changes in the future, this number helps determine compatibility
	public static inline var API:Float = 1.0;
	private var _target:Dynamic;
	private var _type:Class;
	private var _filter:BitmapFilter;
	private var _index:Int;
	private var _remove:Bool;
	

	public function new() {
		
		
		super();
	}

	private function initFilter($props:Dynamic, $default:BitmapFilter):Void {
		
		var filters:Array<Dynamic> = _target.filters;
		var p:String;
		var i:Int;
		var colorTween:HexColorsPlugin;
		_index = -1;
		if ($props.index != null) {
			_index = $props.index;
		} else {
			i = filters.length - 1;
			while (i > -1) {
				if (Std.is(filters[i], _type)) {
					_index = i;
					break;
				}
				
				// update loop variables
				i--;
			}

		}
		if (_index == -1 || filters[_index] == null || $props.addFilter == true) {
			_index = ($props.index != null) ? $props.index : filters.length;
			filters[_index] = $default;
			_target.filters = filters;
		}
		_filter = filters[_index];
		_remove = Boolean($props.remove == true);
		if (_remove) {
			this.onComplete = onCompleteTween;
		}
		//accommodates TweenLiteVars and TweenMaxVars
		var props:Dynamic = ($props.isTV == true) ? $props.exposedVars : $props;
		for (p in Reflect.fields(props)) {
			if (!(p in _filter) || Reflect.field(_filter, p) == Reflect.field(props, p) || p == "remove" || p == "index" || p == "addFilter") {
			} else {
				if (p == "color" || p == "highlightColor" || p == "shadowColor") {
					colorTween = new HexColorsPlugin();
					colorTween.initColor(_filter, p, Reflect.field(_filter, p), Reflect.field(props, p));
					_tweens[_tweens.length] = new TweenInfo(colorTween, "changeFactor", 0, 1, p, false);
				} else if (p == "quality" || p == "inner" || p == "knockout" || p == "hideObject") {
					Reflect.setField(_filter, p, Reflect.field(props, p));
				} else {
					addTween(_filter, p, Reflect.field(_filter, p), Reflect.field(props, p), p);
				}
			}
			
		}

	}

	public function onCompleteTween():Void {
		
		if (_remove) {
			var i:Int;
			var filters:Array<Dynamic> = _target.filters;
			//a filter may have been added or removed since the tween began, changing the index.
			if (!(Std.is(filters[_index], _type))) {
				i = filters.length - 1;
				while (i > -1) {
					if (Std.is(filters[i], _type)) {
						filters.splice(i, 1);
						break;
					}
					
					// update loop variables
					i--;
				}

			} else {
				filters.splice(_index, 1);
			}
			_target.filters = filters;
		}
	}

	override public function setChangeFactor($n:Float):Float {
		
		var i:Int;
		var ti:TweenInfo;
		var filters:Array<Dynamic> = _target.filters;
		i = _tweens.length - 1;
		while (i > -1) {
			ti = _tweens[i];
			Reflect.setField(ti.target, ti.property, ti.start + (ti.change * $n));
			
			// update loop variables
			i--;
		}

		//a filter may have been added or removed since the tween began, changing the index.
		if (!(Std.is(filters[_index], _type))) {
			_index = filters.length - 1;
			i = filters.length - 1;
			while (i > -1) {
				if (Std.is(filters[i], _type)) {
					_index = i;
					break;
				}
				
				// update loop variables
				i--;
			}

		}
		filters[_index] = _filter;
		_target.filters = filters;
		return $n;
	}

}

