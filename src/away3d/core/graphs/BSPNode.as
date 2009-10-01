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
		private var _positiveNode : BSPNode;		// node on the positive side of the division plane
		private var _negativeNode : BSPNode;		// node on the negative side of the division plane
		
		// leaf only
		private var _mesh : Mesh;					// contains the model for this face
		arcane var _visList : Vector.<int>;		// indices of leafs visible from this leaf
		
		private var _lastIterationPositive : Boolean;
		
		//arcane var _session : AbstractRenderSession;
		
		public var extra : Object = new Object();
		
		public function BSPNode(parent : BSPNode)
		{
			_parent = parent;
		}
		
		// TO DO: pass camera
		// so we can determine the correct order for drawing
		// once there's a seperate system that doesn't do z-sorting
		public function traverse(traverser:Traverser):void
        {
			if (_isLeaf) {
				if (mesh && traverser.match(mesh))
            	{
	                traverser.enter(mesh);
	                traverser.apply(mesh);
	                traverser.leave(mesh);
            	}
	        }
	        else {
	        	// depending on last camera check, traverse the tree correctly
	        	if (_lastIterationPositive) {
					if (_negativeNode && !_negativeNode._culled) _negativeNode.traverse(traverser);
					if (_positiveNode && !_positiveNode._culled) _positiveNode.traverse(traverser);
	        	}
				else {
					if (_positiveNode && !_positiveNode._culled) _positiveNode.traverse(traverser);
					if (_negativeNode && !_negativeNode._culled) _negativeNode.traverse(traverser);
				}
	        }
        }
		
		arcane function get positiveNode() : BSPNode
		{
			return _positiveNode;
		}
		
		arcane function set positiveNode(value : BSPNode) : void
		{
			_positiveNode = value;
			//_positiveNode._session = _session;
		}
		
		arcane function get negativeNode() : BSPNode
		{
			return _negativeNode;
		}
		
		arcane function set negativeNode(value : BSPNode) : void
		{
			_negativeNode = value;
			//_negativeNode._session = _session;
		}
		
		arcane function orderNodes(point : Number3D) : void
		{
			var dot : Number = 	_partitionPlane.a*point.x +
								_partitionPlane.b*point.y +
								_partitionPlane.c*point.z +
								_partitionPlane.d
								
			if (dot > 0) _lastIterationPositive = true;	
			else _lastIterationPositive = false;
			
			if (_positiveNode && !_positiveNode._culled && !_positiveNode._isLeaf) _positiveNode.orderNodes(point);
			if (_negativeNode && !_negativeNode._culled && !_negativeNode._isLeaf) _negativeNode.orderNodes(point);
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
			if (dot > 0)
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
			
			if (!_mesh) {
				_mesh = new Mesh();
				// faster screenZ calc
				//_mesh.material = new WireframeMaterial(0x0000ff);
				//_mesh.pushfront = true;
			}
			
			if (len == 0) return;
			
			do {
				_mesh.addFace(Face(faces[i]));
				//faces[i].material = WireframeMaterial(_mesh.material);
				
			} while (++i < len);
		}
		
		arcane function addVisibleLeaf(index : int) : void
		{
			if (!_visList) _visList = new Vector.<int>();
			_visList.push(index);
		}
	}
}