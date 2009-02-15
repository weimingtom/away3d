package away3d.primitives;

import away3d.core.math.Number3D;
import away3d.materials.IMaterial;
import away3d.core.base.Segment;
import away3d.materials.ISegmentMaterial;
import away3d.materials.WireframeMaterial;
import away3d.core.base.Mesh;
import away3d.core.base.Vertex;
import away3d.core.base.Element;


/**
 * Creates a 3d line segment.
 */
class LineSegment extends Mesh  {
	public var start(getStart, setStart) : Vertex;
	public var end(getEnd, setEnd) : Vertex;
	
	private var _segment:Segment;
	private var i:Int;
	private var lsegments:Float;
	public var p1:Number3D;
	public var p2:Number3D;
	private var newsegmentstart:Vertex;
	private var newsegmentend:Vertex;
	

	private override function getDefaultMaterial():IMaterial {
		
		return (ini.getSegmentMaterial("material") != null) ? ini.getSegmentMaterial("material") : new WireframeMaterial();
	}

	/**
	 * Defines the starting vertex.
	 */
	public function getStart():Vertex {
		
		return _segment.v0;
		//TBD: get vertex for segments>1
		
	}

	public function setStart(value:Vertex):Vertex {
		
		recalc(value, p2);
		return value;
	}

	/**
	 * Defines the ending vertex.
	 */
	public function getEnd():Vertex {
		
		return _segment.v1;
		//TBD: get vertex for segments>1
		
	}

	public function setEnd(value:Vertex):Vertex {
		
		recalc(p1, value);
		return value;
	}

	/**
	 * Recalculate start and end Vertex positions 
	 */
	private function recalc(vp1:Dynamic, vp2:Dynamic):Void {
		
		p1 = new Number3D();
		p2 = new Number3D();
		if (lsegments > 1) {
			var _index:Int = segments.length;
			while ((_index-- > 0)) {
				removeSegment(segments[_index]);
			}

			var difx:Float;
			var dify:Float;
			var difz:Float;
			difx = (p1.x - p2.x) / lsegments;
			dify = (p1.y - p2.y) / lsegments;
			difz = (p1.z - p2.z) / lsegments;
			i = 1;
			while (i <= lsegments) {
				newsegmentstart = new Vertex();
				newsegmentend = new Vertex();
				_segment = new Segment();
				addSegment(_segment);
				
				// update loop variables
				i++;
			}

		} else {
			_segment.v0 = new Vertex();
			_segment.v1 = new Vertex();
		}
	}

	/**
	 * Creates a new <code>LineSegment</code> object.
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
		lsegments = ini.getNumber("segments", 1, {min:1});
		p1 = ini.getPosition("start");
		if (p1 == null)  {
			p1 = new Number3D();
		};
		p2 = ini.getPosition("end");
		if (p2 == null)  {
			p2 = new Number3D();
		};
		if (lsegments > 1) {
			recalc(p1, p2);
		} else {
			_segment = new Segment();
			addSegment(_segment);
		}
		type = "LineSegment";
		url = "primitive";
	}

}

