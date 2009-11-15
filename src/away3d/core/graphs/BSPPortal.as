package away3d.core.graphs
{
	import flash.system.System;
	import flash.utils.setTimeout;
	import flash.utils.getTimer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import away3d.arcane;
	import away3d.core.base.Face;
	import away3d.core.base.Vertex;
	import away3d.core.geom.NGon;
	import away3d.core.geom.Plane3D;
	import away3d.core.math.Number3D;
	
	use namespace arcane;
	
	internal final class BSPPortal extends EventDispatcher
	{
		public static const RECURSED_PORTAL_COMPLETE : String = "RecursedPortalComplete";
		public var index : int;
		public var nGon : NGon;
		//public var leaves : Vector.<BSPNode>;
		public var sourceNode : BSPNode;
		public var frontNode : BSPNode;
		public var backNode : BSPNode;
		public var listLen : int;
		public var frontList : Vector.<uint>;
		public var backList : Vector.<uint>;
		public var visList : Vector.<uint>;
		public var hasVisList : Boolean;
		public var frontOrder : int;
		public var maxTimeout : int = 0;
		
		public var isInSequence : Boolean;
		
		public var antiPenumbrae : Array = [];
		
		// containing all visible neighbours, through which we can see adjacent leaves
		public var neighbours : Vector.<BSPPortal>;
		
		private static var EPSILON : Number = 1/128;
		private var _recurseCompleteEvent : Event = new Event(RECURSED_PORTAL_COMPLETE);
		
		// iteration for vis testing
		private static var TRAVERSE_PRE : int = 0;
		private static var TRAVERSE_IN : int = 1;
		private static var TRAVERSE_POST : int = 2;
		
		private var _iterationIndex : int;
		private var _state : int;
		private var _currentPortal : BSPPortal;
		private var _needCheck : Boolean;
		private var _numPortals : int;		
		
		public var next : BSPPortal;
		
		arcane var _currentAntiPenumbra : Vector.<Plane3D>;
		arcane var _currentParent : BSPPortal;
		arcane var _currentFrontList : Vector.<uint>;
		
		public function BSPPortal()
		{
			//leaves = new Vector.<BSPNode>();
			nGon = new NGon();
			// Math.round(Math.random()*0xffffff)
			//nGon.material = new WireColorMaterial(0xffffff, {alpha : .5});
			nGon.vertices = new Vector.<Vertex>();
		}
		
		public function fromNode(node : BSPNode, root : BSPNode) : Boolean
		{
			var bounds : Array = root._bounds;
			var plane : Plane3D = nGon.plane = node._partitionPlane;
			var dist : Number;
			var radius : Number;
			var direction1 : Number3D, direction2 : Number3D;
			var center : Number3D = new Number3D(	(root._minX+root._maxX)*.5,
													(root._minY+root._maxY)*.5,
													(root._minZ+root._maxZ)*.5 );
			var normal : Number3D = new Number3D(plane.a, plane.b, plane.c);
			
			sourceNode = node;
			
			radius = center.distance(bounds[0]);
			radius = Math.sqrt(radius*radius + radius*radius);
			
			// calculate projection of aabb's center on plane
			dist = plane.distance(center);
			center.x -= dist*plane.a;
			center.y -= dist*plane.b; 
			center.z -= dist*plane.c;
			
			// perpendicular to plane normal & world axis, parallel to plane
			direction1 = getPerpendicular(normal);
			direction1.normalize();
			
			// perpendicular to plane normal & direction1, parallel to plane
			direction2 = new Number3D();
			direction2.cross(normal, direction1);
			direction2.normalize();
			
			// form very course bounds of bound projection on plane
			nGon.vertices.push(new Vertex( 	center.x + direction1.x*radius,
											center.y + direction1.y*radius,
											center.z + direction1.z*radius));
			nGon.vertices.push(new Vertex( 	center.x + direction2.x*radius,
											center.y + direction2.y*radius,
											center.z + direction2.z*radius));
			
			// invert direction
			direction1.normalize(-1);
			direction2.normalize(-1);
			
			nGon.vertices.push(new Vertex( 	center.x + direction1.x*radius,
											center.y + direction1.y*radius,
											center.z + direction1.z*radius));
			nGon.vertices.push(new Vertex( 	center.x + direction2.x*radius,
											center.y + direction2.y*radius,
											center.z + direction2.z*radius));
			
			// trim closely to world's bound planes
			trimToAABB(root);
			
			// ngon can become null
			var prev : BSPNode = node; 
			while (node = node._parent) {
				// portal became too small
				if (!nGon || nGon.vertices.length < 3) return false;
				if (prev == node._positiveNode)
					nGon.trim(node._partitionPlane);
				else
					nGon = nGon.split(node._partitionPlane)[1];
				prev = node;
			}
			
			return true;
		}
		
		public function clone() : BSPPortal
		{
			var c : BSPPortal = new BSPPortal();
			c.nGon = nGon.clone();
			c.frontNode = frontNode;
			c.backNode = backNode;
			c.neighbours = neighbours;
			c._currentParent = _currentParent;
			c.frontList = frontList;
			c.visList = visList;
			c.index = index;
			return c;
		}
		
		private function trimToAABB(node : BSPNode) : void
		{
			nGon.trim(new Plane3D(0, -1, 0, node._maxY));
			nGon.trim(new Plane3D(0, 1, 0, -node._minY));
			nGon.trim(new Plane3D(1, 0, 0, -node._minX));
			nGon.trim(new Plane3D(-1, 0, 0, node._maxX));
			nGon.trim(new Plane3D(0, 0, 1, -node._minZ));
			nGon.trim(new Plane3D(0, 0, -1, node._maxZ));
		}
		
		private function getPerpendicular(normal : Number3D) : Number3D
		{
			var p : Number3D = new Number3D();
			p.cross(new Number3D(1, 1, 0), normal);
			if (p.modulo < EPSILON) {
				p.cross(new Number3D(0, 1, 1), normal);
			}
			return p;
		}
		
		public function split(plane : Plane3D) : Vector.<BSPPortal>
		{
			var posPortal : BSPPortal;
			var negPortal : BSPPortal;
			var splits : Vector.<NGon> = nGon.split(plane);
			var ngon : NGon;
			var newPortals : Vector.<BSPPortal> = new Vector.<BSPPortal>(2);
			
			ngon = splits[0];
			if (ngon) {// && ngon.area > EPSILON) {
				posPortal = new BSPPortal();
				posPortal.nGon = ngon;
				//posPortal.nGon.material = new WireColorMaterial(Math.round(Math.random()*0xffffff), {alpha : .5});
				posPortal.sourceNode = sourceNode;
				posPortal.frontNode = frontNode;
				posPortal.backNode = backNode;
				newPortals[0] = posPortal;
			}
			ngon = splits[1];
			if (ngon) {// && ngon.area > EPSILON) {
				negPortal = new BSPPortal();
				negPortal.nGon = ngon;
				negPortal.sourceNode = sourceNode;
				negPortal.frontNode = frontNode;
				negPortal.backNode = backNode;
				//negPortal.nGon.material = new WireColorMaterial(Math.round(Math.random()*0xffffff), {alpha : .5});
				newPortals[1] = negPortal;
			}
			
			return newPortals;
		}
		
		
		/**
		 * Returns a Vector containing the current portal as well as an inverted portal. The results will be treated as one-way portals.
		 */
		public function partition() : Vector.<BSPPortal>
		{
			var parts : Vector.<BSPPortal> = new Vector.<BSPPortal>(2);
			var inverted : BSPPortal = clone();

			inverted.frontNode = backNode;
			inverted.backNode = frontNode;
			inverted.nGon.invert();
			
			parts[0] = this;
			parts[1] = inverted;
			return parts;
		}
		
		// this times out, or BSPTree:partitionPortals() ?
		public function createLists(numPortals : int) : void
		{
			_numPortals = numPortals;
			listLen = (numPortals >> 5) + 1;
			frontList = new Vector.<uint>(listLen);
			backList = new Vector.<uint>(listLen);
			visList = new Vector.<uint>(listLen);
			_currentFrontList = new Vector.<uint>(frontList.length);
		}

		public function addToList(list : Vector.<uint>, index : int) : void
		{
			list[index >> 5] |=  (1 << (index & 0x1f));
		}
		
		public function removeFromList(list : Vector.<uint>, index : int) : void
		{
			list[index >> 5] &= ~(1 << (index & 0x1f));
		}
		
		public function isInList(list : Vector.<uint>, index : int) : Boolean
		{
			if (!list) return false;
			return (list[index >> 5] & (1 << (index & 0x1f))) != 0;
		}
		
		public function findInitialFrontList(list : BSPPortal) : void
		{
			var srcPlane : Plane3D = nGon.plane;
			var i : int;
			var compNGon : NGon;
			
			do {
				i = list.index;
				compNGon = list.nGon;
				// test if spanning or this portal is in front and other in back
				if (compNGon.classifyForPortalFront(srcPlane) && nGon.classifyForPortalBack(compNGon.plane)) {
					// two portals can see eachother
					if (isInList(list.frontList, index)) {
						removeFromList(list.frontList, index);
						--list.frontOrder;
					}
					else {
						frontList[i >> 5] |=  (1 << (i & 0x1f));
						frontOrder++;
					}
				}
			} while (list = list.next);
		}
		
		public function removeReciprocalVisibles(portals : Vector.<BSPPortal>) : void
		{
			var current : BSPPortal;
			var len : int = portals.length;
			var i : int = len;
			
			// no longer need this
			backList = null;
			
			if (frontOrder <= 0) return;
		
			while (--i >= 0) {
				current = portals[i];
				if (isInList(frontList, i) && isInList(current.frontList, index)) {
					removeFromList(frontList, i);
					removeFromList(current.frontList, index);
					frontOrder--;
					current.frontOrder--;
				}
			}
		}
		
		public function findNeighbours() : void
		{
			var backPortals : Vector.<BSPPortal> = frontNode._backPortals;
			var len : int = backPortals.length;
			
			var current : BSPPortal;
			
			neighbours = new Vector.<BSPPortal>();
			
			// TO DO: Something broke in neighbour finding?
			for (var i : int = 0; i < len; ++i) {
				current = backPortals[i];
				
				if (isInList(frontList, current.index)) {
					neighbours.push(current);
					antiPenumbrae[current.index] = generateAntiPrenumbra(current.nGon);
				}
			}
			
			if (neighbours.length == 0) neighbours = null;
		}
		
		public function findVisiblePortals() : void
		{
			var i : int = listLen;
			_state = TRAVERSE_PRE;
			_currentPortal = this;
			_needCheck = false;
			_iterationIndex = 0;
			isInSequence = true;
			
			while (--i >= 0)
				_currentFrontList[i] = frontList[i];
				
			findVisiblePortalStep();
		}
		
		private function onRecursedComplete(event : Event) : void
		{
			setTimeout(dispatchEvent, 1, _recurseCompleteEvent);
		}
		
		private function findVisiblePortalStep(event : Event = null) : void
		{
			var next : BSPPortal;
			var startTime : int = getTimer();
			var vis : Boolean;
			var neighbours : Vector.<BSPPortal>;
			
			if (event) {
				dispatchEvent(_recurseCompleteEvent);
				EventDispatcher(event.target).removeEventListener(Event.COMPLETE, findVisiblePortalStep);
				EventDispatcher(event.target).removeEventListener(RECURSED_PORTAL_COMPLETE, onRecursedComplete);
			}
			
			do {
				if (_needCheck) {
//					if (!(_currentPortal.hasVisList || _currentPortal.isInSequence) && System.totalMemory < 1572864) {
//						_currentPortal.addEventListener(Event.COMPLETE, findVisiblePortalStep);
//						_currentPortal.addEventListener(RECURSED_PORTAL_COMPLETE, onRecursedComplete);
//						setTimeout(_currentPortal.findVisiblePortals, 1);
//						return;
//					}
					
					vis = determineVisibility(_currentPortal);
					if (vis)
						addToList(visList, _currentPortal.index);
					else
						_state = TRAVERSE_POST;
				}
				
				neighbours = _currentPortal.neighbours;
				
				if (_state == TRAVERSE_PRE) {
					if (neighbours) {
						next = neighbours[0];
						next._iterationIndex = 0;
						next._currentParent = _currentPortal;
						_currentPortal = next;
						_needCheck = true;
					}
					else {
						_state = TRAVERSE_POST;
						_currentPortal._currentAntiPenumbra = null;
						_needCheck = false;
					}
				}
				else if (_state == TRAVERSE_IN) {
					if (++_currentPortal._iterationIndex < neighbours.length) {
						next = neighbours[_currentPortal._iterationIndex];
						next._iterationIndex = 0;
						next._currentParent = _currentPortal;
						_currentPortal = next;
						_needCheck = true;
						_state = TRAVERSE_PRE;
					}
					else {
						_state = TRAVERSE_POST;
						_currentPortal._currentAntiPenumbra = null;
						_needCheck = false;
					}
				}
				else if (_state == TRAVERSE_POST) {
					if (_currentPortal._currentParent) {
						// clear memory
						var prev : BSPPortal = _currentPortal;
						_currentPortal = _currentPortal._currentParent;
						prev._currentAntiPenumbra = null;
						_state = TRAVERSE_IN;
					}
					_needCheck = false;
				}
			} while(	(_currentPortal != this || _state != TRAVERSE_POST) &&
						getTimer() - startTime < maxTimeout);
			
			if (_currentPortal == this && _state == TRAVERSE_POST) {
				// update front list
				var i : int = listLen;
				
				while (--i >= 0)
					frontList[i] = visList[i];
				
				hasVisList = true;
				isInSequence = false;
				setTimeout(notifyComplete, 1);
			}
			else {
				setTimeout(findVisiblePortalStep, 1);
			}
		}
		
		private function determineVisibility(currentPortal : BSPPortal) : Boolean
		{
			var antiPenumbra : Vector.<Plane3D>;
			var len : int;
			var i : int = listLen;
			var parent : BSPPortal = currentPortal._currentParent;
			var currentNGon : NGon;
			var clone : NGon;
			
			while (--i >= 0)
				// current front list is the front list of the parents combined, since we need to test
				// this portal against the sequence of parents
				currentPortal._currentFrontList[i] = parent._currentFrontList[i] & parent.frontList[i];
			
			if (currentPortal._currentParent == this) {
				// direct neighbour
				currentPortal._currentAntiPenumbra = antiPenumbrae[currentPortal.index];
				return true;
			}
			else {
				if (!isInList(currentPortal._currentFrontList, currentPortal.index)) return false;
				antiPenumbra = currentPortal._currentParent._currentAntiPenumbra;
			}
			
			currentNGon = currentPortal.nGon;
			
			i = len = antiPenumbra.length;
			
			while (--i >= 0) {
				//var classification : int = currentNGon.classifyToPlane(antiPenumbra[i]);
				// portal falls out of current antipenumbra	
				if (currentNGon.isOutAntiPenumbra(antiPenumbra[i]))
					return false;
			}
			
			// clone and trim current portal to visible antiPenumbra
			clone = currentNGon.clone();
			
			i = len;
			while (--i >= 0) {
				clone.trim(antiPenumbra[i]);
				// this shouldn't occur, but testing to be sure
				if (clone.vertices.length < 3) return false;
			}
			
			// create new antiPenumbra for the trimmed portal
			currentPortal._currentAntiPenumbra = generateAntiPrenumbra(clone);
			
			return true;
		}
		
		private function notifyComplete() : void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}

		private function generateAntiPrenumbra(targetNGon : NGon) : Vector.<Plane3D>
		{
			var anti : Vector.<Plane3D> = new Vector.<Plane3D>();
			var vertices1 : Vector.<Vertex> = nGon.vertices;
			var vertices2 : Vector.<Vertex> = targetNGon .vertices;
			var len1 : int = vertices1.length;
			var len2 : int = vertices2.length;
			var plane : Plane3D = new Plane3D();
			var i : int;
			var j : int;
			var k : int;
			var v1 : Vertex;
			var classification1 : int, classification2 : int;
			
			i = len1;
			while (--i >= 0) {
				v1 = vertices1[i];
				j = len2;
				k = len2-2;
				while (--j >= 0) {
					plane.from3vertices(v1, vertices2[j], vertices2[k]);
					plane.normalize();
					classification1 = nGon.classifyToPlane(plane);
					classification2 = targetNGon.classifyToPlane(plane);
					
//					if (	(classification1 == Plane3D.FRONT && classification2 == Plane3D.BACK) ||
//							(classification1 == Plane3D.BACK && classification2 == Plane3D.FRONT)) {
					if (	(classification1 != Plane3D.INTERSECT && classification2 != Plane3D.INTERSECT) &&
							(classification1 != classification2)) {
						// planes coming out of the target portal should face inward
						if (classification2 == Plane3D.BACK || classification1 == Plane3D.FRONT) {
							plane.a = -plane.a;
							plane.b = -plane.b;
							plane.c = -plane.c;
							plane.d = -plane.d;
						} 
						
						anti.push(plane);
						plane = new Plane3D();
					}
					
					if (--k < 0) k = len2-1;
				}
			}
			
			/*i = len2;
			while (--i >= 0) {
				v1 = vertices2[i];
				j = len1;
				k = len1-2;
				while (--j >= 0) {
					plane.from3vertices(v1, vertices1[j], vertices1[k]);
					plane.normalize();
					classification1 = nGon.classifyToPlane(plane);
					classification2 = targetNGon.classifyToPlane(plane);
					
//					if (	(classification1 == Plane3D.FRONT && classification2 == Plane3D.BACK) ||
//							(classification1 == Plane3D.BACK && classification2 == Plane3D.FRONT)) {
					if (	(classification1 != Plane3D.INTERSECT && classification2 != Plane3D.INTERSECT) &&
							(classification1 != classification2)) {
						// planes coming out of the target portal should face inward
						if (classification2 == Plane3D.BACK || classification1 == Plane3D.FRONT) {
							plane.a = -plane.a;
							plane.b = -plane.b;
							plane.c = -plane.c;
							plane.d = -plane.d;
						} 
						
						anti.push(plane);
						plane = new Plane3D();
					}
					
					if (--k < 0) k = len1-1;
				}
			}*/
			
			/*for (i = 0; i < len2; ++i) {
				k = 1;
				v1 = vertices2[i];
				for (j = 0; j < len1; ++j) {
					plane.from3vertices(v1, vertices1[j], vertices1[k]);
					plane.normalize();
					classification1 = nGon.classifyToPlane(plane);
					classification2 = targetPortal.nGon.classifyToPlane(plane);
					
					if (	(classification1 == Plane3D.FRONT && classification2 == Plane3D.BACK) ||
							(classification1 == Plane3D.BACK && classification2 == Plane3D.FRONT)) {
						// planes coming out of the target portal should face inward
						if (classification2 == Plane3D.BACK) {
							plane.a = -plane.a;
							plane.b = -plane.b;
							plane.c = -plane.c;
							plane.d = -plane.d;
						}
						
						anti.push(plane);
						plane = new Plane3D();
					}
					
					if (++k == len1) k = 0;
				}
			}*/
			
//			if (!antiPenumbrae) antiPenumbrae = new Array();
//			if (!targetPortal.antiPenumbrae) targetPortal.antiPenumbrae = new Array();
//			antiPenumbrae[targetPortal.index] = anti;
//			targetPortal.antiPenumbrae[index] = targetAnti;
			return anti;
		}
		
		
		
		public function removePortalsFromNeighbours(portals : Vector.<BSPPortal>) : void
		{
			if (!frontList) return;
			return;
			
			var current : BSPPortal;
			var i : int = portals.length;
			var len : int = neighbours.length;
			var count : int;
			var neighbour : BSPPortal;
			
			while (--i >= 0) {
				current = portals[i];
				count = 0;
				if (isInList(frontList, i) && !neighbours.indexOf(current)) {
					for (var j : int = 0; j < len; ++j) {
						neighbour = neighbours[j];
						if (!current.checkAgainstAntiPenumbra(antiPenumbrae[neighbour.index])) {
							++count;
						}
					}
					
					// not visible from portal through any neighbour
					if (count == len) {
						removeFromList(frontList, i);
						frontOrder--;
					}
				}
			}
		}
		
		private function checkAgainstAntiPenumbra(antiPenumbra : Vector.<Plane3D>) : Boolean
		{
			var len : int = antiPenumbra.length;
			
			for (var i : int = 0; i < len; ++i) {
				if (!nGon.classifyForPortalFront(antiPenumbra[i])) return false;
				/*if (nGon.classifyToPlane(antiPenumbra[i]) == Plane3D.BACK ||
					nGon.classifyToPlane(antiPenumbra[i]) == -2)
					return false;*/
			}
			return true;
			
		}
		
		public function cutSolids() : Vector.<BSPPortal>
		{
			var subs : Vector.<BSPPortal> = new Vector.<BSPPortal>();
			var i : int;
			var faces : Array;
			var face : Face;
			var len : int;
			var cutCount : int;
			var coincFront : Vector.<Boolean>;
			var coincBack : Vector.<Boolean>;
			var isCoinciding : Boolean;
			
			// only clone ngon?
			var clone : BSPPortal = clone();
			var cloneNGon : NGon = clone.nGon;
			// trim plane by front leaf's triangles, if not coinciding with portal
			
			faces = frontNode._mesh.geometry.faces;
			len = faces.length;
			coincFront = new Vector.<Boolean>(len);
			
			for (i = 0; i < len; ++i) {
				face = faces[i];
				coincFront[i] = isCoinciding = isFaceCoinciding(face);
				if (!isCoinciding)
					cloneNGon.trim(face.plane);
				// will return empty
				if (cloneNGon.vertices.length < 3) return subs;
			}
			
			// trim plane by back leaf's triangles, if not coinciding with portal
			faces = backNode._mesh.geometry.faces;
			len = faces.length;
			coincBack = new Vector.<Boolean>(len);
			
			for (i = 0; i < len; ++i) {
				face = faces[i];
				coincBack[i] = isCoinciding = isFaceCoinciding(face);
				if (!isCoinciding)
					cloneNGon.trim(face.plane);
				// will return empty
				if (cloneNGon.vertices.length < 3) return subs;
			}
			
			subs.push(clone);
			
			/**
			 * Cut out solid coinciding triangles from portal
			 */
			faces = frontNode._mesh.geometry.faces;
			len = faces.length;
			
			for (i = 0; i < len; ++i) {
				face = faces[i];
				if (coincFront[i]) {
					subs = cutToFace(subs, face);
					cutCount++;
				}
			}
			
			faces = backNode._mesh.geometry.faces;
			len = faces.length;
			
			for (i = 0; i < len; ++i) {
				face = faces[i];
				if (coincBack[i]) {
					subs = cutToFace(subs, face);
					cutCount++;
				}
			}
			
			return subs;
		}
		
		private function cutToFace(subs : Vector.<BSPPortal>, face : Face) : Vector.<BSPPortal>
		{
			var newSubs : Vector.<BSPPortal> = new Vector.<BSPPortal>();
			var splits : Vector.<BSPPortal>;
			var i : int = subs.length;
			
			face.generateEdgePlanes();
			
			while (--i >= 0) {
				splits = subs[i].split(face._edgePlane01);
				if (splits[1]) newSubs.push(splits[1]);
				if (splits[0]) {
					splits = splits[0].split(face._edgePlane12);
					if (splits[1]) newSubs.push(splits[1]);
					if (splits[0]) {
						splits = splits[0].split(face._edgePlane20);
						if (splits[1]) newSubs.push(splits[1]);
					}
				}
			}
			
			return newSubs;
		}
		
		private function isFaceCoinciding(face : Face) : Boolean
		{
			var dot : Number;
			dot = nGon.plane.distance(face.v0.position);
			if (dot != 0) return false;
			dot = nGon.plane.distance(face.v1.position);
			if (dot != 0) return false;
			dot = nGon.plane.distance(face.v2.position);
			if (dot != 0) return false;
			
			return true;
		}
	}
}