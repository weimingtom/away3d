package away3d.primitives;

import away3d.core.utils.ValueObject;
import away3d.core.base.Segment;
import away3d.core.utils.Init;
import away3d.core.base.Vertex;
import away3d.core.base.Element;


// use namespace arcane;

/**
 * Creates a 3d grid primitive.
 */
class GridPlane extends AbstractWirePrimitive  {
	public var width(getWidth, setWidth) : Float;
	public var height(getHeight, setHeight) : Float;
	public var segmentsW(getSegmentsW, setSegmentsW) : Float;
	public var segmentsH(getSegmentsH, setSegmentsH) : Float;
	public var yUp(getYUp, setYUp) : Bool;
	
	private var _width:Float;
	private var _height:Float;
	private var _segmentsW:Int;
	private var _segmentsH:Int;
	private var _yUp:Bool;
	

	private function buildPlane(width:Float, height:Float, segmentsW:Int, segmentsH:Int, yUp:Bool):Void {
		
		var i:Int;
		var j:Int;
		if (yUp) {
			i = 0;
			while (i <= segmentsW) {
				addSegment(createSegment(createVertex((i / segmentsW - 0.5) * width, 0, -0.5 * height), createVertex((i / segmentsW - 0.5) * width, 0, 0.5 * height)));
				
				// update loop variables
				i++;
			}

			j = 0;
			while (j <= segmentsH) {
				addSegment(createSegment(createVertex(-0.5 * width, 0, (j / segmentsH - 0.5) * height), createVertex(0.5 * width, 0, (j / segmentsH - 0.5) * height)));
				
				// update loop variables
				j++;
			}

		} else {
			i = 0;
			while (i <= segmentsW) {
				addSegment(createSegment(createVertex((i / segmentsW - 0.5) * width, -0.5 * height, 0), createVertex((i / segmentsW - 0.5) * width, 0.5 * height, 0)));
				
				// update loop variables
				i++;
			}

			j = 0;
			while (j <= segmentsH) {
				addSegment(createSegment(createVertex(-0.5 * width, (j / segmentsH - 0.5) * height, 0), createVertex(0.5 * width, (j / segmentsH - 0.5) * height, 0)));
				
				// update loop variables
				j++;
			}

		}
	}

	/**
	 * Defines the width of the grid. Defaults to 100.
	 */
	public function getWidth():Float {
		
		return _width;
	}

	public function setWidth(val:Float):Float {
		
		if (_width == val) {
			return val;
		}
		_width = val;
		_primitiveDirty = true;
		return val;
	}

	/**
	 * Defines the height of the grid. Defaults to 100.
	 */
	public function getHeight():Float {
		
		return _height;
	}

	public function setHeight(val:Float):Float {
		
		if (_height == val) {
			return val;
		}
		_height = val;
		_primitiveDirty = true;
		return val;
	}

	/**
	 * Defines the number of horizontal segments that make up the grid. Defaults to 1.
	 */
	public function getSegmentsW():Float {
		
		return _segmentsW;
	}

	public function setSegmentsW(val:Float):Float {
		
		if (_segmentsW == val) {
			return val;
		}
		_segmentsW = Std.int(val);
		_primitiveDirty = true;
		return val;
	}

	/**
	 * Defines the number of vertical segments that make up the grid. Defaults to 1.
	 */
	public function getSegmentsH():Float {
		
		return _segmentsH;
	}

	public function setSegmentsH(val:Float):Float {
		
		if (_segmentsH == val) {
			return val;
		}
		_segmentsH = Std.int(val);
		_primitiveDirty = true;
		return val;
	}

	/**
	 * Defines whether the coordinates of the grid points use a yUp orientation (true) or a zUp orientation (false). Defaults to true.
	 */
	public function getYUp():Bool {
		
		return _yUp;
	}

	public function setYUp(val:Bool):Bool {
		
		if (_yUp == val) {
			return val;
		}
		_yUp = val;
		_primitiveDirty = true;
		return val;
	}

	/**
	 * Creates a new <code>GridPlane</code> object.
	 *
	 * @param	init			[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(?init:Dynamic=null) {
		
		OPPOSITE_OR[X | X] = N;
		OPPOSITE_OR[XY | X] = Y;
		OPPOSITE_OR[XZ | X] = Z;
		OPPOSITE_OR[XYZ | X] = YZ;
		OPPOSITE_OR[Y | Y] = N;
		OPPOSITE_OR[XY | Y] = X;
		OPPOSITE_OR[XYZ | Y] = XZ;
		OPPOSITE_OR[YZ | Y] = Z;
		OPPOSITE_OR[Z | Z] = N;
		OPPOSITE_OR[XZ | Z] = X;
		OPPOSITE_OR[XYZ | Z] = XY;
		OPPOSITE_OR[YZ | Z] = Y;
		SCALINGS[1] = [1, 1, 1];
		SCALINGS[2] = [-1, 1, 1];
		SCALINGS[4] = [-1, 1, -1];
		SCALINGS[8] = [1, 1, -1];
		SCALINGS[16] = [1, -1, 1];
		SCALINGS[32] = [-1, -1, 1];
		SCALINGS[64] = [-1, -1, -1];
		SCALINGS[128] = [1, -1, -1];
		
		super(init);
		_width = ini.getNumber("width", 100, {min:0});
		_height = ini.getNumber("height", 100, {min:0});
		var segments:Int = ini.getInt("segments", 1, {min:1});
		_segmentsW = ini.getInt("segmentsW", segments, {min:1});
		_segmentsH = ini.getInt("segmentsH", segments, {min:1});
		_yUp = ini.getBoolean("yUp", true);
		buildPlane(_width, _height, _segmentsW, _segmentsH, _yUp);
		type = "GridPlane";
		url = "primitive";
	}

	/**
	 * @inheritDoc
	 */
	public override function buildPrimitive():Void {
		
		super.buildPrimitive();
		buildPlane(_width, _height, _segmentsW, _segmentsH, _yUp);
	}

}

