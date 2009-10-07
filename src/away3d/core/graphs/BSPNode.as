package away3d.core.graphs
{
	import away3d.arcane;
	import away3d.core.base.Face;
	import away3d.core.base.Mesh;
	import away3d.core.base.UV;
	import away3d.core.base.Vertex;
	import away3d.core.geom.Frustum;
	import away3d.core.geom.Plane3D;
	import away3d.core.math.Number3D;
	import away3d.core.traverse.Traverser;
	import away3d.materials.ITriangleMaterial;
	
	import flash.display.Sprite;
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
		private static const BUILD_EPSILON : Number = 1/128;	
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
		private var _buildFaces : Vector.<Face>;
		private var _buildStepIndex : int;
		private var _countStepIndex : int;
		private var _positiveFaces : Vector.<Face>;
		private var _negativeFaces : Vector.<Face>;
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
			_bounds.push(new Number3D(_minX, _maxY, _minZ));
			_bounds.push(new Number3D(_minX, _minY, _maxZ));
			_bounds.push(new Number3D(_maxX, _maxY, _minZ));
			_bounds.push(new Number3D(_maxX, _minY, _maxZ));
			_bounds.push(new Number3D(_minX, _maxY, _maxZ));
			_bounds.push(new Number3D(_maxX, _maxY, _maxZ));
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
		arcane function build(faces : Vector.<Face>) : void
		{
			var plane : Plane3D;
			var i : int;
			
			_buildStepIndex = 0;
			_buildFaces = faces;
			
			_bestScore = Number.POSITIVE_INFINITY;
			
			buildStep();
		}
		
		/**
		 * One step in the build process, to prevent lock-ups
		 * 
		 * @private
		 */
		arcane function buildStep() : void
		{
			var face : Face;
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
						addFaces(_buildFaces);
					completeNode();
				}
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
			var face : Face;
			var len : int = _buildFaces.length;
			var numPos : int;
			var numNeg : int;
			var numDoubt : int;
			var v : Vertex;
			var dist : Number;
			var sideCount : int;
			var plane : Plane3D = _canditatePlane;
			var startTime : int = getTimer();
			
			do {
				face = _buildFaces[_countStepIndex];
				numPos = 0;
				numNeg = 0;
				numDoubt = 0;
				
				v = face._v0;
				dist = plane.a*v._x + plane.b*v._y + plane.c*v._z + plane.d;
				if (dist > BUILD_EPSILON)
					++numPos;
				else if (dist < -BUILD_EPSILON)
					++numNeg;
				else
					++numDoubt;
				
				v = face._v1;
				dist = plane.a*v._x + plane.b*v._y + plane.c*v._z + plane.d;
				if (dist > BUILD_EPSILON)
					++numPos;
				else if (dist < -BUILD_EPSILON)
					++numNeg;
				else
					++numDoubt;
					
				v = face._v2;
				dist = plane.a*v._x + plane.b*v._y + plane.c*v._z + plane.d;
				if (dist > BUILD_EPSILON)
					++numPos;
				else if (dist < -BUILD_EPSILON)
					++numNeg;
				else
					++numDoubt;
				//trace (numPos, numNeg, numDoubt);
				if (numDoubt == 3) {
					var plane2 : Plane3D = face.plane;
					// triangle coincides with plane
					// if facing into positive side, add to positive
					if (plane2.a * plane.a + plane2.b * plane.b + plane2.c * plane.c > 0)
						++_positiveCount;
					else
						++_negativeCount;
				}
				else if (numPos > 0 && numNeg == 0)
					++_positiveCount;
				else if (numNeg > 0 && numPos == 0)
					++_negativeCount;
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
					_bestPlane = plane;
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
			
			_positiveFaces = new Vector.<Face>();
			_negativeFaces = new Vector.<Face>();
			
			_partitionPlane = plane;
			
			constructStep();
		}
		
		/**
		 * One step in the child-building process, to prevent lock-ups
		 */
		private function constructStep() : void
		{
			var numPos : int;
			var numNeg : int;
			var numDoubt : int;
			var v : Vertex;
			var dist : Number;
			var face : Face;
			var len : int = _buildFaces.length;
			var plane : Plane3D = _partitionPlane;
			var startTime : int = getTimer();
			
			do {
				face = _buildFaces[_buildStepIndex];
				numPos = 0;
				numNeg = 0;
				numDoubt = 0;
				
				v = face._v0;
				dist = plane.a*v.x + plane.b*v.y + plane.c*v.z + plane.d;
				if (dist > BUILD_EPSILON)
					++numPos;
				else if (dist < -BUILD_EPSILON)
					++numNeg;
				else
					++numDoubt;
				
				v = face._v1;
				dist = plane.a*v.x + plane.b*v.y + plane.c*v.z + plane.d;
				if (dist > BUILD_EPSILON)
					++numPos;
				else if (dist < -BUILD_EPSILON)
					++numNeg;
				else
					++numDoubt;
					
				v = face._v2;
				dist = plane.a*v.x + plane.b*v.y + plane.c*v.z + plane.d;
				if (dist > BUILD_EPSILON)
					++numPos;
				else if (dist < -BUILD_EPSILON)
					++numNeg;
				else
					++numDoubt;
				
				if (numDoubt == 3) {
					// triangle coincides with plane
					// if facing into positive side, add to positive
					var plane2 : Plane3D = face.plane;
					if (plane2.a * plane.a + plane2.b * plane.b + plane2.c * plane.c > 0)
						_positiveFaces.push(face);
					else
						_negativeFaces.push(face);
				}
				else if (numPos > 0 && numNeg == 0)
					_positiveFaces.push(face);
				else if (numNeg > 0 && numPos == 0)
					_negativeFaces.push(face);
				else {
					splitFace(face, plane, _positiveFaces, _negativeFaces);
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
		
		/**
		 * Splits up a face into two along a given plane. Used to split up triangles along a partition plane.
		 */
		private function splitFace(face : Face, plane : Plane3D, posFaces : Vector.<Face>, negFaces : Vector.<Face>) : void
		{
			var v0 : Vertex = face._v0;
			var v1 : Vertex = face._v1;
			var v2 : Vertex = face._v2;
			var uv0 : UV = face._uv0;
			var uv1 : UV = face._uv1;
			var uv2 : UV = face._uv2;
			var vertPos : Array = new Array(), vertNeg : Array = new Array();
			var uvPos : Array = new Array(), uvNeg : Array = new Array();
			var faces : Array = new Array();
			var t : Number;
			var dot1 : Number = plane.a*v0.x + plane.b*v0.y + plane.c*v0.z + plane.d;
			var dot2 : Number = plane.a*v1.x + plane.b*v1.y + plane.c*v1.z + plane.d;
			var dot3 : Number = plane.a*v2.x + plane.b*v2.y + plane.c*v2.z + plane.d;
			
			if (Math.abs(dot1) < 0.01) dot1 = 0;
			if (Math.abs(dot2) < 0.01) dot2 = 0;
			if (Math.abs(dot3) < 0.01) dot3 = 0;
			
			if (dot1 >= 0) {
				vertPos.push(v0);
				uvPos.push(uv0);
			}
			if (dot1 <= 0) {
				vertNeg.push(v0);
				uvNeg.push(uv0);
			}
			
			// different signs (= intersects plane):
			if (dot1*dot2 < 0) {
				t = splitEdge(plane, v0, v1, vertPos, vertNeg);
				if (uv0) splitUV(uv0, uv1, t, uvPos, uvNeg);
			}
			
			if (dot2 >= 0) {
				vertPos.push(v1);
				uvPos.push(uv1);
			}
			if (dot2 <= 0) {
				vertNeg.push(v1);
				uvNeg.push(uv1);
			}
			
			if (dot2*dot3 < 0) {
				t = splitEdge(plane, v1, v2, vertPos, vertNeg);
				if (uv0) splitUV(uv1, uv2, t, uvPos, uvNeg);
			}
			
			if (dot3 >= 0) {
				vertPos.push(v2);
				uvPos.push(uv2);
			}
			if (dot3 <= 0) {
				vertNeg.push(v2);
				uvNeg.push(uv2);
			}
			
			if (dot3*dot1 < 0) {
				t = splitEdge(plane, v2, v0, vertPos, vertNeg);
				if (uv0) splitUV(uv2, uv0, t, uvPos, uvNeg);
			}
			
			createTriangles(vertPos, uvPos, posFaces, face.material);
			createTriangles(vertNeg, uvNeg, negFaces, face.material);
		}
		
		/**
		 * Splits an edge of a triangle along a plane and adds the new vertex to the vertices arrays.
		 * targetPos and targetNeg are arrays containing vertices for resp. the positive triangle and negative triangle
		 * returns t (in ]0, 1[) of intersection interval
		 */
		private function splitEdge(plane : Plane3D, v1 : Vertex, v2 : Vertex, targetPos : Array, targetNeg : Array) : Number
		{
			var div : Number, t : Number;
			var v : Vertex;
			
			div = plane.a*(v2.x-v1.x)+plane.b*(v2.y-v1.y)+plane.c*(v2.z-v1.z);
			
			t = -(plane.a*v1.x + plane.b*v1.y + plane.c*v1.z + plane.d)/div;
					
			v = new Vertex(v1.x+t*(v2.x-v1.x), v1.y+t*(v2.y-v1.y), v1.z+t*(v2.z-v1.z));
			
			targetPos.push(v);
			targetNeg.push(v);
			return t;
		}
		
		/**
		 * Calculates the uv values at the new vertex of a split edge. t is the value returned by splitEdge
		 */
		private function splitUV(uv1 : UV, uv2 : UV, t : Number, targetPos : Array, targetNeg : Array) : void
		{
			var uv : UV = new UV(uv1.u+t*(uv2.u-uv1.u), uv1.v+t*(uv2.v-uv1.v));
			targetPos.push(uv);
			targetNeg.push(uv);
		}
		
		/**
		 * Triangulates a given set of vertices. Used when splitting faces.
		 */
		private function createTriangles(vertices : Array, uv : Array, target : Vector.<Face>, material : ITriangleMaterial) : void
		{
			var len : int = vertices.length - 1;
			var v1 : Vertex = vertices[0];
			var uv1 : UV = uv[0];
			for (var i : int = 1; i < len; ++i) {
				var face : Face = new Face(v1, vertices[i], vertices[i+1], material, uv1, uv[i], uv[i+1]);
				target.push(face);
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