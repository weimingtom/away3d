package away3d.core.graphs
{
	import __AS3__.vec.Vector;
	
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Face;
	import away3d.core.geom.Frustum;
	import away3d.core.geom.NGon;
	import away3d.core.geom.Plane3D;
	import away3d.core.math.MatrixAway3D;
	import away3d.core.math.Number3D;
	import away3d.core.render.BSPRenderer;
	import away3d.core.traverse.Traverser;
	
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	use namespace arcane;
	
	/**
	 * BSPTree is a scene graph structure that allows static scenes to be rendered without z-sorting or z-conflicts,
	 * and performs early culling to remove big parts of the geometry that don't need to be rendered. It also speeds up collision detection.
	 */
	public class BSPTree extends ObjectContainer3D
	{
		private var _transformPt : Number3D = new Number3D();
		
		// the root node in the tree
		arcane var _rootNode : BSPNode;
		
		// a list of all leafs in the tree, for fast access
		arcane var _leaves : Vector.<BSPNode>;
		
		private var _activeLeaf : BSPNode;
		
		private var _viewToLocal : MatrixAway3D = new MatrixAway3D();
		
		private var _complete : Boolean;
		
		// debug var
		public var freezeCulling : Boolean;
		
		/**
		 * Creates a new BSPTree object.
		 */
		public function BSPTree()
		{
			super();
			_rootNode = new BSPNode(null);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set parent(value:ObjectContainer3D):void
		{
			super.parent = value;
			ownCanvas = true;
			renderer = new BSPRenderer();
		}
		
		/**
		 * Finds the leaf that contains a given point
		 */
		public function getLeafContaining(point : Number3D) : BSPNode
		{
			var node : BSPNode = _rootNode;
			var dot : Number;
			var plane : Plane3D;
			
			while (!node._isLeaf)
			{
				plane = node._partitionPlane;
				dot = point.x*plane.a+point.y*plane.b+point.z*plane.c+plane.d;
				node = dot > 0? node._positiveNode : node._negativeNode;
			} 
			
			return node;
		}
		
		/**
		 * Build a BSP tree from the current faces.
		 * 
		 * @param faces A list of Face objects from which to build the tree.
		 */
		public function build(faces : Vector.<Face>) : void
		{
			var polys : Vector.<NGon> = convertFaces(faces);
			
			_rootNode.addEventListener(Event.COMPLETE, onBuildComplete);
			_rootNode.build(polys);
		}
		
		/**
		 * converts faces to N-Gons
		 */
		private function convertFaces(faces : Vector.<Face>) : Vector.<NGon>
		{
			var polys : Vector.<NGon> = new Vector.<NGon>();
			var ngon : NGon;
			var len : int = faces.length;
			var i : int;
			
			do {
				ngon = new NGon();
				ngon.fromTriangle(faces[i]);
				polys[i] = ngon;
			} while (++i < len);
			return polys;
		}
		
		private function onBuildComplete(event : Event) : void
		{
			_rootNode.removeEventListener(Event.COMPLETE, onBuildComplete);
			_leaves = new Vector.<BSPNode>();
			_rootNode.gatherLeaves(_leaves);
			init();
			//createPVS();
		}
		
		private function createPVS() : void
		{
			var portals : Vector.<BSPPortal> = new Vector.<BSPPortal>();
			_rootNode.findPortals(portals);
			_splitPortals = new Vector.<BSPPortal>();
			setTimeout(splitPortals, 1, portals);
		}
		
		private var _portalIndex : int;
		private var _maxTimeout : int = 500;
		private var _splitPortals : Vector.<BSPPortal>;
		
		private function splitPortals(portals : Vector.<BSPPortal>) : void
		{
			var startTime : int = getTimer();
			var len : int = portals.length;
			do
			{
				_splitPortals = _splitPortals.concat(_rootNode.splitPortal(portals[_portalIndex]));
			} while (++_portalIndex < len && getTimer()-startTime < _maxTimeout);
			
			if (_portalIndex == portals.length) {
				_portalIndex = 0;
				setTimeout(assignPortals, 1); 
			}
			else {
				setTimeout(splitPortals, 1, portals);
			}
		}
		
		private function assignPortals() : void
		{
			var startTime : int = getTimer();
			var len : int = _splitPortals.length;
			//if (len == 0) return;
			do
			{
				_rootNode.assignPortal(_splitPortals[_portalIndex]);
			} while (++_portalIndex < len && getTimer()-startTime < _maxTimeout);
			
			if (_portalIndex < len) {
				setTimeout(assignPortals, 1);
			}
			else {
				setTimeout(linkPortals, 1);
			}
		}
		
		private function linkPortals() : void
		{
			for (var i : int = 0; i < _leaves.length; ++i) {
				if (_leaves[i]) {
					_leaves[i].linkPortals();
					if (_leaves[i]._tempMesh) addChild(_leaves[i]._tempMesh);
				}
			}
		}
		
		/**
		 * Updates the tree's state. This method is called before the first traversal.
		 * Performs early culling and ordering of nodes.
		 * 
		 * @private
		 */
		arcane function update(camera : Camera3D, frustum : Frustum) : void
		{
			if (!(camera.lens is PerspectiveLens)) {
				throw new Error("Lens is of incorrect type! BSP needs a PerspectiveLens instance assigned to Camera3D.lens");
			}
			
			if (!_complete) return;
			
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
		
		/**
		 * @inheritDoc
		 */
		public override function traverse(traverser:Traverser):void
        {
        	// matching PrimitiveTraverser on a BSPTree
        	// will cause update(_camera) to be called
        	if (traverser.match(this)) {
        		// after apply, visList will be processed
        		// and most nodes won't need to be traversed
        		if (_complete && !_rootNode._culled) {
        			traverser.apply(this);
       				_rootNode.traverse(traverser);
       				if (_activeLeaf && _activeLeaf._tempMesh) _activeLeaf._tempMesh.traverse(traverser);
        		}
        	}
        }
        
		/**
		 * Finds the closest colliding Face between start and end position
		 * 
		 * @param start The starting position of the object (ie the object's current position)
		 * @param end The position the object is trying to reach
		 * @param radii The radii of the object's bounding eclipse
		 * 
		 * @return The closest Face colliding with the object. Null if no collision was found.
		 */
        public function traceCollision(start : Number3D, end : Number3D, radii : Number3D) : Face
        {
        	return _rootNode.traceCollision(start, end, radii);
        }

		/**
		 * Performs early culling by processing the PVS and/or testing nodes against the frustum
		 */ 
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
        				if (_leaves[i]._mesh) {
        					_leaves[i]._culled = false;
        					_leaves[i]._mesh._preCullClassification = Frustum.IN;
        				}
        				else
        					_leaves[i]._culled = true;
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
			
			// propagate culled state. Nodes don't need to be traversed if none of the leafs contained are visible
			// TO DO: this should be done using iteration instead
			_rootNode.propagateCulled();
			_rootNode.cullToFrustum(frustum);
        }
        
		/**
		 * Finalizes the tree. Must be called by build() or by custom parser
		 * 
		 * @private
		 */
        arcane function init() : void
       	{
       		var l : int = _leaves.length;
       		for (var i : int = 0; i < l; ++i)
       		{
       			if (_leaves[i] && _leaves[i].mesh)
       				addChild(_leaves[i].mesh);
       		}
       		_rootNode.propagateBounds();
       		_complete = true;
       	}
	}
}