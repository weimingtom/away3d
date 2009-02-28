package awaybuilder.utils;

import gs.easing.Back;
import gs.easing.Bounce;
import gs.easing.Circ;
import gs.easing.Cubic;
import gs.easing.Elastic;
import gs.easing.Expo;
import gs.easing.Linear;
import gs.easing.Quad;
import gs.easing.Quart;
import gs.easing.Quint;
import gs.easing.Sine;
import gs.easing.Strong;


class EasingUtil  {
	
	

	public function new() {
		
		
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Public Methods
	//
	////////////////////////////////////////////////////////////////////////////////
	public static function stringToFunction(s:String):Dynamic {
		
		var elements:Array<Dynamic> = s.split(".");
		var className:String = elements[0];
		var functionName:String = elements[1];
		var f:Dynamic;
		switch (className) {
			case EasingClass.BACK :
				f = cast(Reflect.field(Back, functionName), Dynamic);
				break;
			case EasingClass.BOUNCE :
				f = cast(Reflect.field(Bounce, functionName), Dynamic);
				break;
			case EasingClass.CIRC :
				f = cast(Reflect.field(Circ, functionName), Dynamic);
				break;
			case EasingClass.CUBIC :
				f = cast(Reflect.field(Cubic, functionName), Dynamic);
				break;
			case EasingClass.ELASTIC :
				f = cast(Reflect.field(Elastic, functionName), Dynamic);
				break;
			case EasingClass.EXPO :
				f = cast(Reflect.field(Expo, functionName), Dynamic);
				break;
			case EasingClass.LINEAR :
				f = cast(Reflect.field(Linear, functionName), Dynamic);
				break;
			case EasingClass.QUAD :
				f = cast(Reflect.field(Quad, functionName), Dynamic);
				break;
			case EasingClass.QUART :
				f = cast(Reflect.field(Quart, functionName), Dynamic);
				break;
			case EasingClass.QUINT :
				f = cast(Reflect.field(Quint, functionName), Dynamic);
				break;
			case EasingClass.SINE :
				f = cast(Reflect.field(Sine, functionName), Dynamic);
				break;
			case EasingClass.STRONG :
				f = cast(Reflect.field(Strong, functionName), Dynamic);
				break;
			default :
				f = Linear.easeNone;
				break;
			

		}
		return f;
	}

}

