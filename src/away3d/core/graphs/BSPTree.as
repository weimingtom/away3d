package away3d.core.graphs
{
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.math.Number3D;
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
		
		public function BSPTree()
		{
			super();
			_rootNode = new BSPNode(null);
		}
		
		public function update(camera : Camera3D) : void
		{
			// transform camera into local coordinate system
			_transformPt.transform(camera.position, inverseSceneTransform);
			
			// figure out leaf containing that point
			// TO DO: this can be done through iteration instead of recursion 
			_activeLeaf = _rootNode.getLeafContaining(_transformPt);
			
			// process the list
			processVisList(_activeLeaf);
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
        	traverser.apply(this);
        	
        	// after apply, visList will be processed
        	// and most nodes won't need to be traversed
			_rootNode.traverse(traverser);
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
	        			// TO DO: add further frustum, while we're looping anyway
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
        
        public function init() : void
       	{
       		var l : int = _leaves.length;
       		for (var i : int = 0; i < l; ++i)
       		{
       			if (_leaves[i] && _leaves[i].mesh) addChild(_leaves[i].mesh);
       		}
       	}
	}
}