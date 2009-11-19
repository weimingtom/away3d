package away3d.core.graphs
{
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
	 * and performs early culling to remove big parts of the geometry that don't need to be rendered. It also speeds up collision detection.
	 */
	 
	// TO DO:
	// - looping can probably be optimized with a check if leaf,
	//   --> state can automatically be set to POST in that case
	//
	// - use if instead of switch?
	public class BSPTree extends ObjectContainer3D
	{
		public static var EPSILON : Number = 1/128;
		
		private var _transformPt : Number3D = new Number3D();
		
		// the root node in the tree
		arcane var _rootNode : BSPNode;
		
		// a list of all leafs in the tree, for fast access
		arcane var _leaves : Vector.<BSPNode>;
		
		private var _activeLeaf : BSPNode;
		
		private var _viewToLocal : MatrixAway3D = new MatrixAway3D();
		
		private var _buildPVS : Boolean;
		private var _complete : Boolean;
		
		// building
		private var _progressEvent : TraceEvent;
		private var _currentBuildNode : BSPNode;
		private var _numNodes : int = 0;
		private var _state : int;
		private static const TRAVERSE_PRE : int = 0;
		private static const TRAVERSE_IN : int = 1;
		private static const TRAVERSE_POST : int = 2;
		
		public var maxTimeout : int = 500;
		
		private var _needBuild : Boolean;
		
		// portal generation
		private var _portalIndex : int;
		private var _portals : Vector.<BSPPortal>;
		
		private var _totalFaces : int;
		private var _assignedFaces : int;
		
		private var _splitWeight : Number = 10;
		private var _balanceWeight : Number = 1;
		private var _xzAxisWeight : Number = 10;
		private var _yAxisWeight : Number = 5;
		public var maxVisibilityPropagation : int = 10;
		
		// debug var
		public var freezeCulling : Boolean;
		
		/**
		 * Creates a new BSPTree object.
		 */
		public function BSPTree()
		{
			super();
			_rootNode = new BSPNode(null);
			_rootNode.maxTimeOut = maxTimeout;
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
			
			while (node && !node._isLeaf)
			{
				plane = node._partitionPlane;
				dot = point.x*plane.a+point.y*plane.b+point.z*plane.c;
				node = dot > -plane.d? node._positiveNode : node._negativeNode;
			} 
			
			return node;
		}
		
		/**
		 * Build a BSP tree from the current faces.
		 * 
		 * @param faces A list of Face objects from which to build the tree.
		 */
		public function build(faces : Vector.<Face>, buildPVS : Boolean = true) : void
		{
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
				_progressEvent.message = "Cleaning up portals";
				_progressEvent.count = 3;
				setTimeout(removeOneSidedPortals, 1);
			}
			else {
				setTimeout(createPortals, 1);
			}
		}
		
		/**
		 * TO DO: can this be done while creating portals? Just don't add them if they don't meet requirements?
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
				_progressEvent.message = "Partitioning portals";
				_progressEvent.count = 5;
				setTimeout(partitionPortals, 1);
			}
			else {
				setTimeout(removeOneSidedPortals, 1);	
			}
		}
		
		// TO DO: locks up on high portal count?
//		private function cutSolidStep() : void
//		{
			/*var startTime : int = getTimer();
			var portal : BSPPortal;
			var newPortals : Vector.<BSPPortal>;
			
			notifyProgress(_portalIndex, _portals.length);
			
			do {
				portal = _portals[_portalIndex];
				newPortals = portal.cutSolids();
				
				_portals.splice(_portalIndex--, 1);
				
				if (newPortals) {
					var i : int = newPortals.length;
					while (--i >= 0) {
						// sigh... using a Vector in splice arguments doesn't actually work
						if (newPortals[i].nGon.vertices.length > 2)
							_portals.splice(_portalIndex++, 0, newPortals[i]);
					}
				}
			} while (++_portalIndex < _portals.length && getTimer() - startTime < maxTimeout);
			
			if (_portalIndex >= _portals.length) {*/
//				_portalIndex = 0;
//				_newPortals = new Vector.<BSPPortal>(_portals.length*2);
//				_progressEvent.message = "Partitioning portals";
//				_progressEvent.count = 5;
//				setTimeout(partitionPortals, 1);
			/*}
			else {
				setTimeout(cutSolidStep, 1);
			}*/
//		}
		
		private var _newPortals : Vector.<BSPPortal>;
		private var _newIndex : int = -1;
		
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
				_progressEvent.message = "Linking portals to leaves";
				_progressEvent.count = 6;
				_portals = _newPortals;
				portalsToLinkedList();
				setTimeout(linkPortals, 1);
			}
			else {
				setTimeout(partitionPortals, 1);
			}
		}
		
		private var _firstPortal : BSPPortal;
		
		private function portalsToLinkedList() : void
		{
			var i : int = _portals.length;
			var portal : BSPPortal;

			_firstPortal = null;
			
			while (--i >= 0) {
				portal = _portals[i];
				portal.next = _firstPortal;
				_firstPortal = portal;
			}
		}
		
		
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
				//portal.backNode.assignPortal(portal);
			} while (++_portalIndex < len && getTimer()-startTime < maxTimeout);
			
			if (_portalIndex >= len) {
				_portalIndex = 0;
				_currentPortal = _firstPortal;
				
				_progressEvent.count = 7;
				_progressEvent.message = "Building front lists";
				setTimeout(buildInitialFrontList, 1);
			}
			else {
				setTimeout(linkPortals, 1);
			}
			//temp
//			createMeshes();
		}
		
		private function createMeshes() : void
		{
			// temp
			var len : int = _leaves.length;
			for (var i : int = 0; i < len; ++i) {
				if (_leaves[i]) {
					if (_leaves[i]._tempMesh && !_leaves[i]._tempMesh.extra) {
						addChild(_leaves[i]._tempMesh);
						_leaves[i]._tempMesh.extra = {created: true};
					}
				}
			}
		}

		private var _currentPortal : BSPPortal;
		
		private function buildInitialFrontList() : void
		{
			var startTime : int = getTimer();
			//var len : int = _portals.length;
			
			notifyProgress(_currentPortal.index, _portals.length);
			
			// find portals that are in front per portal
			do {
				_currentPortal.findInitialFrontList(_firstPortal);
			} while ((_currentPortal = _currentPortal.next) && getTimer() - startTime < maxTimeout);
			
			if (!_currentPortal) {
//				_progressEvent.message = "Updating front lists";
//				_portalIndex = 0;
//				_progressEvent.count = 8;
//				setTimeout(cleanFrontList, 1);
				_portalIndex = 0;
				//setTimeout(initVisibleNeighbours, 1);
				_progressEvent.message = "Finding neighbours";
				_progressEvent.count = 9;
				setTimeout(findPortalNeighbours, 1);
			}
			else {
				setTimeout(buildInitialFrontList, 1);
			}
		}
		
		/*private function cleanFrontList() : void
		{
			var startTime : int = getTimer();
			var len : int = _portals.length;
			
			notifyProgress(_portalIndex, _portals.length);
			
			// remove portals in vislist that are mutually visible
			do {
				_portals[_portalIndex].removeReciprocalVisibles(_portals);
			} while (++_portalIndex < len && getTimer() - startTime < maxTimeout);
			
			if (_portalIndex >= len) {
				_portalIndex = 0;
				//setTimeout(initVisibleNeighbours, 1);
				_progressEvent.message = "Finding neighbours";
				_progressEvent.count = 9;
				setTimeout(findPortalNeighbours, 1);
			}
			else
				setTimeout(cleanFrontList, 1);
		}*/
		
		private function findPortalNeighbours() : void
		{
			var startTime : int = getTimer();
			var len : int = _portals.length;
			
			notifyProgress(_portalIndex, _portals.length);
			
			// find portals that are in front per portal
			do {
				notifyProgress(_portalIndex, _portals.length);
				_portals[_portalIndex].findNeighbours();
			} while (++_portalIndex < len && getTimer() - startTime < maxTimeout);
			
			if (_portalIndex >= len) {
				_portalIndex = 0;
				_progressEvent.message = "Culling portals";
				_progressEvent.count = 10;
				
				setTimeout(removeVisiblesFromNeighbours, 1);
			}
			else {
				setTimeout(findPortalNeighbours, 1);
			}
		}
		
		private function removeVisiblesFromNeighbours() : void
		{
			var startTime : int = getTimer();
			var len : int = _portals.length;
			
			notifyProgress(_portalIndex, _portals.length);
			
			// remove portals in vislist that are mutually visible
			do {
				_portals[_portalIndex].removePortalsFromNeighbours(_portals);
			} while (++_portalIndex < len && getTimer() - startTime < maxTimeout);
			
			if (_portalIndex >= len) {
				_progressEvent.message = "Propagating visibility";
				_progressEvent.count = 12;
				_portals.sort(portalSort);
				_portalIndex = 0;
				_visIterationStep = 0;
				setTimeout(propagateVisibility, 1);
			}
			else
				setTimeout(removeVisiblesFromNeighbours, 1);
		}
		
		private var _visIterationStep : int;
		private function propagateVisibility() : void
		{
			var startTime : int = getTimer();
			var len : int = _portals.length;
			
			notifyProgress(_portalIndex + _visIterationStep * _portals.length, _portals.length * maxVisibilityPropagation);
			
			// remove portals in vislist that are mutually visible
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
					_progressEvent.message = "Finding visible portals";
					_progressEvent.count = 12;
					portalsToLinkedList();
					_currentPortal = _firstPortal;
					setTimeout(findVisiblePortals, 1);
				}
			}
			else
				setTimeout(propagateVisibility, 1);
		}
		
		private function portalSort(a : BSPPortal, b : BSPPortal) : Number
		{
			var fa : int = a.frontOrder;
			var fb : int = b.frontOrder;
			
			if (fa < fb) return -1;
			else if (fa == fb) return 0;
			else return 1;
		}

		private function findVisiblePortals(event : Event = null) : void
		{
			var startTime : int = getTimer();
			/*if (event) {
				++_numPortalsVisd;
				_portals[_portalIndex++].removeEventListener(Event.COMPLETE, findVisiblePortals);
				_portals[_portalIndex++].removeEventListener(BSPPortal.RECURSED_PORTAL_COMPLETE, onRecursedComplete);
			}*/
			
			notifyProgress(_portalIndex, _portals.length);
			
			do {
				_currentPortal.findVisiblePortals();
				_portalIndex++;
			} while ((_currentPortal = _currentPortal.next) && getTimer() - startTime < maxTimeout);
			
			if (!_currentPortal) {
				_portalIndex = 0;
				setTimeout(finalizeVisList, 1);
			}
			else {
				setTimeout(findVisiblePortals, 1);
			}
		}
		
//		private function onRecursedComplete(event : Event) : void
//		{
//			++_numPortalsVisd;
//			notifyProgress(_numPortalsVisd, _portals.length);
//		}
		
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
		 * Updates the tree's state. This method is called before the first traversal.
		 * Performs early culling and ordering of nodes.
		 * 
		 * @private
		 */
		arcane function update(camera : Camera3D, frustum : Frustum) : void
		{
			if (!(camera.lens is PerspectiveLens))
				throw new Error("Lens is of incorrect type! BSP needs a PerspectiveLens instance assigned to Camera3D.lens");
			
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
		
		/**
		 * TO DO: do we actually need this part?
		 * Can we set a renderedFrame property so we know when to recalculate the _lastIterationPositive var inside traverse? 
		 */
		private function orderNodes(point : Number3D) : void
		{
			var loopNode : BSPNode = _rootNode;
			var partitionPlane : Plane3D;
			var pos : BSPNode;
			var neg : BSPNode;
			_needBuild = true;
			_state = TRAVERSE_PRE;
			
			if (loopNode._culled) return;
			
			do {
				if (_needBuild && !loopNode._isLeaf) {
					partitionPlane = loopNode._partitionPlane;
					
					if (partitionPlane._alignment == Plane3D.X_AXIS)
						loopNode._lastIterationPositive = partitionPlane.a*point.x > -partitionPlane.d;
					else if (partitionPlane._alignment == Plane3D.Y_AXIS)
						loopNode._lastIterationPositive = partitionPlane.b*point.y > -partitionPlane.d;
					else if (partitionPlane._alignment == Plane3D.Z_AXIS)
						loopNode._lastIterationPositive = partitionPlane.c*point.z > -partitionPlane.d;
					else
						loopNode._lastIterationPositive = 	partitionPlane.a*point.x +
															partitionPlane.b*point.y +
															partitionPlane.c*point.z
															 > -partitionPlane.d;
				}
				
				pos = loopNode._positiveNode;
				neg = loopNode._negativeNode;
				
				switch(_state) {
					case TRAVERSE_PRE:
						if (pos && !pos._culled) {
							loopNode = pos;
							_needBuild = true;
							break;
						}
						else {
							_state = TRAVERSE_IN;
							//_needBuild = false;
						}
					case TRAVERSE_IN:
						if (neg && !neg._culled) {
							loopNode = neg;
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
						if (loopNode._parent) {
							if (loopNode == loopNode._parent._positiveNode)
								_state = TRAVERSE_IN;
							loopNode = loopNode._parent;
							_needBuild = false;
						}
						break;
				}
			} while (loopNode != _rootNode || _state != TRAVERSE_POST);
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
        	var loopNode : BSPNode = _rootNode;

			_state = TRAVERSE_PRE;
        	
        	if (loopNode._culled) return;
        	
        	do {
        		if (changed) {
        			isLeaf = loopNode._isLeaf;
					if (isLeaf) {
						mesh = loopNode._mesh;
						if (mesh && traverser.match(mesh))
	            		{
		                	traverser.enter(mesh);
		                	traverser.apply(mesh);
		                	traverser.leave(mesh);
		                	// temp
	            		}
	            		if (	loopNode &&
	       						loopNode._tempMesh && 
	       						loopNode._tempMesh.extra && 
	       						loopNode._tempMesh.extra.created
	       					) loopNode._tempMesh.traverse(traverser);
	            		_state = TRAVERSE_POST;
					}
					else {
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
        	var vislist : Vector.<int> = activeNode? activeNode._visList : null;
        	var i : int, j : int;
        	var leaf : BSPNode;
        	var vislen : int = vislist? vislist.length : 0;
        	
        	_rootNode._culled = false;
        	
        	// process PVS
        	if (vislen == 0) {
        		for (i = 0; i < len; ++i) {
        			leaf = _leaves[i];
        			if (leaf) {
        				if (leaf._mesh) {
        					leaf._culled = false;
        					leaf._mesh._preCullClassification = Frustum.IN;
        				}
        				else
        					leaf._culled = true;
        			}
        		}
        	}
        	else {
	        	for (i = 0; i < len; ++i) {
	        		if (!_leaves[i]) continue;
	        		if (j < vislen && i == vislist[j]) {
	        			leaf = _leaves[i];
	        			leaf._culled = false;
	        			leaf._mesh._preCullClassification = Frustum.IN;
	        			++j;
	        		}
	        		else {
	        			_leaves[i]._culled = true;
	        		}
	        	}
	        }
	        if (activeNode) activeNode._culled = false;
			
			// propagate culled state. Nodes don't need to be traversed if none of the leafs contained are visible
			propagateCulled();
			cullToFrustum(frustum);
        }
        
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
						if (loopNode._mesh) loopNode._mesh._preCullClassification = classification;
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
       	
       	private function notifyProgress(steps : int, total : int) : void
       	{
			_progressEvent.percentPart = steps/total*100;
			dispatchEvent(_progressEvent);
		}
		
		public function get xzAxisWeight() : Number
		{
			return _xzAxisWeight;
		}
		
		public function set xzAxisWeight(xzAxisWeight : Number) : void
		{
			_rootNode._nonXZWeight = _xzAxisWeight = xzAxisWeight;
		}

		public function get balanceWeight() : Number
		{
			return _balanceWeight;
		}
		
		public function set balanceWeight(balanceWeight : Number) : void
		{
			_rootNode._balanceWeight = _balanceWeight = balanceWeight;
		}

		public function get splitWeight() : Number
		{
			return _splitWeight;
		}
		
		public function set splitWeight(splitWeight : Number) : void
		{
			_rootNode._splitWeight = _splitWeight = splitWeight;
		}
		
		public function get yAxisWeight() : Number
		{
			return _yAxisWeight;
		}
		
		public function set yAxisWeight(yAxisWeight : Number) : void
		{
			_rootNode._nonYWeight = _yAxisWeight = yAxisWeight;
		}
	}
}