package away3d.extrusions;

import flash.display.BitmapData;
import away3d.core.math.Number3D;


/**
 * Class Elevation returns a multidimentional array of Number3D's to pass to the SkinClass in order to generate an elevated mesh from <Elevation></code>
 * 
 */
class Elevation  {
	public var minElevation(getMinElevation, setMinElevation) : Float;
	public var maxElevation(getMaxElevation, setMaxElevation) : Float;
	
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
	 * Creates a generate <code>Elevation</code> object.
	 *
	 */
	public function new() {
		this._minElevation = 0;
		this._maxElevation = 255;
		
		
	}

	/**
	 * Generate the Array representing the mesh
	 *
	 * @param	sourceBmd				Bitmapdata. The bitmapData to read from.
	 * @param	channel					[optional] String. The channel information to read. supported "a", alpha, "r", red, "g", green, "b", blue and "av" (averages and luminance). Default is red channel "r".
	 * @param	subdivisionX			[optional] int. The subdivision to read the pixels along the x axis. Default is 10.
	 * @param	subdivisionY			[optional] int. The subdivision to read the pixels along the y axis. Default is 10.
	 * @param	scalingX					[optional] Number. The scale multiplier along the x axis. Default is 1.
	 * @param	scalingY					[optional] Number. The scale multiplier along the y axis. Default is 1.
	 * @param	elevate					[optional] Number. The scale multiplier along the z axis. Default is .5.
	 */
	public function generate(sourceBmd:BitmapData, ?channel:String="r", ?subdivisionX:Int=10, ?subdivisionY:Int=10, ?scalingX:Float=1, ?scalingY:Float=1, ?elevate:Float=.5):Array<Dynamic> {
		
		channel = channel.toLowerCase();
		var w:Int = sourceBmd.width;
		var h:Int = sourceBmd.height;
		var i:Int;
		var j:Int;
		var x:Float = 0;
		var y:Float = 0;
		var z:Float = 0;
		var totalArray:Array<Dynamic> = [];
		var tmpArray:Array<Dynamic> = [];
		var color:Int;
		var cha:Float;
		j = h - 1;
		while (j > -subdivisionY) {
			y = (j < 0) ? 0 : j;
			tmpArray = [];
			i = 0;
			while (i < w + subdivisionX) {
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
				tmpArray.push(new Number3D(x * scalingX, y * scalingY, z));
				
				// update loop variables
				i += subdivisionX;
			}

			totalArray.push(tmpArray);
			
			// update loop variables
			j -= subdivisionY;
		}

		return totalArray;
	}

}

