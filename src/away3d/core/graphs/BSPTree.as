package away3d.core.graphs
{
	import away3d.core.base.Object3D;
	import flash.utils.Dictionary;
	import away3d.core.utils.CameraVarsStore;
	import away3d.core.traverse.ProjectionTraverser;
	import away3d.core.traverse.PrimitiveTraverser;
	import away3d.events.TraceEvent;
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Face;
	import away3d.core.base.Mesh;
	import away3d.core.base.Vertex;
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
	 * and performs early culling to remove big parts of the geometry that don't need to be rendered. It also speeds up various tasks such as
	 * collision detection.
	 */
	public class BSPTree extends ObjectContainer3D
	{
		public static const TEST_METHOD_POINT : int = 0;
		public static const TEST_METHOD_AABB : int = 1;
		public static const TEST_METHOD_ELLIPSOID : int = 2;
		public static const EPSILON : Number = 0.07;
		public static const COLLISION_EPSILON : Number = 0.1;
		
		// the root node in the tree
		arcane var _rootNode : BSPNode;
		
		// a list of all leafs in the tree, for fast access
		arcane var _leaves : Vector.<BSPNode>;
		
		// the leaf which currently contains the camera
		private var _activeLeaf : BSPNode;
		
		private var _transformPt : Number3D = new Number3D();
		private var _viewToLocal : MatrixAway3D = new MatrixAway3D();
		
		// debug vars, temporary
		public var freezeCulling : Boolean;
		public var showPortals : Boolean;
		
		// used for correct rendering and pre-culling
		private var _cameraVarsStore : CameraVarsStore;
		private var _dynamics : Vector.<Object3D>;
		
		private var _renderMark : int;
		
		/**
		 * Creates a new BSPTree object.
		 */
		public function BSPTree()
		{
			super();
			_dynamics = new Vector.<Object3D>();
			_preCulled = true;
			_rootNode = new BSPNode(null);
			_rootNode._maxTimeOut = maxTimeout;
		}
		
		/**
		 * The leaf containing the camera. Returns null if the camera is in "solid" space.
		 */
		public function get activeLeaf() : BSPNode
		{
			return _activeLeaf;
		}

		/**
		 * @inheritDoc
		 * Ensure correct renderer is set when it's added
		 */
		override public function set parent(value:ObjectContainer3D):void
		{
			super.parent = value;
			ownCanvas = true;
			renderer = new BSPRenderer();
		}
		
		/**
		 * Finds the leaf that contains a given point
		 * 
		 * @param point The point to be traced. The point is expressed in local space.
		 * @param quitOnCulled Indicates whether leaf finding should stop when a culled node is encountered.
		 * @return The leaf containing the point
		 */
		public function getLeafContaining(point : Number3D, quitOnCulled : Boolean = false) : BSPNode
		{
			var node : BSPNode = _rootNode;
			var dot : Number;
			var plane : Plane3D;
			
			while (node && !node._isLeaf)
			{
				if (quitOnCulled && node._culled) return null;
				plane = node._partitionPlane;
				dot = point.x*plane.a+point.y*plane.b+point.z*plane.c;
				node = dot > -plane.d? node._positiveNode : node._negativeNode;
			} 
			
			return node;
		}
		
		/**
		 * Updates the tree's state. This method is called before the first traversal.
		 * Performs early culling and ordering of nodes.
		 * 
		 * @private
		 */
		arcane function update(camera : Camera3D, frustum : Frustum, cameraVarsStore : CameraVarsStore) : void
		{
			if (!(camera.lens is PerspectiveLens))
				throw new Error("Lens is of incorrect type! BSP needs a PerspectiveLens instance assigned to Camera3D.lens");
			
			if (!_complete) return;
			
			var invSceneTransform : MatrixAway3D = inverseSceneTransform;
			
			// get frustum for local coordinate system
			_viewToLocal.multiply(invSceneTransform, camera.transform);
			
			// transform camera into local coordinate system
			_transformPt.transform(camera.position, invSceneTransform);
			
			// figure out leaf containing the point
			_activeLeaf = getLeafContaining(_transformPt);
			
			if (!freezeCulling)
				doCulling(_activeLeaf, frustum);
			
			++_renderMark;
			
			// order nodes for primitive traversal
			//orderNodes(_transformPt);
			assignDynamics();
			
			_cameraVarsStore = cameraVarsStore;
		}
		
		/**
		 * Places dynamic objects (those not part of the bsp structure) into their respective leaves
		 */
		private function assignDynamics() : void
		{
			var i : int = _dynamics.length;
			var child : Object3D;
			var pos : Number3D = new Number3D();
			var leaf : BSPNode;
			var mark : int;
			
			while (--i >= 0) {
				child = _dynamics[i];
				
				// center position of child object
				pos.transform(child.scenePosition, inverseSceneTransform);
				leaf = getLeafContaining(pos, true);
				
				mark = child._sceneGraphMark;
				if (leaf && mark != leaf.leafId) {
					if (mark >= 0) _leaves[mark].removeChild(child);
					leaf.addChild(child);
				}
				else if (!leaf) {
					child._sceneGraphMark = -1;
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function addChild(child : Object3D) : void
		{
			super.addChild(child);
			_dynamics.push(child);
			child._sceneGraphMark = -1;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function removeChild(child : Object3D)  :void
		{
			var index : int = _dynamics.indexOf(child);
			if (index >= 0) _dynamics.splice(index, 1);
			child._sceneGraphMark = -1;
		}

		/**
		 * @inheritDoc
		 */
		public override function traverse(traverser:Traverser):void
        {
        	// act normal
        	if (!(traverser is ProjectionTraverser || traverser is PrimitiveTraverser)) {
        		super.traverse(traverser);
        		return;
        	}
        	
        	// matching PrimitiveTraverser on a BSPTree
        	// will cause update(_camera) to be called
        	if (_complete && traverser.match(this)) {
        		// after apply, visList will be processed
        		// and most nodes won't need to be traversed
       			traverser.enter(this);
       			traverser.apply(this);
       			// send down for geom
       			doTraverse(traverser);
       			traverser.leave(this);
        	}
	        
        }
        
        /**
         * Moves a Traverser object through the tree in the correct order to preserve z-sorting
         */
        private function doTraverse(traverser:Traverser) : void
        {
        	var mesh : Mesh;
        	var first : BSPNode;
        	var second : BSPNode;
        	var isLeaf : Boolean;
        	var changed : Boolean = true;
        	var loopNode : BSPNode = _rootNode;
			var dictionary : Dictionary = _cameraVarsStore.frustumDictionary;
			var frustum : Frustum = dictionary[this];
			var dynamics : Array;
			var hasDynamics : Boolean;
			var partitionPlane : Plane3D;
			
			_state = TRAVERSE_PRE;
        	
        	if (loopNode._culled) return;
        	
        	do {
        		if (changed) {
        			isLeaf = loopNode._isLeaf;
        			
        			if (isLeaf) {
						mesh = loopNode._mesh;
						dictionary[mesh] = frustum;
						
						dynamics = loopNode._children;
						hasDynamics = (dynamics != null) && dynamics.length > 0;
	            		
						if (traverser.match(mesh))
	            		{
		                	traverser.enter(mesh);
		                	traverser.apply(mesh);
		                	traverser.leave(mesh);
	            		}
	            		
						if (hasDynamics) {
	            			loopNode.traverseChildren(traverser);
						}
	            		
	            		// temp
						if (	showPortals && loopNode &&
	       						loopNode._tempMesh && 
	       						loopNode._tempMesh.extra && 
	       						loopNode._tempMesh.extra.created
	       					) loopNode._tempMesh.traverse(traverser);
	            		_state = TRAVERSE_POST;
					}
					else {
						if (loopNode.renderMark != _renderMark) {
	        				partitionPlane = loopNode._partitionPlane;
						
							if (partitionPlane._alignment == Plane3D.X_AXIS)
								loopNode._lastIterationPositive = partitionPlane.a*_transformPt.x > -partitionPlane.d;
							else if (partitionPlane._alignment == Plane3D.Y_AXIS)
								loopNode._lastIterationPositive = partitionPlane.b*_transformPt.y > -partitionPlane.d;
							else if (partitionPlane._alignment == Plane3D.Z_AXIS)
								loopNode._lastIterationPositive = partitionPlane.c*_transformPt.z > -partitionPlane.d;
							else
								loopNode._lastIterationPositive = 	partitionPlane.a*_transformPt.x +
																	partitionPlane.b*_transformPt.y +
																	partitionPlane.c*_transformPt.z
																	 > -partitionPlane.d;
	        			}
						if (loopNode._lastIterationPositive) {
							first = loopNode._negativeNode;
							second = loopNode._positiveNode;
						}
						else {
							first = loopNode._positiveNode;
							second = loopNode._negativeNode;
						}
					}
        		}
        		
				if (_state == TRAVERSE_PRE) {
						if (first && !first._culled) {
							loopNode = first;
							changed = true;
						}
						else {
							_state = TRAVERSE_IN;
							changed = false;
						}
				}
				else if(_state == TRAVERSE_IN) {
					if (second && !second._culled) {
						loopNode = second;
						_state = TRAVERSE_PRE;
						changed = true;
					}
					else {
						_state = TRAVERSE_POST;
						changed = false;
					}
				}
				else if (_state == TRAVERSE_POST) {
					if ((loopNode._parent._lastIterationPositive && loopNode == loopNode._parent._negativeNode) ||
						(!loopNode._parent._lastIterationPositive && loopNode == loopNode._parent._positiveNode))
						_state = TRAVERSE_IN;
					loopNode = loopNode._parent;
					changed = true;
				}
			} while (loopNode != _rootNode || _state != TRAVERSE_POST);
        }
        
		/**
		 * Performs early culling by processing the PVS and/or testing nodes against the frustum
		 */ 
        private function doCulling(activeNode : BSPNode, frustum : Frustum) : void
        {
        	var len : int = _leaves.length;
        	var vislist : Vector.<int> = activeNode? activeNode._visList : null;
        	var i : int, j : int;
        	var leaf : BSPNode;
        	var vislen : int = vislist? vislist.length : 0;
        	
        	_rootNode._culled = false;
        	
        	// process PVS
        	if (vislen == 0) {
        		for (i = 0; i < len; ++i)
   					_leaves[i]._culled = false;
        	}
        	else {
	        	for (i = 0; i < len; ++i) {
	        		if (j < vislen && i == vislist[j]) {
	        			leaf = _leaves[i];
	        			leaf._culled = false;
	        			leaf._mesh._preCullClassification = Frustum.IN;
	        			++j;
	        		}
	        		else {
	        			leaf = _leaves[i];
	        			leaf._culled = true;
	        		}
	        	}
	        }
	        if (activeNode) activeNode._culled = false;
			
			propagateCulled();
			cullToFrustum(frustum);
        }
        
        /**
         * Bubbles up culled state to limit deep traversal
         */
        private function propagateCulled() : void
        {
			var pos : BSPNode;
			var neg : BSPNode;
			var loopNode : BSPNode = _rootNode;
			_state = TRAVERSE_PRE;
			
			if (loopNode._culled) return;
			
			do {
				pos = loopNode._positiveNode;
				neg = loopNode._negativeNode;
				
				if (_state == TRAVERSE_PRE) {
					if (pos && !pos._isLeaf) {
						loopNode = pos;
					}
					else {
						_state = TRAVERSE_IN;
					}
				}
				else if (_state == TRAVERSE_IN) {
					if (neg && !neg._isLeaf) {
						loopNode = neg;
						_state = TRAVERSE_PRE;
					}
					else {
						_state = TRAVERSE_POST;
					}
				}
				else if (_state == TRAVERSE_POST) {
					if (loopNode._parent) {
						if (loopNode == loopNode._parent._positiveNode)
							_state = TRAVERSE_IN;
						loopNode = loopNode._parent;
					}
				}

				if (_state == TRAVERSE_POST && !loopNode._isLeaf) {
					pos = loopNode._positiveNode;
					neg = loopNode._negativeNode;
					loopNode._culled = (!pos || pos._culled) && (!neg || neg._culled);
				}
				
			} while (loopNode != _rootNode || _state != TRAVERSE_POST);
        }
        
        /**
         * Iterates the tree and tests nodes against the frustum
         */
        private function cullToFrustum(frustum : Frustum) : void
        {
			var pos : BSPNode;
			var neg : BSPNode;
			var classification : int;
			var needCheck : Boolean = true;
			var loopNode : BSPNode = _rootNode;
			
			_state = TRAVERSE_PRE;
			
			if (loopNode._culled) return;
			
			do {
				if (needCheck) {
					classification = frustum.classifyAABB(loopNode._bounds);
					loopNode._culled = (classification == Frustum.OUT);
					
        			if (loopNode._isLeaf) {
						loopNode._mesh._preCullClassification = classification;
//						if (!classification) loopNode._mesh.updateObject();
						_state = TRAVERSE_POST;
					}
					// no further descension is needed if whole bounding box completely inside or outside frustum
					else if (classification != Frustum.INTERSECT)
						_state = TRAVERSE_POST;
				}
				
				pos = loopNode._positiveNode;
				neg = loopNode._negativeNode;
				
				if(_state == TRAVERSE_PRE) {
					if (pos && !pos._culled) {
						loopNode = pos;
						needCheck = true;
					}
					else {
						_state = TRAVERSE_IN;
						needCheck = false;
					}
				}
				else if (_state == TRAVERSE_IN) {
					if (neg && !neg._culled) {
						loopNode = neg;
						_state = TRAVERSE_PRE;
						needCheck = true;
					}
					else {
						_state = TRAVERSE_POST;
						needCheck = false;
					}
				}
				else if (_state == TRAVERSE_POST) {
					if (loopNode._parent) {
						if (loopNode == loopNode._parent._positiveNode)
							_state = TRAVERSE_IN;
						loopNode = loopNode._parent;
					}
					needCheck = false;
				}
			} while (loopNode != _rootNode || _state != TRAVERSE_POST);
			
			_preCullClassification = Frustum.INTERSECT;
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
       				super.addChild(_leaves[i].mesh);
       		}
       		_rootNode.propagateBounds();
			_maxX = _rootNode._maxX;
			_maxY = _rootNode._maxY;
			_maxZ = _rootNode._maxZ;
			_minX = _rootNode._minX;
			_minY = _rootNode._minY;
			_minZ = _rootNode._minZ;
			_dimensionsDirty = true;
			_complete = true;
       	}
       	
       	private var _collisionDir : Number3D = new Number3D();
       	
       	/**
		 * Finds the closest colliding Face between start and end position
		 * 
		 * @param start The starting position of the object (ie the object's current position)
		 * @param end The position the object is trying to reach
		 * @param radii The radii of the object's bounding eclipse
		 * 
		 * @return The closest Face colliding with the object. Null if no collision was found.
		 */
        public function traceCollision(start : Number3D, end : Number3D, testMethod : int = TEST_METHOD_POINT, halfExtents : Number3D = null) : Plane3D
        {
        	_collisionDir.x = end.x-start.x;
			_collisionDir.y = end.y-start.y;
			_collisionDir.z = end.z-start.z;
        	
        	if (testMethod == TEST_METHOD_POINT) {
        		return findCollision(start, _collisionDir, testMethod);
        	}
        	else {
	       		return findCollision(start, _collisionDir, testMethod, halfExtents);
        	}
        }
        
        private var _planeStack : Vector.<Plane3D> = new Vector.<Plane3D>();
        private var _tMaxStack : Vector.<Number> = new Vector.<Number>();
        private var _tMinStack : Vector.<Number> = new Vector.<Number>();
        private var _nodeStack : Vector.<BSPNode> = new Vector.<BSPNode>();
        
 		private function findCollision(start : Number3D, dir : Number3D, testMethod : int, halfExtents : Number3D = null) : Plane3D
        {
        	var plane : Plane3D;
        	var node : BSPNode = _rootNode;
        	var dirDot : Number;
        	var dist : Number;
        	var t : Number;
        	var align : int;
        	var a : Number, b : Number, c : Number, d : Number;
        	var first : BSPNode, second : BSPNode;
        	var tMax : Number = 1, tMin : Number = 0;
        	var stackLen : int;
        	var splitPlane : Plane3D;
        	var offset : Number = 0;
        	var ox : Number, oy : Number, oz : Number;
        	var queue : Boolean;
        	var oldMax : Number;
        	
        	_planeStack.length = 0;
			_tMaxStack.length = 0;
			_nodeStack.length = 0;
        	
        	while (true) {
        		// in a solid leaf, collision
				if (!node)
					return splitPlane;
				
        		// "empty" leaf
        		if (!node || node._isLeaf) {
        			if (stackLen == 0) return null;
					--stackLen;
					node = _nodeStack[stackLen];
					tMin = _tMinStack[stackLen];
					tMax = _tMaxStack[stackLen];
					splitPlane = _planeStack[stackLen];
				}
				else {
					plane = node._partitionPlane;
	        		align = plane._alignment;
					d = plane.d;
	        		if (align == Plane3D.X_AXIS) {
						a = plane.a;
						dirDot = a*dir.x;
						dist = a*start.x + d;
						if (testMethod != TEST_METHOD_POINT)
							offset = halfExtents.x;
					}
					else if (align == Plane3D.Y_AXIS) {
						b = plane.b;
						dirDot = b*dir.y;
						dist = b*start.y + d;
						if (testMethod != TEST_METHOD_POINT)
							offset = halfExtents.y;
					}
					else if (align == Plane3D.Z_AXIS) {
						c = plane.c;
						dirDot = c*dir.z;
						dist = c*start.z + d;
						if (testMethod != TEST_METHOD_POINT)
							offset = halfExtents.z;
					}
					else {
						a = plane.a;
						b = plane.b;
						c = plane.c;
						dirDot = a*dir.x + b*dir.y + c*dir.z;
						dist = a*start.x + b*start.y + c*start.z + d;
						if (testMethod == TEST_METHOD_AABB)
							offset = 	(a > 0? a*halfExtents.x : -a*halfExtents.x) +
										(b > 0? b*halfExtents.y : -b*halfExtents.y) +
										(c > 0? c*halfExtents.z : -c*halfExtents.z);
						else if (testMethod == TEST_METHOD_ELLIPSOID) {
							ox = a*halfExtents.x;
							oy = b*halfExtents.y;
							oz = c*halfExtents.z;
							offset = Math.sqrt(ox*ox + oy*oy + oz*oz);
						}
					}
					dist -= offset;
					// there has to be a way to use offset/dirDot to use bounds
					if (dirDot != 0) {
						if (dirDot < 0) {
							first = node._positiveNode;
							second = node._negativeNode;
						}
						else {
							first = node._negativeNode;
							second= node._positiveNode;
						}
						// plane is between start point and segment end
						t = -dist/dirDot;
						
						if (testMethod != BSPTree.TEST_METHOD_POINT)
							offset /= dirDot > 0 ? dirDot : -dirDot;
						
						oldMax = tMax;
						
						// shift plane up
						if (t >= tMin) {
							if (t < tMax) tMax = t;
							queue = true;
						}
						else queue = false;
						
						// shift plane down
						if (t <= oldMax) {
							if (queue) {
								// splitting segment
								_nodeStack[stackLen] = second;
								_tMinStack[stackLen] = t > tMin ? t : tMin;
								_tMaxStack[stackLen] = oldMax;
								_planeStack[stackLen] = plane;
								++stackLen;
							}
							else {
								first = second;
							}
						}
						node = first;
					}
					else {
						if (dist > offset) node = node._positiveNode;
						else if (dist < -offset) node = node._negativeNode;
						else if (dist < 0){
							_nodeStack[stackLen] = node._positiveNode;
							_tMinStack[stackLen] = tMin;
							_tMaxStack[stackLen] = tMax;
							_planeStack[stackLen] = plane;
							node = node._negativeNode;
						}
						else {
							_nodeStack[stackLen] = node._negativeNode;
							_tMinStack[stackLen] = tMin;
							_tMaxStack[stackLen] = tMax;
							_planeStack[stackLen] = plane;
							node = node._positiveNode;
						}
					}
					
				}
			}
        	
        	return plane;
		}

/**
 * BUILDING
 */
 		// bsp build
		arcane static var nodeCount : int;
		private var _buildPVS : Boolean;
		private var _complete : Boolean;
		private var _progressEvent : TraceEvent;
		private var _currentBuildNode : BSPNode;
		private var _numNodes : int = 0;
		private var _state : int;
		private static const TRAVERSE_PRE : int = 0;
		private static const TRAVERSE_IN : int = 1;
		private static const TRAVERSE_POST : int = 2;
		
		public var maxTimeout : int = 500;
		
		private var _needBuild : Boolean;
		
		// pvs build
		private var _portalIndex : int;
		private var _portals : Vector.<BSPPortal>;
		private var _newPortals : Vector.<BSPPortal>;
		
		private var _totalFaces : int;
		private var _assignedFaces : int;
		
		private var _splitWeight : Number = 10;
		private var _balanceWeight : Number = 1;
		private var _xzAxisWeight : Number = 10;
		private var _yAxisWeight : Number = 5;
		public var maxVisibilityPropagation : int = 10;
		
		private var _newIndex : int = -1;
		private var _visIterationStep : int;
		
		/**
		 * The importance of using axial planes during BSP building with vectors aligned to the X or Z axes (ie: axis-aligned walls). Axis-aligned planes are typically less prone to rounding errors and faster to test against.
		 */
		public function get xzAxisWeight() : Number
		{
			return _xzAxisWeight;
		}
		
		public function set xzAxisWeight(xzAxisWeight : Number) : void
		{
			_rootNode._nonXZWeight = _xzAxisWeight = xzAxisWeight;
		}
		
		/**
		 * The importance of using axial planes during BSP building with vectors aligned to the Y axis (ie: axis-aligned floors and ceilings). Axis-aligned planes are typically less prone to rounding errors and faster to test against.
		 */
		public function get yAxisWeight() : Number
		{
			return _yAxisWeight;
		}
		
		public function set yAxisWeight(yAxisWeight : Number) : void
		{
			_rootNode._nonYWeight = _yAxisWeight = yAxisWeight;
		}

		/**
		 * The importance of the tree balance during BSP building. Well-balanced trees are typically less deep and need less iterating.
		 */
		public function get balanceWeight() : Number
		{
			return _balanceWeight;
		}
		
		public function set balanceWeight(balanceWeight : Number) : void
		{
			_rootNode._balanceWeight = _balanceWeight = balanceWeight;
		}
		
		/**
		 * The importance of avoiding triangle splits during BSP building. Less triangle splits typically results in an overall lower triangle count.
		 */
		public function get splitWeight() : Number
		{
			return _splitWeight;
		}
		
		public function set splitWeight(splitWeight : Number) : void
		{
			_rootNode._splitWeight = _splitWeight = splitWeight;
		}
		
		/**
		 * Build a BSP tree from the current faces.
		 * 
		 * @param faces A list of Face objects from which to build the tree.
		 * @param buildPVS Whether or not to build the potential visible set. Building a PVS allows a large set of the geometry to be culled early on. It's a slow process and definitely not recommended for real-time use.
		 */
		public function build(faces : Vector.<Face>, buildPVS : Boolean = false) : void
		{
			nodeCount = 0;
			_progressEvent = new TraceEvent(TraceEvent.TRACE_PROGRESS);
			_progressEvent.totalParts = buildPVS? 12 : 1;
			_rootNode._buildFaces = convertFaces(faces);
			_currentBuildNode = _rootNode;
			_needBuild = true;
			_progressEvent.count = 1;
			_progressEvent.message = "Building BSP tree";
			_totalFaces = faces.length;
			_buildPVS = buildPVS;
			buildStep();
		}
		
		/**
		 * @private
		 */
		arcane function buildFromNGons(faces : Vector.<NGon>, buildPVS : Boolean = true) : void
		{
			nodeCount = 0;
			_progressEvent = new TraceEvent(TraceEvent.TRACE_PROGRESS);
			_progressEvent.totalParts = buildPVS? 12 : 1;
			_rootNode._buildFaces = faces;
			_currentBuildNode = _rootNode;
			_needBuild = true;
			_progressEvent.count = 1;
			_progressEvent.message = "Building BSP tree";
			_totalFaces = faces.length;
			_buildPVS = buildPVS;
			buildStep();
		}
		
		private function buildStep(event : Event = null) : void
		{
			if (event) {
				if (_needBuild) {
					_assignedFaces += _currentBuildNode._assignedFaces;
					_totalFaces += _currentBuildNode._newFaces;
				}
				
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
			
			notifyProgress(_assignedFaces, _totalFaces);
			
			if (_needBuild) {
				++_numNodes;
				_currentBuildNode.addEventListener(Event.COMPLETE, buildStep);
				_currentBuildNode.build();
			} else {
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
			var i : int, c : int;
			var u : Number3D, v : Number3D, cross : Number3D;
			var v1 : Vertex, v2 : Vertex, v3 : Vertex;
			var face : Face;
			
			u = new Number3D();
			v = new Number3D();
			cross = new Number3D();
			
			do {
				face = faces[i];
				v1 = face._v0;
				v2 = face._v1;
				v3 = face._v2;
				// check if collinear (caused by t-junctions)
				u.x = v2.x-v1.x;
				u.y = v2.y-v1.y;
				u.z = v2.z-v1.z;
				v.x = v1.x-v3.x;
				v.y = v1.y-v3.y;
				v.z = v1.z-v3.z;
				cross.cross(u, v);
				if (cross.modulo > EPSILON) {
					ngon = new NGon();
					ngon.fromTriangle(faces[i]);
					polys[c++] = ngon;
				}
			} while (++i < len);
			return polys;
		}
		
		private function onBuildComplete() : void
		{
			_leaves = new Vector.<BSPNode>();
			_rootNode.gatherLeaves(_leaves);
			init();
			
			if (_buildPVS)
				setTimeout(createPVS, 1);
			else
				dispatchEvent(new TraceEvent(TraceEvent.TRACE_COMPLETE));
		}
		
		/**
		 * Builds the potentially visible set.
		 */
		private function createPVS() : void
		{
			_portals = new Vector.<BSPPortal>();
			_needBuild = true;
			_currentBuildNode = _rootNode;
			_state = TRAVERSE_PRE;
			
			_progressEvent.count = 2;
			_progressEvent.message = "Creating portals";
			_portalIndex = 0;
			
			createPortals();
		}
		
		/**
		 * Generate portals from the BSP tree.
		 */
		private function createPortals() : void
		{
			var startTime : int = getTimer();
			var pos : BSPNode;
			var neg : BSPNode;
			var portals : Vector.<BSPPortal>;
			
			notifyProgress(_portalIndex, _numNodes-_leaves.length);
			
			do {
				if (_needBuild && !_currentBuildNode._isLeaf) {
					portals = _currentBuildNode.generatePortals(_rootNode);
					if (portals)
						_portals = _portals.concat(portals);
					++_portalIndex;
				}
				
				pos = _currentBuildNode._positiveNode;
				neg = _currentBuildNode._negativeNode;
				
				switch(_state) {
					case TRAVERSE_PRE:
						if (pos) {
							_currentBuildNode = pos;
							_needBuild = true;
						}
						else {
							_state = TRAVERSE_IN;
							_needBuild = false;
						}
						break;
					case TRAVERSE_IN:
						if (neg) {
							_currentBuildNode = neg;
							_state = TRAVERSE_PRE;
							_needBuild = true;
						}
						else {
							_state = TRAVERSE_POST;
							_needBuild = false;
						}
						break;
					case TRAVERSE_POST:
						if (_currentBuildNode._parent) {
							if (_currentBuildNode == _currentBuildNode._parent._positiveNode)
								_state = TRAVERSE_IN;
							_currentBuildNode = _currentBuildNode._parent;
						}
						_needBuild = false;
						break;
				}
			} while (	(_currentBuildNode != _rootNode || _state != TRAVERSE_POST) &&
						getTimer()-startTime < maxTimeout);
			
			if (_currentBuildNode == _rootNode && _state == TRAVERSE_POST) {
				_portalIndex = 0;
				_progressEvent.message = "Cleaning up portals (#portals: "+_portals.length+")";
				_progressEvent.count = 3;
				setTimeout(removeOneSidedPortals, 1);
			}
			else {
				setTimeout(createPortals, 1);
			}
		}
		
		/**
		 * Throw away portals not linking 2 leaves together (provide no visibility info)
		 */
		private function removeOneSidedPortals() : void
		{
			var startTime : int = getTimer();
			var portal : BSPPortal;
			
			notifyProgress(_portalIndex, _portals.length);
			
			do {
				portal = _portals[_portalIndex];
				
				if (portal.frontNode == null || portal.backNode == null ||
					!portal.frontNode._isLeaf || !portal.backNode._isLeaf)
					_portals.splice(_portalIndex--, 1);
			} while(++_portalIndex < _portals.length && getTimer() - startTime < maxTimeout);
			
			if (_portalIndex >= _portals.length) {
				_portalIndex = 0;
				_newPortals = new Vector.<BSPPortal>(_portals.length*2, true);
				_progressEvent.message = "Partitioning portals (#portals: "+_portals.length+")";
				_progressEvent.count = 5;
				setTimeout(partitionPortals, 1);
			}
			else {
				setTimeout(removeOneSidedPortals, 1);	
			}
		}
		
		/**
		 * Create one-sided portals, ie. Portals through which we can see INTO a leaf.
		 */
		private function partitionPortals() : void
		{
			var len : int = _portals.length;
			var portal : BSPPortal;
			var newLen : int = len*2;
			var parts : Vector.<BSPPortal>;
			var startTime : int = getTimer();
			
			notifyProgress(_portalIndex, len);
			
			do {
				portal = _portals[_portalIndex];
				parts = portal.partition();
				parts[0].createLists(newLen);
				parts[1].createLists(newLen);
				_newPortals[++_newIndex] = parts[0];
				_newPortals[++_newIndex] = parts[1];
			} while (++_portalIndex < len && getTimer() - startTime < maxTimeout);
			
			if (_portalIndex >= len) {
				_portalIndex = 0;
				_progressEvent.message = "Linking portals to leaves (#portals: "+_portals.length+")";
				_progressEvent.count = 6;
				_portals = _newPortals;
				
				setTimeout(linkPortals, 1);
			}
			else {
				setTimeout(partitionPortals, 1);
			}
		}
		
		/**
		 * Assign portals to leaves
		 */
		private function linkPortals() : void
		{
			var len : int = _portals.length;
			var portal : BSPPortal;
			var startTime : int = getTimer();
			
			notifyProgress(_portalIndex, len);
			
			do {
				portal = _portals[_portalIndex];
				portal.index = _portalIndex;
				portal.maxTimeout = maxTimeout;
				portal.frontNode.assignPortal(portal);
				portal.backNode.assignBackPortal(portal);
			} while (++_portalIndex < len && getTimer()-startTime < maxTimeout);
			
			if (_portalIndex >= len) {
				_portalIndex = 0;
				_progressEvent.count = 7;
				_progressEvent.message = "Building front lists (#portals: "+_portals.length+")";
				
				//temp
				createMeshes();
				//dispatchEvent(new TraceEvent(TraceEvent.TRACE_COMPLETE));
				
				setTimeout(buildInitialFrontList, 1);
			}
			else {
				setTimeout(linkPortals, 1);
			}
		}
		
		// TEMP
		private function createMeshes() : void
		{
			// temp
			var len : int = _leaves.length;
			for (var i : int = 0; i < len; ++i) {
				if (_leaves[i]) {
					if (_leaves[i]._tempMesh && !_leaves[i]._tempMesh.extra) {
						super.addChild(_leaves[i]._tempMesh);
						_leaves[i]._tempMesh.extra = {created: true};
					}
				}
			}
		}
		
		/**
		 * Finds which portals are in front of any given portal. Portals behind a portal (through which we're looking OUT of), can never be seen.
		 */
		private function buildInitialFrontList() : void
		{
			var startTime : int = getTimer();
			var len : int = _portals.length;
			
			notifyProgress(_portalIndex, _portals.length);
			
			// find portals that are in front per portal
			do {
				_portals[_portalIndex].findInitialFrontList(_portals);
			} while (++_portalIndex < len && getTimer() - startTime < maxTimeout);
			
			if (_portalIndex == len) {
				_portalIndex = 0;
				_progressEvent.message = "Finding neighbours (#portals: "+_portals.length+")";
				_progressEvent.count = 9;
				setTimeout(findPortalNeighbours, 1);
			}
			else {
				setTimeout(buildInitialFrontList, 1);
			}
		}
		
		/**
		 * Finds neighbours of every portal.
		 */
		private function findPortalNeighbours() : void
		{
			var startTime : int = getTimer();
			var len : int = _portals.length;
			
			notifyProgress(_portalIndex, _portals.length);
			
			// find portals that are in front per portal
			do {
				_portals[_portalIndex].findNeighbours();
			} while (++_portalIndex < len && getTimer() - startTime < maxTimeout);
			
			if (_portalIndex >= len) {
				_portalIndex = 0;
				_progressEvent.message = "Culling portals (#portals: "+_portals.length+")";
				_progressEvent.count = 10;
				
				setTimeout(removeVisiblesFromNeighbours, 1);
			}
			else {
				setTimeout(findPortalNeighbours, 1);
			}
		}
		
		/**
		 * Do initial culling step. If not visible from a neighbouring portal, it cannot be seen.
		 */
		private function removeVisiblesFromNeighbours() : void
		{
			var startTime : int = getTimer();
			var len : int = _portals.length;
			
			notifyProgress(_portalIndex, _portals.length);
			
			do {
				_portals[_portalIndex].removePortalsFromNeighbours(_portals);
			} while (++_portalIndex < len && getTimer() - startTime < maxTimeout);
			
			if (_portalIndex >= len) {
				_progressEvent.message = "Propagating visibility (#portals: "+_portals.length+")";
				_progressEvent.count = 12;
				_portals.sort(portalSort);
				_portalIndex = 0;
				_visIterationStep = 0;
				setTimeout(propagateVisibility, 1);
			}
			else
				setTimeout(removeVisiblesFromNeighbours, 1);
		}
		
		/**
		 * Propagate visibility data through the portal list, updating portal data for easier early testing during deep test.
		 */
		private function propagateVisibility() : void
		{
			var startTime : int = getTimer();
			var len : int = _portals.length;
			
			notifyProgress(_portalIndex + _visIterationStep * _portals.length, _portals.length * maxVisibilityPropagation);
			
			do {
				_portals[_portalIndex].propagateVisibility();
			} while (++_portalIndex < len && getTimer() - startTime < maxTimeout);
			
			if (_portalIndex >= len) {
				_portalIndex = 0;
				
				_portals.sort(portalSort);
				
				if (++_visIterationStep < maxVisibilityPropagation) {
					setTimeout(propagateVisibility, 1);
				}
				else {
					_portalIndex = 0;
					_progressEvent.message = "Finding visible portals (#portals: "+_portals.length+")";
					_progressEvent.count = 12;
					setTimeout(findVisiblePortals, 1);
				}
			}
			else
				setTimeout(propagateVisibility, 1);
		}
		
		/**
		 * Sort method for portal list. This is used to place portals with less potential visibility in front so it can impact the speed of those with more.
		 */
		private function portalSort(a : BSPPortal, b : BSPPortal) : Number
		{
			var fa : int = a.frontOrder;
			var fb : int = b.frontOrder;
			
			if (fa < fb) return -1;
			else if (fa == fb) return 0;
			else return 1;
		}

		/**
		 * Performs deep anti-penumbra testing to find out exactly which leaves could possibly be seen from any given leaf. 
		 */
		private function findVisiblePortals(event : Event = null) : void
		{
			var len : int = _portals.length;
			var portal : BSPPortal;
			
			if (event) {
				event.target.removeEventListener(Event.COMPLETE, findVisiblePortals);
				++_portalIndex;
			}
			
			notifyProgress(_portalIndex, _portals.length);
			
			// find next portal that has a potential vis list
			while (_portalIndex < len && _portals[_portalIndex].frontOrder <= 0)
				++_portalIndex;
			
			if (_portalIndex == len) {
				_portalIndex = 0;
				setTimeout(finalizeVisList, 1);
			}
			else {
				portal = _portals[_portalIndex];
				portal.addEventListener(Event.COMPLETE, findVisiblePortals);
				portal.findVisiblePortals(_portals);
			}
		}
		
		/**
		 * Applies portal visibility data to the leaves.
		 */
		private function finalizeVisList() : void
		{
			var startTime : int = getTimer();
			var len : int = _leaves.length;
			
			do {
				_leaves[_portalIndex].processVislist(_portals);
			} while (++_portalIndex < len && getTimer() - startTime < maxTimeout);
			
			if (_portalIndex < len)
				setTimeout(finalizeVisList, 1);
			else
				dispatchEvent(new TraceEvent(TraceEvent.TRACE_COMPLETE));
		}
		
		/**
		 * Send out a progress event during building.
		 */
		private function notifyProgress(steps : int, total : int) : void
       	{
			_progressEvent.percentPart = steps/total*100;
			dispatchEvent(_progressEvent);
		}
	}
}