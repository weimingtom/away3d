package gs.utils.tween;

import gs.utils.tween.TweenLiteVars;


class TweenMaxVars extends TweenLiteVars  {
	public var roundProps(getRoundProps, setRoundProps) : Array<Dynamic>;
	
	public static inline var version:Float = 2.01;
	/**
	 * A function to which the TweenMax instance should dispatch a TweenEvent when it begins. This is the same as doing myTweenMaxInstance.addEventListener(TweenEvent.START, myFunction); 
	 */
	public var onStartListener:Dynamic;
	/**
	 * A function to which the TweenMax instance should dispatch a TweenEvent every time it updates values. This is the same as doing myTweenMaxInstance.addEventListener(TweenEvent.UPDATE, myFunction); 
	 */
	public var onUpdateListener:Dynamic;
	/**
	 * A function to which the TweenMax instance should dispatch a TweenEvent when it completes. This is the same as doing myTweenMaxInstance.addEventListener(TweenEvent.COMPLETE, myFunction); 
	 */
	public var onCompleteListener:Dynamic;
	/**
	 * To make the tween reverse when it completes (like a yoyo) any number of times, set this to the number of cycles you'd like the tween to yoyo. A value of zero causes the tween to yoyo endlessly.
	 */
	public var yoyo:Float;
	/**
	 * To make the tween repeat when it completes any number of times, set this to the number of cycles you'd like the tween to loop. A value of zero causes the tween to loop endlessly.
	 */
	public var loop:Float;
	private var _roundProps:Array<Dynamic>;
	

	/**
	 * @param $vars An Object containing properties that correspond to the properties you'd like to add to this TweenMaxVars Object. For example, TweenMaxVars({blurFilter:{blurX:10, blurY:20}, onComplete:myFunction})
	 */
	public function new(?$vars:Dynamic=null) {
		
		
		super($vars);
	}

	/**
	 * Clones the TweenMaxVars object.
	 */
	override public function clone():TweenLiteVars {
		
		var vars:Dynamic = {protectedVars:{}};
		appendCloneVars(vars, vars.protectedVars);
		return new TweenMaxVars(vars);
	}

	/**
	 * Works with clone() to copy all the necessary properties. Split apart from clone() to take advantage of inheritence
	 */
	override private function appendCloneVars($vars:Dynamic, $protectedVars:Dynamic):Void {
		
		super.appendCloneVars($vars, $protectedVars);
		var props:Array<Dynamic> = ["onStartListener", "onUpdateListener", "onCompleteListener", "onCompleteAllListener", "yoyo", "loop"];
		var i:Int = props.length - 1;
		while (i > -1) {
			Reflect.setField($vars, props[i], this[props[i]]);
			
			// update loop variables
			i--;
		}

		$protectedVars._roundProps = _roundProps;
	}

	//---- GETTERS / SETTERS ---------------------------------------------------------------------------------------------
	/**
	 * @param $a An Array of the names of properties that should be rounded to the nearest integer when tweening
	 */
	public function setRoundProps($a:Array<Dynamic>):Array<Dynamic> {
		
		_roundProps = _exposedVars.roundProps = $a;
		return $a;
	}

	public function getRoundProps():Array<Dynamic> {
		
		return _roundProps;
	}

}

