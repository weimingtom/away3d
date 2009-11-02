package away3d.core.graphs
{
	import __AS3__.vec.Vector;
	
	import away3d.arcane;
	import away3d.core.base.Face;
	import away3d.core.base.Vertex;
	import away3d.core.geom.NGon;
	import away3d.core.geom.Plane3D;
	import away3d.core.math.Number3D;
	import away3d.materials.WireColorMaterial;
	
	use namespace arcane;
	
	internal final class BSPPortal
	{
		public var nGon : NGon;
		//public var leaves : Vector.<BSPNode>;
		public var sourceNode : BSPNode;
		public var frontNode : BSPNode;
		public var backNode : BSPNode;
		
		private static var EPSILON : Number = 1/128;
		
		public function BSPPortal()
		{
			//leaves = new Vector.<BSPNode>();
			nGon = new NGon();
			nGon.material = new WireColorMaterial(Math.round(Math.random()*0xffffff), {alpha : .5});
			nGon.vertices = new Vector.<Vertex>();
		}
		
		public function cutSolids() : Vector.<BSPPortal>
		{
			var subs : Vector.<BSPPortal> = new Vector.<BSPPortal>();
			var coinc : Vector.<Face> = new Vector.<Face>();
			var i : int;
			var faces : Array;
			var face : Face;
			var len : int;
			var cutCount : int;
			
			faces = frontNode._mesh.geometry.faces
			len = faces.length;
			
			subs.push(this);
			
			for (i = 0; i < len; ++i) {
				face = faces[i];
				if (isFaceCoinciding(face)) {
					subs = cutToFace(subs, face);
					cutCount++;
				}
			}
			
			faces = backNode._mesh.geometry.faces
			len = faces.length;
			
			for (i = 0; i < len; ++i) {
				face = faces[i];
				if (isFaceCoinciding(face)) {
					subs = cutToFace(subs, face);
					cutCount++;
				}
			}
			
			if (cutCount == 0) return null;
			return subs;
		}
		
		private function cutToFace(subs : Vector.<BSPPortal>, face : Face) : Vector.<BSPPortal>
		{
			var newSubs : Vector.<BSPPortal> = new Vector.<BSPPortal>();
			var splits : Vector.<BSPPortal>;
			var len : int = subs.length;
			
			face.generateEdgePlanes();
			
			for (var i : int = 0; i < len; ++i) {
				splits = subs[i].split(face._edgePlane01);
				if (splits[1]) newSubs.push(splits[1]);
				if (splits[0]) {
					splits = splits[0].split(face._edgePlane12);
					if (splits[1]) newSubs.push(splits[1]);
					if (splits[0]) {
						splits = splits[0].split(face._edgePlane20);
						if (splits[1]) newSubs.push(splits[1]);
					}
				}
			}
			
			return newSubs;
		}
		
		private function isFaceCoinciding(face : Face) : Boolean
		{
			var dot : Number;
			dot = nGon.plane.distance(face.v0.position);
			if (dot != 0) return false;
			dot = nGon.plane.distance(face.v1.position);
			if (dot != 0) return false;
			dot = nGon.plane.distance(face.v2.position);
			if (dot != 0) return false;
			
			return true;
		}
		
		public function fromNode(node : BSPNode, root : BSPNode) : void
		{
			var v : Vertex;
			var bounds : Array = root._bounds;
			var bound : Number3D;
			var plane : Plane3D = nGon.plane = node._partitionPlane;
			var dist : Number;
			var radius : Number;
			var direction1 : Number3D, direction2 : Number3D;
			var center : Number3D = new Number3D(	(root._minX+root._maxX)*.5,
													(root._minY+root._maxY)*.5,
													(root._minZ+root._maxZ)*.5 );
			var normal : Number3D = new Number3D(plane.a, plane.b, plane.c);
			
			sourceNode = node;
			
			radius = center.distance(bounds[0]);
			radius = Math.sqrt(radius*radius + radius*radius);
			
			// calculate projection of aabb's center on plane
			dist = plane.distance(center);
			center.x -= dist*plane.a;
			center.y -= dist*plane.b; 
			center.z -= dist*plane.c;
			
			// perpendicular to plane normal & world axis, parallel to plane
			direction1 = getPerpendicular(normal);
			direction1.normalize();
			
			// perpendicular to plane normal & direction1, parallel to plane
			direction2 = new Number3D();
			direction2.cross(normal, direction1);
			direction2.normalize();
			
			// form very course bounds of bound projection on plane
			nGon.vertices.push(new Vertex( 	center.x + direction1.x*radius,
											center.y + direction1.y*radius,
											center.z + direction1.z*radius));
			nGon.vertices.push(new Vertex( 	center.x + direction2.x*radius,
											center.y + direction2.y*radius,
											center.z + direction2.z*radius));
			
			// invert direction
			direction1.normalize(-1);
			direction2.normalize(-1);
			
			nGon.vertices.push(new Vertex( 	center.x + direction1.x*radius,
											center.y + direction1.y*radius,
											center.z + direction1.z*radius));
			nGon.vertices.push(new Vertex( 	center.x + direction2.x*radius,
											center.y + direction2.y*radius,
											center.z + direction2.z*radius));
			
			// trim closely to world's bound planes
			trimToAABB(root);
			
			var prev : BSPNode = node; 
			while (node = node._parent) {
				if (prev == node._positiveNode)
					nGon.trim(node._partitionPlane);
				else
					nGon = nGon.split(node._partitionPlane)[1];
				prev = node;
			}
		}
		
		public function clone() : BSPPortal
		{
			var c : BSPPortal = new BSPPortal();
			c.nGon = nGon.clone();
			c.frontNode = frontNode;
			c.backNode = backNode;
			return c;
		}
		
		private function trimToAABB(node : BSPNode) : void
		{
			nGon.trim(new Plane3D(0, -1, 0, node._maxY));
			nGon.trim(new Plane3D(0, 1, 0, -node._minY));
			nGon.trim(new Plane3D(1, 0, 0, -node._minX));
			nGon.trim(new Plane3D(-1, 0, 0, node._maxX));
			nGon.trim(new Plane3D(0, 0, 1, -node._minZ));
			nGon.trim(new Plane3D(0, 0, -1, node._maxZ));
		}
		
		private function getProjectionDistance(centerProj : Number3D, p : Number3D, plane : Plane3D) : Number
		{
			var dist : Number = p.x*plane.a + p.y*plane.b + p.z*plane.c + plane.d;
			var d : Number3D = new Number3D(	p.x - dist*plane.a,
												p.y - dist*plane.b,
												p.z - dist*plane.c);
			return d.distance(centerProj);
		}
		
		private function getPerpendicular(normal : Number3D) : Number3D
		{
			var p : Number3D = new Number3D();
			p.cross(new Number3D(1, 1, 0), normal);
			if (p.modulo < EPSILON) {
				p.cross(new Number3D(0, 1, 1), normal);
			}
			return p;
		}
		
		public function split(plane : Plane3D) : Vector.<BSPPortal>
		{
			var posPortal : BSPPortal;
			var negPortal : BSPPortal;
			var splits : Vector.<NGon> = nGon.split(plane);
			var ngon : NGon;
			var newPortals : Vector.<BSPPortal> = new Vector.<BSPPortal>(2);
			
			ngon = splits[0];
			if (ngon && ngon.area > EPSILON) {
				posPortal = new BSPPortal();
				posPortal.nGon = ngon;
				posPortal.nGon.material = new WireColorMaterial(Math.round(Math.random()*0xffffff), {alpha : .5});
				posPortal.sourceNode = sourceNode;
				posPortal.frontNode = frontNode;
				posPortal.backNode = backNode;
				newPortals[0] = posPortal;
			}
			ngon = splits[1];
			if (ngon && ngon.area > EPSILON) {
				negPortal = new BSPPortal();
				negPortal.nGon = ngon;
				negPortal.sourceNode = sourceNode;
				negPortal.frontNode = frontNode;
				negPortal.backNode = backNode;
				negPortal.nGon.material = new WireColorMaterial(Math.round(Math.random()*0xffffff), {alpha : .5});
				newPortals[1] = negPortal;
			}
			
			return newPortals;
		}
	}
}