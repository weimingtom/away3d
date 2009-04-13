package away3d.exporters;

import flash.display.BitmapData;


/**
 * Class Elevation2AS3 generates a string class of the elevation to pass to the SkinClass and ElevationReader in order to save space and processing time.
 * 
 */
class Elevation2AS3  {
	public var minElevation(getMinElevation, setMinElevation) : Float;
	public var maxElevation(getMaxElevation, setMaxElevation) : Float;
	
	private var _minElevation:Float;
	private var _maxElevation:Float;
	private var _exportmap:Bool;
	private var _classname:String;
	private var _packagename:String;
	

	/**
	 * Locks elevation factor beneath this level. Default is 0;
	 *
	 */
	public function setMinElevation(val:Float):Float {
		
		_minElevation = val;
		return val;
	}

	public function getMinElevation():Float {
		
		return _minElevation;
	}

	/**
	 * Locks elevation factor above this level. Default is 255;
	 *
	 */
	public function setMaxElevation(val:Float):Float {
		
		_maxElevation = val;
		return val;
	}

	public function getMaxElevation():Float {
		
		return _maxElevation;
	}

	/**
	 * Creates a generate an as3 file of the elevation array.
	 * @param	classname			String, the name of the class that will be exported.
	 * @param	packagename	[optional] String. the name of the package that will be exported.
	 * @param	exportmap			[optional] Boolean. Defines if the class should generate an array to pass to the ElevationReader.
	 */
	public function new(classname:String, ?packagename:String="", ?exportmap:Bool=false) {
		this._minElevation = 0;
		this._maxElevation = 255;
		
		
		_exportmap = exportmap;
		_classname = classname.substr(0, 1 - 0).toUpperCase() + classname.substr(1, classname.length - 1);
		_packagename = packagename.toLowerCase();
	}

	/**
	 * Generate the string representing the mesh and optionally color information for the reader.
	 *
	 * @param	sourceBmd				Bitmapdata. The bitmapData to read from.
	 * @param	channel					[optional] String. The channel information to read. supported "a", alpha, "r", red, "g", green, "b", blue and "av" (averages and luminance). Default is red channel "r".
	 * @param	subdivisionX			[optional] int. The subdivision to read the pixels along the x axis. Default is 10.
	 * @param	subdivisionY			[optional] int. The subdivision to read the pixels along the y axis. Default is 10.
	 * @param	factorX					[optional] Number. The scale multiplier along the x axis. Default is 1.
	 * @param	factorY					[optional] Number. The scale multiplier along the y axis. Default is 1.
	 * @param	elevate					[optional] Number. The scale multiplier along the z axis. Default is .5.
	 */
	public function export(sourceBmd:BitmapData, ?channel:String="r", ?subdivisionX:Int=10, ?subdivisionY:Int=10, ?factorX:Float=1, ?factorY:Float=1, ?elevate:Float=.5):Void {
		
		var source:String = "package " + _packagename + "\n{\n\timport away3d.core.math.Number3D;\n";
		if (_exportmap) {
			source += "\timport flash.display.BitmapData;\n";
			source += "\timport away3d.extrusions.ElevationReader;\n";
		}
		source += "\n\tpublic class " + _classname + "\n\t{\n";
		source += "\t\t//exporterversion:1.0;\n\n";
		source += "\t\tprivate var arr:Array;\n";
		if (_exportmap) {
			var insert:String = getColorInfo(sourceBmd, channel, subdivisionX, subdivisionY, factorX, factorY, elevate);
			source += "\t\tprivate var arrc:Array;\n";
		}
		source += "\n\t\tpublic function " + _classname + "()\n\t\t{\n\t\t\tarr =[";
		channel = channel.toLowerCase();
		var w:Int = sourceBmd.width;
		var h:Int = sourceBmd.height;
		var i:Int;
		var j:Int;
		var x:Float = 0;
		var y:Float = 0;
		var z:Float = 0;
		var color:Int;
		var cha:Float;
		j = h - 1;
		while (j > -subdivisionY) {
			y = (j < 0) ? 0 : j;
			source += (j == h - 1) ? "[" : "],[";
			i = 0;
			while (i < w + subdivisionX) {
				source += (i > 0) ? "," : "";
				x = (i < w - 1) ? i : w - 1;
				color = (channel == "a") ? sourceBmd.getPixel32(x, y) : sourceBmd.getPixel(x, y);
				switch (channel) {
					case "a" :
						cha = color >> 24 & 0xFF;
					case "r" :
						cha = color >> 16 & 0xFF;
					case "g" :
						cha = color >> 8 & 0xFF;
					case "b" :
						cha = color & 0xFF;
					case "av" :
						cha = ((color >> 16 & 0xFF) * 0.212671) + ((color >> 8 & 0xFF) * 0.715160) + ((color >> 8 & 0xFF) * 0.072169);
					

				}
				if (maxElevation < cha) {
					cha = maxElevation;
				}
				if (minElevation > cha) {
					cha = minElevation;
				}
				z = cha * elevate;
				source += (x * factorX) + "," + (y * factorY) + "," + z;
				
				// update loop variables
				i += subdivisionX;
			}

			
			// update loop variables
			j -= subdivisionY;
		}

		source += "]];\n\t\t};";
		if (_exportmap) {
			source += insert;
		}
		source += "\n\n\t\tpublic function get data():Array\n\t\t{\n\t\t\t\ var output:Array = [];\n\t\t\t var i:int;\n\t\t\t var j:int;\n\t\t\t var tmp:Array;\n\t\t\t var tmp2:Array;\n\n\t\t\t for(i = 0;i<arr.length;++i){\n\t\t\t\ttmp = arr[i];\n\t\t\t\ttmp2 = [];\n\t\t\t\tfor(j = 0;j<tmp.length;j+=3){\n\t\t\t\t\ttmp2.push(new Number3D(tmp[j], tmp[j+1], tmp[j+2]));\n\t\t\t\t}\n\t\t\t\toutput.push(tmp2);\n\t\t\t }\n\t\t\t\ return output;\n\t\t}\n\n\t}\n}";
		trace(source);
	}

	private function getColorInfo(sourceBmd:BitmapData, channel:String, subdivisionX:Int, subdivisionY:Int, factorX:Float, factorY:Float, elevate:Float):String {
		
		var w:Float = sourceBmd.width;
		var h:Float = sourceBmd.height;
		var i:Int = 0;
		var j:Int = 0;
		var k:Int = 0;
		var l:Int = 0;
		var px1:Float;
		var px2:Float;
		var px3:Float;
		var px4:Float;
		var lockx:Int;
		var locky:Int;
		var col:Float;
		var incXL:Float;
		var incXR:Float;
		var incYL:Float;
		var incYR:Float;
		var pxx:Float;
		var pxy:Float;
		var colorinfo:String = "\n\n\t\tpublic function set map(elevationreader:ElevationReader):void\n\t\t{\n\t\t\t\televationreader.setSource( buildMap(), \"" + channel + "\", " + factorX + ", " + factorY + ", " + elevate + ");\n\t\t};\n\n\t\tpublic function buildMap():BitmapData\n\t\t{\n\t\t\tvar w:Number = " + w + ";\n\t\t\tvar h:Number = " + h + ";\n\t\t\tvar subdivisionX:Number = " + subdivisionX + ";\n\t\t\tvar subdivisionY:Number = " + subdivisionY + ";\n\t\t\tvar i:int = 0;\n\t\t\tvar j:int = 0;\n\t\t\tvar k:int = 0;\n\t\t\tvar l:int = 0;\n\t\t\tvar px1:Number;\n\t\t\tvar px2:Number;\n\t\t\tvar px3:Number;\n\t\t\tvar px4:Number;\n\t\t\tvar col:Number;\n\t\t\tvar incXL:Number;\n\t\t\tvar incXR:Number;\n\t\t\tvar incYL:Number;\n\t\t\tvar incYR:Number;\n\t\t\tvar pxx:Number;\n\t\t\tvar pxy:Number;\n\t\t\tvar index:int = 0;\n\t\t\tvar aCol:Array = [";
		var del:String;
		i = 0;
		while (i < w + 1) {
			del = (i == 0) ? "" : ",";
			if (i + subdivisionX > w) {
				lockx = Std.int(w);
			} else {
				lockx = i + subdivisionX;
			}
			j = 0;
			while (j < h + 1) {
				if (j + subdivisionY > h) {
					locky = Std.int(h);
				} else {
					locky = j + subdivisionY;
				}
				if (j == 0) {
					switch (channel) {
						case "a" :
							px1 = sourceBmd.getPixel32(i, j) >> 24 & 0xFF;
							px2 = sourceBmd.getPixel32(lockx, j) >> 24 & 0xFF;
							px3 = sourceBmd.getPixel32(lockx, locky) >> 24 & 0xFF;
							px4 = sourceBmd.getPixel32(i, locky) >> 24 & 0xFF;
						case "r" :
							px1 = sourceBmd.getPixel(i, j) >> 16 & 0xFF;
							px2 = sourceBmd.getPixel(lockx, j) >> 16 & 0xFF;
							px3 = sourceBmd.getPixel(lockx, locky) >> 16 & 0xFF;
							px4 = sourceBmd.getPixel(i, locky) >> 16 & 0xFF;
						case "g" :
							px1 = sourceBmd.getPixel(i, j) >> 8 & 0xFF;
							px2 = sourceBmd.getPixel(lockx, j) >> 8 & 0xFF;
							px3 = sourceBmd.getPixel(lockx, locky) >> 8 & 0xFF;
							px4 = sourceBmd.getPixel(i, locky) >> 8 & 0xFF;
						case "b" :
							px1 = sourceBmd.getPixel(i, j) & 0xFF;
							px2 = sourceBmd.getPixel(lockx, j) & 0xFF;
							px3 = sourceBmd.getPixel(lockx, locky) & 0xFF;
							px4 = sourceBmd.getPixel(i, locky) & 0xFF;
						

					}
					colorinfo += del + px1 + "," + px2 + "," + px3 + "," + px4;
				} else {
					px1 = px4;
					px2 = px3;
					switch (channel) {
						case "a" :
							px3 = sourceBmd.getPixel32(lockx, locky) >> 24 & 0xFF;
							px4 = sourceBmd.getPixel32(i, locky) >> 24 & 0xFF;
						case "r" :
							px3 = sourceBmd.getPixel(lockx, locky) >> 16 & 0xFF;
							px4 = sourceBmd.getPixel(i, locky) >> 16 & 0xFF;
						case "g" :
							px3 = sourceBmd.getPixel(lockx, locky) >> 8 & 0xFF;
							px4 = sourceBmd.getPixel(i, locky) >> 8 & 0xFF;
						case "b" :
							px3 = sourceBmd.getPixel(lockx, locky) & 0xFF;
							px4 = sourceBmd.getPixel(i, locky) & 0xFF;
						

					}
					colorinfo += "," + px3 + "," + px4;
				}
				
				// update loop variables
				j += subdivisionY;
			}

			
			// update loop variables
			i += subdivisionX;
		}

		colorinfo += "];\n\t\t\tvar bmd:BitmapData = new BitmapData(" + w + ", " + h + ", false, 0x000000);\n\t\t\tbmd.lock();\n\n\t\t\tfor(i = 0; i < w+1; i+=subdivisionX)\n\t\t\t{\n\t\t\t\tfor(j = 0; j < h+1; j+=subdivisionY)\n\t\t\t\t{\n\t\t\t\t\tif(j == 0){\n\t\t\t\t\t\tpx1 = aCol[index];\n\t\t\t\t\t\tpx2 = aCol[index+1];\n\t\t\t\t\t\tpx3 = aCol[index+2];\n\t\t\t\t\t\tpx4 = aCol[index+3];\n\t\t\t\t\t\tindex +=4;\n\n\t\t\t\t\t} else {\n\t\t\t\t\t\tpx1 = px4;\n\t\t\t\t\t\tpx2 = px3;\n\t\t\t\t\t\tpx3 = aCol[index];\n\t\t\t\t\t\tpx4 = aCol[index+1];\n\t\t\t\t\t\tindex +=2;\n\t\t\t\t\t}\n\n\t\t\t\t\tfor(k = 0; k < subdivisionX; k++)\n\t\t\t\t\t{\n\t\t\t\t\t\tincXL = 1/subdivisionX * k;\n\t\t\t\t\t\tincXR = 1-incXL;\n\n\t\t\t\t\t\tfor(l = 0; l < subdivisionY; l++)\n\t\t\t\t\t\t{\n\t\t\t\t\t\t\tincYL = 1/subdivisionY * l;\n\t\t\t\t\t\t\tincYR = 1-incYL;\n\t\t\t\t\t\t\tpxx = ((px1*incXR) + (px2*incXL))*incYR;\n\t\t\t\t\t\t\tpxy = ((px4*incXR) + (px3*incXL))*incYL;\n\t\t\t\t\t\t\tbmd.setPixel(k+i, l+j, pxy+pxx << 16 );\n\t\t\t\t\t\t}\n\t\t\t\t\t}\n\t\t\t\t}\n\t\t\t}\n\n\t\t\tbmd.unlock();\n\n\t\t\treturn bmd;\n\n\t\t}\n";
		return colorinfo;
	}

}

