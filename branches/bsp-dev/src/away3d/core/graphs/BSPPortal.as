package away3d.core.graphs
{
	import __AS3__.vec.Vector;
	
	import away3d.arcane;
	import away3d.core.base.Vertex;
	import away3d.core.geom.Plane3D;
	import away3d.core.math.Number3D;
	
	use namespace arcane;
	
	internal class BSPPortal
	{
		public var vertices : Vector.<Vertex>;
		public var splitNegative : Vector.<Vertex>;
		public var splitPositive : Vector.<Vertex>;
		
		public var partitionPlane : Plane3D;
		
		public function BSPPortal()
		{
			vertices = new Vector.<Vertex>();
		}
		
		public function fromNode(node : BSPNode) : void
		{
			var v : Number3D;
			var bounds : Array = node._bounds;
			partitionPlane = node._partitionPlane;
		}
		
		public function split(plane : Plane3D) : void
		{
			var posPortal : BSPPortal = new BSPPortal();
			var negPortal : BSPPortal = new BSPPortal();
			posPortal.partitionPlane = partitionPlane;
			negPortal.partitionPlane = partitionPlane;
		}
	}
}