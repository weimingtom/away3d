package away3d.primitives;

import away3d.materials.IMaterial;
import away3d.materials.ITriangleMaterial;
import away3d.core.base.Face;
import away3d.core.base.Mesh;
import away3d.materials.IUVMaterial;
import away3d.core.base.UV;
import away3d.core.base.Vertex;


/**
 * QTVR-style 360 panorama renderer that is initialized with one solid image.
 * A skybox contains six sides that are arranged like the inside of a cube.
 */
class Skybox6 extends Mesh  {
	
	

	/**
	 * Creates a new <code>Skybox6</code> object.
	 *
	 * @param	material		The material to use for generating all six skybox sides.
	 * 
	 */
	public function new(material:ITriangleMaterial) {
		
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
		
		super({material:material});
		var udelta:Float = 1 / 600;
		var vdelta:Float = 1 / 400;
		if (Std.is(material, IUVMaterial)) {
			var uvm:IUVMaterial = cast(material, IUVMaterial);
			udelta = 1 / uvm.width;
			vdelta = 1 / uvm.height;
		}
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
		var uvrighta:UV = new UV();
		var uvrightb:UV = new UV();
		var uvrightc:UV = new UV();
		var uvrightd:UV = new UV();
		var uvfronta:UV = new UV();
		var uvfrontb:UV = new UV();
		var uvfrontc:UV = new UV();
		var uvfrontd:UV = new UV();
		var uvlefta:UV = new UV();
		var uvleftb:UV = new UV();
		var uvleftc:UV = new UV();
		var uvleftd:UV = new UV();
		var uvbacka:UV = new UV();
		var uvbackb:UV = new UV();
		var uvbackc:UV = new UV();
		var uvbackd:UV = new UV();
		var uvupa:UV = new UV();
		var uvupb:UV = new UV();
		var uvupc:UV = new UV();
		var uvupd:UV = new UV();
		var uvdowna:UV = new UV();
		var uvdownb:UV = new UV();
		var uvdownc:UV = new UV();
		var uvdownd:UV = new UV();
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
		type = "Skybox6";
		url = "primitive";
	}

}

