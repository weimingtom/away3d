package away3d.primitives;

import away3d.materials.ITriangleMaterial;
import away3d.core.base.Face;
import away3d.core.base.Mesh;
import away3d.core.base.UV;
import away3d.core.base.Vertex;


/**
 * QTVR-style 360 panorama renderer that is initialized with six images.
 * A skybox contains six sides that are arranged like the inside of a cube.
 */
class Skybox extends Mesh  {
	
	

	/**
	 * Creates a new <code>Skybox</code> object.
	 *
	 * @param	front		The material to use for the skybox front.
	 * @param	left		The material to use for the skybox left.
	 * @param	back		The material to use for the skybox back.
	 * @param	right		The material to use for the skybox right.
	 * @param	up			The material to use for the skybox up.
	 * @param	down		The material to use for the skybox down.
	 * 
	 */
	public function new(front:ITriangleMaterial, left:ITriangleMaterial, back:ITriangleMaterial, right:ITriangleMaterial, up:ITriangleMaterial, down:ITriangleMaterial) {
		
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
		
		super();
		var width:Float = 800000;
		var height:Float = 800000;
		var depth:Float = 800000;
		var v000:Vertex = new Vertex();
		var v001:Vertex = new Vertex();
		var v010:Vertex = new Vertex();
		var v011:Vertex = new Vertex();
		var v100:Vertex = new Vertex();
		var v101:Vertex = new Vertex();
		var v110:Vertex = new Vertex();
		var v111:Vertex = new Vertex();
		var uva:UV = new UV();
		var uvb:UV = new UV();
		var uvc:UV = new UV();
		var uvd:UV = new UV();
		addFace(new Face());
		addFace(new Face());
		addFace(new Face());
		addFace(new Face());
		addFace(new Face());
		addFace(new Face());
		addFace(new Face());
		addFace(new Face());
		addFace(new Face());
		addFace(new Face());
		addFace(new Face());
		addFace(new Face());
		quarterFaces();
		quarterFaces();
		mouseEnabled = false;
		type = "Skybox";
		url = "primitive";
	}

}

