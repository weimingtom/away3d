package away3d.primitives;

import away3d.core.utils.ValueObject;
import away3d.core.base.Face;
import away3d.core.utils.Init;
import away3d.core.base.UV;
import away3d.core.base.Vertex;
import away3d.core.base.Element;


// use namespace arcane;

/**
 * Creates a 3d torus primitive.
 */
class Torus extends AbstractPrimitive  {
	public var radius(getRadius, setRadius) : Float;
	public var tube(getTube, setTube) : Float;
	public var segmentsR(getSegmentsR, setSegmentsR) : Float;
	public var segmentsT(getSegmentsT, setSegmentsT) : Float;
	public var yUp(getYUp, setYUp) : Bool;
	
	private var grid:Array<Dynamic>;
	private var _radius:Float;
	private var _tube:Float;
	private var _segmentsR:Int;
	private var _segmentsT:Int;
	private var _yUp:Bool;
	

	private function buildTorus(radius:Float, tube:Float, segmentsR:Int, segmentsT:Int, yUp:Bool):Void {
		
		var i:Int;
		var j:Int;
		grid = new Array<Dynamic>();
		i = 0;
		while (i < segmentsR) {
			grid[i] = new Array<Dynamic>();
			j = 0;
			while (j < segmentsT) {
				var u:Float = i / segmentsR * 2 * Math.PI;
				var v:Float = j / segmentsT * 2 * Math.PI;
				if (yUp) {
					grid[i][j] = createVertex((radius + tube * Math.cos(v)) * Math.cos(u), tube * Math.sin(v), (radius + tube * Math.cos(v)) * Math.sin(u));
				} else {
					grid[i][j] = createVertex((radius + tube * Math.cos(v)) * Math.cos(u), -(radius + tube * Math.cos(v)) * Math.sin(u), tube * Math.sin(v));
				}
				
				// update loop variables
				j++;
			}

			
			// update loop variables
			i++;
		}

		i = 0;
		while (i < segmentsR) {
			j = 0;
			while (j < segmentsT) {
				var ip:Int = (i + 1) % segmentsR;
				var jp:Int = (j + 1) % segmentsT;
				var a:Vertex = grid[i][j];
				var b:Vertex = grid[ip][j];
				var c:Vertex = grid[i][jp];
				var d:Vertex = grid[ip][jp];
				var uva:UV = createUV(i / segmentsR, j / segmentsT);
				var uvb:UV = createUV((i + 1) / segmentsR, j / segmentsT);
				var uvc:UV = createUV(i / segmentsR, (j + 1) / segmentsT);
				var uvd:UV = createUV((i + 1) / segmentsR, (j + 1) / segmentsT);
				addFace(createFace(a, b, c, null, uva, uvb, uvc));
				addFace(createFace(d, c, b, null, uvd, uvc, uvb));
				
				// update loop variables
				j++;
			}

			
			// update loop variables
			i++;
		}

	}

	/**
	 * Defines the overall radius of the torus. Defaults to 100.
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
	 * Defines the tube radius of the torus. Defaults to 40.
	 */
	public function getTube():Float {
		
		return _tube;
	}

	public function setTube(val:Float):Float {
		
		if (_tube == val) {
			return val;
		}
		_tube = val;
		_primitiveDirty = true;
		return val;
	}

	/**
	 * Defines the number of radial segments that make up the torus. Defaults to 8.
	 */
	public function getSegmentsR():Float {
		
		return _segmentsR;
	}

	public function setSegmentsR(val:Float):Float {
		
		if (_segmentsR == val) {
			return val;
		}
		_segmentsR = Std.int(val);
		_primitiveDirty = true;
		return val;
	}

	/**
	 * Defines the number of tubular segments that make up the torus. Defaults to 6.
	 */
	public function getSegmentsT():Float {
		
		return _segmentsT;
	}

	public function setSegmentsT(val:Float):Float {
		
		if (_segmentsT == val) {
			return val;
		}
		_segmentsT = Std.int(val);
		_primitiveDirty = true;
		return val;
	}

	/**
	 * Defines whether the coordinates of the torus points use a yUp orientation (true) or a zUp orientation (false). Defaults to true.
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
	 * Creates a new <code>Torus</code> object.
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
		_tube = ini.getNumber("tube", 40, {min:0, max:radius});
		_segmentsR = ini.getInt("segmentsR", 8, {min:3});
		_segmentsT = ini.getInt("segmentsT", 6, {min:3});
		_yUp = ini.getBoolean("yUp", true);
		buildTorus(_radius, _tube, _segmentsR, _segmentsT, _yUp);
		type = "Torus";
		url = "primitive";
	}

	/**
	 * @inheritDoc
	 */
	public override function buildPrimitive():Void {
		
		super.buildPrimitive();
		buildTorus(_radius, _tube, _segmentsR, _segmentsT, _yUp);
	}

	/**
	 * Returns the vertex object specified by the grid position of the mesh.
	 * 
	 * @param	r	The radial position on the primitive mesh.
	 * @param	t	The tubular position on the primitive mesh.
	 */
	public function vertex(r:Int, t:Int):Vertex {
		
		return grid[t][r];
	}

}

