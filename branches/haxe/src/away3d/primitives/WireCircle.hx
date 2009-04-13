package away3d.primitives;

import away3d.core.utils.ValueObject;
import away3d.core.base.Segment;
import away3d.core.utils.Init;
import away3d.core.base.Vertex;
import away3d.core.base.Element;


// use namespace arcane;

/**
 * Creates a 3d wire polygon.
 */
class WireCircle extends AbstractWirePrimitive  {
	public var radius(getRadius, setRadius) : Float;
	public var sides(getSides, setSides) : Float;
	public var yUp(getYUp, setYUp) : Bool;
	
	private var _radius:Float;
	private var _sides:Float;
	private var _yUp:Bool;
	

	private function buildCircle(radius:Float, sides:Int, yUp:Bool):Void {
		
		var vertices:Array<Vertex> = [];
		var i:Int;
		i = 0;
		while (i < sides) {
			var u:Float = i / sides * 2 * Math.PI;
			if (yUp) {
				vertices.push(createVertex(radius * Math.cos(u), 0, -radius * Math.sin(u)));
			} else {
				vertices.push(createVertex(radius * Math.cos(u), radius * Math.sin(u), 0));
			}
			
			// update loop variables
			i++;
		}

		i = 0;
		while (i < sides) {
			addSegment(createSegment(vertices[i], vertices[(i + 1) % sides]));
			
			// update loop variables
			i++;
		}

	}

	/**
	 * Defines the radius of the polygon. Defaults to 100.
	 */
	public function getRadius():Float {
		
		return _radius;
	}

	public function setRadius(val:Float):Float {
		
		if (_radius == val) {
			return val;
		}
		_radius = val;
		_primitiveDirty = true;
		return val;
	}

	/**
	 * Defines the number of sides of the polygon. Defaults to 8 (octohedron).
	 */
	public function getSides():Float {
		
		return _sides;
	}

	public function setSides(val:Float):Float {
		
		if (_sides == val) {
			return val;
		}
		_sides = val;
		_primitiveDirty = true;
		return val;
	}

	/**
	 * Defines whether the coordinates of the polygon points use a yUp orientation (true) or a zUp orientation (false). Defaults to true.
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
	 * Creates a new <code>WireCircle</code> object.
	 *
	 * @param	init			[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(?init:Dynamic=null) {
		
		
		super(init);
		_radius = ini.getNumber("radius", 100, {min:0});
		_sides = ini.getInt("sides", 8, {min:3});
		_yUp = ini.getBoolean("yUp", true);
		buildCircle(_radius, _sides, _yUp);
		type = "WireCircle";
		url = "primitive";
	}

	/**
	 * @inheritDoc
	 */
	public override function buildPrimitive():Void {
		
		super.buildPrimitive();
		buildCircle(_radius, _sides, _yUp);
	}

}

