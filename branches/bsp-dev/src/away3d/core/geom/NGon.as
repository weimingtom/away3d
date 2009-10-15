package away3d.core.geom
{
	import __AS3__.vec.Vector;
	
	import away3d.arcane;
	import away3d.core.base.Face;
	import away3d.core.base.UV;
	import away3d.core.base.Vertex;
	import away3d.core.math.Number3D;
	import away3d.materials.ITriangleMaterial;
	
	use namespace arcane;
	
	public class NGon
	{
		private static const EPSILON : Number = 1/128;
		
		public var vertices : Vector.<Vertex>;
		public var uvs : Vector.<UV>;
		
		public var normal : Number3D;
		public var plane : Plane3D;
		public var material : ITriangleMaterial;
		
		// used during splitting etc
		private var _edgePlane : Plane3D = new Plane3D();
		private var _edge : Number3D = new Number3D();
		private var _edgeNormal : Number3D = new Number3D();
		
		public function NGon()
		{
			
		}
		
		public function classifyToPlane(compPlane : Plane3D) : int
		{
			var numPos : int;
			var numNeg : int;
			var numDoubt : int;
			var len : int = vertices.length;
			var dist : Number;
			var v : Vertex;
			
			for (var i : int = 0; i < len; ++i) {
				v = vertices[i];
				dist = compPlane.a*v._x + compPlane.b*v._y + compPlane.c*v._z + compPlane.d;
				if (dist > EPSILON)
					++numPos;
				else if (dist < -EPSILON)
					++numNeg;
				else
					++numDoubt;
			}
			
			if (numDoubt == len)
				return -2;
			if (numPos > 0 && numNeg == 0)
				return Plane3D.FRONT;
			if (numNeg > 0 && numPos == 0)
				return Plane3D.BACK;
			
			return Plane3D.INTERSECT;
		}
		
		public function clone() : NGon
		{
			var c : NGon = new NGon();
			c.vertices = vertices.concat();
			if (uvs) c.uvs = uvs.concat();
			c.material = material;
			c.plane = new Plane3D(plane.a, plane.b, plane.c, plane.d);
			return c;
		}
		
		public function triangulate() : Vector.<Face>
		{
			var len : int = vertices.length - 1;
			if (len < 1) return null;
			var tris : Vector.<Face> = new Vector.<Face>(len-1);
			var v0 : Vertex = vertices[0], v1 : Vertex, v2 : Vertex;
			var uv0 : UV, uv1 : UV, uv2 : UV;
			
			if (uvs) uv0 = uvs[0];
			
			for (var i : int = 1; i < len; ++i) {
				v1 = vertices[i];
				v2 = vertices[i+1];
				if (uvs) uv1 = uvs[i];
				if (uvs) uv2 = uvs[i+1];
				tris[i-1] = new Face(v0, v1, v2, material, uv0, uv1, uv2);
			}
			
			return tris;
		}
		
		public function fromTriangle(face : Face) : void
		{
			vertices = new Vector.<Vertex>();
			uvs = new Vector.<UV>();
			vertices[0] = face.v0;
			vertices[1] = face.v1;
			vertices[2] = face.v2;
			uvs[0] = face.uv0;
			uvs[1] = face.uv1;
			uvs[2] = face.uv2;
			normal = face.normal;
			plane = face.plane;
			material = face.material;
		}
		
		/**
		 * @return Whether collapse was succesful or not
		 */
		public function collapse(nGon : NGon) : Boolean
		{
			if (nGon.material != material) return false;
			return collapseVertices(nGon.vertices, nGon.uvs, nGon.plane);
		}
		
		/**
		 * Splits the ngon into two according to a split plane
		 * 
		 * @return Two new polygons. The first is on the positive side of the split plane, the second on the negative.
		 */
		public function split(plane : Plane3D) : Vector.<NGon>
		{
			var ngons : Vector.<NGon> = new Vector.<NGon>(2);
			var len : int = vertices.length;
			var dists : Vector.<Number> = new Vector.<Number>(len);
			var v1 : Vertex, v2 : Vertex;
			var posNGon : NGon = new NGon();
			var negNGon : NGon = new NGon();
			var posVerts : Vector.<Vertex>;
			var negVerts : Vector.<Vertex>;
			var posUV : Vector.<UV>;
			var negUV : Vector.<UV>;
			var j : int;
			ngons[0] = posNGon;
			ngons[1] = negNGon;
			negNGon.plane = posNGon.plane = this.plane;
			negNGon.normal = posNGon.normal = this.normal;
			negNGon.material = posNGon.material = this.material;
			posVerts = posNGon.vertices = new Vector.<Vertex>();
			negVerts = negNGon.vertices = new Vector.<Vertex>();
			
			if (uvs) posUV = posNGon.uvs = new Vector.<UV>();
			if (uvs) negUV = negNGon.uvs = new Vector.<UV>();
			
			for (var i : int = 0; i < len; ++i) {
				v1 = vertices[i];
				dists[i] = plane.a*v1.x + plane.b*v1.y + plane.c*v1.z + plane.d;
				if (dists[i] > -EPSILON && dists[i] < EPSILON) dists[i] = 0;
			}
			
			j = 1;
			for (i = 0; i < len; ++i) {
				v1 = vertices[i];
				v2 = vertices[j];
				
				if (dists[i] >= 0) {
					posVerts.push(vertices[i]);
					if (uvs) posUV.push(uvs[i]);
				}
				if (dists[i] <= 0) {
					negVerts.push(vertices[i]);
					if (uvs) negUV.push(uvs[i]);
				}
				
				if (dists[i]*dists[j] < 0) {
					if (uvs) splitEdge(plane, v1, v2, uvs[i], uvs[j], posNGon, negNGon);
					else splitEdge(plane, v1, v2, null, null, posNGon, negNGon);
				}
				
				if (++j == len) j = 0;
			}
			
			if (posVerts.length < 3) ngons[0] = null;
			if (negVerts.length < 3) ngons[1] = null;
			
			return ngons;
		}
		
		public function trim(plane : Plane3D) : void
		{
			if (vertices.length < 2) return;
			
			var len : int = vertices.length;
			var dists : Vector.<Number> = new Vector.<Number>(len);
			var v1 : Vertex, v2 : Vertex, uv1 : UV, uv2 : UV;
			var j : int, k : int;
			var newVerts : Vector.<Vertex> = new Vector.<Vertex>();
			var newUVs : Vector.<UV>;
			
			for (var i : int = 0; i < len; ++i) {
				v1 = vertices[i];
				dists[i] = plane.a*v1.x + plane.b*v1.y + plane.c*v1.z + plane.d;
				if (dists[i] > -EPSILON && dists[i] < EPSILON) dists[i] = 0;
			}
			
			if (uvs) newUVs = new Vector.<UV>()
			
			j = 1;
			for (i = 0; i < len; ++i) {
				v1 = vertices[i];
				v2 = vertices[j];
				if (uvs) {
					uv1 = uvs[i];
					uv2 = uvs[j];
				}
				
				if (dists[i] >= 0) {
					newVerts.push(v1);
					if (uvs) newUVs.push(uv1);
				}
				
				if (dists[i]*dists[j] < 0) {
					trimEdge(plane, v1, v2, uv1, uv2, newVerts, newUVs);
				}
				
				if (++j == len) j = 0;
			}
			
			vertices = newVerts;
			uvs = newUVs;
		}
		
		private function trimEdge(plane : Plane3D, v1 : Vertex, v2 : Vertex, uv1 : UV, uv2 : UV, newVerts : Vector.<Vertex>, newUV : Vector.<UV>) : void
		{
			var div : Number, t : Number;
			var v : Vertex;
			var uv : UV;
			
			div = plane.a*(v2.x-v1.x)+plane.b*(v2.y-v1.y)+plane.c*(v2.z-v1.z);
			
			t = -(plane.a*v1.x + plane.b*v1.y + plane.c*v1.z + plane.d)/div;
					
			v = new Vertex(v1.x+t*(v2.x-v1.x), v1.y+t*(v2.y-v1.y), v1.z+t*(v2.z-v1.z));
			newVerts.push(v);
			if (uv1 && uv2) {
				uv = new UV(uv1.u+t*(uv2.u-uv1.u), uv1.v+t*(uv2.v-uv1.v));
				newUV.push(uv);
			}
		}
		
		private function splitEdge(plane : Plane3D, v1 : Vertex, v2 : Vertex, uv1 : UV, uv2 : UV, pos : NGon, neg : NGon) : void
		{
			var div : Number, t : Number;
			var v : Vertex;
			var uv : UV;
			
			div = plane.a*(v2.x-v1.x)+plane.b*(v2.y-v1.y)+plane.c*(v2.z-v1.z);
			
			t = -(plane.a*v1.x + plane.b*v1.y + plane.c*v1.z + plane.d)/div;
					
			v = new Vertex(v1.x+t*(v2.x-v1.x), v1.y+t*(v2.y-v1.y), v1.z+t*(v2.z-v1.z));
			
			if (pos) pos.vertices.push(v);
			if (neg) neg.vertices.push(v);

			if (uv1 && uv2) {
				uv = new UV(uv1.u+t*(uv2.u-uv1.u), uv1.v+t*(uv2.v-uv1.v));
				if (pos) pos.uvs.push(uv);
				if (neg) neg.uvs.push(uv);
			}
						
		}
		
		/**
		 * @return Whether collapse was succesful or not
		 */
		public function collapseTriangle(face : Face) : Boolean
		{
			if (face.material != material) return false;
			var srcVert : Vector.<Vertex> = new Vector.<Vertex>(3);
			var srcUV : Vector.<UV> = new Vector.<UV>(3);
			srcVert[0] = face.v0;
			srcVert[1] = face.v1;
			srcVert[2] = face.v2;
			srcUV[0] = face.uv0;
			srcUV[1] = face.uv1;
			srcUV[2] = face.uv2;
			material = face.material;
			return collapseVertices(srcVert, srcUV, face.plane);
		}
		
		/**
		 * Edge collapsing between 2 adjacent coplanar convex polygons.
		 * Assuming polygons are optimized, only 1 edge can be shared (ie: 2 adjacent vertices)
		 */
		private function collapseVertices(srcVert : Vector.<Vertex>, srcUV : Vector.<UV>, srcPlane : Plane3D) : Boolean
		{
			var sharedVerticesA : Vector.<Boolean>;
			var sharedVerticesB : Vector.<Boolean>;
			var v1 : Vertex, v2 : Vertex;
			var uv1 : UV, uv2 : UV;
			var du : Number, dv : Number;
			var lastSharedIndexA : int = -1;
			var lastSharedIndexB : int = -1;
			var count : int;
			var len1 : int;
			var len2 : int;
			
			// if normals not equal enough or planes not incident, quit early
			if (Math.abs(plane.d - srcPlane.d) > EPSILON ||
				Math.abs(plane.a*srcPlane.a + plane.b*srcPlane.b + plane.c*srcPlane.c - 1) > EPSILON)
				return false;
			
			len1 = vertices.length;
			len2 = srcVert.length;
			sharedVerticesA = new Vector.<Boolean>(len1);
			sharedVerticesB = new Vector.<Boolean>(len2);
			
			for (var i : int = 0; i < len1; ++i) {
				sharedVerticesA[i] = false;
			}
			for (var j : int = 0; j < len2; ++j) {
				sharedVerticesB[j] = false;
			}

			// keep track of shared vertices
			for (i = 0; i < len1; ++i) {
				v1 = vertices[i];
				uv1 = uvs[i];
				
				for (j = 0; j < len2; ++j) {
					v2 = srcVert[j];
					uv2 = srcUV[j];
					du = Math.abs(uv1.u-uv2.u);
					dv = Math.abs(uv1.v-uv2.v);
					// if vertices coinciding with matching uv coords, collapse if close enough
					if ((v1 == v2 || v1.position.distance(v2.position) < EPSILON) &&
						(uv1 == uv2 || (du < EPSILON && dv < EPSILON))) {
						sharedVerticesA[i] = true;
						sharedVerticesB[j] = true;
						if (lastSharedIndexA == -1) {
							lastSharedIndexA = i;
							lastSharedIndexB = j;
						}
						else {
							// considering preconditions: two shared vertices need to be adjacent
							if (!(	(i - lastSharedIndexA == 1) ||
									(lastSharedIndexA == 0 && i == len1-1)
								)) return false;
							if (!(	(Math.abs(j - lastSharedIndexB) == 1) ||
									(j == 0 && lastSharedIndexB == len2-1) ||
									(lastSharedIndexB == 0 && j == len2-1)
								)) return false;
						}
						// more than 2 vertices shared. Considering preconditions, we can assume no merge is possible
						if (++count > 2) return false;
						
						// once match for i has been found, skip all other in second tri
						j = len2;
					}
				}
			}
			
			// no edge shared
			if (count < 2) return false;
			
			if (isCollapseConvex(srcVert, sharedVerticesA, sharedVerticesB)) {
				// safe to merge
				i = sharedVerticesA.indexOf(true);
				// check if 0 is not the second vertex of the edge
				// otherwise increment index as insertion point (after last vertex) 
				if (!(i == 0 && !sharedVerticesA[1]))
					i++;
				
				j = lastSharedIndexB = sharedVerticesB.indexOf(true);
				
				// loop through input set and add unshared vertices
				do {
					if (!sharedVerticesB[j]) {
						vertices.splice(i, 0, srcVert[j]);
						uvs.splice(i, 0, srcUV[j]);
						++i;
					}
					if (++j == len2) j = 0;
				} while (j != lastSharedIndexB);
				removeColinears();
				return true;
				
			}
			return false;
		}
		
		private function removeColinears() : void
		{
			var j : int = 1;
			var k : int = 2;
			var v0 : Vertex, v1 : Vertex, v2 : Vertex;
			var u : Number3D = new Number3D();
			var v : Number3D = new Number3D();
			var cross : Number3D = new Number3D();
			
			for (var i : int = 0; i < vertices.length; ++i) {
				v0 = vertices[i];
				v1 = vertices[j];
				v2 = vertices[k];
				
				// check if collinear (caused by t-junctions)
				u.x = v1.x-v0.x;
				u.y = v1.y-v0.y;
				u.z = v1.z-v0.z;
				v.x = v2.x-v0.x;
				v.y = v2.y-v0.y;
				v.z = v2.z-v0.z;
				cross.cross(u, v);
				
				if (cross.modulo < EPSILON) {
					vertices.splice(j, 1);
					uvs.splice(j, 1);
					--i;
				}
				else {
					++j;
					++k;
				}
				if (j == vertices.length) j = 0;
				if (k == vertices.length) k = 0;
			}
		}
		
		private function isCollapseConvex(srcVert : Vector.<Vertex>, sharedA : Vector.<Boolean>, sharedB : Vector.<Boolean>) : Boolean
		{
			var v1A : Vertex, v2A : Vertex, vB : Vertex;
			var len1 : int = vertices.length;
			var len2 : int = srcVert.length;
			var v1AShared : Boolean, v2AShared : Boolean;
			var i : int;
			var complete : Boolean;
			var c : int;
			var compPoint : Vertex;
			
			// vertices && srcVect are already convex on their own
			// need to check if same goes for vertices -> srcVect (symmetrical case, one direction is enough)
			v1A = vertices[0];
			v1AShared = sharedA[0];
			
			i = 1;
			c = 2;
			
			do {
				if (i == 0) complete = true;
				v2A = vertices[i];
				v2AShared = sharedA[i];
				
				// can skip shared edge
				if (v1AShared && v2AShared) {
					v1AShared = v2AShared;
					v1A = v2A;
					if (++i == len1) i = 0;
					if (++c == len1) c = 0;
					continue;
				}
				
				_edge.x = v2A.x-v1A.x;
				_edge.y = v2A.y-v1A.y;
				_edge.z = v2A.z-v1A.z;
				_edge.normalize();
				_edgeNormal.cross(normal, _edge);
				compPoint = vertices[c];
				
				if (_edgeNormal.x*(compPoint.x-v1A.x) + _edgeNormal.y*(compPoint.y-v1A.y) + _edgeNormal.z*(compPoint.z-v1A.z) < 0) {
					_edgeNormal.x = -_edgeNormal.x;
					_edgeNormal.y = -_edgeNormal.y;
					_edgeNormal.z = -_edgeNormal.z;
				}
				_edgePlane.a = _edgeNormal.x;
				_edgePlane.b = _edgeNormal.y;
				_edgePlane.c = _edgeNormal.z;
				_edgePlane.d = -(v2A.x*_edgeNormal.x + v2A.y*_edgeNormal.y + v2A.z*_edgeNormal.z);
				
				for (var j : int = 0; j < len2; ++j) {
					// can skip shared points
					if (sharedB[j]) continue;
					
					vB = srcVert[j];
					// calculate side of point relative to edge
					if (_edgePlane.a*vB.x + _edgePlane.b*vB.y + _edgePlane.c*vB.z + _edgePlane.d < -EPSILON)
						return false;
				}
				
				v1AShared = v2AShared;
				v1A = v2A;
				if (++i == len1) i = 0;
				if (++c == len1) c = 0;
			} while(!complete);
			
			return true;
		}
	}
}