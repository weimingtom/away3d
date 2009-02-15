package away3d.core.utils;

import flash.geom.Matrix;
import flash.utils.ByteArray;
import away3d.materials.IMaterial;
import flash.events.EventDispatcher;
import flash.display.BitmapData;
import away3d.materials.ISegmentMaterial;
import flash.utils.Dictionary;
import away3d.materials.WhiteShadingBitmapMaterial;
import away3d.materials.ShadingColorMaterial;
import away3d.materials.WireframeMaterial;
import flash.display.MovieClip;
import away3d.materials.ColorMaterial;
import flash.display.Bitmap;
import flash.display.DisplayObject;
import away3d.materials.MovieMaterial;
import away3d.materials.WireColorMaterial;
import away3d.materials.BitmapMaterial;


//import mx.core.BitmapAsset;
/** Helper class for casting assets to usable objects */
class Cast  {
	
	private static var colornames:Dictionary;
	private static var hexchars:String = "0123456789abcdefABCDEF";
	private static var notclasses:Dictionary = new Dictionary();
	private static var classes:Dictionary = new Dictionary();
	

	public static function string(data:Dynamic):String {
		
		if (Std.is(data, Class<Dynamic>)) {
			data = new data();
		}
		if (Std.is(data, String)) {
			return data;
		}
		return Std.string(data);
	}

	public static function bytearray(data:Dynamic):ByteArray {
		//throw new Error(typeof(data));
		
		if (Std.is(data, Class<Dynamic>)) {
			data = new data();
		}
		if (Std.is(data, ByteArray)) {
			return data;
		}
		return ByteArray(data);
	}

	public static function xml(data:Dynamic):Xml {
		
		if (Std.is(data, Class<Dynamic>)) {
			data = new data();
		}
		if (Std.is(data, Xml)) {
			return data;
		}
		return XML(data);
	}

	private static function hexstring(string:String):Bool {
		
		var i:Int = 0;
		while (i < string.length) {
			if (hexchars.indexOf(string.charAt(i)) == -1) {
				return false;
			}
			
			// update loop variables
			i++;
		}

		return true;
	}

	public static function trycolor(data:Dynamic):Int {
		
		if (Std.is(data, Int)) {
			return cast(data, Int);
		}
		if (Std.is(data, Int)) {
			return cast(data, Int);
		}
		if (Std.is(data, String)) {
			if (data == "random") {
				return Std.int(Math.random() * 0x1000000);
			}
			if (colornames == null) {
				colornames = new Dictionary();
				colornames[cast "steelblue"] = 0x4682B4;
				colornames[cast "royalblue"] = 0x041690;
				colornames[cast "cornflowerblue"] = 0x6495ED;
				colornames[cast "lightsteelblue"] = 0xB0C4DE;
				colornames[cast "mediumslateblue"] = 0x7B68EE;
				colornames[cast "slateblue"] = 0x6A5ACD;
				colornames[cast "darkslateblue"] = 0x483D8B;
				colornames[cast "midnightblue"] = 0x191970;
				colornames[cast "navy"] = 0x000080;
				colornames[cast "darkblue"] = 0x00008B;
				colornames[cast "mediumblue"] = 0x0000CD;
				colornames[cast "blue"] = 0x0000FF;
				colornames[cast "dodgerblue"] = 0x1E90FF;
				colornames[cast "deepskyblue"] = 0x00BFFF;
				colornames[cast "lightskyblue"] = 0x87CEFA;
				colornames[cast "skyblue"] = 0x87CEEB;
				colornames[cast "lightblue"] = 0xADD8E6;
				colornames[cast "powderblue"] = 0xB0E0E6;
				colornames[cast "azure"] = 0xF0FFFF;
				colornames[cast "lightcyan"] = 0xE0FFFF;
				colornames[cast "paleturquoise"] = 0xAFEEEE;
				colornames[cast "mediumturquoise"] = 0x48D1CC;
				colornames[cast "lightseagreen"] = 0x20B2AA;
				colornames[cast "darkcyan"] = 0x008B8B;
				colornames[cast "teal"] = 0x008080;
				colornames[cast "cadetblue"] = 0x5F9EA0;
				colornames[cast "darkturquoise"] = 0x00CED1;
				colornames[cast "aqua"] = 0x00FFFF;
				colornames[cast "cyan"] = 0x00FFFF;
				colornames[cast "turquoise"] = 0x40E0D0;
				colornames[cast "aquamarine"] = 0x7FFFD4;
				colornames[cast "mediumaquamarine"] = 0x66CDAA;
				colornames[cast "darkseagreen"] = 0x8FBC8F;
				colornames[cast "mediumseagreen"] = 0x3CB371;
				colornames[cast "seagreen"] = 0x2E8B57;
				colornames[cast "darkgreen"] = 0x006400;
				colornames[cast "green"] = 0x008000;
				colornames[cast "forestgreen"] = 0x228B22;
				colornames[cast "limegreen"] = 0x32CD32;
				colornames[cast "lime"] = 0x00FF00;
				colornames[cast "chartreuse"] = 0x7FFF00;
				colornames[cast "lawngreen"] = 0x7CFC00;
				colornames[cast "greenyellow"] = 0xADFF2F;
				colornames[cast "yellowgreen"] = 0x9ACD32;
				colornames[cast "palegreen"] = 0x98FB98;
				colornames[cast "lightgreen"] = 0x90EE90;
				colornames[cast "springgreen"] = 0x00FF7F;
				colornames[cast "mediumspringgreen"] = 0x00FA9A;
				colornames[cast "darkolivegreen"] = 0x556B2F;
				colornames[cast "olivedrab"] = 0x6B8E23;
				colornames[cast "olive"] = 0x808000;
				colornames[cast "darkkhaki"] = 0xBDB76B;
				colornames[cast "darkgoldenrod"] = 0xB8860B;
				colornames[cast "goldenrod"] = 0xDAA520;
				colornames[cast "gold"] = 0xFFD700;
				colornames[cast "yellow"] = 0xFFFF00;
				colornames[cast "khaki"] = 0xF0E68C;
				colornames[cast "palegoldenrod"] = 0xEEE8AA;
				colornames[cast "blanchedalmond"] = 0xFFEBCD;
				colornames[cast "moccasin"] = 0xFFE4B5;
				colornames[cast "wheat"] = 0xF5DEB3;
				colornames[cast "navajowhite"] = 0xFFDEAD;
				colornames[cast "burlywood"] = 0xDEB887;
				colornames[cast "tan"] = 0xD2B48C;
				colornames[cast "rosybrown"] = 0xBC8F8F;
				colornames[cast "sienna"] = 0xA0522D;
				colornames[cast "saddlebrown"] = 0x8B4513;
				colornames[cast "chocolate"] = 0xD2691E;
				colornames[cast "peru"] = 0xCD853F;
				colornames[cast "sandybrown"] = 0xF4A460;
				colornames[cast "darkred"] = 0x8B0000;
				colornames[cast "maroon"] = 0x800000;
				colornames[cast "brown"] = 0xA52A2A;
				colornames[cast "firebrick"] = 0xB22222;
				colornames[cast "indianred"] = 0xCD5C5C;
				colornames[cast "lightcoral"] = 0xF08080;
				colornames[cast "salmon"] = 0xFA8072;
				colornames[cast "darksalmon"] = 0xE9967A;
				colornames[cast "lightsalmon"] = 0xFFA07A;
				colornames[cast "coral"] = 0xFF7F50;
				colornames[cast "tomato"] = 0xFF6347;
				colornames[cast "darkorange"] = 0xFF8C00;
				colornames[cast "orange"] = 0xFFA500;
				colornames[cast "orangered"] = 0xFF4500;
				colornames[cast "crimson"] = 0xDC143C;
				colornames[cast "red"] = 0xFF0000;
				colornames[cast "deeppink"] = 0xFF1493;
				colornames[cast "fuchsia"] = 0xFF00FF;
				colornames[cast "magenta"] = 0xFF00FF;
				colornames[cast "hotpink"] = 0xFF69B4;
				colornames[cast "lightpink"] = 0xFFB6C1;
				colornames[cast "pink"] = 0xFFC0CB;
				colornames[cast "palevioletred"] = 0xDB7093;
				colornames[cast "mediumvioletred"] = 0xC71585;
				colornames[cast "purple"] = 0x800080;
				colornames[cast "darkmagenta"] = 0x8B008B;
				colornames[cast "mediumpurple"] = 0x9370DB;
				colornames[cast "blueviolet"] = 0x8A2BE2;
				colornames[cast "indigo"] = 0x4B0082;
				colornames[cast "darkviolet"] = 0x9400D3;
				colornames[cast "darkorchid"] = 0x9932CC;
				colornames[cast "mediumorchid"] = 0xBA55D3;
				colornames[cast "orchid"] = 0xDA70D6;
				colornames[cast "violet"] = 0xEE82EE;
				colornames[cast "plum"] = 0xDDA0DD;
				colornames[cast "thistle"] = 0xD8BFD8;
				colornames[cast "lavender"] = 0xE6E6FA;
				colornames[cast "ghostwhite"] = 0xF8F8FF;
				colornames[cast "aliceblue"] = 0xF0F8FF;
				colornames[cast "mintcream"] = 0xF5FFFA;
				colornames[cast "honeydew"] = 0xF0FFF0;
				colornames[cast "lightgoldenrodyellow"] = 0xFAFAD2;
				colornames[cast "lemonchiffon"] = 0xFFFACD;
				colornames[cast "cornsilk"] = 0xFFF8DC;
				colornames[cast "lightyellow"] = 0xFFFFE0;
				colornames[cast "ivory"] = 0xFFFFF0;
				colornames[cast "floralwhite"] = 0xFFFAF0;
				colornames[cast "linen"] = 0xFAF0E6;
				colornames[cast "oldlace"] = 0xFDF5E6;
				colornames[cast "antiquewhite"] = 0xFAEBD7;
				colornames[cast "bisque"] = 0xFFE4C4;
				colornames[cast "peachpuff"] = 0xFFDAB9;
				colornames[cast "papayawhip"] = 0xFFEFD5;
				colornames[cast "beige"] = 0xF5F5DC;
				colornames[cast "seashell"] = 0xFFF5EE;
				colornames[cast "lavenderblush"] = 0xFFF0F5;
				colornames[cast "mistyrose"] = 0xFFE4E1;
				colornames[cast "snow"] = 0xFFFAFA;
				colornames[cast "white"] = 0xFFFFFF;
				colornames[cast "whitesmoke"] = 0xF5F5F5;
				colornames[cast "gainsboro"] = 0xDCDCDC;
				colornames[cast "lightgrey"] = 0xD3D3D3;
				colornames[cast "silver"] = 0xC0C0C0;
				colornames[cast "darkgrey"] = 0xA9A9A9;
				colornames[cast "grey"] = 0x808080;
				colornames[cast "lightslategrey"] = 0x778899;
				colornames[cast "slategrey"] = 0x708090;
				colornames[cast "dimgrey"] = 0x696969;
				colornames[cast "darkslategrey"] = 0x2F4F4F;
				colornames[cast "black"] = 0x000000;
				colornames[cast "transparent"] = 0xFF000000;
			}
			if (colornames[cast data] != null) {
				return colornames[cast data];
			}
			if (((cast(data, String)).length == 6) && hexstring(data)) {
				return Std.parseInt("0x" + data);
			}
		}
		return 0xFFFFFF;
	}

	public static function color(data:Dynamic):Int {
		
		var result:Int = trycolor(data);
		if (result == 0xFFFFFFFF) {
			throw new CastError();
		}
		return result;
	}

	public static function bitmap(data:Dynamic):BitmapData {
		
		if (data == null) {
			return null;
		}
		if (Std.is(data, String)) {
			data = tryclass(data);
		}
		if (Std.is(data, Class<Dynamic>)) {
			try {
				data = new data();
			} catch (bitmaperror:ArgumentError) {
				data = new data();
			}

		}
		if (Std.is(data, BitmapData)) {
			return data;
		}
		if (Std.is(data, Bitmap)) {
			// if (data is BitmapAsset)
			if ((cast(data, Bitmap)).hasOwnProperty("bitmapData")) {
				return (cast(data, Bitmap)).bitmapData;
			}
		}
		if (Std.is(data, DisplayObject)) {
			var ds:DisplayObject = cast(data, DisplayObject);
			var bmd:BitmapData = new BitmapData();
			var mat:Matrix = ds.transform.matrix.clone();
			mat.tx = 0;
			mat.ty = 0;
			bmd.draw(ds, mat, ds.transform.colorTransform, ds.blendMode, bmd.rect, true);
			return bmd;
		}
		throw new CastError();
		
		// autogenerated
		return null;
	}

	public static function tryclass(name:String):Dynamic {
		
		if ((notclasses[cast name] != null)) {
			return name;
		}
		var result:Class<Dynamic> = classes[cast name];
		if (result != null) {
			return result;
		}
		try {
			result = cast(Type.resolveClass(name), Class<Dynamic>);
			classes[cast name] = result;
			return result;
		} catch (error:Dynamic) {
		}

		notclasses[cast name] = true;
		return name;
	}

	public static function material(data:Dynamic):IMaterial {
		
		if (data == null) {
			return null;
		}
		if (Std.is(data, String)) {
			data = tryclass(data);
		}
		if (Std.is(data, Class<Dynamic>)) {
			try {
				data = new data();
			} catch (materialerror:ArgumentError) {
				data = new data();
			}

		}
		if (Std.is(data, IMaterial)) {
			return data;
		}
		if (Std.is(data, Int)) {
			return new ColorMaterial();
		}
		if (Std.is(data, MovieClip)) {
			return new MovieMaterial();
		}
		if (Std.is(data, String)) {
			if (data == "") {
				return null;
			}
			var hash:Array<Dynamic>;
			if ((cast(data, String)).indexOf("#") != -1) {
				hash = (cast(data, String)).split("#");
				if (hash[1] == "") {
					return new WireColorMaterial();
				}
				if (hash[1].indexOf("|") == -1) {
					if (hash[0] == "") {
						return new WireframeMaterial();
					} else {
						return new WireColorMaterial();
					}
				} else {
					var line:Array<Dynamic> = hash[1].split("|");
					if (hash[0] == "") {
						return new WireframeMaterial();
					} else {
						return new WireColorMaterial();
					}
				}
			} else if ((cast(data, String)).indexOf("@") != -1) {
				hash = (cast(data, String)).split("@");
				if (hash[1] == "") {
					return new ShadingColorMaterial();
				}
			} else {
				return new ColorMaterial();
			}
		}
		try {
			var bmd:BitmapData = Cast.bitmap(data);
			return new BitmapMaterial();
		} catch (error:CastError) {
		}

		if (Std.is(data, Dynamic)) {
			var ini:Init = Init.parse(data);
			var bitmap:BitmapData = ini.getBitmap("bitmap");
			var color:Int = ini.getColor("color", 0xFFFFFFFF);
			var alpha:Float = ini.getNumber("alpha", 1, {min:0, max:1});
			var lighting:Bool = ini.getBoolean("lighting", false);
			var wire:WireframeMaterial = cast(wirematerial(ini.getObject("wire")), WireframeMaterial);
			if ((bitmap != null) && (color != 0xFFFFFFFF)) {
				throw new CastError();
			}
			if (bitmap != null) {
				if (wire != null) {
					Debug.warning("Bitmap materials do not support wire");
				}
				var smooth:Bool = ini.getBoolean("smooth", false);
				var precision:Float = ini.getNumber("precision", 0);
				if ((precision > 0)) {
					if (lighting) {
						return new WhiteShadingBitmapMaterial();
					}
					if (alpha < 1) {
						Debug.warning("Can't create precise bitmap material with alpha (yet)");
					}
					return new BitmapMaterial();
				}
				if (lighting) {
					if (alpha < 1) {
						Debug.warning("Can't create bitmap material with lighting and alpha (yet)");
					}
					return new WhiteShadingBitmapMaterial();
				}
				return new BitmapMaterial();
			}
			if (color != 0xFFFFFFFF) {
				if (lighting) {
					if (wire != null) {
						Debug.warning("Can't create shading material with wire");
					}
					return new ShadingColorMaterial();
				}
				if (wire == null) {
					return new ColorMaterial();
				} else {
					return new WireColorMaterial();
				}
			}
			if (wire != null) {
				return wire;
			}
		}
		throw new CastError();
		
		// autogenerated
		return null;
	}

	public static function wirematerial(data:Dynamic):ISegmentMaterial {
		
		if (data == null) {
			return null;
		}
		if (Std.is(data, ISegmentMaterial)) {
			return data;
		}
		if (Std.is(data, Int)) {
			return new WireframeMaterial();
		}
		if (Std.is(data, String)) {
			if (data == "") {
				return null;
			}
			if ((cast(data, String)).indexOf("#") == 0) {
				data = (cast(data, String)).substr(1);
			}
			if ((cast(data, String)).indexOf("|") == -1) {
				return new WireframeMaterial();
			}
			var line:Array<Dynamic> = (cast(data, String)).split("|");
			return new WireframeMaterial();
		}
		if (Std.is(data, Dynamic)) {
			var dat:Init = Init.parse(data);
			var color:Int = dat.getColor("color", 0);
			var alpha:Float = dat.getNumber("alpha", 1, {min:0, max:1});
			var width:Float = dat.getNumber("width", 1, {min:0});
			return new WireframeMaterial();
		}
		throw new CastError();
		
		// autogenerated
		return null;
	}

	// autogenerated
	public function new () {
		
	}

	

}

