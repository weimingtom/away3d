package away3d.primitives;

import away3d.primitives.data.PatchData;
import away3d.core.utils.ValueObject;
import away3d.materials.IMaterial;
import flash.events.EventDispatcher;
import away3d.core.base.Segment;
import away3d.materials.ITriangleMaterial;
import away3d.haxeutils.HashMap;
import away3d.core.base.Face;
import away3d.core.base.Mesh;
import away3d.core.utils.Init;
import away3d.materials.WireColorMaterial;
import away3d.core.base.UV;
import away3d.core.base.Vertex;
import away3d.core.base.Geometry;


// use namespace arcane;

/**
 * BezierPatch primitive creates a smooth mesh based on a 4x4 vertex patch using a cubic bezier curve.
 */
class BezierPatch extends Mesh  {
	
	public var patchData:PatchData;
	public var xOffset:Float;
	public var yOffset:Float;
	public var zOffset:Float;
	public var renderMode:Float;
	public var connectMirrors:Float;
	private var _pI:Array<Dynamic>;
	private var _patchVertices:HashMap<Vertex, Array<Dynamic>>;
	private var _edgeCache:Array<Dynamic>;
	private var _gen:Array<Dynamic>;
	private var _patchName:String;
	private var _patchCount:Int;
	private var _normDir:Bool;
	private var _material:ITriangleMaterial;
	private var _w1:WireColorMaterial;
	private var _w2:WireColorMaterial;
	private static inline var resol:Int = 1000;
	public static inline var PATCH:Int = 0;
	public static inline var WIRE_ONLY:Int = 1;
	public static inline var BASEWIRE_ONLY:Int = 2;
	public static inline var MIRRORWIRE_ONLY:Int = 3;
	public static inline var NOTSET:Int = 0;
	public static inline var N:Int = 1;
	public static inline var X:Int = 2;
	public static inline var XZ:Int = 4;
	public static inline var Z:Int = 8;
	public static inline var Y:Int = 16;
	public static inline var XY:Int = 32;
	public static inline var XYZ:Int = 64;
	public static inline var YZ:Int = 128;
	public static inline var L:Int = 256;
	public static inline var R:Int = 512;
	public static inline var T:Int = 1024;
	public static inline var B:Int = 2048;
	public static inline var LX:Int = X | L;
	public static inline var LY:Int = Y | L;
	public static inline var LZ:Int = Z | L;
	public static inline var RX:Int = X | R;
	public static inline var RY:Int = Y | R;
	public static inline var RZ:Int = Z | R;
	public static inline var TX:Int = X | T;
	public static inline var TY:Int = Y | T;
	public static inline var TZ:Int = Z | T;
	public static inline var BX:Int = X | B;
	public static inline var BY:Int = Y | B;
	public static inline var BZ:Int = Z | B;
	public static inline var TOP:Array<Dynamic> = [N, XZ, Z, X];
	public static inline var BOTTOM:Array<Dynamic> = [Y, XYZ, XY, YZ];
	public static inline var FRONT:Array<Dynamic> = [N, XY, X, Y];
	public static inline var BACK:Array<Dynamic> = [Z, XYZ, YZ, XZ];
	public static inline var LEFT:Array<Dynamic> = [N, YZ, Y, Z];
	public static inline var RIGHT:Array<Dynamic> = [X, XYZ, XZ, XY];
	public static inline var TOPLEFT:Int = 1;
	public static inline var TOPRIGHT:Int = 2;
	public static inline var BOTTOMLEFT:Int = 3;
	public static inline var BOTTOMRIGHT:Int = 4;
	private static inline var OPPOSITE_OR:Array<Dynamic> = new Array();
	private static inline var SCALINGS:Array<Dynamic> = new Array();
	private var uva:UV;
	private var uvb:UV;
	private var uvc:UV;
	private var uvd:UV;
	private var u1Pos:Float;
	private var v1Pos:Float;
	private var u2Pos:Float;
	private var v2Pos:Float;
	private var u1:Float;
	private var v1:Float;
	private var u2:Float;
	private var v2:Float;
	private var vx0:Vertex;
	private var vx1:Vertex;
	private var vx2:Vertex;
	private var vx3:Vertex;
	private var ovx0:Vertex;
	private var ovx1:Vertex;
	private var ovx2:Vertex;
	private var ovx3:Vertex;
	

	/**
	 * Creates a new <code>BezierPatch</code> object.
	 * 
	 * @param	patchDataPrm   Patch definition for this object.
	 * @param	init           [optional]  An initialisation object for specifying default instance properties.
	 */
	public function new(patchDataPrm:PatchData, ?init:Dynamic=null) {
		this._patchVertices = new HashMap<Vertex, Array<Dynamic>>();
		this._gen = new Array();
		this.vx0 = new Vertex();
		this.vx1 = new Vertex();
		this.vx2 = new Vertex();
		this.vx3 = new Vertex();
		
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
		_material = cast(material, ITriangleMaterial);
		patchData = patchDataPrm;
		_pI = patchData.patchInfo;
		xOffset = ini.getNumber("xoffset", 0);
		yOffset = ini.getNumber("yoffset", 0);
		zOffset = ini.getNumber("zoffset", 0);
		renderMode = ini.getInt("renderMode", 0, {min:0, max:3});
		type = "primitive";
		type = "BezierPatch";
		buildPatch();
	}

	/**
	 * Generate the patch mesh based on the patch data and render modes.
	 */
	public function buildPatch():Void {
		
		var start:Int = flash.Lib.getTimer();
		_patchVertices = new HashMap<Vertex, Array<Dynamic>>();
		_edgeCache = new Array();
		geometry = new Geometry();
		// Iterate through all the items in the patch array
		var key:String;
		for (key in patchData.patchInfo) {
			if (renderMode == WIRE_ONLY || renderMode == BASEWIRE_ONLY || renderMode == MIRRORWIRE_ONLY) {
				buildWirePatch(key);
			}
			if (renderMode == PATCH) {
				buildTrianglePatch(key);
			}
			
		}

		//trace("Generated '" + name + "' in : " + (getTimer() - start) + "ms");
		
	}

	// Render the wireframe of the patch
	private function buildWirePatch(key:String):Void {
		
		var or:Int = Reflect.field(patchData.patchInfo, key).oOr;
		if (renderMode == BASEWIRE_ONLY) {
			or = N;
		}
		if (renderMode == MIRRORWIRE_ONLY) {
			or = or & ~N;
		}
		for (__i in 0...[1, 2, 4, 8, 16, 32, 64, 128].length) {
			var orientation:Int = [1, 2, 4, 8, 16, 32, 64, 128][__i];

			if (orientation != null) {
				if ((or & orientation) > 0) {
					var xOr:Bool = ((orientation & X) | (orientation & XY) | (orientation & XZ) | (orientation & XYZ)) > 0;
					var yOr:Bool = ((orientation & Y) | (orientation & XY) | (orientation & YZ) | (orientation & XYZ)) > 0;
					var zOr:Bool = ((orientation & Z) | (orientation & YZ) | (orientation & XZ) | (orientation & XYZ)) > 0;
					var xS:Float = (xOr ? -1 : 1);
					var yS:Float = (yOr ? -1 : 1);
					var zS:Float = (zOr ? -1 : 1);
					// Iterate through each key in the object
					var i:Int = 0;
					while (i < Reflect.field(patchData.nodes, key).length) {
						var vA:Array<Dynamic> = Reflect.field(patchData.nodes, key);
						var v0:Vertex = new Vertex((patchData.vertices[vA[i]].x + xOffset) * xS, (patchData.vertices[vA[i]].y + yOffset) * yS, (patchData.vertices[vA[i]].z + zOffset) * zS);
						var v1:Vertex = new Vertex((patchData.vertices[vA[i + 1]].x + xOffset) * xS, (patchData.vertices[vA[i + 1]].y + yOffset) * yS, (patchData.vertices[vA[i + 1]].z + zOffset) * zS);
						var v2:Vertex = new Vertex((patchData.vertices[vA[i + 2]].x + xOffset) * xS, (patchData.vertices[vA[i + 2]].y + yOffset) * yS, (patchData.vertices[vA[i + 2]].z + zOffset) * zS);
						var v3:Vertex = new Vertex((patchData.vertices[vA[i + 3]].x + xOffset) * xS, (patchData.vertices[vA[i + 3]].y + yOffset) * yS, (patchData.vertices[vA[i + 3]].z + zOffset) * zS);
						addSegment(new Segment(v0, v1));
						addSegment(new Segment(v1, v2));
						addSegment(new Segment(v2, v3));
						if (i + 4 < Reflect.field(patchData.nodes, key).length) {
							var v4:Vertex = new Vertex((patchData.vertices[vA[i + 4]].x + xOffset) * xS, (patchData.vertices[vA[i + 4]].y + yOffset) * yS, (patchData.vertices[vA[i + 4]].z + zOffset) * zS);
							var v5:Vertex = new Vertex((patchData.vertices[vA[i + 5]].x + xOffset) * xS, (patchData.vertices[vA[i + 5]].y + yOffset) * yS, (patchData.vertices[vA[i + 5]].z + zOffset) * zS);
							var v6:Vertex = new Vertex((patchData.vertices[vA[i + 6]].x + xOffset) * xS, (patchData.vertices[vA[i + 6]].y + yOffset) * yS, (patchData.vertices[vA[i + 6]].z + zOffset) * zS);
							var v7:Vertex = new Vertex((patchData.vertices[vA[i + 7]].x + xOffset) * xS, (patchData.vertices[vA[i + 7]].y + yOffset) * yS, (patchData.vertices[vA[i + 7]].z + zOffset) * zS);
							addSegment(new Segment(v0, v4));
							addSegment(new Segment(v1, v5));
							addSegment(new Segment(v2, v6));
							addSegment(new Segment(v3, v7));
						}
						
						// update loop variables
						i += 4;
					}

				}
			}
		}

	}

	// Render the full uv mapped patch
	private function buildTrianglePatch(key:String):Void {
		// Establish if UVs are present
		
		var pUV:Array<Dynamic>;
		if ((patchData.uvs != null) && (Reflect.field(patchData.uvs, key) != null)) {
			pUV = Reflect.field(patchData.uvs, key);
		} else {
			u1 = v1 = u2 = v2 = 1;
		}
		// Iterate through each 4x4 sub-patch of the patch
		var p:Int = 0;
		while (p < Reflect.field(_pI, key).patchCount) {
			var x:Float;
			var y:Float;
			var tv0:Vertex = new Vertex();
			var tv1:Vertex = new Vertex();
			var tv2:Vertex = new Vertex();
			var thisOr:Int;
			var orientation:Int;
			var f:Face;
			definePatchData(key, p);
			// Split the patch into segments vertically
			y = 0;
			while (y <= Reflect.field(_pI, key).oSegH) {
				x = 0;
				while (x <= Reflect.field(_pI, key).oSegW) {
					for (__i in 0...[1, 2, 4, 8, 16, 32, 64, 128].length) {
						orientation = [1, 2, 4, 8, 16, 32, 64, 128][__i];

						if (orientation != null) {
							thisOr = Reflect.field(_pI, key).oOr & orientation;
							// If we have the correct orientation proceed
							if (thisOr > 0) {
								var hasUVs:Bool = false;
								var xOr:Bool = ((orientation & X) | (orientation & XY) | (orientation & XZ) | (orientation & XYZ)) > 0;
								var yOr:Bool = ((orientation & Y) | (orientation & XY) | (orientation & YZ) | (orientation & XYZ)) > 0;
								var zOr:Bool = ((orientation & Z) | (orientation & YZ) | (orientation & XZ) | (orientation & XYZ)) > 0;
								// Decide on the direction of the normals for the faces
								_normDir = ((((xOr ? 1 : 0) + (yOr ? 1 : 0) + (zOr ? 1 : 0)) % 2) > 0);
								// Only add faces to the patch when not top or left edge (y=0 & x=0)
								if (x > 0 && y > 0) {
									u1 = v1 = u2 = v2 = 1;
									if ((patchData.uvs != null) && (Reflect.field(patchData.uvs, key) != null)) {
										if ((Reflect.field(patchData.uvs, key)[thisOr] != null)) {
											u1 = pUV[thisOr][p][0];
											v1 = pUV[thisOr][p][1];
											u2 = pUV[thisOr][p][2];
											v2 = pUV[thisOr][p][3];
										} else if ((Reflect.field(patchData.uvs, key)[p] != null)) {
											u1 = pUV[p][0];
											v1 = pUV[p][1];
											u2 = pUV[p][2];
											v2 = pUV[p][3];
										}
										if (_normDir) {
											u2Pos = ((u1 - u2) * (x / Reflect.field(_pI, key).oSegW)) + u2;
											v2Pos = ((v2 - v1) * (y / Reflect.field(_pI, key).oSegH)) + v1;
											u1Pos = u2Pos - ((u1 - u2) * Reflect.field(_pI, key).xStp);
											v1Pos = v2Pos - ((v2 - v1) * Reflect.field(_pI, key).yStp);
											// Set up the UVs
											uva = new UV(u2Pos, 1 - v1Pos);
											uvb = new UV(u2Pos, 1 - v2Pos);
											uvc = new UV(u1Pos, 1 - v2Pos);
											uvd = new UV(u1Pos, 1 - v1Pos);
										} else {
											u2Pos = ((u2 - u1) * (x / Reflect.field(_pI, key).oSegW)) + u1;
											v2Pos = ((v2 - v1) * (y / Reflect.field(_pI, key).oSegH)) + v1;
											u1Pos = u2Pos - ((u2 - u1) * Reflect.field(_pI, key).xStp);
											v1Pos = v2Pos - ((v2 - v1) * Reflect.field(_pI, key).yStp);
											// Set up the UVs
											uva = new UV(u2Pos, 1 - v2Pos);
											uvb = new UV(u2Pos, 1 - v1Pos);
											uvc = new UV(u1Pos, 1 - v1Pos);
											uvd = new UV(u1Pos, 1 - v2Pos);
										}
									}
									// Get the stored vertices and switch face normal as necessary
									vx0 = _gen[p][y - 1][x][orientation];
									vx1 = _gen[p][y][x - 1][orientation];
									vx2 = _gen[p][y - 1][x - 1][orientation];
									vx3 = _gen[p][y][x][orientation];
									_patchVertices.put(vx0, [key, p, y - 1, x, orientation]);
									_patchVertices.put(vx1, [key, p, y, x - 1, orientation]);
									_patchVertices.put(vx2, [key, p, y - 1, x - 1, orientation]);
									_patchVertices.put(vx3, [key, p, y, x, orientation]);
									// Add faces based on normal and if the vertices do not shared
									if (_normDir) {
										if (vx0 != vx1 && vx0 != vx3 && vx1 != vx3) {
											addFace(new Face(vx0, vx3, vx1, _material, uva, uvb, uvc));
										}
										if (vx0 != vx1 && vx0 != vx2 && vx1 != vx2) {
											addFace(new Face(vx0, vx1, vx2, _material, uva, uvc, uvd));
										}
									} else {
										if (vx0 != vx1 && vx0 != vx3 && vx1 != vx3) {
											addFace(new Face(vx0, vx1, vx3, _material, uvb, uvd, uva));
										}
										if (vx0 != vx1 && vx0 != vx2 && vx1 != vx2) {
											addFace(new Face(vx0, vx2, vx1, _material, uvb, uvc, uvd));
										}
									}
								}
								// Connect along the edges in the defined direction
								if (Reflect.field(_pI, key).oCL > 0) {
									connectEdge(pUV, X, key, p, x, y, 0, _normDir, orientation, Reflect.field(_pI, key).oCL, L);
								}
								if (Reflect.field(_pI, key).oCR > 0) {
									connectEdge(pUV, X, key, p, x, y, Reflect.field(_pI, key).oSegW, !_normDir, orientation, Reflect.field(_pI, key).oCR, R);
								}
								if (Reflect.field(_pI, key).oCT > 0) {
									connectEdge(pUV, Y, key, p, x, y, 0, !_normDir, orientation, Reflect.field(_pI, key).oCT, T);
								}
								if (Reflect.field(_pI, key).oCB > 0) {
									connectEdge(pUV, Y, key, p, x, y, Reflect.field(_pI, key).oSegH, _normDir, orientation, Reflect.field(_pI, key).oCB, B);
								}
							}
						}
					}

					
					// update loop variables
					x++;
				}

				
				// update loop variables
				y++;
			}

			// Fill in the holes between mirrored patches (e.g. vert0 on patches N, X, XZ, Z)
			fillPatchMirrorHoles(pUV, Reflect.field(_pI, key).fillPoints, key, p, Reflect.field(_pI, key).oSegW, Reflect.field(_pI, key).oSegH);
			
			// update loop variables
			p++;
		}

	}

	private function definePatchData(key:String, p:Int):Void {
		
		var v:Vertex = new Vertex();
		var xCtr:Int = 0;
		var yCtr:Int = 0;
		var thisOr:Int = 0;
		_gen[p] = new Array();
		// Generate mesh for base patch and apply to the other orientations and store
		var yPos:Float = 0;
		while (yPos <= 1 + (Reflect.field(_pI, key).yStp / 2)) {
			_gen[p][yCtr] = new Array();
			xCtr = 0;
			var xPos:Float = 0;
			while (xPos <= 1 + (Reflect.field(_pI, key).xStp / 2)) {
				_gen[p][yCtr][xCtr] = new Array();
				for (__i in 0...[1, 2, 4, 8, 16, 32, 64, 128].length) {
					var orientation:Int = [1, 2, 4, 8, 16, 32, 64, 128][__i];

					if (orientation != null) {
						thisOr = Reflect.field(_pI, key).oOr & orientation;
						if (thisOr > 0) {
							_gen[p][yCtr][xCtr][orientation] = vScaleXYZ(Reflect.field(patchData.generatedPatch, key)[p][yCtr][xCtr], xPos, yPos, SCALINGS[orientation][0], SCALINGS[orientation][1], SCALINGS[orientation][2]);
							// Cache the edges for re-use later
							if (xPos == 0 || yPos == 0 || (Math.round(xPos * resol) / resol) == 1 || (Math.round(yPos * resol) / resol) >= 1) {
								_edgeCache.push(_gen[p][yCtr][xCtr][orientation]);
							}
						}
					}
				}

				xCtr++;
				
				// update loop variables
				xPos += Reflect.field(_pI, key).xStp;
			}

			yCtr++;
			
			// update loop variables
			yPos += Reflect.field(_pI, key).yStp;
		}

	}

	/**
	 * Refresh the patch with updated patch data information - this is far quicker than re-building the patch
	 */
	public function refreshPatch():Void {
		
		var start:Int = flash.Lib.getTimer();
		var xCtr:Int;
		var yCtr:Int;
		var v:Vertex;
		var vData:Array<Dynamic>;
		var tempVertices:Array<Dynamic>;
		var pId:Int;
		var yId:Int;
		var xId:Int;
		var orId:Int;
		patchData.build(true);
		// Iterate through all the items in the patch array
		var key:String;
		for (key in _pI) {
			var p:Int = 0;
			while (p < Reflect.field(_pI, key).patchCount) {
				for (__i in 0...vertices.length) {
					v = vertices[__i];

					if (v != null) {
						pId = _patchVertices.get(v)[1];
						yId = _patchVertices.get(v)[2];
						xId = _patchVertices.get(v)[3];
						orId = _patchVertices.get(v)[4];
						v.x = Reflect.field(patchData.generatedPatch, key)[pId][yId][xId].x;
						v.y = Reflect.field(patchData.generatedPatch, key)[pId][yId][xId].y;
						v.z = Reflect.field(patchData.generatedPatch, key)[pId][yId][xId].z;
						vRescaleXYZ(v, SCALINGS[orId][0], SCALINGS[orId][1], SCALINGS[orId][2]);
					}
				}

				
				// update loop variables
				p++;
			}

			
		}

		//trace("Refreshed '" + name + "' in : " + (getTimer() - start) + "ms");
		_objectDirty = true;
		updateObject();
	}

	// Add connecting faces to the required edge and mirror faces
	private function connectEdge(pUV:Array<Dynamic>, edge:Int, key:String, p:Int, x:Int, y:Int, pos:Int, nDir:Bool, orient:Int, cOr:Int, cPos:Int):Void {
		// Connect along x==0 for the left connection or x=o.segmentsW for right
		
		var thisOr:Int = cOr | cPos;
		var oppOr:Int = OPPOSITE_OR[orient | cOr];
		if (edge == X && x == pos && y > 0 && oppOr > 0) {
			if ((pUV != null) && (pUV[thisOr] != null)) {
				u1 = pUV[thisOr][p][0];
				v1 = pUV[thisOr][p][1];
				u2 = pUV[thisOr][p][2];
				v2 = pUV[thisOr][p][3];
			}
			if (nDir) {
				vx0 = _gen[p][y - 1][x][orient];
				vx1 = _gen[p][y][x][oppOr];
				vx2 = _gen[p][y - 1][x][oppOr];
				vx3 = _gen[p][y][x][orient];
				// Get the correct UV coordinates
				u1Pos = ((u2 - u1) * (y / Reflect.field(_pI, key).oSegH)) + u1;
				u2Pos = u1Pos - ((u2 - u1) * Reflect.field(_pI, key).yStp);
			} else {
				vx0 = _gen[p][y][x][orient];
				vx1 = _gen[p][y - 1][x][oppOr];
				vx2 = _gen[p][y][x][oppOr];
				vx3 = _gen[p][y - 1][x][orient];
				// Get the correct UV coordinates
				u2Pos = ((u2 - u1) * (y / Reflect.field(_pI, key).oSegH)) + u1;
				u1Pos = u2Pos - ((u2 - u1) * Reflect.field(_pI, key).yStp);
			}
			// Set up the UVs
			uva = new UV(u2Pos, 1 - v1);
			uvb = new UV(u2Pos, 1 - v2);
			uvc = new UV(u1Pos, 1 - v2);
			uvd = new UV(u1Pos, 1 - v1);
			addFace(new Face(vx0, vx3, vx1, _material, uva, uvd, uvc));
			addFace(new Face(vx0, vx1, vx2, _material, uva, uvc, uvb));
		}
		// Connect along y==0 for the top connection or y=o.segmentsH for bottom
		if (edge == Y && x > 0 && y == pos && oppOr > 0) {
			if ((pUV != null) && (pUV[thisOr] != null)) {
				u1 = pUV[thisOr][p][0];
				v1 = pUV[thisOr][p][1];
				u2 = pUV[thisOr][p][2];
				v2 = pUV[thisOr][p][3];
			}
			if (nDir) {
				vx0 = _gen[p][y][x - 1][orient];
				vx1 = _gen[p][y][x][oppOr];
				vx2 = _gen[p][y][x - 1][oppOr];
				vx3 = _gen[p][y][x][orient];
				u1Pos = ((u2 - u1) * (x / Reflect.field(_pI, key).oSegW)) + u1;
				u2Pos = u1Pos - ((u2 - u1) * Reflect.field(_pI, key).xStp);
			} else {
				vx0 = _gen[p][y][x][orient];
				vx1 = _gen[p][y][x - 1][oppOr];
				vx2 = _gen[p][y][x][oppOr];
				vx3 = _gen[p][y][x - 1][orient];
				u2Pos = ((u2 - u1) * (x / Reflect.field(_pI, key).oSegW)) + u1;
				u1Pos = u2Pos - ((u2 - u1) * Reflect.field(_pI, key).xStp);
			}
			// Set up the UVs
			uva = new UV(u2Pos, 1 - v2);
			uvb = new UV(u2Pos, 1 - v1);
			uvc = new UV(u1Pos, 1 - v1);
			uvd = new UV(u1Pos, 1 - v2);
			addFace(new Face(vx0, vx3, vx1, _material, uva, uvd, uvc));
			addFace(new Face(vx0, vx1, vx2, _material, uva, uvc, uvb));
		}
	}

	private function fillPatchMirrorHoles(pUV:Array<Dynamic>, fillPoints:Array<Dynamic>, key:String, p:Int, segW:Int, segH:Int):Void {
		
		for (__i in 0...fillPoints.length) {
			var vData:Array<Dynamic> = fillPoints[__i];

			if (vData != null) {
				var vId:Int = vData[0];
				var vOr:Array<Dynamic> = vData[1];
				var x:Int;
				var y:Int;
				switch (vId) {
					case TOPLEFT :
						x = 0;
						y = 0;
					case TOPRIGHT :
						x = segW;
						y = 0;
					case BOTTOMLEFT :
						x = 0;
						y = segH;
					case BOTTOMRIGHT :
						x = segW;
						y = segH;
					

				}
				vx0 = _gen[p][y][x][vOr[0]];
				vx1 = _gen[p][y][x][vOr[1]];
				vx2 = _gen[p][y][x][vOr[2]];
				vx3 = _gen[p][y][x][vOr[3]];
				if ((vx0 != null) && (vx1 != null) && (vx2 != null) && (vx3 != null)) {
					u1 = v1 = 0;
					u2 = v2 = 1;
					if ((pUV != null)) {
						if ((pUV[vOr] != null)) {
							u1 = pUV[vOr][p][0];
							v1 = pUV[vOr][p][1];
							u2 = pUV[vOr][p][2];
							v2 = pUV[vOr][p][3];
						}
						// Set up the UVs
						uva = new UV(u2, 1 - v2);
						uvb = new UV(u2, 1 - v1);
						uvc = new UV(u1, 1 - v1);
						uvd = new UV(u1, 1 - v2);
					}
					addFace(new Face(vx0, vx3, vx1, _material, uva, uvb, uvc));
					addFace(new Face(vx0, vx1, vx2, _material, uva, uvc, uvd));
				} else {
					trace("BezierPatch Error-fillPatchMirrorHoles: Incorrect orientations defined for this hole fill");
				}
			}
		}

	}

	// Scale a Vertex and apply an x, y or z offset for a new vertex or a closely matching one
	private function vScaleXYZ(v:Vertex, x:Float, y:Float, xS:Float, yS:Float, zS:Float):Vertex {
		
		var sV:Vertex = new Vertex(Math.round(((v.x * xS) + (xOffset * xS)) * resol) / resol, Math.round(((v.y * yS) + (yOffset * yS)) * resol) / resol, Math.round(((v.z * zS) + (zOffset * zS)) * resol) / resol);
		if (x == 0 || (Math.round(x * resol) / resol) == 1 || y == 0 || (Math.round(y * resol) / resol) == 1) {
			for (__i in 0..._edgeCache.length) {
				var cV:Vertex = _edgeCache[__i];

				if (cV != null) {
					if (sV.x == cV.x && sV.y == cV.y && sV.z == cV.z) {
						return cV;
					}
				}
			}

		}
		if (v.x == sV.x && v.y == sV.y && v.z == sV.z) {
			return v;
		} else {
			return sV;
		}
		
		// autogenerated
		return null;
	}

	// Scale a Vertex and apply an x, y or z offset for a new vertex - reuses vertex
	private function vRescaleXYZ(v:Vertex, xS:Float, yS:Float, zS:Float):Void {
		
		v.x = (v.x * xS) + (xOffset * xS);
		v.y = (v.y * yS) + (yOffset * yS);
		v.z = (v.z * zS) + (zOffset * zS);
	}

}

