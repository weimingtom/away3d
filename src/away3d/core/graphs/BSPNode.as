package away3d.core.graphs
{
	import flash.utils.Dictionary;
	import away3d.core.base.Object3D;
	import away3d.core.project.ProjectorType;
	import away3d.materials.WireColorMaterial;
	import away3d.arcane;
	import away3d.core.base.Face;
	import away3d.core.base.Mesh;
	import away3d.core.geom.Frustum;
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
	public final class BSPNode extends EventDispatcher
	{
		public var leafId : int = -1;
		public var nodeId : int;
		public var renderMark : int = -1;
		
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
		
		// leaf only
		arcane var _mesh : Mesh;					// contains the model for this face
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
		
		// used for collision detection
		private var _middle : Number3D = new Number3D();
		
		arcane var _children : Array;

		/**
		 * Creates a new BSPNode object.
		 * 
		 * @param parent A reference to the parent BSPNode. Pass null if this is the root node.
		 */
		public function BSPNode(parent : BSPNode)
		{
			nodeId = BSPTree.nodeCount;
			BSPTree.nodeCount++;
			_parent = parent;
		}
		
		/**
		 * Sends a traverser down the dynamic children
		 * 
		 * @private
		 */
		public function traverseChildren(traverser : Traverser) : void
		{
			var i : int = _children.length;
			var child : Object3D;
			
			while (--i >= 0) {
				child = Object3D(_children[i]);
				if (child._sceneGraphMark != -1 && traverser.match(child)) {
					traverser.enter(child);
					traverser.apply(child);
					traverser.leave(child);
				}
			}
		}
		
		/**
		 * Adds a dynamic child to this leaf
		 * 
		 * @private
		 */
		public function addChild(child : Object3D) : void
		{
			if (!_children) _children = [];
			
			child._sceneGraphMark = leafId;
			_children.push(child);
		}

		/**
		 * Removes a dynamic child from this leaf
		 * 
		 * @private
		 */
		public function removeChild(child : Object3D) : void
		{
			var index : int = _children.indexOf(child);
			if (index != -1) _children.splice(index, 1);
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
				// faster screenZ calc
				_mesh.pushfront = true;
			}
			
			if (len == 0) return;
			
			do {
				face = faces[i];
				face.generateEdgePlanes();
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
			var face : Face;
			
			if (_isLeaf)
				return _mesh? findCollision(start, end, radii) : null;
			
			var startDist : Number = 	_partitionPlane.a*start.x +
										_partitionPlane.b*start.y +
										_partitionPlane.c*start.z +
										_partitionPlane.d;	
			var endDist : Number = 	_partitionPlane.a*end.x +
									_partitionPlane.b*end.y +
									_partitionPlane.c*end.z +
									_partitionPlane.d;
			var radX : Number = radii.x*_partitionPlane.a;
			var radY : Number = radii.y*_partitionPlane.b;
			var radZ : Number = radii.z*_partitionPlane.c;
			var radius : Number = Math.sqrt(radX*radX + radY*radY + radZ*radZ);
			// movement is completely on one side of the node, recurse down that side
			if (startDist >= radius && endDist >= radius) {
				if (_positiveNode) face = _positiveNode.traceCollision(start, end, radii);
				else return null;
			}
			else if (startDist < -radius && endDist < -radius) {
				if (_negativeNode) face = _negativeNode.traceCollision(start, end, radii);
				else return null;
			}
			else if (startDist < endDist) {
				if (_negativeNode)
					face = _negativeNode.traceCollision(start, end, radii);
				if (!face && _positiveNode) 
					face = _positiveNode.traceCollision(start, end, radii);
			}
			else {
				if (_positiveNode)
					face = _positiveNode.traceCollision(start, end, radii);
				if (!face && _negativeNode) 
					face = _negativeNode.traceCollision(start, end, radii);
			}
			return face;
		}
		
		/**
		 * Finds a colliding face in a leaf.
		 */
		private function findCollision(start : Number3D, end : Number3D, radii : Number3D) : Face
		{
			var faces : Array = _mesh.faces;
			var face : Face;
			var i : int = faces.length;
			var startDist : Number, endDist : Number;
			var plane : Plane3D;
			var fraction : Number;
			var radX : Number, radY : Number, radZ : Number;
			var radius : Number;
			// when nodes are convex, we could return first intersecting poly
			// since we're supposed to be inside the leaf
			while (face = Face(faces[--i])) {
				plane = face.plane;
				radX = radii.x*plane.a;
				radY = radii.y*plane.b;
				radZ = radii.z*plane.c;
				radius = Math.sqrt(radX*radX + radY*radY + radZ*radZ);
				startDist = plane.a*start.x +
							plane.b*start.y +
							plane.c*start.z +
							plane.d;
				endDist = 	plane.a*end.x +
							plane.b*end.y +
							plane.c*end.z +
							plane.d;
							
				// both points are far enough on the same side of the tri's plane
				// so no intersection
				if ((startDist >= radius && endDist >= radius) ||
					(startDist < -radius && endDist < -radius))
						continue;
				
				// calculate the fraction [0, 1] on the movement line
				fraction = startDist/(startDist-endDist);
				
				// no need to check beyond the end position
				if (fraction > 1) fraction = 1;
				else if (fraction < 0) fraction = 0;
				// the bounding sphere intersects with the plane
				
				_middle.x = start.x + fraction*(end.x-start.x);
				_middle.y = start.y + fraction*(end.y-start.y);
				_middle.z = start.z + fraction*(end.z-start.z);
				
				// check all edge planes of the triangle
				// if sphere completely on negative side, no intersection and escape asap
				// no inlining, so a lot of dry violations
				plane = face._edgePlane01;
				if (plane.a*_middle.x + plane.b*_middle.y + plane.c*_middle.z + plane.d
					< -radius) continue;
				
				plane = face._edgePlane12;
				if (plane.a*_middle.x + plane.b*_middle.y + plane.c*_middle.z + plane.d
					< -radius) continue;
				
				plane = face._edgePlane20;
				if (plane.a*_middle.x + plane.b*_middle.y + plane.c*_middle.z + plane.d
					< -radius) continue;
				
				plane = face._edgePlaneN0;
				if (plane.a*_middle.x + plane.b*_middle.y + plane.c*_middle.z + plane.d
					< -radius) continue;
				
				plane = face._edgePlaneN1;
				if (plane.a*_middle.x + plane.b*_middle.y + plane.c*_middle.z + plane.d
					< -radius) continue;
				
				plane = face._edgePlaneN2;
				if (plane.a*_middle.x + plane.b*_middle.y + plane.c*_middle.z + plane.d
					< -radius) continue;
				
				return face;
			}
			
			return null;
		}


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
		private var _convex : Boolean;
		// triangle planes used to create solid leaf tree
		private var _solidPlanes : Vector.<Plane3D>;
		
		private var _planeCount : int;
		
		arcane var _maxTimeOut : int = 500;
		
		arcane var _newFaces : int;
		arcane var _assignedFaces : int;
		arcane var _buildFaces : Vector.<NGon>;
		
		arcane var _tempMesh : Mesh;
		
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
				if (faces.length > 0)
					addNGons(_buildFaces);
			}
			else {
				_partitionPlane = _solidPlanes.pop();
				_positiveNode = new BSPNode(this);
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
					if (bestPlane.a * plane.a + bestPlane.b * plane.b + bestPlane.c * plane.c > 0)
						_positiveFaces.push(face);
					else
						_negativeFaces.push(face);
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
			_positiveNode._maxTimeOut = _maxTimeOut;
			_positiveNode._buildFaces = _positiveFaces;
			_negativeNode = new BSPNode(this);
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
 			var faces : Vector.<Face>;
 			if(!_tempMesh) {
				_tempMesh = new Mesh();
			}
			portal.nGon.material = new WireColorMaterial(null, {alpha: .5});
			faces = portal.nGon.triangulate();
			
			for (var j : int = 0; j < faces.length; j++)
				_tempMesh.addFace(faces[j]);
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
		
	}
}