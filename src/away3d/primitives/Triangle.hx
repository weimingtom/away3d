package away3d.primitives;

import away3d.core.base.Face;
import away3d.core.base.Mesh;
import away3d.core.base.UV;
import away3d.core.base.Vertex;
import away3d.core.base.Element;


/**
 * Creates a 3d triangle.
 */
class Triangle extends Mesh  {
	public var a(getA, setA) : Vertex;
	public var b(getB, setB) : Vertex;
	public var c(getC, setC) : Vertex;
	
	private var _face:Face;
	

	private function buildTriangle(edge:Float, yUp:Bool):Void {
		
		var s3:Float = 1 / Math.sqrt(3);
		if (yUp) {
			_face = new Face(new Vertex(0, 0, 2 * s3 * edge), new Vertex(edge, 0, -s3 * edge), new Vertex(-edge, 0, -s3 * edge), null, new UV(0, 0), new UV(1, 0), new UV(0, 1));
		} else {
			_face = new Face(new Vertex(0, 2 * s3 * edge, 0), new Vertex(edge, -s3 * edge, 0), new Vertex(-edge, -s3 * edge, 0), null, new UV(0, 0), new UV(1, 0), new UV(0, 1));
		}
		addFace(_face);
		type = "Triangle";
		url = "primitive";
	}

	/**
	 * Defines the first vertex that makes up the triangle.
	 */
	public function getA():Vertex {
		
		return _face.v0;
	}

	public function setA(value:Vertex):Vertex {
		
		_face.v0 = value;
		return value;
	}

	/**
	 * Defines the second vertex that makes up the triangle.
	 */
	public function getB():Vertex {
		
		return _face.v1;
	}

	public function setB(value:Vertex):Vertex {
		
		_face.v1 = value;
		return value;
	}

	/**
	 * Defines the third vertex that makes up the triangle.
	 */
	public function getC():Vertex {
		
		return _face.v2;
	}

	public function setC(value:Vertex):Vertex {
		
		_face.v2 = value;
		return value;
	}

	/**
	 * Creates a new <code>Triangle</code> object.
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
		var edge:Float = ini.getNumber("edge", 100, {min:0}) / 2;
		var yUp:Bool = ini.getBoolean("yUp", true);
		buildTriangle(edge, yUp);
	}

}

