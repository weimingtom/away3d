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
		
		if (Std.is(data, Class)) {
			data = Type.createInstance(data, []);
		}
		if (Std.is(data, String)) {
			return data;
		}
		return Std.string(data);
	}

	public static function bytearray(data:Dynamic):ByteArray {
		//throw new Error(typeof(data));
		
		if (Std.is(data, Class)) {
			data = Type.createInstance(data, []);
		}
		if (Std.is(data, ByteArray)) {
			return data;
		}
		var byteArray:ByteArray = new ByteArray();
		byteArray.writeObject(data);
		return byteArray;
	}

	public static function xml(data:Dynamic):Xml {
		
		if (Std.is(data, Class)) {
			data = Type.createInstance(data, []);
		}
		if (Std.is(data, Xml)) {
			return data;
		}
		var xml:Xml = Xml.parse(data.toString());
		return xml;
	}

	private static function hexstring(string:String):Bool {
		
		var i:Int = 0;
		while (i < string.length) {
			if (untyped hexchars.indexOf(string.charAt(i)) == -1) {
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
				colornames[untyped "steelblue"] = 0x4682B4;
				colornames[untyped "royalblue"] = 0x041690;
				colornames[untyped "cornflowerblue"] = 0x6495ED;
				colornames[untyped "lightsteelblue"] = 0xB0C4DE;
				colornames[untyped "mediumslateblue"] = 0x7B68EE;
				colornames[untyped "slateblue"] = 0x6A5ACD;
				colornames[untyped "darkslateblue"] = 0x483D8B;
				colornames[untyped "midnightblue"] = 0x191970;
				colornames[untyped "navy"] = 0x000080;
				colornames[untyped "darkblue"] = 0x00008B;
				colornames[untyped "mediumblue"] = 0x0000CD;
				colornames[untyped "blue"] = 0x0000FF;
				colornames[untyped "dodgerblue"] = 0x1E90FF;
				colornames[untyped "deepskyblue"] = 0x00BFFF;
				colornames[untyped "lightskyblue"] = 0x87CEFA;
				colornames[untyped "skyblue"] = 0x87CEEB;
				colornames[untyped "lightblue"] = 0xADD8E6;
				colornames[untyped "powderblue"] = 0xB0E0E6;
				colornames[untyped "azure"] = 0xF0FFFF;
				colornames[untyped "lightcyan"] = 0xE0FFFF;
				colornames[untyped "paleturquoise"] = 0xAFEEEE;
				colornames[untyped "mediumturquoise"] = 0x48D1CC;
				colornames[untyped "lightseagreen"] = 0x20B2AA;
				colornames[untyped "darkcyan"] = 0x008B8B;
				colornames[untyped "teal"] = 0x008080;
				colornames[untyped "cadetblue"] = 0x5F9EA0;
				colornames[untyped "darkturquoise"] = 0x00CED1;
				colornames[untyped "aqua"] = 0x00FFFF;
				colornames[untyped "cyan"] = 0x00FFFF;
				colornames[untyped "turquoise"] = 0x40E0D0;
				colornames[untyped "aquamarine"] = 0x7FFFD4;
				colornames[untyped "mediumaquamarine"] = 0x66CDAA;
				colornames[untyped "darkseagreen"] = 0x8FBC8F;
				colornames[untyped "mediumseagreen"] = 0x3CB371;
				colornames[untyped "seagreen"] = 0x2E8B57;
				colornames[untyped "darkgreen"] = 0x006400;
				colornames[untyped "green"] = 0x008000;
				colornames[untyped "forestgreen"] = 0x228B22;
				colornames[untyped "limegreen"] = 0x32CD32;
				colornames[untyped "lime"] = 0x00FF00;
				colornames[untyped "chartreuse"] = 0x7FFF00;
				colornames[untyped "lawngreen"] = 0x7CFC00;
				colornames[untyped "greenyellow"] = 0xADFF2F;
				colornames[untyped "yellowgreen"] = 0x9ACD32;
				colornames[untyped "palegreen"] = 0x98FB98;
				colornames[untyped "lightgreen"] = 0x90EE90;
				colornames[untyped "springgreen"] = 0x00FF7F;
				colornames[untyped "mediumspringgreen"] = 0x00FA9A;
				colornames[untyped "darkolivegreen"] = 0x556B2F;
				colornames[untyped "olivedrab"] = 0x6B8E23;
				colornames[untyped "olive"] = 0x808000;
				colornames[untyped "darkkhaki"] = 0xBDB76B;
				colornames[untyped "darkgoldenrod"] = 0xB8860B;
				colornames[untyped "goldenrod"] = 0xDAA520;
				colornames[untyped "gold"] = 0xFFD700;
				colornames[untyped "yellow"] = 0xFFFF00;
				colornames[untyped "khaki"] = 0xF0E68C;
				colornames[untyped "palegoldenrod"] = 0xEEE8AA;
				colornames[untyped "blanchedalmond"] = 0xFFEBCD;
				colornames[untyped "moccasin"] = 0xFFE4B5;
				colornames[untyped "wheat"] = 0xF5DEB3;
				colornames[untyped "navajowhite"] = 0xFFDEAD;
				colornames[untyped "burlywood"] = 0xDEB887;
				colornames[untyped "tan"] = 0xD2B48C;
				colornames[untyped "rosybrown"] = 0xBC8F8F;
				colornames[untyped "sienna"] = 0xA0522D;
				colornames[untyped "saddlebrown"] = 0x8B4513;
				colornames[untyped "chocolate"] = 0xD2691E;
				colornames[untyped "peru"] = 0xCD853F;
				colornames[untyped "sandybrown"] = 0xF4A460;
				colornames[untyped "darkred"] = 0x8B0000;
				colornames[untyped "maroon"] = 0x800000;
				colornames[untyped "brown"] = 0xA52A2A;
				colornames[untyped "firebrick"] = 0xB22222;
				colornames[untyped "indianred"] = 0xCD5C5C;
				colornames[untyped "lightcoral"] = 0xF08080;
				colornames[untyped "salmon"] = 0xFA8072;
				colornames[untyped "darksalmon"] = 0xE9967A;
				colornames[untyped "lightsalmon"] = 0xFFA07A;
				colornames[untyped "coral"] = 0xFF7F50;
				colornames[untyped "tomato"] = 0xFF6347;
				colornames[untyped "darkorange"] = 0xFF8C00;
				colornames[untyped "orange"] = 0xFFA500;
				colornames[untyped "orangered"] = 0xFF4500;
				colornames[untyped "crimson"] = 0xDC143C;
				colornames[untyped "red"] = 0xFF0000;
				colornames[untyped "deeppink"] = 0xFF1493;
				colornames[untyped "fuchsia"] = 0xFF00FF;
				colornames[untyped "magenta"] = 0xFF00FF;
				colornames[untyped "hotpink"] = 0xFF69B4;
				colornames[untyped "lightpink"] = 0xFFB6C1;
				colornames[untyped "pink"] = 0xFFC0CB;
				colornames[untyped "palevioletred"] = 0xDB7093;
				colornames[untyped "mediumvioletred"] = 0xC71585;
				colornames[untyped "purple"] = 0x800080;
				colornames[untyped "darkmagenta"] = 0x8B008B;
				colornames[untyped "mediumpurple"] = 0x9370DB;
				colornames[untyped "blueviolet"] = 0x8A2BE2;
				colornames[untyped "indigo"] = 0x4B0082;
				colornames[untyped "darkviolet"] = 0x9400D3;
				colornames[untyped "darkorchid"] = 0x9932CC;
				colornames[untyped "mediumorchid"] = 0xBA55D3;
				colornames[untyped "orchid"] = 0xDA70D6;
				colornames[untyped "violet"] = 0xEE82EE;
				colornames[untyped "plum"] = 0xDDA0DD;
				colornames[untyped "thistle"] = 0xD8BFD8;
				colornames[untyped "lavender"] = 0xE6E6FA;
				colornames[untyped "ghostwhite"] = 0xF8F8FF;
				colornames[untyped "aliceblue"] = 0xF0F8FF;
				colornames[untyped "mintcream"] = 0xF5FFFA;
				colornames[untyped "honeydew"] = 0xF0FFF0;
				colornames[untyped "lightgoldenrodyellow"] = 0xFAFAD2;
				colornames[untyped "lemonchiffon"] = 0xFFFACD;
				colornames[untyped "cornsilk"] = 0xFFF8DC;
				colornames[untyped "lightyellow"] = 0xFFFFE0;
				colornames[untyped "ivory"] = 0xFFFFF0;
				colornames[untyped "floralwhite"] = 0xFFFAF0;
				colornames[untyped "linen"] = 0xFAF0E6;
				colornames[untyped "oldlace"] = 0xFDF5E6;
				colornames[untyped "antiquewhite"] = 0xFAEBD7;
				colornames[untyped "bisque"] = 0xFFE4C4;
				colornames[untyped "peachpuff"] = 0xFFDAB9;
				colornames[untyped "papayawhip"] = 0xFFEFD5;
				colornames[untyped "beige"] = 0xF5F5DC;
				colornames[untyped "seashell"] = 0xFFF5EE;
				colornames[untyped "lavenderblush"] = 0xFFF0F5;
				colornames[untyped "mistyrose"] = 0xFFE4E1;
				colornames[untyped "snow"] = 0xFFFAFA;
				colornames[untyped "white"] = 0xFFFFFF;
				colornames[untyped "whitesmoke"] = 0xF5F5F5;
				colornames[untyped "gainsboro"] = 0xDCDCDC;
				colornames[untyped "lightgrey"] = 0xD3D3D3;
				colornames[untyped "silver"] = 0xC0C0C0;
				colornames[untyped "darkgrey"] = 0xA9A9A9;
				colornames[untyped "grey"] = 0x808080;
				colornames[untyped "lightslategrey"] = 0x778899;
				colornames[untyped "slategrey"] = 0x708090;
				colornames[untyped "dimgrey"] = 0x696969;
				colornames[untyped "darkslategrey"] = 0x2F4F4F;
				colornames[untyped "black"] = 0x000000;
				colornames[untyped "transparent"] = 0xFF000000;
			}
			if (colornames[untyped data] != null) {
				return colornames[untyped data];
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
			throw new CastError("Can't cast to color: " + data);
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
		if (Std.is(data, Class)) {
			try {
				data = Type.createInstance(data, []);
			} catch (bitmaperror:Dynamic) {
				data = Type.createInstance(data, []);
			}

		}
		if (Std.is(data, BitmapData)) {
			return data;
		}
		if (Std.is(data, Bitmap)) {
			// if (data is BitmapAsset)
			if (Reflect.hasField(cast(data, Bitmap), "bitmapData")) {
				return (cast(data, Bitmap)).bitmapData;
			}
		}
		if (Std.is(data, DisplayObject)) {
			var ds:DisplayObject = cast(data, DisplayObject);
			var bmd:BitmapData = new BitmapData(Std.int(ds.width), Std.int(ds.height), true, 0x00FFFFFF);
			var mat:Matrix = ds.transform.matrix.clone();
			mat.tx = 0;
			mat.ty = 0;
			bmd.draw(ds, mat, ds.transform.colorTransform, ds.blendMode, bmd.rect, true);
			return bmd;
		}
		throw new CastError("Can't cast to bitmap: " + data);
		
		// autogenerated
		return null;
	}

	public static function tryclass(name:String):Dynamic {
		
		if ((notclasses[untyped name] != null)) {
			return name;
		}
		var result:Class<Dynamic> = classes[untyped name];
		if (result != null) {
			return result;
		}
		try {
			result = cast(Type.resolveClass(name), Class<Dynamic>);
			classes[untyped name] = result;
			return result;
		} catch (error:Dynamic) {
		}

		notclasses[untyped name] = true;
		return name;
	}

	public static function material(data:Dynamic):IMaterial {
		
		if (data == null) {
			return null;
		}
		if (Std.is(data, String)) {
			data = tryclass(data);
		}
		if (Std.is(data, Class)) {
			try {
				data = Type.createInstance(data, []);
			} catch (materialerror:Dynamic) {
				data = Type.createInstance(data, []);
			}

		}
		if (Std.is(data, IMaterial)) {
			return data;
		}
		if (Std.is(data, Int)) {
			return new ColorMaterial(data);
		}
		if (Std.is(data, MovieClip)) {
			return new MovieMaterial(data);
		}
		if (Std.is(data, String)) {
			if (data == "") {
				return null;
			}
			var hash:Array<Dynamic>;
			if (untyped (cast(data, String)).indexOf("#") != -1) {
				hash = (cast(data, String)).split("#");
				if (hash[1] == "") {
					return new WireColorMaterial(color(hash[0]));
				}
				if (untyped hash[1].indexOf("|") == -1) {
					if (hash[0] == "") {
						return new WireframeMaterial(color(hash[1]));
					} else {
						return new WireColorMaterial(color(hash[0]), {wirecolor:color(hash[1])});
					}
				} else {
					var line:Array<Dynamic> = hash[1].split("|");
					if (hash[0] == "") {
						return new WireframeMaterial(color(line[0]), {width:Std.parseFloat(line[1])});
					} else {
						return new WireColorMaterial(color(hash[0]), {wirecolor:color(line[0]), width:Std.parseFloat(line[1])});
					}
				}
			} else if (untyped (cast(data, String)).indexOf("@") != -1) {
				hash = (cast(data, String)).split("@");
				if (hash[1] == "") {
					return new ShadingColorMaterial({color:color(hash[0])});
				}
			} else {
				return new ColorMaterial(color(data));
			}
		}
		try {
			var bmd:BitmapData = Cast.bitmap(data);
			return new BitmapMaterial(bmd);
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
				throw new CastError("Can't create material with color and bitmap: " + data);
			}
			if (bitmap != null) {
				if (wire != null) {
					Debug.warning("Bitmap materials do not support wire");
				}
				var smooth:Bool = ini.getBoolean("smooth", false);
				var precision:Float = ini.getNumber("precision", 0);
				if ((precision > 0)) {
					if (lighting) {
						return new WhiteShadingBitmapMaterial(bitmap, {smooth:smooth, precision:precision});
					}
					if (alpha < 1) {
						Debug.warning("Can't create precise bitmap material with alpha (yet)");
					}
					return new BitmapMaterial(bitmap, {smooth:smooth, precision:precision});
				}
				if (lighting) {
					if (alpha < 1) {
						Debug.warning("Can't create bitmap material with lighting and alpha (yet)");
					}
					return new WhiteShadingBitmapMaterial(bitmap, {smooth:smooth, alpha:alpha});
				}
				return new BitmapMaterial(bitmap, {smooth:smooth});
			}
			if (color != 0xFFFFFFFF) {
				if (lighting) {
					if (wire != null) {
						Debug.warning("Can't create shading material with wire");
					}
					return new ShadingColorMaterial({color:color, alpha:alpha});
				}
				if (wire == null) {
					return new ColorMaterial(color, {alpha:alpha});
				} else {
					return new WireColorMaterial(color, {alpha:alpha, wirecolor:wire.color, wirealpha:wire.alpha, width:wire.width});
				}
			}
			if (wire != null) {
				return wire;
			}
		}
		throw new CastError("Can't cast to material: " + data);
		
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
			return new WireframeMaterial(data);
		}
		if (Std.is(data, String)) {
			if (data == "") {
				return null;
			}
			if (untyped (cast(data, String)).indexOf("#") == 0) {
				data = (cast(data, String)).substr(1);
			}
			if (untyped (cast(data, String)).indexOf("|") == -1) {
				return new WireframeMaterial(color(data));
			}
			var line:Array<Dynamic> = (cast(data, String)).split("|");
			return new WireframeMaterial(color(line[0]), {width:Std.parseFloat(line[1])});
		}
		if (Std.is(data, Dynamic)) {
			var dat:Init = Init.parse(data);
			var color:Int = dat.getColor("color", 0);
			var alpha:Float = dat.getNumber("alpha", 1, {min:0, max:1});
			var width:Float = dat.getNumber("width", 1, {min:0});
			return new WireframeMaterial(color, {alpha:alpha, width:width});
		}
		throw new CastError("Can't cast to wirematerial: " + data);
		
		// autogenerated
		return null;
	}

	// autogenerated
	public function new () {
		
	}

	

}

