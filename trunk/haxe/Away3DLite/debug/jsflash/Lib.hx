﻿/**
 * ...
 * @author waneck
 */

package jsflash;
import jsflash.display.Sprite;

class Lib 
{

	public static var current(default, null):Sprite;
	public static function as<T>(obj:Dynamic, clazz:Class<T>):T
	{
		return if (Std.is(obj, clazz))
			obj;
		else
			null;
	}
	
	public static inline function vectorOfArray<T>(arr:Array<T>):Vector<T>
	{
		return arr;
	}
}