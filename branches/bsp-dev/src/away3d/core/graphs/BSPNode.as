package away3d.core.graphs
{
	import away3d.arcane;
	import away3d.core.base.Face;
	import away3d.core.base.Mesh;
	import away3d.core.geom.Plane3D;
	import away3d.core.math.Number3D;
	import away3d.core.traverse.Traverser;
	
	use namespace arcane;
	
	public class BSPNode
	{
		public var id : int;
		// indicates whether this node is a leaf or not
		// leaves contain triangles
		arcane var _isLeaf : Boolean;
		
		// flag used when processing vislist
		arcane var _culled : Boolean;
		
		// a reference to the parent node
		arcane var _parent : BSPNode;
		
		// non-leaf only
		arcane var _partitionPlane : Plane3D;		// the plane that divides the node in half
		arcane var _positiveNode : BSPNode;		// node on the positive side of the division plane
		arcane var _negativeNode : BSPNode;		// node on the negative side of the division plane
		
		// leaf only
		private var _mesh : Mesh;					// contains the model for this face
		arcane var _visList : Vector.<int>;		// indices of leafs visible from this leaf
		
		private var _lastIterationPositive : Boolean;
		
		public function BSPNode(parent : BSPNode)
		{
			_parent = parent;
		}
		
		// TO DO: pass camera
		// so we can determine the correct order for drawing
		// once there's a seperate system that doesn't do z-sorting
		public function traverse(traverser:Traverser):void
        {
        	if (_culled) return;
			if (_isLeaf) {
				if (mesh && traverser.match(mesh))
            	{
            		// this will cause mesh to be added to the normal render pipeline
            		// TO DO: add seperate state to handle BSPNode and pass (this)
            		// instead of mesh, so it can add it to a seperate projector
            		// which won't end up doing z-sorting?
	                traverser.enter(mesh);
	                traverser.apply(mesh);
	                traverser.leave(mesh);
            	}
	        }
	        else {
	        	// depending on last camera check, traverse the tree correctly
	        	if (_lastIterationPositive) {
					if (_negativeNode) _negativeNode.traverse(traverser);
					if (_positiveNode) _positiveNode.traverse(traverser);
	        	}
				else {
					if (_positiveNode) _positiveNode.traverse(traverser);
					if (_negativeNode) _negativeNode.traverse(traverser);
				}
	        }
        }
		
		public function get mesh() : Mesh
		{
			return _mesh;
		}
		
		// TO DO: remove recursion, use bifurcate iteration algo
		public function checkCulled() : void
		{
			if (!_positiveNode._isLeaf) _positiveNode.checkCulled();
			if (!_negativeNode._isLeaf) _negativeNode.checkCulled();
			_culled = _positiveNode._culled && _negativeNode._culled;
		}
		
		public function getLeafContaining(point : Number3D) : BSPNode
		{
			if (_isLeaf) return this;
			
			var dot : Number = 	_partitionPlane.a*point.x +
								_partitionPlane.b*point.y +
								_partitionPlane.c*point.z +
								_partitionPlane.d;
			
			// used to make iterations faster when doing camera and object tests
			_lastIterationPositive = dot > 0;
			
			if (_lastIterationPositive)
				// point is on positive side of partition plane
				return _positiveNode.getLeafContaining(point);
			else
				// point is on negative side of partition plane
				return _negativeNode.getLeafContaining(point);
		}
		
		arcane function addFaces(faces : Vector.<Face>) : void
		{
			var len : int = faces.length;
			var i : int;
			
			if (!_mesh) _mesh = new Mesh();
			
			if (len == 0) return;
			
			do {
				_mesh.addFace(Face(faces[i]));
			} while (++i < len);
		}
		
		arcane function addVisibleLeaf(index : int) : void
		{
			if (!_visList) _visList = new Vector.<int>();
			_visList.push(index);
		}		
	}
}