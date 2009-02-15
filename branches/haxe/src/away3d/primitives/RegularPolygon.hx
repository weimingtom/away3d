package away3d.primitives;

import away3d.core.utils.ValueObject;
import away3d.core.base.Face;
import away3d.core.utils.Init;
import away3d.core.math.Number3D;
import away3d.core.base.UV;
import away3d.core.base.Vertex;
import away3d.core.base.Element;


// use namespace arcane;

/**
 * Creates a regular polygon.
 */
class RegularPolygon extends AbstractPrimitive  {
	public var radius(getRadius, setRadius) : Float;
	public var sides(getSides, setSides) : Float;
	public var subdivision(getSubdivision, setSubdivision) : Float;
	public var yUp(getYUp, setYUp) : Bool;
	
	private var _radius:Float;
	private var _sides:Float;
	private var _subdivision:Float;
	private var _yUp:Bool;
	

	private function buildRegularPolygon(radius:Float, sides:Int, subdivision:Int, yUp:Bool):Void {
		
		var tmpPoints:Array<Dynamic> = new Array<Dynamic>();
		var i:Int = 0;
		var j:Int = 0;
		var innerstep:Float = radius / subdivision;
		var radstep:Float = 360 / sides;
		var ang:Float = 0;
		var ang_inc:Float = radstep;
		var uva:UV;
		var uvb:UV;
		var uvc:UV;
		var uvd:UV;
		var facea:Vertex;
		var faceb:Vertex;
		var facec:Vertex;
		var faced:Vertex;
		i;
		while (i <= subdivision) {
			tmpPoints.push(new Number3D());
			
			// update loop variables
			i++;
		}

		var base:Number3D = new Number3D();
		var zerouv:UV = createUV(0.5, 0.5);
		i = 0;
		while (i < sides) {
			j = 0;
			while (j < tmpPoints.length - 1) {
				uva = createUV((Math.cos(-ang_inc / 180 * Math.PI) / ((subdivision * 2) / j)) + .5, (Math.sin(ang_inc / 180 * Math.PI) / ((subdivision * 2) / j)) + .5);
				uvb = createUV((Math.cos(-ang / 180 * Math.PI) / ((subdivision * 2) / (j + 1))) + .5, (Math.sin(ang / 180 * Math.PI) / ((subdivision * 2) / (j + 1))) + .5);
				uvc = createUV((Math.cos(-ang_inc / 180 * Math.PI) / ((subdivision * 2) / (j + 1))) + .5, (Math.sin(ang_inc / 180 * Math.PI) / ((subdivision * 2) / (j + 1))) + .5);
				uvd = createUV((Math.cos(-ang / 180 * Math.PI) / ((subdivision * 2) / j)) + .5, (Math.sin(ang / 180 * Math.PI) / ((subdivision * 2) / j)) + .5);
				if (j == 0) {
					if (yUp) {
						facea = createVertex(base.x, base.y, base.z);
						faceb = createVertex(Math.cos(-ang / 180 * Math.PI) * tmpPoints[1].x, base.y, Math.sin(ang / 180 * Math.PI) * tmpPoints[1].x);
						facec = createVertex(Math.cos(-ang_inc / 180 * Math.PI) * tmpPoints[1].x, base.y, Math.sin(ang_inc / 180 * Math.PI) * tmpPoints[1].x);
					} else {
						facea = createVertex(base.x, base.y, base.z);
						faceb = createVertex(Math.cos(-ang / 180 * Math.PI) * tmpPoints[1].x, Math.sin(ang / 180 * Math.PI) * tmpPoints[1].x, base.z);
						facec = createVertex(Math.cos(-ang_inc / 180 * Math.PI) * tmpPoints[1].x, Math.sin(ang_inc / 180 * Math.PI) * tmpPoints[1].x, base.z);
					}
					addFace(createFace(facea, faceb, facec, null, zerouv, uvb, uvc));
				} else {
					if (yUp) {
						facea = createVertex(Math.cos(-ang_inc / 180 * Math.PI) * tmpPoints[j].x, base.y, Math.sin(ang_inc / 180 * Math.PI) * tmpPoints[j].x);
						faceb = createVertex(Math.cos(-ang_inc / 180 * Math.PI) * tmpPoints[j + 1].x, base.y, Math.sin(ang_inc / 180 * Math.PI) * tmpPoints[j + 1].x);
						facec = createVertex(Math.cos(-ang / 180 * Math.PI) * tmpPoints[j + 1].x, base.y, Math.sin(ang / 180 * Math.PI) * tmpPoints[j + 1].x);
						faced = createVertex(Math.cos(-ang / 180 * Math.PI) * tmpPoints[j].x, base.y, Math.sin(ang / 180 * Math.PI) * tmpPoints[j].x);
					} else {
						facea = createVertex(Math.cos(-ang_inc / 180 * Math.PI) * tmpPoints[j].x, Math.sin(ang_inc / 180 * Math.PI) * tmpPoints[j].x, base.z);
						faceb = createVertex(Math.cos(-ang_inc / 180 * Math.PI) * tmpPoints[j + 1].x, Math.sin(ang_inc / 180 * Math.PI) * tmpPoints[j + 1].x, base.z);
						facec = createVertex(Math.cos(-ang / 180 * Math.PI) * tmpPoints[j + 1].x, Math.sin(ang / 180 * Math.PI) * tmpPoints[j + 1].x, base.z);
						faced = createVertex(Math.cos(-ang / 180 * Math.PI) * tmpPoints[j].x, Math.sin(ang / 180 * Math.PI) * tmpPoints[j].x, base.z);
					}
					addFace(createFace(facec, faceb, facea, null, uvb, uvc, uva));
					addFace(createFace(facec, facea, faced, null, uvb, uva, uvd));
				}
				
				// update loop variables
				j++;
			}

			ang += radstep;
			ang_inc += radstep;
			
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
	 * Defines the subdivision of the polygon. Defaults to 1.
	 */
	public function getSubdivision():Float {
		
		return _subdivision;
	}

	public function setSubdivision(val:Float):Float {
		
		if (_subdivision == val) {
			return val;
		}
		_subdivision = val;
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
	 * Creates a new <code>RegularPolygon</code> object.
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
		_radius = ini.getNumber("radius", 100, {min:0});
		_sides = ini.getInt("sides", 8, {min:3});
		_subdivision = ini.getInt("subdivision", 1, {min:1});
		_yUp = ini.getBoolean("yUp", true);
		buildRegularPolygon(_radius, _sides, _subdivision, _yUp);
		type = "RegularPolygon";
		url = "primitive";
	}

	/**
	 * @inheritDoc
	 */
	public override function buildPrimitive():Void {
		
		super.buildPrimitive();
		buildRegularPolygon(_radius, _sides, _subdivision, _yUp);
	}

}

