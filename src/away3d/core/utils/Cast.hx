package away3d.core.utils;

import flash.geom.Matrix;
import flash.utils.ByteArray;
import away3d.materials.IMaterial;
import flash.events.EventDispatcher;
import flash.display.BitmapData;
import away3d.materials.ISegmentMaterial;
import away3d.haxeutils.HashMap;
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
	
	private static var colornames:Hash<Int>;
	private static var hexchars:String = "0123456789abcdefABCDEF";
	private static var notclasses:Array<String> = new Array<String>();
	private static var classes:Hash<Class<Dynamic>> = new Hash<Class<Dynamic>>();
	

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
				colornames = new Hash<Int>();
				colornames.set("steelblue", 0x4682B4);
				colornames.set("royalblue", 0x041690);
				colornames.set("cornflowerblue", 0x6495ED);
				colornames.set("lightsteelblue", 0xB0C4DE);
				colornames.set("mediumslateblue", 0x7B68EE);
				colornames.set("slateblue", 0x6A5ACD);
				colornames.set("darkslateblue", 0x483D8B);
				colornames.set("midnightblue", 0x191970);
				colornames.set("navy", 0x000080);
				colornames.set("darkblue", 0x00008B);
				colornames.set("mediumblue", 0x0000CD);
				colornames.set("blue", 0x0000FF);
				colornames.set("dodgerblue", 0x1E90FF);
				colornames.set("deepskyblue", 0x00BFFF);
				colornames.set("lightskyblue", 0x87CEFA);
				colornames.set("skyblue", 0x87CEEB);
				colornames.set("lightblue", 0xADD8E6);
				colornames.set("powderblue", 0xB0E0E6);
				colornames.set("azure", 0xF0FFFF);
				colornames.set("lightcyan", 0xE0FFFF);
				colornames.set("paleturquoise", 0xAFEEEE);
				colornames.set("mediumturquoise", 0x48D1CC);
				colornames.set("lightseagreen", 0x20B2AA);
				colornames.set("darkcyan", 0x008B8B);
				colornames.set("teal", 0x008080);
				colornames.set("cadetblue", 0x5F9EA0);
				colornames.set("darkturquoise", 0x00CED1);
				colornames.set("aqua", 0x00FFFF);
				colornames.set("cyan", 0x00FFFF);
				colornames.set("turquoise", 0x40E0D0);
				colornames.set("aquamarine", 0x7FFFD4);
				colornames.set("mediumaquamarine", 0x66CDAA);
				colornames.set("darkseagreen", 0x8FBC8F);
				colornames.set("mediumseagreen", 0x3CB371);
				colornames.set("seagreen", 0x2E8B57);
				colornames.set("darkgreen", 0x006400);
				colornames.set("green", 0x008000);
				colornames.set("forestgreen", 0x228B22);
				colornames.set("limegreen", 0x32CD32);
				colornames.set("lime", 0x00FF00);
				colornames.set("chartreuse", 0x7FFF00);
				colornames.set("lawngreen", 0x7CFC00);
				colornames.set("greenyellow", 0xADFF2F);
				colornames.set("yellowgreen", 0x9ACD32);
				colornames.set("palegreen", 0x98FB98);
				colornames.set("lightgreen", 0x90EE90);
				colornames.set("springgreen", 0x00FF7F);
				colornames.set("mediumspringgreen", 0x00FA9A);
				colornames.set("darkolivegreen", 0x556B2F);
				colornames.set("olivedrab", 0x6B8E23);
				colornames.set("olive", 0x808000);
				colornames.set("darkkhaki", 0xBDB76B);
				colornames.set("darkgoldenrod", 0xB8860B);
				colornames.set("goldenrod", 0xDAA520);
				colornames.set("gold", 0xFFD700);
				colornames.set("yellow", 0xFFFF00);
				colornames.set("khaki", 0xF0E68C);
				colornames.set("palegoldenrod", 0xEEE8AA);
				colornames.set("blanchedalmond", 0xFFEBCD);
				colornames.set("moccasin", 0xFFE4B5);
				colornames.set("wheat", 0xF5DEB3);
				colornames.set("navajowhite", 0xFFDEAD);
				colornames.set("burlywood", 0xDEB887);
				colornames.set("tan", 0xD2B48C);
				colornames.set("rosybrown", 0xBC8F8F);
				colornames.set("sienna", 0xA0522D);
				colornames.set("saddlebrown", 0x8B4513);
				colornames.set("chocolate", 0xD2691E);
				colornames.set("peru", 0xCD853F);
				colornames.set("sandybrown", 0xF4A460);
				colornames.set("darkred", 0x8B0000);
				colornames.set("maroon", 0x800000);
				colornames.set("brown", 0xA52A2A);
				colornames.set("firebrick", 0xB22222);
				colornames.set("indianred", 0xCD5C5C);
				colornames.set("lightcoral", 0xF08080);
				colornames.set("salmon", 0xFA8072);
				colornames.set("darksalmon", 0xE9967A);
				colornames.set("lightsalmon", 0xFFA07A);
				colornames.set("coral", 0xFF7F50);
				colornames.set("tomato", 0xFF6347);
				colornames.set("darkorange", 0xFF8C00);
				colornames.set("orange", 0xFFA500);
				colornames.set("orangered", 0xFF4500);
				colornames.set("crimson", 0xDC143C);
				colornames.set("red", 0xFF0000);
				colornames.set("deeppink", 0xFF1493);
				colornames.set("fuchsia", 0xFF00FF);
				colornames.set("magenta", 0xFF00FF);
				colornames.set("hotpink", 0xFF69B4);
				colornames.set("lightpink", 0xFFB6C1);
				colornames.set("pink", 0xFFC0CB);
				colornames.set("palevioletred", 0xDB7093);
				colornames.set("mediumvioletred", 0xC71585);
				colornames.set("purple", 0x800080);
				colornames.set("darkmagenta", 0x8B008B);
				colornames.set("mediumpurple", 0x9370DB);
				colornames.set("blueviolet", 0x8A2BE2);
				colornames.set("indigo", 0x4B0082);
				colornames.set("darkviolet", 0x9400D3);
				colornames.set("darkorchid", 0x9932CC);
				colornames.set("mediumorchid", 0xBA55D3);
				colornames.set("orchid", 0xDA70D6);
				colornames.set("violet", 0xEE82EE);
				colornames.set("plum", 0xDDA0DD);
				colornames.set("thistle", 0xD8BFD8);
				colornames.set("lavender", 0xE6E6FA);
				colornames.set("ghostwhite", 0xF8F8FF);
				colornames.set("aliceblue", 0xF0F8FF);
				colornames.set("mintcream", 0xF5FFFA);
				colornames.set("honeydew", 0xF0FFF0);
				colornames.set("lightgoldenrodyellow", 0xFAFAD2);
				colornames.set("lemonchiffon", 0xFFFACD);
				colornames.set("cornsilk", 0xFFF8DC);
				colornames.set("lightyellow", 0xFFFFE0);
				colornames.set("ivory", 0xFFFFF0);
				colornames.set("floralwhite", 0xFFFAF0);
				colornames.set("linen", 0xFAF0E6);
				colornames.set("oldlace", 0xFDF5E6);
				colornames.set("antiquewhite", 0xFAEBD7);
				colornames.set("bisque", 0xFFE4C4);
				colornames.set("peachpuff", 0xFFDAB9);
				colornames.set("papayawhip", 0xFFEFD5);
				colornames.set("beige", 0xF5F5DC);
				colornames.set("seashell", 0xFFF5EE);
				colornames.set("lavenderblush", 0xFFF0F5);
				colornames.set("mistyrose", 0xFFE4E1);
				colornames.set("snow", 0xFFFAFA);
				colornames.set("white", 0xFFFFFF);
				colornames.set("whitesmoke", 0xF5F5F5);
				colornames.set("gainsboro", 0xDCDCDC);
				colornames.set("lightgrey", 0xD3D3D3);
				colornames.set("silver", 0xC0C0C0);
				colornames.set("darkgrey", 0xA9A9A9);
				colornames.set("grey", 0x808080);
				colornames.set("lightslategrey", 0x778899);
				colornames.set("slategrey", 0x708090);
				colornames.set("dimgrey", 0x696969);
				colornames.set("darkslategrey", 0x2F4F4F);
				colornames.set("black", 0x000000);
				colornames.set("transparent", 0xFF000000);
			}
			if (colornames.exists(data)) {
				return colornames.get(data);
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
		
		if (untyped notclasses.indexOf(name) != -1) {
			return name;
		}
		var result:Class<Dynamic> = classes.get(name);
		if (result != null) {
			return result;
		}
		try {
			result = cast(Type.resolveClass(name), Class<Dynamic>);
			classes.set(name, result);
			return result;
		} catch (error:Dynamic) {
		}

		notclasses.push(name);
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

