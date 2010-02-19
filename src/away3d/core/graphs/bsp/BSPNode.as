package away3d.core.graphs.bsp
{
	import away3d.core.graphs.*;
	import away3d.materials.ITriangleMaterial;
	import away3d.core.base.UV;
	import away3d.core.traverse.PrimitiveTraverser;
	import away3d.materials.WireColorMaterial;
	import away3d.core.base.Vertex;
	import away3d.core.base.Object3D;
	import away3d.arcane;
	import away3d.core.base.Face;
	import away3d.core.base.Mesh;
	import away3d.core.geom.NGon;
	import away3d.core.geom.Plane3D;
	import away3d.core.math.Number3D;
	import away3d.core.traverse.Traverser;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	use namespace arcane;
	
	/**
	 * BSPNode is a single node in a BSPTree
	 */
	public final class BSPNode extends EventDispatcher implements ITreeNode
	{
		public var leafId : int = -1;
		public var nodeId : int;
		public var renderMark : int = -1;

		public var name : String;

		// indicates whether this node is a leaf or not, leaves contain triangles
		arcane var _isLeaf : Boolean;
		
		// flag used when processing vislist
		arcane var _culled : Boolean;
		
		// a reference to the parent node
		arcane var _parent : BSPNode;
		
		// non-leaf only
		arcane var _partitionPlane : Plane3D;		// the plane that divides the node in half
		arcane var _positiveNode : BSPNode;		// node on the positive side of the division plane
		arcane var _negativeNode : BSPNode;		// node on the negative side of the division plane
		
		arcane var _bevelPlanes : Vector.<Plane3D>;
		
		// leaf only
		arcane var _faces : Vector.<NGon>;
		arcane var _mesh : Mesh;				// contains the model for this face
		arcane var _visList : Vector.<int>;		// indices of leafs visible from this leaf
		
		// used for correct z-order traversing
		arcane var _lastIterationPositive : Boolean;
		
		arcane var _bounds : Array;
		
		// bounds
		arcane var _minX : Number;
		arcane var _minY : Number;
		arcane var _minZ : Number;
		arcane var _maxX: Number;
		arcane var _maxY: Number;
		arcane var _maxZ: Number;
		
		arcane var _children : Array;
		arcane var _meshes : Array;
		arcane var _colliders : Array;
		arcane var _hasChildren : Boolean;

		/**
		 * Creates a new BSPNode object.
		 * 
		 * @param parent A reference to the parent BSPNode. Pass null if this is the root node.
		 */
		public function BSPNode(parent : BSPNode)
		{
			nodeId = BSPTree.nodeCount++;
			_parent = parent;
		}        

		public function get leftChild() : ITreeNode
		{
			return _positiveNode;
		}

		public function get rightChild() : ITreeNode
		{
			return _negativeNode;
		}

		public function get parent() : ITreeNode
		{
			return _parent;
		}

		/**
		 * Sends a traverser down the dynamic children
		 * 
		 * @private
		 */
		public function traverseChildren(traverser : Traverser) : void
		{
			var i : int;
			var child : Object3D;
			var mng : BSPMeshManager;
			
			if (_children) {
				i = _children.length;
			
				while (--i >= 0) {
					child = Object3D(_children[i]);
					if (traverser.match(child)) {
						traverser.enter(child);
						traverser.apply(child);
						traverser.leave(child);
					}
				}
			}
			if (_meshes) {
				i = _meshes.length;
				while (--i >= 0) {
					mng = BSPMeshManager(_meshes[i]);
					mng.setLeaf(leafId);
					child = mng.mesh;
					if (traverser.match(child)) {
						traverser.enter(child);
						traverser.apply(child);
						traverser.leave(child);
					}
				}
			}
		}
		
		/*public function assignDynamic(child : Object3D, center : Number3D, radius : Number) : void
		{
			var dist : Number;
			var align : int;
		}*/
		
		public function assignCollider(child : Object3D, center : Number3D, radius : Number) : void 
		{
			var dist : Number;
			var align : int;
			
			if (_isLeaf) {
//				addCollider(child);
				return;
			}
			
			align = _partitionPlane._alignment;
			if (align == Plane3D.X_AXIS)
				dist = center.x*_partitionPlane.a + _partitionPlane.d;
			else if (align == Plane3D.Y_AXIS)
				dist = center.y*_partitionPlane.b + _partitionPlane.d;
			else if (align == Plane3D.Z_AXIS)
				dist = center.z*_partitionPlane.c + _partitionPlane.d;
			else
				dist = center.x*_partitionPlane.a + center.y*_partitionPlane.b + center.z*_partitionPlane.c + _partitionPlane.d;
			
			if (dist < radius && _negativeNode) _negativeNode.assignCollider(child, center, radius);
			if (dist > -radius && _positiveNode) _positiveNode.assignCollider(child, center, radius);
		}

		/*public function addCollider(child : Object3D) : void 
		{
			if (!_colliders) _colliders = [];
			_colliders.push(child);
			child._sceneGraphCollisionMarks.push(leafId);
		}

		public function removeCollider(child : Object3D) : void 
		{
			var index : int = _colliders.indexOf(child);
			var marks : Array = child._sceneGraphCollisionMarks;
			if (index != -1) {
				_colliders.splice(index, 1);
				index = marks.indexOf(leafId);
				if (index != -1) marks.splice(index, 1);
			}
		}*/
		
		public function addMesh(mesh : BSPMeshManager) : void 
		{
			if (!_meshes) _meshes = [];
			_meshes.push(mesh);
			if (mesh.sourceMesh._collider) {
				if (!_colliders) _colliders = [];
				_colliders.push(mesh.sourceMesh);
			}
			_hasChildren = true;
		}
		
		public function removeMesh(mesh : BSPMeshManager) : void 
		{
			var index : int = _meshes.indexOf(mesh);

			if (index != -1) {
				_meshes.splice(index, 1);
			}
			if (mesh.mesh._collider) {
				index = _colliders.indexOf(mesh.sourceMesh);
				if (index != -1) {
					_colliders.splice(index, 1);
				}
			}
			_hasChildren = (_meshes.length > 0 || (_children && _children.length > 0));
		}
		
		/**
		 * Adds a dynamic child to this leaf
		 * 
		 * @private
		 */
		public function addChild(child : Object3D) : void
		{
			if (!_children) _children = [];
			_children.push(child);
			child._sceneGraphMark = leafId;
			_hasChildren = true;
		}
		
		
		/**
		 * Removes a dynamic child from this leaf
		 * 
		 * @private
		 */
		public function removeChild(child : Object3D) : void
		{
			var index : int = _children.indexOf(child);
			if (index != -1) {
				_children.splice(index, 1);
				child._sceneGraphMark = -1;
			}
			_hasChildren = (_children.length > 0 || (_meshes && _meshes.length > 0));
		}
		
		/**
		 * The mesh contained within if the current node is a leaf, otherwise null
		 */
		public function get mesh() : Mesh
		{
			return _mesh;
		}
		
		/**
		 * The bounding box for this node.
		 */
		public function get bounds() : Array
		{
			return _bounds;
		}
		
 /*
  * Methods used in construction or parsing
  */
  		/**
  		 * Adds faces to the current leaf's mesh
  		 * 
  		 * @private
  		 */
  		arcane function addFaces(faces : Vector.<Face>) : void
		{
			var len : int = faces.length;
			var face : Face;
			var i : int;
			
			if (!_mesh) {
				_mesh = new Mesh();
				_mesh._preCulled = true;
				_mesh._preSorted = true;
				// faster screenZ calc if needed
				_mesh.pushback = true;
			}
			
			if (len == 0) return;
			
			do {
				face = faces[i];
				_mesh.addFace(face);
			} while (++i < len);
			
		}
		
		/**
		 * Adds a leaf to the current leaf's PVS
		 * 
		 * @private
		 */
		arcane function addVisibleLeaf(index : int) : void
		{
			if (!_visList) _visList = new Vector.<int>();
			_visList.push(index);
		}
		
 		/**
 		 * Recursively calculates bounding box for the node
 		 * 
 		 * @private
 		 */
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
			_bounds.push(new Number3D(_maxX, _maxY, _minZ));
			_bounds.push(new Number3D(_minX, _maxY, _minZ));
			_bounds.push(new Number3D(_minX, _minY, _maxZ));
			_bounds.push(new Number3D(_maxX, _minY, _maxZ));
			_bounds.push(new Number3D(_maxX, _maxY, _maxZ));
			_bounds.push(new Number3D(_minX, _maxY, _maxZ));
		}
 		
 		/**
 		 * Checks if a leaf is empty
 		 */
 		arcane function isEmpty() : Boolean
 		{
 			return _mesh.geometry.faces.length == 0;
 		}
 		
		/**
		 * Adds all leaves in the node's hierarchy to the vector
		 * 
		 * @private
		 */
		arcane function gatherLeaves(leaves : Vector.<BSPNode>) : void
		{
			// TO DO: do this during build phase
			if (_isLeaf) {
				leafId = leaves.length;
				leaves.push(this);
			}
			else {
				if (_positiveNode != null)
					if (_positiveNode._isLeaf && _positiveNode.isEmpty())
						// TO DO: throw error
						_positiveNode = null;
					else
						_positiveNode.gatherLeaves(leaves);
				
				if (_negativeNode != null)
					if (_negativeNode._isLeaf && _negativeNode.isEmpty())
						_negativeNode = null;
					else
						_negativeNode.gatherLeaves(leaves);
			}
		}

//
// COLLISION DETECTION
//
//		arcane static var _impact : Number3D;
//		arcane static var _collisionPlane : Plane3D;
//		
//		public function traceCollision(startPos : Number3D, targetPos : Number3D, dir : Number3D, testMethod : int, halfExtents : Number3D, plane : Plane3D = null) : Boolean
//		{
//			var hit : Boolean;
//			var startDist : Number;
//			var endDist : Number;
//			var align : int;
//			var a : Number, b : Number, c : Number, d : Number; 
//			var offset : Number = 0;
//			var t : Number;
//			var dirDot : Number;
//			var dx : Number = targetPos.x - startPos.x;
//			var dy : Number = targetPos.y - startPos.y;
//			var dz : Number = targetPos.z - startPos.z;
//			
//			if (_isLeaf) return false;
//			
//			d = _partitionPlane.d;
//			align = _partitionPlane._alignment;
//			switch (align) {
//				case Plane3D.X_AXIS:
//					a = _partitionPlane.a;
//					startDist = a*startPos.x + d;
//					endDist = a*targetPos.x + d;
//					dirDot = a*dx;
//					if (testMethod == BSPTree.TEST_METHOD_AABB)
//						offset = a > 0? a*halfExtents.x : -a*halfExtents.x;
//					break;
//				case Plane3D.Y_AXIS:
//					b = _partitionPlane.a;
//					startDist = b*startPos.y + d;
//					endDist = b*targetPos.y + d;
//					dirDot = b*dy;
//					if (testMethod == BSPTree.TEST_METHOD_AABB)
//						offset = b > 0? b*halfExtents.y : -b*halfExtents.y;
//					break;
//				case Plane3D.X_AXIS:
//					c = _partitionPlane.c;
//					startDist = c*startPos.z + d;
//					endDist = c*targetPos.z + d;
//					dirDot = c*dz;
//					if (testMethod == BSPTree.TEST_METHOD_AABB)
//						offset = c > 0? c*halfExtents.z : -c*halfExtents.z;
//					break;
//				default:
//					a = _partitionPlane.a;
//					b = _partitionPlane.b;
//					c = _partitionPlane.c;
//					startDist = a*startPos.x + b*startPos.y + c*startPos.z + d;
//					endDist = a*targetPos.x + b*targetPos.y + c*targetPos.z + d;
//					dirDot = a*dx + b*dy + c*dz;
//					if (testMethod == BSPTree.TEST_METHOD_AABB)
//						offset = 	(a > 0? a*halfExtents.x : -a*halfExtents.x) +
//									(b > 0? b*halfExtents.y : -b*halfExtents.y) +
//									(c > 0? c*halfExtents.z : -c*halfExtents.z);
//					break;
//			}
//			
//			if (startDist > offset && endDist > offset)
//				return _positiveNode.traceCollision(startPos, targetPos, dir, testMethod, halfExtents, plane);
//			
//			if (startDist < -offset && endDist < -offset)
//				return _negativeNode.traceCollision(startPos, targetPos, dir, testMethod, halfExtents, plane);
//			
//			if (dirDot == 0) {
//				return startDist < 0 	? _negativeNode.traceCollision(startPos, targetPos, dir, testMethod, halfExtents, plane)
//										: _positiveNode.traceCollision(startPos, targetPos, dir, testMethod, halfExtents, plane);
//			}
//			
//			if (dirDot > 0) {
//				// shift plane up, if segment is at least partly on negative side
//				if (startDist < offset) {
//					t = (offset-startDist)/dirDot;
//									
//					// is solid
//					if (!_negativeNode) {
//						// going out from solid node, should be allowed for easy fall-in
//						_impact = startPos;
//						_collisionPlane = plane;
//						hit = true;
//					}
//					else {
//						if (t < 1) {
//							_middle.x = startPos.x + t*dx;
//							_middle.y = startPos.y + t*dy;
//							_middle.z = startPos.z + t*dz;
//							hit = _negativeNode.traceCollision(startPos, _middle, dir, testMethod, halfExtents, _partitionPlane);
//						}
//						else
//							hit = _negativeNode.traceCollision(startPos, targetPos, dir, testMethod, halfExtents, plane);
//					}
//					
//					if (hit) {
//						targetPos = _impact;
//						endDist = a*targetPos.x + b*targetPos.y + c*targetPos.z + d;
//					}
//				}
//				
//				// shift plane down
//				if (endDist > -offset) {
//					t = -(startDist+offset)/dirDot;
//					
//					if (t > 0) {
//						_middle.x = startPos.x + t*dx;
//						_middle.y = startPos.y + t*dy;
//						_middle.z = startPos.z + t*dz;
//					
//						hit ||= _positiveNode.traceCollision(_middle, targetPos, dir, testMethod, halfExtents, _partitionPlane);
//					}
//					else
//						hit ||= _positiveNode.traceCollision(startPos, targetPos, dir, testMethod, halfExtents, plane);
//				}
//				
//				return hit;
//			}
//			else {
//				if (startDist > -offset) {
//					t = -(startDist+offset)/dirDot;
//									
//					// is solid
//					if (!_negativeNode) {
//						_collisionPlane = plane;
//						_impact = startPos;
//						hit = true;
//					}
//					else {
//						if (t < 1) {
//							_middle.x = startPos.x + t*dx;
//							_middle.y = startPos.y + t*dy;
//							_middle.z = startPos.z + t*dz;
//							hit = _negativeNode.traceCollision(startPos, _middle, dir, testMethod, halfExtents, _partitionPlane);
//						}
//						else
//							hit = _negativeNode.traceCollision(startPos, targetPos, dir, testMethod, halfExtents, plane);
//					}
//					
//					if (hit) {
//						targetPos = _impact;
//						endDist = a*targetPos.x + b*targetPos.y + c*targetPos.z + d;
//					}
//				}
//				
//				// shift plane down
//				if (endDist < offset) {
//					t = (offset-startDist)/dirDot;
//					if (t > 0) {
//						_middle.x = startPos.x + t*dx;
//						_middle.y = startPos.y + t*dy;
//						_middle.z = startPos.z + t*dz;
//						
//						hit ||= _positiveNode.traceCollision(_middle, targetPos, dir, testMethod, halfExtents, _partitionPlane);
//					}
//					else
//						hit ||= _positiveNode.traceCollision(startPos, targetPos, dir, testMethod, halfExtents, plane);
//				}
//				
//				return hit;
//			}
//		}

		
//
// BUILDING
//
		// used for building tree
		// scores dictating the importance of triangle splits, tree balance and axis aligned splitting planes
		arcane var _splitWeight : Number = 10;
		arcane var _balanceWeight : Number = 1;
		arcane var _nonXZWeight : Number = 1.5;
		arcane var _nonYWeight : Number = 1.2;
		
		private var _bestPlane : Plane3D;
		private var _bestScore : Number;
		private var _positiveFaces : Vector.<NGon>;
		private var _negativeFaces : Vector.<NGon>;
		
		// indicates whether contents is convex or not when creating solid leaf tree
		arcane var _convex : Boolean;
		// triangle planes used to create solid leaf tree
		private var _solidPlanes : Vector.<Plane3D>;
		
		private var _planeCount : int;
		
		arcane var _maxTimeOut : int = 500;
		
		arcane var _newFaces : int;
		arcane var _assignedFaces : int;
		arcane var _buildFaces : Vector.<NGon>;
		
//		arcane var _tempMesh : Mesh;
		
		arcane var _portals : Vector.<BSPPortal>;
		arcane var _backPortals : Vector.<BSPPortal>;
		
		private static var _completeEvent : Event;
		
		/**
		 * Builds the node hierarchy from the given faces
		 * 
		 * @private
		 */
		arcane function build(faces : Vector.<NGon> = null) : void
		{
			if (!_completeEvent) _completeEvent = new Event(Event.COMPLETE);
			if (faces) _buildFaces = faces;
			_bestScore = Number.POSITIVE_INFINITY;
			if (_convex)
				solidify(_buildFaces);
			else
				getBestPlane(_buildFaces);
		}
		
		/**
		 * Finds the best picking plane.
		 */
		private function getBestPlane(faces : Vector.<NGon>) : void
		{
			var face : NGon;
			var len : int = faces.length;
			var startTime : int = getTimer();
			
			do {
				face = faces[_planeCount];
				if (face._isSplitter) continue;
				getPlaneScore(face.plane, faces);
				if (_bestScore == 0) _planeCount = len;
			} while (++_planeCount < len && getTimer()-startTime < _maxTimeOut);
			
			if (_planeCount >= len) {
				if (_bestPlane)
					// best plane was found, subdivide
					setTimeout(constructChildren, 1, _bestPlane, faces);
				else {
					_convex = true;
					_solidPlanes = gatherConvexPlanes(faces);
					setTimeout(solidify, 1, faces);
				}
			}
			else {
				setTimeout(getBestPlane, 1, faces);
			}
		}
		
		/**
		 * Finds all unique planes in a convex set of faces, used to turn the tree into a solid leaf tree (allows us to have empty or "solid" space)
		 */
		private function gatherConvexPlanes(faces : Vector.<NGon>) : Vector.<Plane3D>
		{
			var planes : Vector.<Plane3D> = new Vector.<Plane3D>();
			var i : int = faces.length;
			var j : int;
			var srcPlane : Plane3D;
			var check : Boolean;
			var face : NGon;
			
			while (--i >= 0) {
				face = faces[i];
				if (!face._isSplitter) {
					srcPlane = face.plane;
					j = planes.length;
					check = true;
					// see if plane is already used as (convex) partition plane
					while (--j >= 0 && check) {
						if (face.isCoinciding(planes[j]))
							check = false;
					}
					if (check) planes.push(srcPlane);
				}
			}
			return planes;
		}
		
		/**
		 * Takes a set of convex faces and creates the solid leaf node
		 */
		private function solidify(faces : Vector.<NGon>) : void
		{
			if (!_solidPlanes.length) {
				// no planes left, is leaf
				_isLeaf = true;

				_faces = faces;
				if (faces.length > 0)
					addNGons(faces);
				
			}
			else {
				_partitionPlane = _solidPlanes.pop();
				_positiveNode = new BSPNode(this);
				_positiveNode.name = name + " -> +";
				_positiveNode._convex = true;
				_positiveNode._maxTimeOut = _maxTimeOut;
				_positiveNode._buildFaces = faces;
				_positiveNode._solidPlanes = _solidPlanes;
			}
			completeNode();
		}
		
		/**
		 * Adds faces to the leaf mesh based on NGons
		 */
		private function addNGons(faces : Vector.<NGon>) : void
		{
			var len : int = faces.length;
			var tris : Vector.<Face>;

			for (var i : int = 0; i < len; ++i) {
				addFaces(faces[i].triangulate());

			}
			_assignedFaces = faces.length;
		}
		
		/**
		 * Calculates the score for a given plane. The lower the score, the better a partition plane it is.
		 * Score is -1 if the plane is completely unsuited.
		 */
		private function getPlaneScore(candidate : Plane3D, faces : Vector.<NGon>) : void
		{
			var score : Number;
			var classification : int;
			var plane : Plane3D;
			var face : NGon;
			var i : int = faces.length;
			var posCount : int, negCount : int, splitCount : int;
			
			while (--i >= 0) {
				face = faces[i];
				classification = face.classifyToPlane(candidate);
				if (classification == -2) { 
					plane = face.plane;
					if (candidate.a * plane.a + candidate.b * plane.b + candidate.c * plane.c > 0)
						++posCount;
					else
						++negCount;
				}
				else if (classification == Plane3D.BACK)
					++negCount;
				else if (classification == Plane3D.FRONT)
					++posCount;
				else
					++splitCount;
			}
			
			// all polys are on one side
			if ((posCount == 0 || negCount == 0) && splitCount == 0)
				return;
			else {
				score = Math.abs(negCount-posCount)*_balanceWeight + splitCount*_splitWeight;
				if (candidate._alignment != Plane3D.X_AXIS || candidate._alignment != Plane3D.Z_AXIS) {
					
					if (candidate._alignment != Plane3D.Y_AXIS)
						score *= _nonXZWeight;
					else
						score *= _nonYWeight;
				}
				
			}
			
			if (score >= 0 && score < _bestScore) {
				_bestScore = score;
				_bestPlane = candidate;
			}
		}
		
		/**
		 * Builds the child nodes, based on the partition plane
		 */
		private function constructChildren(bestPlane : Plane3D, faces : Vector.<NGon>) : void
		{
			var classification : int;
			var face : NGon;
			var len : int = faces.length;
			var i : int = 0;
			var plane : Plane3D;
			
			_positiveFaces = new Vector.<NGon>();
			_negativeFaces = new Vector.<NGon>();
			
			_partitionPlane = bestPlane;
			
			do {
				face = faces[i];
				classification = face.classifyToPlane(bestPlane);
				
				if (classification == -2) { 
					plane = face.plane;
					
					if (bestPlane.a * plane.a + bestPlane.b * plane.b + bestPlane.c * plane.c > 0) {
						_positiveFaces.push(face);
						face._isSplitter = true;
					}
					else {
						_negativeFaces.push(face);
					}
				}
				else if (classification == Plane3D.FRONT)
					_positiveFaces.push(face);
				else if (classification == Plane3D.BACK)
					_negativeFaces.push(face);
				else {
					var splits : Vector.<NGon> = face.split(_partitionPlane);
					_positiveFaces.push(splits[0]);
					_negativeFaces.push(splits[1]);
					++_newFaces;
				}
			} while (++i < len);

			_positiveNode = new BSPNode(this);
			_positiveNode.name = name + " -> +";
			_positiveNode._maxTimeOut = _maxTimeOut;
			_positiveNode._buildFaces = _positiveFaces;
			_negativeNode = new BSPNode(this);
			_negativeNode.name = name + " -> -";
			_negativeNode._maxTimeOut = _maxTimeOut;
			_negativeNode._buildFaces = _negativeFaces;
			completeNode();
		}
		
		/**
		 * Cleans up temporary data and notifies parent of completion
		 */
		private function completeNode() : void
		{
			_negativeFaces = null;
			_positiveFaces = null;
			_buildFaces = null;
			_solidPlanes = null;
			dispatchEvent(_completeEvent);
		}
		
	/*
	 * Methods used to generate the PVS
	 */
	 	/**
	 	 * Creates portals on this node's partition plane, connecting linking leaves on either side.
	 	 */
 		arcane function generatePortals(rootNode : BSPNode) : Vector.<BSPPortal>
 		{
 			if (_isLeaf || _convex) return null;
 			
 			var portal : BSPPortal = new BSPPortal();
 			var posPortals : Vector.<BSPPortal>;
 			var finalPortals : Vector.<BSPPortal>;
 			var splits : Vector.<BSPPortal>;
 			var i : int;
 			
 			if (!portal.fromNode(this, rootNode)) return null;
 			portal.frontNode = _positiveNode;
 			portal.backNode = _negativeNode;
 			posPortals = _positiveNode.splitPortalByChildren(portal, Plane3D.FRONT);
 			
			if (!_negativeNode) return posPortals;
 			
			if (posPortals) {
				i = posPortals.length;
 				while (--i >= 0) {
					splits = _negativeNode.splitPortalByChildren(posPortals[i], Plane3D.BACK);
 					if (splits) {
 						if (!finalPortals) finalPortals = new Vector.<BSPPortal>();
 						finalPortals = finalPortals.concat(splits);
 					}
 				}
 			}
 			
 			return finalPortals;
 		}
 		
 		/**
	 	 * Splits a portal by this node's children, creating portals between leaves.
	 	 */
 		arcane function splitPortalByChildren(portal : BSPPortal, side : int) : Vector.<BSPPortal>
 		{
 			var portals : Vector.<BSPPortal>;
 			var splits : Vector.<BSPPortal>;
 			var classification : int;
 			
 			if (!portal) return new Vector.<BSPPortal>();
 			
 			if (side == Plane3D.FRONT)
				portal.frontNode = this;
			else
				portal.backNode = this;
 			
			if (_isLeaf) {
				portals = new Vector.<BSPPortal>();
				portals.push(portal);
				return portals;
			}
			else if (_convex) {
				if (portal.nGon.classifyToPlane(_partitionPlane) != -2)
					portal.nGon.trim(_partitionPlane);

				// portal became too small
				if (portal.nGon.isNeglectable())
					return null;
				
				portals = _positiveNode.splitPortalByChildren(portal, side);
				return portals;
			}
 			
 			classification = portal.nGon.classifyToPlane(_partitionPlane);
 			
 			switch (classification) {
 				case Plane3D.FRONT:
 					portals = _positiveNode.splitPortalByChildren(portal, side);
 					break;
 				case Plane3D.BACK:
					if (_negativeNode) portals = _negativeNode.splitPortalByChildren(portal, side);
					else portals = null;
 					break;
 				case Plane3D.INTERSECT:
 					splits = portal.split(_partitionPlane);
					// how can positiveNode be null?
 					portals = _positiveNode.splitPortalByChildren(splits[0], side);
					splits = _negativeNode.splitPortalByChildren(splits[1], side);
 					
					if (portals && splits)
						portals = portals.concat(splits);
					else if (!portals) portals = splits;
 					
 					break;
 			}
 			
 			return portals;
 		}
		
		/**
	 	 * Assigns a portal to this leaf, looking in.
	 	 */
		arcane function assignPortal(portal : BSPPortal) : void
 		{
 			if (!_portals) _portals = new Vector.<BSPPortal>();
 			_portals.push(portal);
 			
 			// temp
// 			var faces : Vector.<Face>;
// 			if(!_tempMesh) {
//				_tempMesh = new Mesh();
//			}
//			portal.nGon.material = new WireColorMaterial(null, {alpha: .5});
//			faces = portal.nGon.triangulate();
//			
//			for (var j : int = 0; j < faces.length; j++)
//				_tempMesh.addFace(faces[j]);
 		}
 		
 		/**
 		 * Assigns a portal to this leaf, looking out.
 		 */
 		arcane function assignBackPortal(portal : BSPPortal) : void
		{
			if (!_backPortals) _backPortals = new Vector.<BSPPortal>();
			_backPortals.push(portal);
		}
		
		/**
		 * Takes a set of portals and applies the visibility information
		 */
		arcane function processVislist(portals : Vector.<BSPPortal>) : void
		{
			if (!_backPortals || !portals) return;
			
			var backLen : int = _backPortals.length;
			var backPortal : BSPPortal;
			var portalsLen : int = portals.length;
			var portal : BSPPortal;
			var visLen : int = 0;
			
			_visList = new Vector.<int>();
			
			for (var i : int = 0; i < backLen; ++i) {
				backPortal = _backPortals[i];
				// direct neighbours are always visible
				if (_visList.indexOf(backPortal.frontNode.leafId) == -1)
					_visList[visLen++] = backPortal.frontNode.leafId;
					
				for (var j : int = 0; j < portalsLen; ++j) {
					portal = portals[j];
					// if in vislist and not yet added
					if (backPortal.isInList(backPortal.visList, portal.index) && (_visList.indexOf(portal.frontNode.leafId) == -1))
						_visList[visLen++] = portals[j].frontNode.leafId;
				}
			}
			_visList.sort(sortVisList);
			
			_portals = null;
			_backPortals = null;
		}	
		
		/**
		 * Sort the vislist so it can be culled fast
		 */
		private function sortVisList(a : int, b : int) : Number
		{
			return a < b? -1 : (a == b? 0 : 1);
		}

		public function removeTJunctions(targetNode : BSPNode, portal : BSPPortal) : void 
		{
			var faces : Array = _mesh.faces;
			var face : Face;
			var i : int = -1;
			var len : int = faces.length;
			var plane : Plane3D = portal.nGon.plane;
			
			while (++i < len) {
				face = Face(faces[i]);
				if (faceHasEdgeOnPlane(face, plane) && testTJunctions(face, targetNode._mesh.faces, plane)) {
					// one face removed, two created and placed at the end of the list
					--i;
					++len;
				}
			}
		}

		private function faceHasEdgeOnPlane(face : Face, plane : Plane3D) : Boolean 
		{
			var v0 : Vertex = face._v0;
			var v1 : Vertex = face._v1;
			var v2 : Vertex = face._v2;
			var numEdge : int;
			var d0 : Number, d1 : Number, d2 : Number;
			var align : int = plane._alignment;
			var a : Number = plane.a,
				b : Number = plane.b,
				c : Number = plane.c,
				d : Number = plane.d;
			
			if (align == Plane3D.X_AXIS) {
				d0 = a*v0._x + d;
				d1 = a*v1._x + d;
				d2 = a*v2._x + d;
			}
			else if (align == Plane3D.Y_AXIS) {
				d0 = b*v0._y + d;
				d1 = b*v1._y + d;
				d2 = b*v2._y + d;
			}
			else if (align == Plane3D.Z_AXIS) {
				d0 = c*v0._z + d;
				d1 = c*v1._z + d;
				d2 = c*v2._z + d;
			}
			else {
				d0 = a*v0._x + b*v0._y + c*v0._z + d;
				d1 = a*v1._x + b*v1._y + c*v1._z + d;
				d2 = a*v2._x + b*v2._y + c*v2._z + d;
			}
			if (d0 < BSPTree.EPSILON && d0 > -BSPTree.EPSILON) ++numEdge;
			if (d1 < BSPTree.EPSILON && d1 > -BSPTree.EPSILON) ++numEdge;
			if (d2 < BSPTree.EPSILON && d2 > -BSPTree.EPSILON) ++numEdge;
			
			return numEdge > 1;
		}

		private function testTJunctions(face : Face, targetFaces : Array, plane : Plane3D) : Boolean 
		{
			var targetFace : Face;
			var i : int = targetFaces.length;
			
			while (--i >= 0) {
				targetFace = Face(targetFaces[i]);
				if (faceHasEdgeOnPlane(face, plane) && fixTJunctions(face, targetFace))
					return true;
			}
			return false;
		}

		private function fixTJunctions(face : Face, targetFace : Face) : Boolean 
		{
			var i : int = 3;
			var v0 : Vertex = face._v0,
				v1 : Vertex = face._v1,
				v2 : Vertex = face._v2;
			var v : Vertex;
			var t : Number;
			
			while (--i >= 0) {
				v = Vertex(targetFace.vertices[i]);
				t = getTFraction(v0, v1, v);
				if (t > 0) {
					splitFace(face, 0, v, t);
					return true;
				}
				else {
					t = getTFraction(v1, v2, v);
					if (t > 0) {
						splitFace(face, 1, v, t);
						return true;
					}
					else {
						t = getTFraction(v2, v0, v);
						if (t > 0) {
							splitFace(face, 2, v, t);
							return true;
						}
					}
				}
			}
			return false;
		}

		private function splitFace(face : Face, index : int, tPoint : Vertex, t : Number) : void 
		{
			var face1 : Face;
			var face2 : Face;
			var v0 : Vertex = face._v0;
			var v1 : Vertex = face._v1;
			var v2 : Vertex = face._v2;
			var uv0 : UV = face._uv0;
			var uv1 : UV = face._uv1;
			var uv2 : UV = face._uv2;
			var uv : UV;
			var material : ITriangleMaterial = face.material;
			
			_mesh.removeFace(face);
			
			if (index == 0) {
				uv = new UV(uv0._u + t*(uv1._u-uv0._u), uv0._v + t*(uv1._v-uv0._v));
				face1 = new Face(v0, tPoint, v2, material, uv0, uv, uv2);
				face2 = new Face(tPoint, v1, v2, material, uv, uv1, uv2);
			}
			else if (index == 1) {
				uv = new UV(uv1._u + t*(uv2._u-uv1._u), uv1._v + t*(uv2._v-uv1._v));
				face1 = new Face(v0, v1, tPoint, material, uv0, uv1, uv);
				face2 = new Face(tPoint, v2, v0, material, uv, uv2, uv0);
			}
			else if (index == 2) {
				uv = new UV(uv2._u + t*(uv0._u-uv2._u), uv2._v + t*(uv0._v-uv2._v));
				face1 = new Face(v0, v1, tPoint, material, uv0, uv1, uv);
				face2 = new Face(tPoint, v1, v2, material, uv, uv1, uv2);
			}
			
			_mesh.addFace(face1);
			_mesh.addFace(face2);
		}

		private function getTFraction(v0 : Vertex, v1 : Vertex, tgt : Vertex) : Number
		{
			// test colinearity
			var dx1 : Number = v1._x - v0._x;
			var dy1 : Number = v1._y - v0._y;
			var dz1 : Number = v1._z - v0._z;
			var dx2 : Number = tgt._x - v0._x;
			var dy2 : Number = tgt._y - v0._y;
			var dz2 : Number = tgt._z - v0._z;
			var cx : Number = dy2 * dz1 - dz2 * dy1;
        	var cy : Number = dz2 * dx1 - dx2 * dz1;
        	var cz : Number = dx2 * dy1 - dy2 * dx1;
        	var t : Number;
        	var minT : Number;
        	var maxT : Number;
        	
        	// tgt is not on edge
        	if (cx*cx+cy*cy+cz*cz > BSPTree.EPSILON) return -1;
        	
        	// pick the divisor with highest absolute value to minimize rounding errors
        	if ((dx1 > 0 && dx1 >= dy1 && dx1 >= dz1) ||
				(dx1 < 0 && dx1 <= dy1 && dx1 <= dz1)) {
				dx1 = 1/dx1;
				t = dx2*dx1;
			}
			else if ((dy1 > 0 && dy1 >= dx1 && dy1 >= dz1) ||
					(dy1 < 0 && dy1 <= dx1 && dy1 <= dz1)) {
				dy1 = 1/dy1;
				t = dy2*dy1;
			}
			else if ((dz1 > 0 && dz1 >= dx1 && dz1 >= dy1) ||
					(dz1 < 0 && dz1 <= dx1 && dz1 <= dy1)) {
				dz1 = 1/dz1;
				t = dz2*dz1;
			}
        	
        	maxT = 1-minT;
        	
        	if (t > 0.002 && t < 0.998) return t;
        	
			return -1;
		}

		/**
		 * Generates bevel planes used for collision detection (prevents offsets causing false collisions at angles > 180°)
		 */
		public function generateBevelPlanes(targetNode : BSPNode) : void
		{
			var node : BSPNode = _parent;

			while (node && node._convex) {
				node.createBevelPlanes(_faces, targetNode._faces);
				node = node._parent;
			}
		}

		// to do: there are no bevel planes if partition planes form concave shape
		private function createBevelPlanes(sourceNGons : Vector.<NGon>, targetNGons : Vector.<NGon>) : void
		{
			var i : int = sourceNGons.length, j : int;
			var srcNGon : NGon, tgtNGon : NGon;
			var tgtPlane : Plane3D;
			var tgtLen : int = targetNGons.length;
			var bevel : Plane3D;
			var a1 : Number, b1 : Number, c1 : Number;
			var a2 : Number, b2 : Number, c2 : Number;

			a1 = _partitionPlane.a;
			b1 = _partitionPlane.b;
			c1 = _partitionPlane.c;

			while (--i >= 0) {
				srcNGon = sourceNGons[i];

				// nGon is coinciding with partition plane, we need to check it
				if (srcNGon.classifyToPlane(_partitionPlane) == -2) {
					j = tgtLen;
					while (--j >= 0) {
						tgtNGon = targetNGons[j];
						tgtPlane = tgtNGon.plane;
						a2 = tgtPlane.a;
						b2 = tgtPlane.b;
						c2 = tgtPlane.c;

						// if angle between planes < 0 and adjacent, create bevel plane
						if (a1*a2+b1*b2+c1*c2 < -BSPTree.EPSILON &&
							srcNGon.adjacent(tgtNGon)) {
							bevel = new Plane3D(a1+a2, b1+b2, c1+c2, _partitionPlane.d+tgtPlane.d);
							bevel.normalize();
							if (isNaN(bevel.a) || isNaN(bevel.b) || isNaN(bevel.c) || isNaN(bevel.d))
								trace ("Warning: invalid bevel plane, this could indicate an integrity error in the source model.");
							else {
								if (!_bevelPlanes) _bevelPlanes = new Vector.<Plane3D>();
   								_bevelPlanes.push(bevel);
							}
						}
					}
				}
			}
		}
	}
}