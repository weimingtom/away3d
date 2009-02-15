package away3d.primitives;

import away3d.core.base.Segment;
import away3d.core.base.Vertex;
import away3d.core.base.Element;


// use namespace arcane;

/**
 * Creates a 3d wire cube primitive.
 */
class WireCube extends AbstractWirePrimitive  {
	public var width(getWidth, setWidth) : Float;
	public var height(getHeight, setHeight) : Float;
	public var depth(getDepth, setDepth) : Float;
	
	private var _width:Float;
	private var _height:Float;
	private var _depth:Float;
	public var v000:Vertex;
	public var v001:Vertex;
	public var v010:Vertex;
	public var v011:Vertex;
	public var v100:Vertex;
	public var v101:Vertex;
	public var v110:Vertex;
	public var v111:Vertex;
	

	private function buildWireCube(width:Float, height:Float, depth:Float):Void {
		
		v000 = createVertex(-width / 2, -height / 2, -depth / 2);
		v001 = createVertex(-width / 2, -height / 2,  depth / 2);
		v010 = createVertex(-width / 2,  height / 2, -depth / 2);
		v011 = createVertex(-width / 2,  height / 2,  depth / 2);
		v100 = createVertex( width / 2, -height / 2, -depth / 2);
		v101 = createVertex( width / 2, -height / 2,  depth / 2);
		v110 = createVertex( width / 2,  height / 2, -depth / 2);
		v111 = createVertex( width / 2,  height / 2,  depth / 2);
		addSegment(createSegment(v000, v001));
		addSegment(createSegment(v011, v001));
		addSegment(createSegment(v011, v010));
		addSegment(createSegment(v000, v010));
		addSegment(createSegment(v100, v000));
		addSegment(createSegment(v101, v001));
		addSegment(createSegment(v111, v011));
		addSegment(createSegment(v110, v010));
		addSegment(createSegment(v100, v101));
		addSegment(createSegment(v111, v101));
		addSegment(createSegment(v111, v110));
		addSegment(createSegment(v100, v110));
	}

	/**
	 * Defines the width of the cube. Defaults to 100.
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
	 * Defines the height of the cube. Defaults to 100.
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
	 * Defines the depth of the cube. Defaults to 100.
	 */
	public function getDepth():Float {
		
		return _depth;
	}

	public function setDepth(val:Float):Float {
		
		if (_depth == val) {
			return val;
		}
		_depth = val;
		_primitiveDirty = true;
		return val;
	}

	/**
	 * Creates a new <code>WireCube</code> object.
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
		_depth = ini.getNumber("depth", 100, {min:0});
		buildWireCube(_width, _height, _depth);
		type = "WireCube";
		url = "primitive";
	}

	/**
	 * @inheritDoc
	 */
	public override function buildPrimitive():Void {
		
		super.buildPrimitive();
		buildWireCube(_width, _height, _depth);
	}

}

