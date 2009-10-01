package away3d.core.graphs
{
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.math.Number3D;
	import away3d.core.render.BSPRenderer;
	import away3d.core.traverse.Traverser;
	import away3d.materials.WireframeMaterial;

	use namespace arcane;

	public class BSPTree extends ObjectContainer3D
	{
		private var _transformPt : Number3D = new Number3D();
		
		// the root node in the tree
		arcane var _rootNode : BSPNode;
		
		// a list of all leafs in the tree, for fast access
		arcane var _leaves : Vector.<BSPNode>;
		
		private var _activeLeaf : BSPNode;
		
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
		
		public function update(camera : Camera3D) : void
		{
			var oldLeaf : BSPNode = _activeLeaf;
			
			// transform camera into local coordinate system
			_transformPt.transform(camera.position, inverseSceneTransform);
			// figure out leaf containing that point
			// TO DO: this can be done through iteration instead of recursion
			/* if (_activeLeaf && _activeLeaf.mesh) {
				WireframeMaterial(_activeLeaf.mesh.material).color = 0x0000ff;
			} */
			_activeLeaf = _rootNode.getLeafContaining(_transformPt);
			/* if (_activeLeaf && _activeLeaf.mesh) {
				WireframeMaterial(_activeLeaf.mesh.material).color = 0xff00ff;
			} */
			
			
			if (oldLeaf != _activeLeaf) {
				processVisList(_activeLeaf);
				// order nodes for primitive traversal
				_rootNode.orderNodes(_transformPt);
			}
		}
		
		public function getLeafContaining(point : Number3D) : BSPNode
		{
			// TO DO: this can be done through iteration instead of recursion
			return _rootNode.getLeafContaining(point);
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
        
        private function processVisList(activeNode : BSPNode) : void
        {
        	var len : int = _leaves.length;
        	var comp : BSPNode;
        	var vislist : Vector.<int> = activeNode._visList;
        	var i : int, j : int;
        	
        	if (!vislist || vislist.length == 0) {
        		for (i = 0; i < len; ++i) {
        			if (_leaves[i]) _leaves[i]._culled = false;
        		}
        	} 
        	else {
	        	for (i = 0; i < len; ++i) {
	        		if (!_leaves[i]) continue;
	        		if (j < vislist.length && i == vislist[j]) {
	        			_leaves[i]._culled = false;
	        			// TO DO: add further frustum culling, while we're looping anyway
	        			// or use objectCulling?
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
			_rootNode.checkCulled();
        }
        
        arcane function init() : void
       	{
       		var l : int = _leaves.length;
       		for (var i : int = 0; i < l; ++i)
       		{
       			if (_leaves[i] && _leaves[i].mesh)
       				addChild(_leaves[i].mesh);
       		}
       	}
	}
}