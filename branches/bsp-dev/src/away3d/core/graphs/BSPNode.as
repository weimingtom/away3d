package away3d.core.graphs
{
	import __AS3__.vec.Vector;
	
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
	public class BSPNode extends EventDispatcher
	{
		private static var EPSILON : Number = 1/32;
		
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
		
		arcane var _lastIterationPositive : Boolean;
		
		//arcane var _session : AbstractRenderSession;
		
		arcane var _bounds : Array;
		
		public var extra : Object = new Object();
		
		arcane var _minX : Number;
		arcane var _minY : Number;
		arcane var _minZ : Number;
		arcane var _maxX: Number;
		arcane var _maxY: Number;
		arcane var _maxZ: Number;
		
		// used for collision detection
		private var _middle : Number3D = new Number3D();
		
		// used for building tree
		private var _bestPlane : Plane3D;
		private var _bestScore : Number;
		private var _splitWeight : Number = 10;
		private var _balanceWeight : Number = 1;
		private var _maxTimeout : int = 1000;
		private var _deferralTime : int = 1;
		private var _positiveFaces : Vector.<NGon>;
		private var _negativeFaces : Vector.<NGon>;
		private var _completeCount : int;
		
		arcane var _buildFaces : Vector.<NGon>;
		
		arcane var _tempMesh : Mesh;
		
		private var _portals : Vector.<BSPPortal>;
		
		/**
		 * Creates a new BSPNode object.
		 * 
		 * @param parent A reference to the parent BSPNode. Pass null if this is the root node.
		 */
		public function BSPNode(parent : BSPNode)
		{
			_parent = parent;
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
			if (startDist >= radius && endDist >= radius)
				face = _positiveNode.traceCollision(start, end, radii);
			else if (startDist < -radius && endDist < -radius)
				face = _negativeNode.traceCollision(start, end, radii);
			else if (startDist < endDist)
					face = 	_negativeNode.traceCollision(start, end, radii) || 
							_positiveNode.traceCollision(start, end, radii);
			else
					face = 	_positiveNode.traceCollision(start, end, radii) || 
							_negativeNode.traceCollision(start, end, radii);
			
			return face;
		}
		
/*
 * METHODS USED DURING RENDERING STEP
 */
		/**
		 * Moves a traverser through the nodes in the correct bsp order. orderNodes must be called before traversal
		 * 
		 * @private
		 */
		arcane function traverse(traverser:Traverser):void
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
		
		/**
		 * Determines the traversal order of the nodes based on a position in the tree
		 * 
		 * @private
		 */
		arcane function orderNodes(point : Number3D) : void
		{
			if (_isLeaf) return;
			_lastIterationPositive = (	_partitionPlane.a*point.x +
										_partitionPlane.b*point.y +
										_partitionPlane.c*point.z +
										_partitionPlane.d ) > 0;
								
			if (_positiveNode && !(_positiveNode._culled || _positiveNode._isLeaf)) _positiveNode.orderNodes(point);
			if (_negativeNode && !(_negativeNode._culled || _negativeNode._isLeaf)) _negativeNode.orderNodes(point);
		}
		
		/**
		 * Recursively checks if node's culled. If all are culled, so is the current node. Used to avoid future recursion.
		 * TO DO: remove recursion, use bifurcate iteration algo
		 * 
		 * @private
		 */ 
		arcane function propagateCulled() : void
		{
			if (_isLeaf) return;
			if (!_positiveNode._isLeaf) _positiveNode.propagateCulled();
			if (!_negativeNode._isLeaf) _negativeNode.propagateCulled();
			_culled = _positiveNode._culled && _negativeNode._culled;
		}
		
		/**
		 * Checks the current node's bounding box against a camera frustum and culls it if necessary
		 * 
		 * @private
		 */
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
		 * Adds all leaves in the node's hierarchy to the vector
		 * 
		 * @private
		 */
		arcane function gatherLeaves(leaves : Vector.<BSPNode>) : void
		{
			// TO DO: do this during build phase
			if (_isLeaf) {
				id = leaves.length;
				leaves.push(this);
			}
			else {
				_positiveNode.gatherLeaves(leaves);
				_negativeNode.gatherLeaves(leaves);
			}
		}
		
		/**
		 * Builds the node hierarchy from the given faces
		 * 
		 * @private
		 */
		arcane function build(faces : Vector.<NGon> = null) : void
		{
			if (faces) _buildFaces = faces;
			_bestScore = Number.POSITIVE_INFINITY;
			getBestScore(_buildFaces);
			// check if best score == 0, if so, best plane hands down
		}
		
		
		private var _planeCount : int;
		private var _maxTimeOut : int = 500;
		
		private function getBestScore(faces : Vector.<NGon>) : void
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
				if (_bestPlane) {
					// best plane was found, subdivide
					setTimeout(constructChildren, 1, _bestPlane, faces);
				}
				else {
					// no best plane, must be leaf
					_isLeaf = true;
					if (faces.length > 0)
						addNGons(faces);
					completeNode();
				}
			}
			else {
				setTimeout(getBestScore, 1, faces);
			}
		}
		
		private function addNGons(faces : Vector.<NGon>) : void
		{
			var tris : Vector.<Face>;
			var len : int = faces.length;
			for (var i : int = 0; i < len; ++i) {
				addFaces(faces[i].triangulate());
			}
		}
		
		/**
		 * Calculates the score for a given plane. The lower the score, the better a partition plane it is.
		 * Score is -1 if the plane is completely unsuited.
		 */
		private function getPlaneScore(candidate : Plane3D, faces : Vector.<NGon>) : void
		{
			var score : Number;
			var classification : int;
			var len : int = faces.length;
			var plane : Plane3D;
			var face : NGon;
			var i : int;
			var posCount : int, negCount : int, splitCount : int;
			
			do {
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
					
			} while (++i < len);
			
			// all polys are on one side
			if ((posCount == 0 || negCount == 0) && splitCount == 0)
				score = -1;
			else
				score = Math.abs(negCount-posCount)*_balanceWeight + splitCount*_splitWeight
			
			if (score >= 0 && score < _bestScore) {
				_bestScore = score;
				_bestPlane = candidate;
			}
		}
		
		/**
		 * Builds the child nodes, based on the partition plane
		 */
		private function constructChildren(plane : Plane3D, faces : Vector.<NGon>) : void
		{
			_positiveFaces = new Vector.<NGon>();
			_negativeFaces = new Vector.<NGon>();
			
			_partitionPlane = plane;
			
			var classification : int;
			var face : NGon;
			var len : int = faces.length;
			var plane : Plane3D;
			var i : int = 0;
			
			do {
				face = faces[i];
				classification = face.classifyToPlane(_partitionPlane);
				
				if (classification == -2) { 
					plane = face.plane;
					if (_partitionPlane.a * plane.a + _partitionPlane.b * plane.b + _partitionPlane.c * plane.c > 0)
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
				}
			} while (++i < len);
			
			_positiveNode = new BSPNode(this);
			_negativeNode = new BSPNode(this);
			_positiveNode._buildFaces = _positiveFaces;
			//_positiveNode.build(_positiveFaces);
			_negativeNode._buildFaces = _negativeFaces;
			//_negativeNode.build(_negativeFaces);
			completeNode();
		}
		
		private static const COMPLETE_EVENT : Event = new Event(Event.COMPLETE);
		
		/**
		 * Cleans up temporary data and notifies parent of completion
		 */
		private function completeNode() : void
		{
			_negativeFaces = null;
			_positiveFaces = null;
			_buildFaces = null;
			dispatchEvent(COMPLETE_EVENT);
		}
		
/*
 * Methods used to generate the PVS
 */
		arcane function findPortals(portals : Vector.<BSPPortal>) : void
		{
			var portal : BSPPortal;
			
			if (!_isLeaf) {
				if (_positiveNode) _positiveNode.findPortals(portals);
				if (_negativeNode) _negativeNode.findPortals(portals);
				portal = new BSPPortal();
				portal.fromNode(this);
				/* if (_parent) {
					var s : Vector.<BSPPortal> = portal.split(_parent._partitionPlane);
					if (this == _parent._positiveNode)
						portal = s[0];
					else
						portal = s[1];
				} */
				
				portals.push(portal);
			}
			
			/* var pos : Vector.<BSPPortal>;
			var neg : Vector.<BSPPortal>;
			var portal : BSPPortal;
			var len : int;
			var splits : Vector.<BSPPortal>;
			
			if (!_isLeaf) {
				pos = new Vector.<BSPPortal>();
				neg = new Vector.<BSPPortal>();
				if (portals) {
					len = portals.length;
					
					for (var i : int = 0; i < len; ++i) {
						splits = portals[i].split(_partitionPlane);
						if (splits[0]) pos.push(splits[0]);
						if (splits[1]) neg.push(splits[1]);
					}
				}
				
				portal = new BSPPortal();
				portal.fromNode(this);
				if (portals) trimPortal(portal, portals);
				pos.push(portal);
				
				var n : BSPPortal = portal.clone();
				n.nGon.plane.a = -portal.nGon.plane.a;
				n.nGon.plane.b = -portal.nGon.plane.b;
				n.nGon.plane.c = -portal.nGon.plane.c;
				n.nGon.plane.d = -portal.nGon.plane.d;
				neg.push(n);
				
				if (_positiveNode) _positiveNode.findPortals(pos);
				if (_negativeNode) _negativeNode.findPortals(neg);
			}
			else {
				_tempMesh = new Mesh();
				var tris : Vector.<Face>;
				for (var j : int = 0; j < portals.length; ++j) {
					tris = portals[j].nGon.triangulate();
					if (tris) {
						for (i = 0; i < tris.length; ++i) {
							_tempMesh.addFace(tris[i]);
							_tempMesh.bothsides = true;
						}
					}
				}
			} */
		}
		
		arcane function splitPortal(portal : BSPPortal) : Vector.<BSPPortal>
		{
			var pos : Vector.<BSPPortal>;
			var neg : Vector.<BSPPortal>;
			var splits : Vector.<BSPPortal>;
			
			if (_isLeaf) {
				splits = new Vector.<BSPPortal>(1);
				splits[0] = portal;
				return splits;
			}
			
			if (portal.nGon.plane == _partitionPlane) {
				if (_positiveNode) pos = _positiveNode.splitPortal(portal);
				if (_negativeNode) {
					for (var i : int = 0; i < pos.length; ++i) {
						if (!neg) neg = _negativeNode.splitPortal(pos[i]);
						else neg = neg.concat(_negativeNode.splitPortal(pos[i]));
					}
					
				}
			}
			else {
				splits = portal.split(_partitionPlane)
				
				if (splits[0] && _positiveNode) pos = _positiveNode.splitPortal(splits[0]);
				if (splits[1] && _negativeNode) neg = _negativeNode.splitPortal(splits[1]);
			}
			
			if (pos != null && neg != null) return pos.concat(neg);
			else if (pos) return pos;
			else return neg;
		}
		
		arcane function assignPortal(portal : BSPPortal) : void
		{
			var classification : int;
			
			if (_isLeaf) {
				if (!isHierarchyValid(portal)) return;
				if (!_portals) _portals = new Vector.<BSPPortal>();
				_portals.push(portal);
				//trimPortalToLeaf(portal);
				if (!portal.leaves) portal.leaves = new Vector.<BSPNode>();
				portal.leaves.push(this);
				return;
			}
			
			if (portal.nGon.plane == _partitionPlane) {
				if (_positiveNode) _positiveNode.assignPortal(portal);
				if (_negativeNode) _negativeNode.assignPortal(portal);
			}
			else {
				classification = portal.nGon.classifyToPlane(_partitionPlane)
				if (classification == Plane3D.BACK) {
					if (_negativeNode) _negativeNode.assignPortal(portal);
				}
				else if (classification == Plane3D.FRONT) {
					if (_positiveNode) _positiveNode.assignPortal(portal);
				}
			}
		}
		
		/**
		 * Checks if portal matches the hierarchy. Only occurs due to bounding box approx
		 */
		private function isHierarchyValid(portal : BSPPortal) : Boolean
		{
			var node : BSPNode = this;
			if (!node._parent) return true;
			
			do {
				if (node == portal.sourceNode) return true;
			} while (node = node._parent);
			return false;
		}
		
		arcane function linkPortals() : void
		{
			var len : int = _portals.length;
			var portal : BSPPortal;
			
			for (var i : int = 0; i < len; ++i) {
				portal = _portals[i];
				// portal only belongs to this leaf or is trimmed away
				if (portal.leaves.length < 2 || portal.nGon.vertices.length < 3) {
					// dispose
					_portals.splice(i, 1);
					--len;
					--i;
				}
				else {
					if (!_tempMesh) {
						_tempMesh = new Mesh();
						_tempMesh.bothsides = true;
					}
					var faces : Vector.<Face> = portal.nGon.triangulate();
					for (var j : int = 0; j < faces.length; ++j)
					{
						_tempMesh.addFace(faces[j]);
					}
				}
			}
		}
		
		private function trimPortalToLeaf(portal : BSPPortal) : void
		{
			var len : int = _mesh.faces.length;
			var face : Face;
			var facePlane : Plane3D;
			var portalPlane : Plane3D;
			var dot : Number;
			for (var i : int = 0; i < len; ++i) {
				face = _mesh.faces[i];
				facePlane = face.plane;
				portalPlane = portal.nGon.plane;
				dot = Math.abs(facePlane.a*portalPlane.a + facePlane.b*portalPlane.b + facePlane.c*portalPlane.c);
				// maybe I should split if they intersect?
				if (Math.abs(dot-1) > EPSILON)
					portal.nGon.trim(facePlane);
			}
		}
		
		private function trimPortal(portal : BSPPortal, portals : Vector.<BSPPortal>) : void
		{
			var len : int = portals.length;
			
			for (var i : int = 0; i < len; ++i) {
				portal.nGon.trim(portals[i].nGon.plane);
			}
		}

/*
 * Methods used for colision detection
 */
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
	}
}