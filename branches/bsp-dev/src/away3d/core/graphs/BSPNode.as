package away3d.core.graphs
{
	import __AS3__.vec.Vector;
	
	import away3d.arcane;
	import away3d.core.base.Face;
	import away3d.core.base.Mesh;
	import away3d.core.base.UV;
	import away3d.core.base.Vertex;
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
		
		private var _lastIterationPositive : Boolean;
		
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
		private var _splitCount : int;
		private var _positiveCount : int;
		private var _negativeCount : int;
		private var _bestPlane : Plane3D;
		private var _canditatePlane : Plane3D;
		private var _bestScore : Number;
		private var _splitWeight : Number = 3;
		private var _balanceWeight : Number = 1;
		private var _maxTimeout : int = 1000;
		private var _deferralTime : int = 1;
		private var _buildFaces : Vector.<NGon>;
		private var _buildStepIndex : int;
		private var _countStepIndex : int;
		private var _positiveFaces : Vector.<NGon>;
		private var _negativeFaces : Vector.<NGon>;
		private var _completeCount : int;
		
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
		arcane function build(faces : Vector.<NGon>) : void
		{
			var plane : Plane3D;
			var i : int;
			
			_buildStepIndex = 0;
			_buildFaces = faces;
			
			_bestScore = Number.POSITIVE_INFINITY;
			
			collapseFaces(faces);
			buildStep();
		}
		
		/**
		 * Collapses convex NGons if they still form a new convex NGon
		 * 
		 * @private
		 */
		private function collapseFaces(polys : Vector.<NGon>) : void
		{
			var poly1 : NGon;
			var poly2 : NGon;
			var listChanged : Boolean;
			
			do {
				listChanged = false;
				// length changes during loop, do not store in var
				for (var i : int = 0; i < polys.length; ++i) {
					poly1 = polys[i];
					for (var j : int = i+1; j < polys.length; ++j) {
						poly2 = polys[j];
						if (poly1.collapse(poly2)) {
							// remove second poly & adjust index
							polys.splice(j--, 1);
							listChanged = true;
						}
					}
				}
			} while (listChanged);
		}
		
		/**
		 * One step in the build process, to prevent lock-ups
		 * 
		 * @private
		 */
		arcane function buildStep() : void
		{
			var face : NGon;
			var len : int = _buildFaces.length;
			
			if (_buildStepIndex < len) {
				face = _buildFaces[_buildStepIndex];
				getPlaneScore(face.plane);
				++_buildStepIndex;
			}
			else {
				if (_bestPlane) {
					// best plane was found, subdivide
					constructChildren(_bestPlane);
				}
				else {
					// no best plane, must be leaf
					_isLeaf = true;
					if (_buildFaces.length > 0)
						addNGons(_buildFaces);
					completeNode();
				}
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
		private function getPlaneScore(plane : Plane3D) : void
		{
			_canditatePlane = plane;
			_splitCount = 0;
			_positiveCount = 0;
			_negativeCount = 0;
			_countStepIndex = 0;
			
			getPlaneScoreStep();
		}
		
		/**
		 * One step in the plane scoring process, used to avoid lock-ups
		 */
		private function getPlaneScoreStep() : void
		{
			var score : Number;
			var startTime : int = getTimer();
			var classification : int;
			var len : int = _buildFaces.length;
			var plane : Plane3D;
			var face : NGon;
			
			do {
				face = _buildFaces[_countStepIndex];
				classification = face.classifyToPlane(_canditatePlane);
				if (classification == -2) { 
					plane = face.plane;
					if (_canditatePlane.a * plane.a + _canditatePlane.b * plane.b + _canditatePlane.c * plane.c > 0)
						++_positiveCount;
					else
						++_negativeCount;
				}
				else if (classification == Plane3D.BACK)
					++_negativeCount;
				else if (classification == Plane3D.FRONT)
					++_positiveCount;
				else
					++_splitCount;
					
			} while (++_countStepIndex < len && (getTimer()-startTime < _maxTimeout));
			
			if (_countStepIndex == len) {
				// all polys are on one side
				if ((_positiveCount == 0 || _negativeCount == 0) && _splitCount == 0)
					score = -1;
				else
					score = Math.abs(_negativeCount-_positiveCount)*_balanceWeight+_splitCount*_splitWeight
				
				if (score > 0 && score < _bestScore) {
					_bestScore = score;
					_bestPlane = _canditatePlane;
				}
				
				setTimeout(buildStep, _deferralTime);
			}
			else {
				setTimeout(getPlaneScoreStep, _deferralTime);
			}
		}
		
		/**
		 * Builds the child nodes, based on the partition plane
		 */
		private function constructChildren(plane : Plane3D) : void
		{
			_buildStepIndex = 0;
			
			_positiveFaces = new Vector.<NGon>();
			_negativeFaces = new Vector.<NGon>();
			
			_partitionPlane = plane;
			
			constructStep();
		}
		
		/**
		 * One step in the child-building process, to prevent lock-ups
		 */
		private function constructStep() : void
		{
			var startTime : int = getTimer();
			var classification : int;
			var face : NGon;
			var len : int = _buildFaces.length;
			var plane : Plane3D;
			
			do {
				face = _buildFaces[_buildStepIndex];
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
			} while (++_buildStepIndex < len && (getTimer()-startTime < _maxTimeout));
			
			if (_buildStepIndex == len) {
				_positiveNode = new BSPNode(this);
				_negativeNode = new BSPNode(this);
				
				_completeCount = 0;
				_positiveNode.addEventListener(Event.COMPLETE, onBuildChildComplete);
				_positiveNode.build(_positiveFaces);
				_negativeNode.addEventListener(Event.COMPLETE, onBuildChildComplete);
				_negativeNode.build(_negativeFaces);
			}
			else {
				setTimeout(constructStep, _deferralTime);
			}
		}
		
		/**
		 * Called when a child has finished building
		 */
		private function onBuildChildComplete(event : Event) : void
		{
			event.target.removeEventListener(Event.COMPLETE, onBuildChildComplete);
			if (++_completeCount == 2) completeNode();
		}
		
		/**
		 * Cleans up temporary data and notifies parent of completion
		 */
		private function completeNode() : void
		{
			_negativeFaces = null;
			_positiveFaces = null;
			_buildFaces = null;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
/*
 * Methods used to generate the PVS
 */
		arcane function findPortals() : void
		{
			if (_positiveNode && !_positiveNode._isLeaf) _positiveNode.findPortals();
			if (_negativeNode && !_negativeNode._isLeaf) _negativeNode.findPortals();
			
			if (!_isLeaf) {
				var portal : BSPPortal = new BSPPortal();
				portal.fromNode(this);
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
				plane = face._plane;
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