package away3d.core.graphs
{
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.geom.Frustum;
	import away3d.core.geom.Plane3D;
	import away3d.core.math.MatrixAway3D;
	import away3d.core.math.Number3D;
	import away3d.core.render.BSPRenderer;
	import away3d.core.traverse.Traverser;

	use namespace arcane;

	public class BSPTree extends ObjectContainer3D
	{
		private var _transformPt : Number3D = new Number3D();
		
		// the root node in the tree
		arcane var _rootNode : BSPNode;
		
		// a list of all leafs in the tree, for fast access
		arcane var _leaves : Vector.<BSPNode>;
		
		private var _activeLeaf : BSPNode;
		
		private var _viewToLocal : MatrixAway3D = new MatrixAway3D();
		
		// debug var
		public var freezeCulling : Boolean;
		
		public function BSPTree()
		{
			super();
			_rootNode = new BSPNode(null);
		}
		
		override public function set parent(value:ObjectContainer3D):void
		{
			super.parent = value;
			ownCanvas = true;
			renderer = new BSPRenderer();
		}
		
		public function update(camera : Camera3D, frustum : Frustum) : void
		{
			var invSceneTransform : MatrixAway3D = inverseSceneTransform;
			
			// get frustum for local coordinate system
			_viewToLocal.multiply(invSceneTransform, camera.transform);
			
			// transform camera into local coordinate system
			_transformPt.transform(camera.position, invSceneTransform);
			
			// figure out leaf containing that point
			_activeLeaf = getLeafContaining(_transformPt); //_rootNode.getLeafContaining(_transformPt);
			
			if (!freezeCulling)
				doCulling(_activeLeaf, frustum);
			// order nodes for primitive traversal
			_rootNode.orderNodes(_transformPt);
		}
		
		public function getLeafContaining(point : Number3D) : BSPNode
		{
			var node : BSPNode = _rootNode;
			var dot : Number;
			var plane : Plane3D;
			do
			{
				plane = node._partitionPlane;
				dot = point.x*plane.a+point.y*plane.b+point.z*plane.c+plane.d;
				node = dot > 0? node._positiveNode : node._negativeNode;
			} while (!node._isLeaf);
			
			return node;
		}
		
		public override function traverse(traverser:Traverser):void
        {
        	// applying PrimitiveTraverser on a BSPTree
        	// will cause update(_camera) to be called
        	if (traverser.match(this)) {
        		traverser.apply(this);
        	
        		_rootNode.traverse(traverser);
        	}
        	// after apply, visList will be processed
        	// and most nodes won't need to be traversed
			
        }
        
        private function doCulling(activeNode : BSPNode, frustum : Frustum) : void
        {
        	var len : int = _leaves.length;
        	var comp : BSPNode;
        	var vislist : Vector.<int> = activeNode._visList;
        	var i : int, j : int;
        	
        	// process PVS
        	if (!vislist || vislist.length == 0) {
        		for (i = 0; i < len; ++i) {
        			if (_leaves[i]) {
        				_leaves[i]._culled = false;
        				_leaves[i]._mesh._preCullClassification = Frustum.IN;
        			}
        		}
        	} 
        	else {
	        	for (i = 0; i < len; ++i) {
	        		if (!_leaves[i]) continue;
	        		if (j < vislist.length && i == vislist[j]) {
	        			_leaves[i]._culled = false;
	        			_leaves[i]._mesh._preCullClassification = Frustum.IN;
	        			++j;
	        		}
	        		else {
	        			_leaves[i]._culled = true;
	        		}
	        	}
	        }
			activeNode._culled = false;
			
			// propagate culled state. Nodes don't need to be traversed
			// if none of the leafs contained are visible
			// this should be done using iteration instead
			_rootNode.propagateCulled();
			_rootNode.cullToFrustum(frustum);
        }
        
        arcane function init() : void
       	{
       		var l : int = _leaves.length;
       		for (var i : int = 0; i < l; ++i)
       		{
       			if (_leaves[i] && _leaves[i].mesh)
       				addChild(_leaves[i].mesh);
       		}
       		_rootNode.propagateBounds();
       	}
	}
}