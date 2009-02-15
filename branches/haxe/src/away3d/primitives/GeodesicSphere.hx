package away3d.primitives;

import away3d.core.base.Face;
import away3d.core.base.UV;
import away3d.core.base.Vertex;
import away3d.core.base.Element;


// use namespace arcane;

/**
 * Creates a 3d geodesic sphere primitive.
 */
class GeodesicSphere extends AbstractPrimitive  {
	public var radius(getRadius, setRadius) : Float;
	public var fractures(getFractures, setFractures) : Float;
	
	private var _radius:Float;
	private var _fractures:Float;
	

	private function buildGeodesicSphere(radius_in:Float, fractures_in:Int):Void {
		// Set up variables for keeping track of the vertices, faces, and texture coords.
		
		var aVertice:Array<Dynamic> = [];
		var aUV:Array<Dynamic> = [];
		// Set up variables for keeping track of the number of iterations and the angles
		var iVerts:Int = fractures_in + 1;
		var jVerts:Int;
		var j:Int;
		var Theta:Float = 0;
		var Phi:Float = 0;
		var ThetaDel:Float;
		var PhiDel:Float;
		var cosTheta:Float;
		var sinTheta:Float;
		var rcosPhi:Float;
		var rsinPhi:Float;
		// Set up variables for figuring out the texture coordinates using a diamond ~equal area map projection
		// This is done so that there is the minimal amount of distortion of textures around poles.
		// Visually, this map projection looks like this.
		/*	Phi   /\0,0
		 |    /  \
		 \/  /    \
		 /      \
		 /        \
		 / 1,0      \0,1
		 \ Theta->  /
		 \        /
		 \      /
		 \    /
		 \  /
		 \/1,1
		 */
		var Pd4:Float = Math.PI / 4;
		// Set up variables for figuring out the texture coordinates using a diamond ~equal area map projection
		// This is done so that there is the minimal amount of distortion of textures around poles.
		// Visually, this map projection looks like this.
		/*	Phi   /\0,0
		 |    /  \
		 \/  /    \
		 /      \
		 /        \
		 / 1,0      \0,1
		 \ Theta->  /
		 \        /
		 \      /
		 \    /
		 \  /
		 \/1,1
		 */
		var cosPd4:Float = Math.cos(Pd4);
		// Set up variables for figuring out the texture coordinates using a diamond ~equal area map projection
		// This is done so that there is the minimal amount of distortion of textures around poles.
		// Visually, this map projection looks like this.
		/*	Phi   /\0,0
		 |    /  \
		 \/  /    \
		 /      \
		 /        \
		 / 1,0      \0,1
		 \ Theta->  /
		 \        /
		 \      /
		 \    /
		 \  /
		 \/1,1
		 */
		var sinPd4:Float = Math.sin(Pd4);
		// Set up variables for figuring out the texture coordinates using a diamond ~equal area map projection
		// This is done so that there is the minimal amount of distortion of textures around poles.
		// Visually, this map projection looks like this.
		/*	Phi   /\0,0
		 |    /  \
		 \/  /    \
		 /      \
		 /        \
		 / 1,0      \0,1
		 \ Theta->  /
		 \        /
		 \      /
		 \    /
		 \  /
		 \/1,1
		 */
		var PIInv:Float = 1 / Math.PI;
		var R_00:Float = cosPd4;
		var R_01:Float = -sinPd4;
		var R_10:Float = sinPd4;
		var R_11:Float = cosPd4;
		var Scale:Float = Math.SQRT2;
		var uOff:Float = 0.5;
		var vOff:Float = 0.5;
		var UU:Float;
		var VV:Float;
		var u:Float;
		var v:Float;
		PhiDel = Math.PI / (2 * iVerts);
		// Build the top vertex
		aVertice.push(createVertex(0, 0, radius_in));
		aUV.push(createUV(0, 0));
		//i++;
		Phi += PhiDel;
		var i:Int;
		i = 1;
		while (i <= iVerts) {
			j = 0;
			jVerts = i * 4;
			Theta = 0;
			ThetaDel = 2 * Math.PI / jVerts;
			rcosPhi = Math.cos(Phi) * radius_in;
			rsinPhi = Math.sin(Phi) * radius_in;
			j;
			while (j < jVerts) {
				UU = Theta * PIInv / 2 - 0.5;
				VV = (Phi * PIInv - 1) * (0.5 - Math.abs(UU));
				u = (UU * R_00 + VV * R_01) * Scale + uOff;
				v = (UU * R_10 + VV * R_11) * Scale + vOff;
				cosTheta = Math.cos(Theta);
				sinTheta = Math.sin(Theta);
				aVertice.push(createVertex(cosTheta * rsinPhi, sinTheta * rsinPhi, rcosPhi));
				aUV.push(createUV(u, v));
				Theta += ThetaDel;
				
				// update loop variables
				++j;
			}

			Phi += PhiDel;
			
			// update loop variables
			++i;
		}

		// Build the bottom worth of vertices for the sphere.
		i = iVerts - 1;
		while (i > 0) {
			j = 0;
			jVerts = i * 4;
			Theta = 0;
			ThetaDel = 2 * Math.PI / jVerts;
			rcosPhi = Math.cos(Phi) * radius_in;
			rsinPhi = Math.sin(Phi) * radius_in;
			j;
			while (j < jVerts) {
				UU = Theta * PIInv / 2 - 0.5;
				VV = (Phi * PIInv - 1) * (0.5 + Math.abs(UU));
				u = (UU * R_00 + VV * R_01) * Scale + uOff;
				v = (UU * R_10 + VV * R_11) * Scale + vOff;
				cosTheta = Math.cos(Theta);
				sinTheta = Math.sin(Theta);
				aVertice.push(createVertex(cosTheta * rsinPhi, sinTheta * rsinPhi, rcosPhi));
				aUV.push(createUV(u, v));
				Theta += ThetaDel;
				
				// update loop variables
				++j;
			}

			Phi += PhiDel;
			
			// update loop variables
			i--;
		}

		// Build the last vertice
		aVertice.push(createVertex(0, 0, -radius_in));
		aUV.push(createUV(1, 1));
		var k:Int;
		var L_Ind_s:Int;
		var U_Ind_s:Int;
		var U_Ind_e:Int;
		var L_Ind_e:Int;
		var L_Ind:Int;
		var U_Ind:Int;
		var isUpTri:Bool;
		var Pt0:Int;
		var Pt1:Int;
		var Pt2:Int;
		var triInd:Int;
		var tris:Int;
		tris = 1;
		var v0:Vertex;
		var v1:Vertex;
		var v2:Vertex;
		var uv0:Vertex;
		var uv1:Vertex;
		L_Ind_s = 0;
		L_Ind_e = 0;
		i = 0;
		while (i < iVerts) {
			U_Ind_s = L_Ind_s;
			U_Ind_e = L_Ind_e;
			if (i == 0) {
				L_Ind_s++;
			}
			L_Ind_s += 4 * i;
			L_Ind_e += 4 * (i + 1);
			U_Ind = U_Ind_s;
			L_Ind = L_Ind_s;
			k = 0;
			while (k < 4) {
				isUpTri = true;
				triInd = 0;
				while (triInd < tris) {
					if (isUpTri) {
						Pt0 = U_Ind;
						Pt1 = L_Ind;
						L_Ind++;
						if (L_Ind > L_Ind_e) {
							L_Ind = L_Ind_s;
						}
						Pt2 = L_Ind;
						isUpTri = false;
					} else {
						Pt0 = L_Ind;
						Pt2 = U_Ind;
						U_Ind++;
						if (U_Ind > U_Ind_e) {
							U_Ind = U_Ind_s;
						}
						Pt1 = U_Ind;
						isUpTri = true;
					}
					addFace(createFace(aVertice[Pt1], aVertice[Pt0], aVertice[Pt2], null, aUV[Pt1], aUV[Pt0], aUV[Pt2]));
					
					// update loop variables
					triInd++;
				}

				
				// update loop variables
				++k;
			}

			tris += 2;
			
			// update loop variables
			i++;
		}

		U_Ind_s = L_Ind_s;
		U_Ind_e = L_Ind_e;
		// Build the lower four sections
		i = iVerts - 1;
		while (i >= 0) {
			L_Ind_s = U_Ind_s;
			L_Ind_e = U_Ind_e;
			U_Ind_s = L_Ind_s + 4 * (i + 1);
			U_Ind_e = L_Ind_e + 4 * i;
			if (i == 0) {
				U_Ind_e++;
			}
			tris -= 2;
			U_Ind = U_Ind_s;
			L_Ind = L_Ind_s;
			k = 0;
			while (k < 4) {
				isUpTri = true;
				triInd = 0;
				while (triInd < tris) {
					if (isUpTri) {
						Pt0 = U_Ind;
						Pt1 = L_Ind;
						L_Ind++;
						if (L_Ind > L_Ind_e) {
							L_Ind = L_Ind_s;
						}
						Pt2 = L_Ind;
						isUpTri = false;
					} else {
						Pt0 = L_Ind;
						Pt2 = U_Ind;
						U_Ind++;
						if (U_Ind > U_Ind_e) {
							U_Ind = U_Ind_s;
						}
						Pt1 = U_Ind;
						isUpTri = true;
					}
					addFace(createFace(aVertice[Pt2], aVertice[Pt0], aVertice[Pt1], null, aUV[Pt2], aUV[Pt0], aUV[Pt1]));
					
					// update loop variables
					triInd++;
				}

				
				// update loop variables
				++k;
			}

			
			// update loop variables
			i--;
		}

	}

	/**
	 * Defines the radius of the sphere. Defaults to 100.
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
	 * Defines the fractures of the sphere. Defaults to 2.
	 */
	public function getFractures():Float {
		
		return _fractures;
	}

	public function setFractures(val:Float):Float {
		
		if (_fractures == val) {
			return val;
		}
		_fractures = val;
		_primitiveDirty = true;
		return val;
	}

	/**
	 * Creates a new <code>GeodesicSphere</code> object.
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
		_radius = ini.getNumber("radius", 100, {min:100});
		_fractures = ini.getInt("fractures", 2, {min:2});
		buildGeodesicSphere(_radius, _fractures);
		type = "GeoSphere";
		url = "primitive";
	}

	/**
	 * @inheritDoc
	 */
	public override function buildPrimitive():Void {
		
		super.buildPrimitive();
		buildGeodesicSphere(_radius, _fractures);
	}

}

