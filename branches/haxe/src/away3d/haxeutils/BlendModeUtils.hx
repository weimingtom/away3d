package away3d.haxeutils;

import flash.display.BlendMode;

class BlendModeUtils  {
	
	public static var NORMAL:String = "normal";
	public static var SUBTRACT:String = "subtract";
	public static var SCREEN:String = "screen";
	public static var OVERLAY:String = "overlay";
	public static var MULTIPLY:String = "multiply";
	public static var LIGHTEN:String = "lighten";
	public static var LAYER:String = "layer";
	public static var INVERT:String = "invert";
	public static var HARDLIGHT:String = "hardlight";
	public static var ERASE:String = "erase";
	public static var DIFFERENCE:String = "difference";
	public static var DARKEN:String = "darken";
	public static var ALPHA:String = "alpha";
	public static var ADD:String = "add";
              

	public static function toHaxe(as3BlendMode:String):flash.display.BlendMode {
		if (as3BlendMode == NORMAL) {
			return flash.display.BlendMode.NORMAL;
		} else if (as3BlendMode == SUBTRACT) {
			return flash.display.BlendMode.SUBTRACT;
		} else if (as3BlendMode == SCREEN) {
			return flash.display.BlendMode.SCREEN;
		} else if (as3BlendMode == OVERLAY) {
			return flash.display.BlendMode.OVERLAY;
		} else if (as3BlendMode == MULTIPLY) {
			return flash.display.BlendMode.MULTIPLY;
		} else if (as3BlendMode == LIGHTEN) {
			return flash.display.BlendMode.LIGHTEN;
		} else if (as3BlendMode == LAYER) {
			return flash.display.BlendMode.LAYER;
		} else if (as3BlendMode == INVERT) {
			return flash.display.BlendMode.INVERT;
		} else if (as3BlendMode == HARDLIGHT) {
			return flash.display.BlendMode.HARDLIGHT;
		} else if (as3BlendMode == ERASE) {
			return flash.display.BlendMode.ERASE;
		} else if (as3BlendMode == DIFFERENCE) {
			return flash.display.BlendMode.DIFFERENCE;
		} else if (as3BlendMode == DARKEN) {
			return flash.display.BlendMode.DARKEN;
		} else if (as3BlendMode == ALPHA) {
			return flash.display.BlendMode.ALPHA;
		} else if (as3BlendMode == ADD) {
			return flash.display.BlendMode.ADD;
		} 
		return flash.display.BlendMode.NORMAL;
	}

}

