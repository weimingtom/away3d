package away3d.extrusions;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Matrix;


class ElevationReader  {
	public var minElevation(getMinElevation, setMinElevation) : Float;
	public var maxElevation(getMaxElevation, setMaxElevation) : Float;
	public var source(getSource, null) : BitmapData;
	
	private var channel:String;
	private var levelBmd:BitmapData;
	private var elevate:Float;
	private var scalingX:Float;
	private var scalingY:Float;
	private var buffer:Array<Float>;
	private var level:Float;
	private var offsetX:Float;
	private var offsetY:Float;
	private var smoothness:Int;
	private var _minElevation:Float;
	private var _maxElevation:Float;
	

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
	 * Class generates a traced representation of the elevation geometry, allowing surface tracking to place or move objects on the elevation geometry.  <ElevationReader ></code>
	 * 
	 */
	public function new(?smoothness:Int=0) {
		this.offsetX = 0;
		this.offsetY = 0;
		this._minElevation = 0;
		this._maxElevation = 255;
		
		
		buildBuffer(smoothness);
	}

	private function buildBuffer(?smoothness:Int=0):Void {
		
		this.smoothness = smoothness;
		buffer = [];
		var i:Int = 0;
		while (i < smoothness) {
			buffer.push(0);
			
			// update loop variables
			i++;
		}

		level = 0;
	}

	/**
	 * Optional method to be allow the use of a custom (externally) prerendered map.
	 * @param	sourceBmd		Bitmapdata. The bitmapData to read from.
	 * @param	channel			[optional] String. The channel information to read. Supported "a", alpha, "r", red, "g", green, "b", blue and "av" (averages and luminance). Default is red channel "r".
	 * @param	factorX			[optional] Number. The scale multiplier along the x axis. Default is 1.
	 * @param	factorY			[optional] Number. The scale multiplier along the y axis. Default is 1.
	 * @param	factorZ			[optional] Number. The scale multiplier along the z axis (the elevation factor). Default is .5.
	 */
	public function setSource(sourceBmd:BitmapData, ?channel:String="r", ?factorX:Float=1, ?factorY:Float=1, ?factorZ:Float=.5):Void {
		
		levelBmd = sourceBmd;
		this.channel = channel;
		scalingX = factorX;
		scalingY = factorY;
		elevate = factorZ;
	}

	/**
	 * returns the generated bitmapdata, a smooth representation of the geometry.
	 */
	public function getSource():BitmapData {
		
		return levelBmd;
	}

	/**
	 * returns the generated bitmapdata, a smooth representation of the geometry.
	 * 
	 * @param	x				The x coordinate on the generated bitmapdata.
	 * @param	y				The y coordinate on the generated bitmapdata.
	 * @param	offset			[optional]	the offset that will be added to the elevation value at the x and y coordinates plus the offset. Default = 0. 
	 *
	 * @return 	A Number, the elevation value at the x and y coordinates plus the offset.
	 */
	public function getLevel(x:Float, y:Float, ?offset:Float=0):Float {
		
		var col:Float = x / scalingX;
		var row:Float = y / scalingY;
		col += (levelBmd.width * .5) + offsetX;
		row += (levelBmd.height * .5) + offsetY;
		var color:Float = levelBmd.getPixel(col, row);
		var r:Float = color >> 16 & 0xFF;
		if (maxElevation < r) {
			r = maxElevation;
		}
		if (minElevation > r) {
			r = minElevation;
		}
		if (smoothness == 0) {
			return (r * elevate) + offset;
		}
		buffer.push((r * elevate) + offset);
		buffer.shift();
		level = 0;
		var i:Int = 0;
		while (i < buffer.length) {
			level += buffer[i];
			
			// update loop variables
			i++;
		}

		return level / buffer.length;
	}

	/**
	 * generates the smooth representation of the geometry. uses same parameters as the Elevation class.
	 * 
	 * @param	sourceBmd				Bitmapdata. The bitmapData to read from.
	 * @param	channel					[optional] String. The channel information to read. supported "a", alpha, "r", red, "g", green, "b", blue and "av" (averages and luminance). Default is red channel "r".
	 * @param	subdivisionX			[optional] int. The subdivision to read the pixels along the x axis. Default is 10.
	 * @param	subdivisionY			[optional] int. The subdivision to read the pixels along the y axis. Default is 10.
	 * @param	scalingX					[optional] Number. The scale multiplier along the x axis. Default is 1.
	 * @param	scalingY					[optional] Number. The scale multiplier along the y axis. Default is 1.
	 * @param	elevate					[optional] Number. The scale multiplier along the z axis. Default is .5.
	 * 
	 * @see away3d.extrusions.Elevation
	 */
	public function traceLevels(sourceBmd:BitmapData, ?channel:String="r", ?subdivisionX:Int=10, ?subdivisionY:Int=10, ?factorX:Float=1, ?factorY:Float=1, ?elevate:Float=.5):Void {
		
		setSource(sourceBmd.clone(), channel, factorX, factorY, elevate);
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
		levelBmd.lock();
		var incXL:Float;
		var incXR:Float;
		var incYL:Float;
		var incYR:Float;
		var pxx:Float;
		var pxy:Float;
		i = 0;
		while (i < w + 1) {
			if (i + subdivisionX > w - 1) {
				offsetX = (w - i - 1) * .5;
				lockx = Std.int(w - 1);
			} else {
				lockx = i + subdivisionX;
			}
			j = 0;
			while (j < h + 1) {
				if (j + subdivisionY > h - 1) {
					offsetY = (h - j - 1) * .5;
					locky = Std.int(h - 1);
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
						case "av" :
							px1 = ((sourceBmd.getPixel(i, j) >> 16 & 0xFF) * 0.212671) + ((sourceBmd.getPixel(i, j) >> 8 & 0xFF) * 0.715160) + ((sourceBmd.getPixel(i, j) & 0xFF) * 0.072169);
							px2 = ((sourceBmd.getPixel(lockx, j) >> 16 & 0xFF) * 0.212671) + ((sourceBmd.getPixel(lockx, j) >> 8 & 0xFF) * 0.715160) + ((sourceBmd.getPixel(lockx, j) & 0xFF) * 0.072169);
							px3 = ((sourceBmd.getPixel(lockx, locky) >> 16 & 0xFF) * 0.212671) + ((sourceBmd.getPixel(lockx, locky) >> 8 & 0xFF) * 0.715160) + ((sourceBmd.getPixel(lockx, locky) & 0xFF) * 0.072169);
							px4 = ((sourceBmd.getPixel(i, locky) >> 16 & 0xFF) * 0.212671) + ((sourceBmd.getPixel(i, locky) >> 8 & 0xFF) * 0.715160) + ((sourceBmd.getPixel(i, locky) & 0xFF) * 0.072169);
						

					}
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
						case "av" :
							px3 = ((sourceBmd.getPixel(lockx, locky) >> 16 & 0xFF) * 0.212671) + ((sourceBmd.getPixel(lockx, locky) >> 8 & 0xFF) * 0.715160) + ((sourceBmd.getPixel(lockx, locky) & 0xFF) * 0.072169);
							px4 = ((sourceBmd.getPixel(i, locky) >> 16 & 0xFF) * 0.212671) + ((sourceBmd.getPixel(i, locky) >> 8 & 0xFF) * 0.715160) + ((sourceBmd.getPixel(i, locky) & 0xFF) * 0.072169);
						

					}
				}
				k = 0;
				while (k < subdivisionX) {
					incXL = 1 / subdivisionX * k;
					incXR = 1 - incXL;
					l = 0;
					while (l < subdivisionY) {
						incYL = 1 / subdivisionY * l;
						incYR = 1 - incYL;
						pxx = ((px1 * incXR) + (px2 * incXL)) * incYR;
						pxy = ((px4 * incXR) + (px3 * incXL)) * incYL;
						levelBmd.setPixel(k + i, l + j, pxy + pxx << 16 | 0xFF - (pxy + pxx) << 8 | 0xFF - (pxy + pxx));
						
						// update loop variables
						++l;
					}

					
					// update loop variables
					++k;
				}

				
				// update loop variables
				j += subdivisionY;
			}

			
			// update loop variables
			i += subdivisionX;
		}

		levelBmd.unlock();
	}

	/**
	 * Apply the generated height source to a bitmapdata. The height information is merged to the source creating a smoother look.
	 * 
	 * @param	src			The bitmapdata that will be merged.
	 * @param	color			[optional]	The color that will be applied. Note that 32 bits color will allow alpha. 0x88FF0000 defines a red with .5 alpha while 0xFF0000 defines a red with no alpha. Default is .5 alpha black.
	 * @param	reverse			[optional]	Defines if the color is set using the heightmap from 0-255 or 255-0. Default = true, if a black is used, the darkest are will be at the base of the elevation. 
	 * @param	blendmode			[optional] Blendmode to be applyed in the merge. Possible string values are: lighten, multiply, overlay, screen, substract, add, darken, difference, erase, hardlight, invert and layer.Default = "normal";
	 */
	public function applyHeightGradient(src:BitmapData, ?color:Int=0x80000000, ?reverse:Bool=true, ?blendmode:BlendMode=BlendMode.NORMAL):Void {
		
		var gs:BitmapData;
		var scl:Bool;
		if (src.width != levelBmd.width || src.height != levelBmd.height) {
			scl = true;
			gs = levelBmd.clone();
			var sclmat:Matrix = new Matrix();
			var Wscl:Float = gs.width / src.width;
			var Hscl:Float = gs.height / src.height;
			sclmat.scale(Wscl, Hscl);
			var sclbmd:BitmapData = new BitmapData(gs.width * Wscl, gs.height * Hscl, true, 0x00FFFFFF);
			sclbmd.draw(gs, sclmat, null, "normal", sclbmd.rect, true);
		} else {
			gs = levelBmd;
		}
		var mskBmd:BitmapData = new BitmapData(gs.width, gs.height, true, color);
		var z:Point = new Point(0, 0);
		if (reverse) {
			mskBmd.copyChannel(gs, gs.rect, z, 2, 8);
		} else {
			mskBmd.copyChannel(gs, gs.rect, z, 1, 8);
		}
		if (blendmode == BlendMode.NORMAL) {
			src.copyPixels(mskBmd, mskBmd.rect, z, mskBmd, z, true);
		} else {
			src.draw(mskBmd, null, null, blendmode, mskBmd.rect, true);
		}
		mskBmd.dispose();
		if (scl) {
			sclbmd.dispose();
			gs.dispose();
		}
	}

}

