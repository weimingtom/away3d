package away3d.haxeutils;

import flash.utils.Dictionary;

class DictionaryUtils {
	
	public static var __castVar:Dynamic = null; 

	public static function iterator(dictionary:Dictionary):Iterator<Dynamic> {
		return untyped (__keys__(dictionary)).iterator();
	}

}

