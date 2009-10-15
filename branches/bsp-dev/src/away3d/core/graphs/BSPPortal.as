package away3d.core.graphs
{
	import __AS3__.vec.Vector;
	
	import away3d.arcane;
	import away3d.core.base.Vertex;
	import away3d.core.geom.NGon;
	import away3d.core.geom.Plane3D;
	import away3d.core.math.Number3D;
	import away3d.materials.WireColorMaterial;
	
	use namespace arcane;
	
	internal class BSPPortal
	{
		public var nGon : NGon;
		public var leaves : Vector.<BSPNode>;
		public var sourceNode : BSPNode;
		
		private static var EPSILON : Number = 1/32;
		
		public function BSPPortal()
		{
			nGon = new NGon();
			nGon.material = new WireColorMaterial(Math.round(Math.random()*0xffffff), {alpha : .5});
			nGon.vertices = new Vector.<Vertex>();
		}
		
		public function fromNode(node : BSPNode) : void
		{
			var v : Vertex;
			var bounds : Array = node._bounds;
			var bound : Number3D;
			var plane : Plane3D = nGon.plane = node._partitionPlane;
			var dist : Number;
			var radius : Number;
			var direction1 : Number3D, direction2 : Number3D;
			var center : Number3D = new Number3D(	(node._minX+node._maxX)*.5,
													(node._minY+node._maxY)*.5,
													(node._minZ+node._maxZ)*.5 );
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
			
			// trim closely to bound planes
			trimToAABB(node);
		}
		
		public function clone() : BSPPortal
		{
			var c : BSPPortal = new BSPPortal();
			c.nGon = nGon.clone();
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
			var newPortals : Vector.<BSPPortal> = new Vector.<BSPPortal>(2);
			
			if (splits[0]) {
				posPortal = new BSPPortal();
				posPortal.nGon = splits[0];
				posPortal.nGon.material = new WireColorMaterial(Math.round(Math.random()*0xffffff), {alpha : .5});
				posPortal.sourceNode = sourceNode;
				newPortals[0] = posPortal;
			}
			if (splits[1]) {
				negPortal = new BSPPortal();
				negPortal.nGon = splits[1];
				negPortal.sourceNode = sourceNode;
				negPortal.nGon.material = new WireColorMaterial(Math.round(Math.random()*0xffffff), {alpha : .5});
				newPortals[1] = negPortal;
			}
			
			return newPortals;
		}
	}
}