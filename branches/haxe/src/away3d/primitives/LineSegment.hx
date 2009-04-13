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
		
		recalc(value, _segment.v1);
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
		
		recalc(_segment.v0, value);
		return value;
	}

	/**
	 * Recalculate start and end Vertex positions 
	 */
	private function recalc(vp1:Vertex, vp2:Vertex):Void {
		
		if (lsegments > 1) {
			var _index:Int = segments.length;
			while ((_index-- > 0)) {
				removeSegment(segments[_index]);
			}

			var difx:Float;
			var dify:Float;
			var difz:Float;
			difx = (vp1.x - vp2.x) / lsegments;
			dify = (vp1.y - vp2.y) / lsegments;
			difz = (vp1.z - vp2.z) / lsegments;
			i = 1;
			while (i <= lsegments) {
				newsegmentstart = new Vertex(vp1.x - (difx * (i)), vp1.y - (dify * (i)), vp1.z - (difz * (i)));
				newsegmentend = new Vertex(vp2.x + (difx * (lsegments - (i - 1))), vp2.y + (dify * (lsegments - (i - 1))), vp2.z + (difz * (lsegments - (i - 1))));
				_segment = new Segment(newsegmentstart, newsegmentend);
				addSegment(_segment);
				
				// update loop variables
				i++;
			}

		} else {
			_segment.v0 = vp1;
			_segment.v1 = vp2;
		}
	}

	/**
	 * Creates a new <code>LineSegment</code> object.
	 *
	 * @param	init			[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(?init:Dynamic=null) {
		
		
		super(init);
		var edge:Float = ini.getNumber("edge", 100, {min:0}) / 2;
		lsegments = ini.getNumber("segments", 1, {min:1});
		var p1:Number3D = ini.getPosition("start");
		if (p1 == null)  {
			p1 = new Number3D(-edge, 0, 0);
		};
		var p2:Number3D = ini.getPosition("end");
		if (p2 == null)  {
			p2 = new Number3D(edge, 0, 0);
		};
		var vp1:Vertex = new Vertex(p1.x, p1.y, p1.z);
		var vp2:Vertex = new Vertex(p2.x, p2.y, p2.z);
		if (lsegments > 1) {
			recalc(vp1, vp2);
		} else {
			_segment = new Segment(vp1, vp2);
			addSegment(_segment);
		}
		type = "LineSegment";
		url = "primitive";
	}

}

