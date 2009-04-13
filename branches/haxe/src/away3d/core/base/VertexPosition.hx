package away3d.core.base;

import away3d.core.math.Number3D;
import away3d.core.math.Matrix3D;


/**
 * Vertex position value object.
 */
class VertexPosition  {
	
	/**
	 * Defines the x coordinate.
	 */
	public var x:Float;
	/**
	 * Defines the y coordinate.
	 */
	public var y:Float;
	/**
	 * Defines the z coordinate.
	 */
	public var z:Float;
	public var vertex:Vertex;
	

	/**
	 * Creates a new <code>VertexPosition</code> object.
	 *
	 * @param	vertex	The vertex object used to define the default x, y and z values.
	 */
	public function new(vertex:Vertex) {
		
		
		this.vertex = vertex;
		this.x = 0;
		this.y = 0;
		this.z = 0;
	}

	/**
	 * Adjusts the position of the vertex object incrementally.
	 *
	 * @param	k	The fraction by which to adjust the vertex values.
	 */
	public function adjust(?k:Float=1):Void {
		
		vertex.adjust(x, y, z, k);
	}

	/**
	 * Adjusts the position of the vertex object by Number3D.
	 *
	 * @param	value	Amount to add in Number3D format.
	 */
	public function add(value:Number3D):Void {
		
		vertex.add(value);
	}

	/**
	 * Transforms the position of the vertex object by the given 3d matrix.
	 *
	 * @param	m	The 3d matrix to use.
	 */
	public function transform(m:Matrix3D):Void {
		
		vertex.transform(m);
	}

	/**
	 * Reset the position of the vertex object by Number3D.
	 */
	public function reset():Void {
		
		vertex.reset();
	}

	//temp patch, to retreive the missing async indexes for md2 files and as3 animated outputs.
	//returns position into vertices array
	public function getIndex(vertices:Array<Vertex>):Int {
		
		var ox:Float = vertex.x;
		var oy:Float = vertex.y;
		var oz:Float = vertex.z;
		vertex.x = Math.NaN;
		vertex.y = Math.NaN;
		vertex.z = Math.NaN;
		var id:Int = 0;
		var i:Int = 0;
		while (i < vertices.length) {
			if (Math.isNaN(vertices[i].x) && Math.isNaN(vertices[i].y) && Math.isNaN(vertices[i].z)) {
				id = i;
				break;
			}
			
			// update loop variables
			++i;
		}

		vertex.x = ox;
		vertex.y = oy;
		vertex.z = oz;
		return id;
	}

}

