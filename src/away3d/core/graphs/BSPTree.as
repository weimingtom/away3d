package away3d.core.graphs
{
	import __AS3__.vec.Vector;
	
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Face;
	import away3d.core.base.Mesh;
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
			_rootNode._buildFaces = convertFaces(faces);
			_currentBuildNode = _rootNode;
			_needBuild = true;
			buildStep();
		}
		
		
		private var _currentBuildNode : BSPNode;
		private var _state : int;
		private static const TRAVERSE_PRE : int = 0;
		private static const TRAVERSE_IN : int = 1;
		private static const TRAVERSE_POST : int = 2;
		
		public var maxTimeout : int = 500;
		
		private var _needBuild : Boolean;
		
		private function buildStep(event : Event = null) : void
		{
			if (event) {
				if (_currentBuildNode.hasEventListener(Event.COMPLETE))
					_currentBuildNode.removeEventListener(Event.COMPLETE, buildStep);
				switch(_state) {
					case TRAVERSE_PRE:
						if (_currentBuildNode._positiveNode) {
							_currentBuildNode = _currentBuildNode._positiveNode;
							_needBuild = true;
						}
						else {
							_state = TRAVERSE_IN;
							_needBuild = false;
						}
						break;
					case TRAVERSE_IN:
						if (_currentBuildNode._negativeNode) {
							_currentBuildNode = _currentBuildNode._negativeNode;
							_state = TRAVERSE_PRE;
							_needBuild = true;
						}
						else {
							_state = TRAVERSE_POST;
							_needBuild = false;
						}
						break;
					case TRAVERSE_POST:
						if (_currentBuildNode == _currentBuildNode._parent._positiveNode)
							_state = TRAVERSE_IN;
						_currentBuildNode = _currentBuildNode._parent;
						_needBuild = false;
						break;
				}
				if (_currentBuildNode == _rootNode && _state == TRAVERSE_POST) {
					onBuildComplete();
					return;
				}
			}
			
			// this times out, which means something is wrong in the iterations
			if (_needBuild) {
				_currentBuildNode.addEventListener(Event.COMPLETE, buildStep);
				_currentBuildNode.build();
			}
			else {
				buildStep(event);
			}
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
		
		private function onBuildComplete() : void
		{
			_leaves = new Vector.<BSPNode>();
			_rootNode.gatherLeaves(_leaves);
			init();
			dispatchEvent(new Event(Event.COMPLETE));
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
			orderNodes(_transformPt);
		}
		
		private function orderNodes(point : Number3D) : void
		{
			var partitionPlane : Plane3D;
			var pos : BSPNode;
			var neg : BSPNode;
			_needBuild = true;
			_state = TRAVERSE_PRE;
			_currentBuildNode = _rootNode;
			
			if (_currentBuildNode._culled) return;
			
			do {
				if (_needBuild && !_currentBuildNode._isLeaf) {
					partitionPlane = _currentBuildNode._partitionPlane;
					_currentBuildNode._lastIterationPositive = (	partitionPlane.a*point.x +
																	partitionPlane.b*point.y +
																	partitionPlane.c*point.z +
																	partitionPlane.d ) > 0;
				}
				
				pos = _currentBuildNode._positiveNode;
				neg = _currentBuildNode._negativeNode;
				
				switch(_state) {
					case TRAVERSE_PRE:
						if (pos && !pos._culled) {
							_currentBuildNode = _currentBuildNode._positiveNode;
							_needBuild = true;
							break;
						}
						else {
							_state = TRAVERSE_IN;
							//_needBuild = false;
						}
					case TRAVERSE_IN:
						if (neg && !neg._culled) {
							_currentBuildNode = _currentBuildNode._negativeNode;
							_state = TRAVERSE_PRE;
							_needBuild = true;
							break;
						}
						else {
							_state = TRAVERSE_POST;
							//_needBuild = false;
						}
						//break;
					case TRAVERSE_POST:
						if (_currentBuildNode._parent) {
							if (_currentBuildNode == _currentBuildNode._parent._positiveNode)
								_state = TRAVERSE_IN;
							_currentBuildNode = _currentBuildNode._parent;
							_needBuild = false;
						}
						break;
				}
			} while (_currentBuildNode != _rootNode || _state != TRAVERSE_POST);
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
        			doTraverse(traverser);
       				//_rootNode.traverse(traverser);
       				//if (_activeLeaf && _activeLeaf._tempMesh) _activeLeaf._tempMesh.traverse(traverser);
        		}
        	}
        }
        
        private function doTraverse(traverser:Traverser) : void
        {
        	var mesh : Mesh;
        	var first : BSPNode;
        	var second : BSPNode;
        	var isLeaf : Boolean;
        	var changed : Boolean = true;
			_state = TRAVERSE_PRE;
			_currentBuildNode = _rootNode;
        	
        	if (_currentBuildNode._culled) return;
        	
        	do {
        		if (changed) {
        			isLeaf = _currentBuildNode._isLeaf
					if (isLeaf) {
						mesh = _currentBuildNode._mesh;
						if (mesh && traverser.match(mesh))
	            		{
		                	traverser.enter(mesh);
		                	traverser.apply(mesh);
		                	traverser.leave(mesh);
	            		}
	            		_state = TRAVERSE_POST;
					}
					else {
						if (_currentBuildNode._lastIterationPositive) {
							first = _currentBuildNode._negativeNode;
							second = _currentBuildNode._positiveNode;
						}
						else {
							first = _currentBuildNode._positiveNode;
							second = _currentBuildNode._negativeNode;
						}
					}
        		}
        		
				switch(_state) {
					case TRAVERSE_PRE:
						if (first && !first._culled) {
							_currentBuildNode = first;
							changed = true;
						}
						else {
							_state = TRAVERSE_IN;
							changed = false;
						}
						break;
					case TRAVERSE_IN:
						if (second && !second._culled) {
							_currentBuildNode = second;
							_state = TRAVERSE_PRE;
							changed = true;
						}
						else {
							_state = TRAVERSE_POST;
							changed = false;
						}
						break;
					case TRAVERSE_POST:
						if ((_currentBuildNode._parent._lastIterationPositive && _currentBuildNode == _currentBuildNode._parent._negativeNode) ||
							(!_currentBuildNode._parent._lastIterationPositive && _currentBuildNode == _currentBuildNode._parent._positiveNode))
							_state = TRAVERSE_IN;
						_currentBuildNode = _currentBuildNode._parent;
						changed = true;
						break;
				}
			} while (_currentBuildNode != _rootNode || _state != TRAVERSE_POST);
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
			propagateCulled();
			cullToFrustum(frustum);
        }
        
        private function propagateCulled() : void
        {
        	var partitionPlane : Plane3D;
			var pos : BSPNode;
			var neg : BSPNode;
			_state = TRAVERSE_PRE;
			_currentBuildNode = _rootNode;
			
			if (_currentBuildNode._culled) return;
			
			do {
				pos = _currentBuildNode._positiveNode;
				neg = _currentBuildNode._negativeNode;
				
				switch(_state) {
					case TRAVERSE_PRE:
						if (pos && !pos._isLeaf) {
							_currentBuildNode = pos;
						}
						else {
							_state = TRAVERSE_IN;
						}
						break;
					case TRAVERSE_IN:
						if (neg && !neg._isLeaf) {
							_currentBuildNode = neg;
							_state = TRAVERSE_PRE;
						}
						else {
							_state = TRAVERSE_POST;
						}
						break;
					case TRAVERSE_POST:
						if (_currentBuildNode._parent) {
							if (_currentBuildNode == _currentBuildNode._parent._positiveNode)
								_state = TRAVERSE_IN;
							_currentBuildNode = _currentBuildNode._parent;
						}
						break;
				}

				if (_state == TRAVERSE_POST && !_currentBuildNode._isLeaf) {
					pos = _currentBuildNode._positiveNode;
					neg = _currentBuildNode._negativeNode;
					_currentBuildNode._culled = (!pos || pos._culled) && (!neg || neg._culled);
				}
				
			} while (_currentBuildNode != _rootNode || _state != TRAVERSE_POST);
        }
        
        private function cullToFrustum(frustum : Frustum) : void
        {
        	var partitionPlane : Plane3D;
			var pos : BSPNode;
			var neg : BSPNode;
			var classification : int;
			var needCheck : Boolean = true;
			
			_state = TRAVERSE_PRE;
			_currentBuildNode = _rootNode;
			
			if (_currentBuildNode._culled) return;
			
			do {
				if (needCheck) {
					classification = frustum.classifyAABB(_currentBuildNode._bounds);
					_currentBuildNode._culled = (classification == Frustum.OUT);
					
					if (_currentBuildNode._isLeaf) {
						if (_currentBuildNode._mesh) _currentBuildNode._mesh._preCullClassification = classification;
						_state = TRAVERSE_POST;
					}
					// no further descension is needed if whole bounding box completely inside or outside frustum
					else if (classification != Frustum.INTERSECT)
						_state = TRAVERSE_POST;
				}
				
				pos = _currentBuildNode._positiveNode;
				neg = _currentBuildNode._negativeNode;
				
				switch(_state) {
					case TRAVERSE_PRE:
						if (pos && !pos._culled) {
							_currentBuildNode = pos;
							needCheck = true;
						}
						else {
							_state = TRAVERSE_IN;
							needCheck = false;
						}
						break;
					case TRAVERSE_IN:
						if (neg && !neg._culled) {
							_currentBuildNode = neg;
							_state = TRAVERSE_PRE;
							needCheck = true;
						}
						else {
							_state = TRAVERSE_POST;
							needCheck = false;
						}
						break;
					case TRAVERSE_POST:
						if (_currentBuildNode._parent) {
							if (_currentBuildNode == _currentBuildNode._parent._positiveNode)
								_state = TRAVERSE_IN;
							_currentBuildNode = _currentBuildNode._parent;
						}
						needCheck = false;
						break;
				}
				
				/* if (_state == TRAVERSE_POST && !_currentBuildNode._isLeaf) {
					pos = _currentBuildNode._positiveNode;
					neg = _currentBuildNode._negativeNode;
					_currentBuildNode._culled = (!pos || pos._culled) && (!neg || neg._culled);
				} */
			} while (_currentBuildNode != _rootNode || _state != TRAVERSE_POST);
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