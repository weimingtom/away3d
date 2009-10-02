package away3d.core.graphs
{
	import away3d.arcane;
	import away3d.core.base.Face;
	import away3d.core.base.Mesh;
	import away3d.core.geom.Frustum;
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
		arcane var _mesh : Mesh;					// contains the model for this face
		arcane var _visList : Vector.<int>;		// indices of leafs visible from this leaf
		
		private var _lastIterationPositive : Boolean;
		
		//arcane var _session : AbstractRenderSession;
		
		arcane var _bounds : Array;
		
		public var extra : Object = new Object();
		
		arcane var _minX : Number;
		arcane var _minY : Number;
		arcane var _minZ : Number;
		arcane var _maxX: Number;
		arcane var _maxY: Number;
		arcane var _maxZ: Number;
		
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
				if (_mesh && traverser.match(_mesh))
            	{
	                traverser.enter(_mesh);
	                traverser.apply(_mesh);
	                traverser.leave(_mesh);
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
		
		arcane function orderNodes(point : Number3D) : void
		{
			_lastIterationPositive = (	_partitionPlane.a*point.x +
										_partitionPlane.b*point.y +
										_partitionPlane.c*point.z +
										_partitionPlane.d ) > 0;
								
			if (_positiveNode && !(_positiveNode._culled || _positiveNode._isLeaf)) _positiveNode.orderNodes(point);
			if (_negativeNode && !(_negativeNode._culled || _negativeNode._isLeaf)) _negativeNode.orderNodes(point);
		}
		
		public function get mesh() : Mesh
		{
			return _mesh;
		}
		
		public function get bounds() : Array
		{
			return _bounds;
		}
		
		// TO DO: remove recursion, use bifurcate iteration algo
		arcane function propagateCulled() : void
		{
			if (!_positiveNode._isLeaf) _positiveNode.propagateCulled();
			if (!_negativeNode._isLeaf) _negativeNode.propagateCulled();
			_culled = _positiveNode._culled && _negativeNode._culled;
		}
		
		arcane function cullToFrustum(frustum : Frustum) : void
		{
			var classification : int = frustum.classifyAABB(_bounds);
			_culled = (classification == Frustum.OUT);
			
			if (_isLeaf) {
				if (_mesh) _mesh._preCullClassification = classification;
				return;
			}
			// nothing needs to be checked if whole bounding box completely inside
			// or outside frustum
			if (classification == Frustum.INTERSECT) {
				// only check when child nodes haven't been culled by PVS
				if (_positiveNode && !_positiveNode._culled) _positiveNode.cullToFrustum(frustum);
				if (_negativeNode && !_negativeNode._culled) _negativeNode.cullToFrustum(frustum);
				_culled = _positiveNode._culled && _negativeNode._culled;
			}
		}
		
		/**
		 * Recursive version. Kept for reference. Use BSPTree.getLeafContaining() instead
		 * 
		 * @private
		 */
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
				_mesh._preCulled = true;
				// faster screenZ calc
				_mesh.pushfront = true;
			}
			
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
		
		arcane function propagateBounds() : void
		{
			if (!_isLeaf) {
				if (_positiveNode) {
					_positiveNode.propagateBounds();
					_minX = _positiveNode._minX;
					_minY = _positiveNode._minY;
					_minZ = _positiveNode._minZ;
					_maxX = _positiveNode._maxX;
					_maxY = _positiveNode._maxY;
					_maxZ = _positiveNode._maxZ;
				}
				else {
					_minX = Number.POSITIVE_INFINITY;
					_maxX = Number.NEGATIVE_INFINITY;
					_minY = Number.POSITIVE_INFINITY;
					_maxY = Number.NEGATIVE_INFINITY;
					_minZ = Number.POSITIVE_INFINITY;
					_maxZ = Number.NEGATIVE_INFINITY;
				}
				if (_negativeNode) {
					_negativeNode.propagateBounds();
					if (_negativeNode._minX < _minX) _minX = _negativeNode._minX;
					if (_negativeNode._minY < _minY) _minY = _negativeNode._minY;
					if (_negativeNode._minZ < _minZ) _minZ = _negativeNode._minZ;
					if (_negativeNode._maxX > _maxX) _maxX = _negativeNode._maxX;
					if (_negativeNode._maxY > _maxY) _maxY = _negativeNode._maxY;
					if (_negativeNode._maxZ > _maxZ) _maxZ = _negativeNode._maxZ;
				}
			}
			else {
				if (_mesh) {
					_minX = _mesh.minX;
					_minY = _mesh.minY;
					_minZ = _mesh.minZ;
					_maxX = _mesh.maxX;
					_maxY = _mesh.maxY;
					_maxZ = _mesh.maxZ;
				}
				else {
					_minX = Number.POSITIVE_INFINITY;
					_maxX = Number.NEGATIVE_INFINITY;
					_minY = Number.POSITIVE_INFINITY;
					_maxY = Number.NEGATIVE_INFINITY;
					_minZ = Number.POSITIVE_INFINITY;
					_maxZ = Number.NEGATIVE_INFINITY;
				}
			}
			_bounds = [];
			_bounds.push(new Number3D(_minX, _minY, _minZ));
			_bounds.push(new Number3D(_maxX, _minY, _minZ));
			_bounds.push(new Number3D(_minX, _maxY, _minZ));
			_bounds.push(new Number3D(_minX, _minY, _maxZ));
			_bounds.push(new Number3D(_maxX, _maxY, _minZ));
			_bounds.push(new Number3D(_maxX, _minY, _maxZ));
			_bounds.push(new Number3D(_minX, _maxY, _maxZ));
			_bounds.push(new Number3D(_maxX, _maxY, _maxZ));
		}
	}
}