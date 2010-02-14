package away3d.exporters
{
	import away3d.arcane;
	import away3d.core.base.Mesh;
	import away3d.core.geom.Plane3D;
	import away3d.core.graphs.TreeIterator;
	import away3d.core.graphs.bsp.BSPNode;
	import away3d.core.graphs.bsp.BSPTree;

	import flash.events.EventDispatcher;

	use namespace arcane;

	public class BSPExporter extends EventDispatcher
	{
		private var _iterator : TreeIterator;
		private var _exportString : String;
		private var _branchesString : String;
		private var _leavesString : String;
		private var _meshString : String;
		private var _numMeshes : int;

		public function BSPExporter()
		{
			super();
		}

		private function reset() : void
		{
			// temp start values
			_exportString = "#v:1.1\n#f:2\n#t:bsp\n";
			_branchesString = "#b\n";
			_leavesString = "#l\n";
			_meshString = "";
			_numMeshes = 0;
		}

		public function export(tree : BSPTree) : void
		{
			reset();
			_iterator = new TreeIterator(tree._rootNode);
			_iterator.performMethod(parseNode);
		}

		private function parseNode(node : BSPNode) : void
		{
			if (node._isLeaf)
				parseLeaf(node);
			else
				parseBranch(node);
		}

		private function parseBranch(node : BSPNode) : void
		{
			var plane : Plane3D;
			var bevels : Vector.<Plane3D> = node._bevelPlanes;
			var len : int;
			var pos : BSPNode = node._positiveNode;
			var neg : BSPNode = node._negativeNode;

			// save:
			// - node id
			// - positive node id
			// - negative node id
			// - partition plane
			// - bevel planes

			_branchesString += node.nodeId + ",";
			_branchesString += pos? pos.nodeId : "-1";
			_branchesString += neg? neg.nodeId : "-1";

			plane = node._partitionPlane;
			_branchesString += plane._alignment + "," +
							   plane.a.toString(16) + "," + 
							   plane.b.toString(16) + "," +
							   plane.c.toString(16) + "," +
							   plane.d.toString(16) + "\n";

			if (bevels) {
				len = bevels.length;

				for (var i : int = 0; i < len; ++i) {
					plane = bevels[i];
					_branchesString += plane._alignment + "," +
								   plane.a.toString(16) + "," +
								   plane.b.toString(16) + "," +
								   plane.c.toString(16) + "," +
								   plane.d.toString(16);
					if (i < len-1) _branchesString += ",";
				}
			}
			_branchesString += "\n";
		}

		private function parseLeaf(node : BSPNode) : void
		{
			var visList : Vector.<int> = node._visList;
			var len : int;
			
			_leavesString += node.nodeId.toString() + ",";
			_leavesString += node.leafId.toString() + ",";
			_leavesString += _numMeshes + "\n";

			if (visList) {
				len = visList.length;
				for (var i : int = 0; i < len; ++i) {
					_leavesString += visList[i].toString();
					if (i < len-1) _leavesString += ",";
				}
			}
			_leavesString += "\n";

			parseMesh(node._mesh);

			// save:
			// - node id
			// - leaf id
			// - mesh (maybe we can save mesh data somewhere else, and keep leaf id?)
			// - vislist
		}

		private function parseMesh(mesh : Mesh) : void
		{
			// I guess this can be reused from original AWD
			++_numMeshes;
		}
	}
}