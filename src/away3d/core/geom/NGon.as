package away3d.core.geom
{
	import away3d.core.graphs.BSPTree;
	import away3d.arcane;
	import away3d.core.base.Face;
	import away3d.core.base.UV;
	import away3d.core.base.Vertex;
	import away3d.core.math.Number3D;
	import away3d.materials.ITriangleMaterial;
	
	use namespace arcane;
	
	public final class NGon
	{
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
		
		public function invert() : void
		{
			var len : int = vertices.length;
			var newVertices : Vector.<Vertex> = new Vector.<Vertex>(len);
			var i : int = len;
			var j : int = 0;
			
			plane.a = -plane.a;
			plane.b = -plane.b;
			plane.c = -plane.c;
			plane.d = -plane.d;
			
			while (--i >= 0)
				newVertices[j++] = vertices[i];
			
			vertices = newVertices;
		}
		
		public function classifyToPlane(compPlane : Plane3D) : int
		{
			var numPos : int;
			var numNeg : int;
			var numDoubt : int;
			var len : int = vertices.length;
			var dist : Number;
			var v : Vertex;
			var i : int = len;
			var align : int = compPlane._alignment;
			var a : Number = compPlane.a,
				b : Number = compPlane.b,
				c : Number = compPlane.c,
				d : Number = compPlane.d;
			
			if (align == Plane3D.X_AXIS) {
				while (--i >= 0) {
					dist = a*vertices[i].x + d;
					if (dist > BSPTree.EPSILON)
						++numPos;
					else if (dist < -BSPTree.EPSILON)
						++numNeg;
					else
						++numDoubt;
					if (numNeg > 0 && numPos > 0) return Plane3D.INTERSECT;
				}
			}
			else if (align == Plane3D.Y_AXIS) {
				while (--i >= 0) {
					dist = b*vertices[i].y + d;
					if (dist > BSPTree.EPSILON)
						++numPos;
					else if (dist < -BSPTree.EPSILON)
						++numNeg;
					else
						++numDoubt;
					if (numNeg > 0 && numPos > 0) return Plane3D.INTERSECT;
				}
			}
			else if (align == Plane3D.Z_AXIS) {
				while (--i >= 0) {
					dist = c*vertices[i].z + d;
					if (dist > BSPTree.EPSILON)
						++numPos;
					else if (dist < -BSPTree.EPSILON)
						++numNeg;
					else
						++numDoubt;
					if (numNeg > 0 && numPos > 0) return Plane3D.INTERSECT;
				}
			}
			else {
				while (--i >= 0) {
					v = vertices[i];
					dist = a*v.x + b*v.y + c*v.z + d;
					if (dist > BSPTree.EPSILON)
						++numPos;
					else if (dist < -BSPTree.EPSILON)
						++numNeg;
					else
						++numDoubt;
					if (numNeg > 0 && numPos > 0) return Plane3D.INTERSECT;
				}
			}
			
			if (numDoubt == len)
				return -2;
			if (numPos > 0 && numNeg == 0)
				return Plane3D.FRONT;
			if (numNeg > 0 && numPos == 0)
				return Plane3D.BACK;
			
			return Plane3D.INTERSECT;
		}
		
		/**
		 * Returns true if either in front of plane or intersecting
		 */
		public function isCoinciding(compPlane : Plane3D) : Boolean
		{
			var v : Vertex;
			var i : int = vertices.length;
			var align : int = compPlane._alignment;
			var a : Number = compPlane.a,
				b : Number = compPlane.b,
				c : Number = compPlane.c,
				d : Number = compPlane.d;
			var dist : Number;
			
			if (align == Plane3D.X_AXIS) {
				while (--i >= 0) {
					dist = a*vertices[i].x + d;
					if(dist > BSPTree.EPSILON || dist < -BSPTree.EPSILON)
						return false;
				}
			}
			else if (align == Plane3D.Y_AXIS) {
				while (--i >= 0) {
					dist = b*vertices[i].y + d;
					if(dist > BSPTree.EPSILON || dist < -BSPTree.EPSILON)
						return false;
				}
			}
			else if (align == Plane3D.Z_AXIS) {
				while (--i >= 0) {
					dist = c*vertices[i].z + d;
					if(dist > BSPTree.EPSILON || dist < -BSPTree.EPSILON)
						return false;
				}
			}
			else {
				while (--i >= 0) {
					v = vertices[i];
					dist = a*v.x + b*v.y + c*v.z + d;
					if(dist > BSPTree.EPSILON || dist < -BSPTree.EPSILON)
						return false;
				}
			}
			
			return true;
		}
		
		/**
		 * Returns true if either in front of plane or intersecting
		 */
		public function classifyForPortalFront(compPlane : Plane3D) : Boolean
		{
			var v : Vertex;
			var i : int = vertices.length;
			var align : int = compPlane._alignment;
			var a : Number = compPlane.a,
				b : Number = compPlane.b,
				c : Number = compPlane.c,
				d : Number = compPlane.d;
			
			if (align == Plane3D.X_AXIS) {
				while (--i >= 0) {
					if(a*vertices[i].x + d > BSPTree.EPSILON)
						return true;
				}
			}
			else if (align == Plane3D.Y_AXIS) {
				while (--i >= 0) {
					if(b*vertices[i].y + d > BSPTree.EPSILON)
						return true;
				}
			}
			else if (align == Plane3D.Z_AXIS) {
				while (--i >= 0) {
					if(c*vertices[i].z + d > BSPTree.EPSILON)
						return true;
				}
			}
			else {
				while (--i >= 0) {
					v = vertices[i];
					if (a*v.x + b*v.y + c*v.z + d > BSPTree.EPSILON)
						return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Returns true if either behind plane or intersecting
		 */
		public function classifyForPortalBack(compPlane : Plane3D) : Boolean
		{
			var v : Vertex;
			var i : int = vertices.length;
			var align : int = compPlane._alignment;
			var a : Number = compPlane.a,
				b : Number = compPlane.b,
				c : Number = compPlane.c,
				d : Number = compPlane.d;
				
			if (align == Plane3D.X_AXIS) {
				while (--i >= 0) {
					if(a*vertices[i].x + d < -BSPTree.EPSILON)
						return true;
				}
			}
			else if (align == Plane3D.Y_AXIS) {
				while (--i >= 0) {
					if(b*vertices[i].y + d < -BSPTree.EPSILON)
						return true;
				}
			}
			else if (align == Plane3D.Z_AXIS) {
				while (--i >= 0) {
					if(c*vertices[i].z + d < -BSPTree.EPSILON)
						return true;
				}
			}
			else {
				while (--i >= 0) {
					v = vertices[i];
					if (a*v.x + b*v.y + c*v.z + d < -BSPTree.EPSILON)
						return true;
				}
			}
			return false;
		}
		
		public function isOutAntiPenumbra(compPlane : Plane3D) : Boolean
		{
			var v : Vertex;
			var i : int = vertices.length;
				
			// anti-penumbrae have no alignment info, skip tests
			while (--i >= 0) {
				v = vertices[i];
				if (compPlane.a*v.x + compPlane.b*v.y + compPlane.c*v.z + compPlane.d > BSPTree.EPSILON)
					return false;
			}
			return true;
		}
		
		public function clone() : NGon
		{
			var c : NGon = new NGon();
			c.vertices = vertices.concat();
			if (uvs) c.uvs = uvs.concat();
			c.material = material;
			c.plane = new Plane3D(plane.a, plane.b, plane.c, plane.d);
			c.plane._alignment = plane._alignment;
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
			var triPlane : Plane3D = face.plane;
			vertices = new Vector.<Vertex>();
			uvs = new Vector.<UV>();
			vertices[0] = face.v0;
			vertices[1] = face.v1;
			vertices[2] = face.v2;
			uvs[0] = face.uv0;
			uvs[1] = face.uv1;
			uvs[2] = face.uv2;
			normal = face.normal;
			plane = new Plane3D(triPlane.a, triPlane.b, triPlane.c, triPlane.d);
			plane._alignment = triPlane._alignment;
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
		public function split(splitPlane : Plane3D) : Vector.<NGon>
		{
			var ngons : Vector.<NGon> = new Vector.<NGon>(2);
			var len : int = vertices.length;
			var v1 : Vertex, v2 : Vertex;
			var posNGon : NGon = new NGon();
			var negNGon : NGon = new NGon();
			var posVerts : Vector.<Vertex>;
			var negVerts : Vector.<Vertex>;
			var posUV : Vector.<UV>;
			var negUV : Vector.<UV>;
			var j : int;
			var d0 : Number;
			var d1 : Number;
			var d2 : Number;
			var i : int = len;
			
			ngons[0] = posNGon;
			ngons[1] = negNGon;
			negNGon.plane = posNGon.plane = plane;
			negNGon.normal = posNGon.normal = normal;
			negNGon.material = posNGon.material = material;
			posVerts = posNGon.vertices = new Vector.<Vertex>();
			negVerts = negNGon.vertices = new Vector.<Vertex>();
			
			if (uvs) {
				posUV = posNGon.uvs = new Vector.<UV>();
				negUV = negNGon.uvs = new Vector.<UV>();
			}
			
			v1 = vertices[0];
			if (splitPlane._alignment == Plane3D.X_AXIS)
				d0 = d2 = splitPlane.a*v1.x + splitPlane.d;
			else if (splitPlane._alignment == Plane3D.Y_AXIS)
				d0 = d2 = splitPlane.b*v1.y + splitPlane.d;
			else if (splitPlane._alignment == Plane3D.Z_AXIS)
				d0 = d2 = splitPlane.c*v1.z + splitPlane.d;
			else
				d0 = d2 = splitPlane.a*v1.x + splitPlane.b*v1.y + splitPlane.c*v1.z + splitPlane.d;
			
			if (d2 >= -BSPTree.EPSILON && d2 <= BSPTree.EPSILON) d2 = 0;
			
			j = 1;
			for (i = 0; i < len; ++i) {
				v1 = vertices[i];
				v2 = vertices[j];
				
				d1 = d2;
				
				if (j == 0)
					d2 = d0;
				else {
					if (splitPlane._alignment == Plane3D.X_AXIS)
						d2 = splitPlane.a*v2.x + splitPlane.d;
					else if (splitPlane._alignment == Plane3D.Y_AXIS)
						d2 = splitPlane.b*v2.y + splitPlane.d;
					else if (splitPlane._alignment == Plane3D.Z_AXIS)
						d2 = splitPlane.c*v2.z + splitPlane.d;
					else
						d2 = splitPlane.a*v2.x + splitPlane.b*v2.y + splitPlane.c*v2.z + splitPlane.d;
				}
				
				if (d2 >= -BSPTree.EPSILON && d2 <= BSPTree.EPSILON) d2 = 0;
				
				if (d1 >= 0) {
					posVerts.push(v1);
					if (uvs) posUV.push(uvs[i]);
				}
				if (d1 <= 0) {
					negVerts.push(v1);
					if (uvs) negUV.push(uvs[i]);
				}
				
				if (d1*d2 < 0) {
					if (uvs) splitEdge(splitPlane, v1, v2, uvs[i], uvs[j], posNGon, negNGon);
					else splitEdge(splitPlane, v1, v2, null, null, posNGon, negNGon);
				}
				
				if (++j == len) j = 0;
			}
			
			if (posVerts.length < 3) ngons[0] = null;
			if (negVerts.length < 3) ngons[1] = null;
			
			return ngons;
		}
		
		private static var _newVerts : Vector.<Vertex>;
		private static var _newUVs : Vector.<UV>;
		
		public function trim(trimPlane : Plane3D) : void
		{
			//if (vertices.length < 3) return;
			
			var len : int = vertices.length;
			var v1 : Vertex, v2 : Vertex, uv1 : UV, uv2 : UV;
			var j : int;
			var i : int;
			var d0 : Number;
			var d1 : Number;
			var d2 : Number;
			
			if (!_newVerts) _newVerts = new Vector.<Vertex>();
			if (uvs && !_newUVs) _newUVs = new Vector.<UV>();
			
			v1 = vertices[0];
			if (trimPlane._alignment == Plane3D.X_AXIS)
				d0 = d2 = trimPlane.a*v1.x + trimPlane.d;
			else if (trimPlane._alignment == Plane3D.Y_AXIS)
				d0 = d2 = trimPlane.b*v1.y + trimPlane.d;
			else if (trimPlane._alignment == Plane3D.Z_AXIS)
				d0 = d2 = trimPlane.c*v1.z + trimPlane.d;
			else
				d0 = d2 = trimPlane.a*v1.x + trimPlane.b*v1.y + trimPlane.c*v1.z + trimPlane.d;
			
			if (d2 >= -BSPTree.EPSILON && d2 <= BSPTree.EPSILON) d0 = d2 = 0;
			
			j = 1;
			i = 0;
			
			v2 = vertices[0];
			if (uvs) uv2 = uvs[0];
			
			do {
				v1 = v2;
				v2 = vertices[j];
				if (uvs) {
					uv1 = uv2;
					uv2 = uvs[j];
				}
				
				d1 = d2;
				
				if (j == 0)
					d2 = d0;
				else {
					if (trimPlane._alignment == Plane3D.X_AXIS)
						d2 = trimPlane.a*v2.x + trimPlane.d;
					else if (trimPlane._alignment == Plane3D.Y_AXIS)
						d2 = trimPlane.b*v2.y + trimPlane.d;
					else if (trimPlane._alignment == Plane3D.Z_AXIS)
						d2 = trimPlane.c*v2.z + trimPlane.d;
					else
						d2 = trimPlane.a*v2.x + trimPlane.b*v2.y + trimPlane.c*v2.z + trimPlane.d;
				}
				
				if (d2 >= -BSPTree.EPSILON && d2 <= BSPTree.EPSILON) d2 = 0;
				
				if (d1 >= 0) {
					_newVerts.push(v1);
					if (uvs) _newUVs.push(uv1);
				}
				
				if (d1*d2 < 0)
					trimEdge(trimPlane, v1, v2, uv1, uv2, _newVerts, _newUVs);
				
				if (++j == len) j = 0;
			} while (++i < len);
			
			var vTemp : Vector.<Vertex>;
			var uvTemp : Vector.<UV>;
			
			vTemp = vertices;
			vertices = _newVerts;
			_newVerts = vTemp;
			_newVerts.length = 0;
			
			if (uvs) {
				uvTemp = uvs;
				uvs = _newUVs;
				_newUVs = uvTemp;
				_newUVs.length = 0;
			}
		}
		
		public function trimBack(trimPlane : Plane3D) : void
		{
//			if (vertices.length < 3) return;
			
			var len : int = vertices.length;
			var v1 : Vertex, v2 : Vertex, uv1 : UV, uv2 : UV;
			var j : int;
			var i : int = len;
			var d0 : Number;
			var d1 : Number;
			var d2 : Number;
			
			if (!_newVerts) _newVerts = new Vector.<Vertex>();
			if (uvs && !_newUVs) _newUVs = new Vector.<UV>();
			
			v1 = vertices[0];
			if (trimPlane._alignment == Plane3D.X_AXIS)
				d0 = d2 = trimPlane.a*v1.x + trimPlane.d;
			else if (trimPlane._alignment == Plane3D.Y_AXIS)
				d0 = d2 = trimPlane.b*v1.y + trimPlane.d;
			else if (trimPlane._alignment == Plane3D.Z_AXIS)
				d0 = d2 = trimPlane.c*v1.z + trimPlane.d;
			else
				d0 = d2 = trimPlane.a*v1.x + trimPlane.b*v1.y + trimPlane.c*v1.z + trimPlane.d;
			
			if (d2 >= -BSPTree.EPSILON && d2 <= BSPTree.EPSILON) d0 = d2 = 0;
			
			j = 1;
			i = 0;
			do {
				v1 = vertices[i];
				v2 = vertices[j];
				if (uvs) {
					uv1 = uvs[i];
					uv2 = uvs[j];
				}
				
				d1 = d2;
				
				if (j == 0)
					d2 = d0;
				else {
					if (trimPlane._alignment == Plane3D.X_AXIS)
						d2 = trimPlane.a*v2.x + trimPlane.d;
					else if (trimPlane._alignment == Plane3D.Y_AXIS)
						d2 = trimPlane.b*v2.y + trimPlane.d;
					else if (trimPlane._alignment == Plane3D.Z_AXIS)
						d2 = trimPlane.c*v2.z + trimPlane.d;
					else
						d2 = trimPlane.a*v2.x + trimPlane.b*v2.y + trimPlane.c*v2.z + trimPlane.d;
				}
				
				if (d2 >= -BSPTree.EPSILON && d2 <= BSPTree.EPSILON) d2 = 0;
				
				if (d1 <= 0) {
					_newVerts.push(v1);
					if (uvs) _newUVs.push(uv1);
				}
				
				if (d1*d2 < 0)
					trimEdge(trimPlane, v1, v2, uv1, uv2, _newVerts, _newUVs);
				
				if (++j == len) j = 0;
			} while (++i < len);
			
			var vTemp : Vector.<Vertex>;
			var uvTemp : Vector.<UV>;
			
			vTemp = vertices;
			vertices = _newVerts;
			_newVerts = vTemp;
			_newVerts.length = 0;
			
			if (uvs) {
				uvTemp = uvs;
				uvs = _newUVs;
				_newUVs = uvTemp;
				_newUVs.length = 0;
			}
		}
		
		public function isNeglectable() : Boolean
		{
			var i : int = vertices.length;
			var j : int = i-2;
			var v1 : Vertex;
			var v2 : Vertex;
			var dx : Number, dy : Number, dz : Number;
			var count : int;
			
			if (i < 3) return true;
			
			// check each edge of polygon, must have at least 3 edges long enough
			while (--i >= 0) {
				v1 = vertices[i];
				v2 = vertices[j];
				
				dx = v1.x-v2.x;
				dy = v1.y-v2.y;
				dz = v1.z-v2.z;
				
				if (dx*dx+dy*dy+dz*dz > BSPTree.EPSILON)
					if (++count >= 3) return false;
				
				
				if (--j < 0) j = vertices.length-1;
			}
			
			return true;
		}
		
		public function get area() : Number
		{
			var area : Number = 0;
			var v1 : Vertex = vertices[0];
			var v2 : Vertex, v3 : Vertex;
			var len : int = vertices.length-1;
			var ux : Number, uy : Number, uz : Number,
				vx : Number, vy : Number, vz : Number,
				cx : Number, cy : Number, cz : Number;
			var i : int, j : int;
			
			do {
				v2 = vertices[i];
				v3 = vertices[++j];
				ux = v2._x-v1._x;
				uy = v2._y-v1._y;
				uz = v2._z-v1._z;
				vx = v3._x-v1._x;
				vy = v3._y-v1._y;
				vz = v3._z-v1._z;
				
				cx = vy * uz - vz * uy;
        		cy = vz * ux - vx * uz;
        		cz = vx * uy - vy * ux;
				
				area += Math.sqrt(cx*cx+cy*cy+cz*cz);
			} while (++i < len);
			
			return area;
		}
		
		private function trimEdge(plane : Plane3D, v1 : Vertex, v2 : Vertex, uv1 : UV, uv2 : UV, newVerts : Vector.<Vertex>, newUV : Vector.<UV>) : void
		{
			var div : Number, t : Number;
			var v : Vertex;
			var uv : UV;
			
			if (plane._alignment == Plane3D.X_AXIS) {
				div = plane.a*(v2.x-v1.x);
				t = -(plane.a*v1.x + plane.d)/div;
			}
			else if (plane._alignment == Plane3D.Y_AXIS) {
				div = plane.b*(v2.y-v1.y);
				t = -(plane.b*v1.y + plane.d)/div;
			}
			else if (plane._alignment == Plane3D.Z_AXIS) {
				div = plane.c*(v2.z-v1.z);
				t = -(plane.c*v1.z + plane.d)/div;
			}
			else {
				div = plane.a*(v2.x-v1.x)+plane.b*(v2.y-v1.y)+plane.c*(v2.z-v1.z);
				t = -(plane.a*v1.x + plane.b*v1.y + plane.c*v1.z + plane.d)/div;
			}
					
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
			if (Math.abs(plane.d - srcPlane.d) > BSPTree.EPSILON ||
				Math.abs(plane.a*srcPlane.a + plane.b*srcPlane.b + plane.c*srcPlane.c - 1) > BSPTree.EPSILON)
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
					if ((v1 == v2 || v1.position.distance(v2.position) < BSPTree.EPSILON) &&
						(uv1 == uv2 || (du < BSPTree.EPSILON && dv < BSPTree.EPSILON))) {
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
				
				if (cross.modulo < BSPTree.EPSILON) {
					vertices.splice(j, 1);
					if (uvs) uvs.splice(j, 1);
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
					if (_edgePlane.a*vB.x + _edgePlane.b*vB.y + _edgePlane.c*vB.z + _edgePlane.d < -BSPTree.EPSILON)
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