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
		
		// iteration for vis testing
		private static var TRAVERSE_PRE : int = 0;
		private static var TRAVERSE_IN : int = 1;
		private static var TRAVERSE_POST : int = 2;
		
		private var _iterationIndex : int;
		private var _state : int;
		private var _currentPortal : BSPPortal;
		private var _needCheck : Boolean;
		private var _numPortals : int;		
		
		private static var _sizeLookUp : Vector.<int>;
		
		public var next : BSPPortal;
		
		arcane var _currentAntiPenumbra : Vector.<Plane3D>;
		arcane var _currentParent : BSPPortal;
		arcane var _currentFrontList : Vector.<uint>;
		
		public function BSPPortal()
		{
			if (!_sizeLookUp) generateSizeLookUp();
			//leaves = new Vector.<BSPNode>();
			nGon = new NGon();
			// Math.round(Math.random()*0xffffff)
			//nGon.material = new WireColorMaterial(0xffffff, {alpha : .5});
			nGon.vertices = new Vector.<Vertex>();
		}
		
		// checks how many bits are set in a byte
		// wait, I can actually combine this and 32 bit lists
		private function generateSizeLookUp() : void
		{
			var size : int = 255;
			var i : int = 1;
			var bit : int;
			var count : int;
			
			_sizeLookUp = new Vector.<int>(255);
			_sizeLookUp[0x00] = 0;
			
			do {
				count = 0;
				bit = 8;
				while (--bit >= 0)
					if (i & (1 << bit)) ++count;
					
				_sizeLookUp[i] = count;
			} while (++i < size);
			
			_sizeLookUp[0xff] = 8;
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
			
			var prev : BSPNode = node; 
			while (node = node._parent) {
				// portal became too small
				if (!nGon || nGon.vertices.length < 3) return false;
				if (prev == node._positiveNode)
					nGon.trim(node._partitionPlane);
				else
					nGon.trimBack(node._partitionPlane);
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
			if (p.modulo < BSPTree.EPSILON) {
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
			if (ngon) {// && ngon.area > BSPTree.EPSILON) {
				posPortal = new BSPPortal();
				posPortal.nGon = ngon;
				//posPortal.nGon.material = new WireColorMaterial(Math.round(Math.random()*0xffffff), {alpha : .5});
				posPortal.sourceNode = sourceNode;
				posPortal.frontNode = frontNode;
				posPortal.backNode = backNode;
				newPortals[0] = posPortal;
			}
			ngon = splits[1];
			if (ngon) {// && ngon.area > BSPTree.EPSILON) {
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
			// only using 1 byte per item, as to keep the size look up table small
			listLen = (numPortals >> 3) + 1;
			frontList = new Vector.<uint>(listLen);
			backList = new Vector.<uint>(listLen);
			visList = new Vector.<uint>(listLen);
			_currentFrontList = new Vector.<uint>(listLen);
		}

		public function addToList(list : Vector.<uint>, index : int) : void
		{
			list[index >> 3] |=  (1 << (index & 0x7));
		}
		
		public function removeFromList(list : Vector.<uint>, index : int) : void
		{
			list[index >> 3] &= ~(1 << (index & 0x7));
		}
		
		public function isInList(list : Vector.<uint>, index : int) : Boolean
		{
			if (!list) return false;
			return (list[index >> 3] & (1 << (index & 0x7))) != 0;
		}
		
		public function findInitialFrontList(list : BSPPortal) : void
		{
			var srcPlane : Plane3D = nGon.plane;
			var i : int;
			var compNGon : NGon;
			var listIndex : int;
			var bitIndex : int;
			
			do {
				i = list.index;
				compNGon = list.nGon;
				// test if spanning or this portal is in front and other in back
				if (compNGon.classifyForPortalFront(srcPlane) && nGon.classifyForPortalBack(compNGon.plane)) {
					// two portals can see eachother
					// isInList(list.frontList, index)
					listIndex = index >> 3;
					bitIndex = index & 0x7;
					if (list.frontList[listIndex] & (1 << bitIndex)) {
						// removeFromList(list.frontList, index);
						list.frontList[listIndex] &= ~(1 << bitIndex);
						--list.frontOrder;
					}
					else {
						frontList[i >> 3] |=  (1 << (i & 0x7));
						frontOrder++;
					}
				}
			} while (list = list.next);
		}
		
//		public function removeReciprocalVisibles(portals : Vector.<BSPPortal>) : void
//		{
//			var current : BSPPortal;
//			var len : int = portals.length;
//			var i : int = len;
//			
//			// no longer need this
//			backList = null;
//			
//			if (frontOrder <= 0) return;
//		
//			while (--i >= 0) {
//				current = portals[i];
//				if (isInList(frontList, i) && isInList(current.frontList, index)) {
//					removeFromList(frontList, i);
//					removeFromList(current.frontList, index);
//					frontOrder--;
//					current.frontOrder--;
//				}
//			}
//		}
		
		public function findNeighbours() : void
		{
			var backPortals : Vector.<BSPPortal> = frontNode._backPortals;
			var i : int = backPortals.length;
			
			var current : BSPPortal;
			var currIndex : int;
			neighbours = new Vector.<BSPPortal>();
			
			while (--i >= 0) {
				current = backPortals[i];
				currIndex = current.index;
				
				//if (isInList(frontList, current.index)) {
				if (frontList[currIndex >> 3] & (1 << (currIndex & 0x7))) {
					neighbours.push(current);
					antiPenumbrae[currIndex] = generateAntiPenumbra(current.nGon);
				}
			}
			
			if (neighbours.length == 0) {
				neighbours = null;
				frontOrder = 0;
			}
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
		
		/*private function onRecursedComplete(event : Event) : void
		{
			setTimeout(dispatchEvent, 1, _recurseCompleteEvent);
		}*/
		
		private function findVisiblePortalStep() : void
		{
			var next : BSPPortal;
			var startTime : int = getTimer();
			var neighbours : Vector.<BSPPortal>;
			
			/*if (event) {
				dispatchEvent(_recurseCompleteEvent);
				EventDispatcher(event.target).removeEventListener(Event.COMPLETE, findVisiblePortalStep);
				EventDispatcher(event.target).removeEventListener(RECURSED_PORTAL_COMPLETE, onRecursedComplete);
			}*/
			
			do {
				if (_needCheck) {
					if (_currentPortal.isInSequence) throw new Error("Cycle occurs!");
//					if (!(_currentPortal.hasVisList || _currentPortal.isInSequence) && System.totalMemory < 1572864) {
//						_currentPortal.addEventListener(Event.COMPLETE, findVisiblePortalStep);
//						_currentPortal.addEventListener(RECURSED_PORTAL_COMPLETE, onRecursedComplete);
//						setTimeout(_currentPortal.findVisiblePortals, 1);
//						return;
//					}
					
					if (determineVisibility(_currentPortal)) {
						var currIndex : int = _currentPortal.index;
						//addToList(visList, _currentPortal.index);
						visList[currIndex >> 3] |=  (1 << (currIndex & 0x7));
					}
						
					else
						_state = TRAVERSE_POST;
				}
				if (_currentPortal.frontOrder <= 0) _state = TRAVERSE_POST;
				
				if (_state == TRAVERSE_PRE) {
					neighbours = _currentPortal.neighbours;
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
					neighbours = _currentPortal.neighbours;
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
						_currentPortal._currentAntiPenumbra = null;
						_currentPortal.isInSequence = false;
						_currentPortal = _currentPortal._currentParent;
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
			var currAntiPenumbra : Vector.<Plane3D>;
			var len : int;
			var i : int = listLen;
			var parent : BSPPortal = currentPortal._currentParent;
			var currentNGon : NGon;
			var clone : NGon;
			var currList : Vector.<uint> = currentPortal._currentFrontList;
			var currParentList : Vector.<uint> = parent._currentFrontList;
			var parentList : Vector.<uint> = parent.frontList;
			var currIndex : int = currentPortal.index;

			while (--i >= 0)
				// current front list is the front list of the parents combined, since we need to test
				// this portal against the sequence of parents
				currList[i] = currParentList[i] & parentList[i];
			
			if (parent == this) {
				// direct neighbour
				currentPortal._currentAntiPenumbra = antiPenumbrae[currIndex];
				return true;
			}
			
			//if (!isInList(currList, currentPortal.index))
			if ((currList[currIndex >> 3] & (1 << (currIndex & 0x7))) == 0)
				return false;
				
			currentNGon = currentPortal.nGon;
			currAntiPenumbra = parent._currentAntiPenumbra;
			i = len = currAntiPenumbra.length;
			
			while (--i >= 0) {
				//var classification : int = currentNGon.classifyToPlane(antiPenumbra[i]);
				// portal falls out of current antipenumbra	
				if (currentNGon.isOutAntiPenumbra(currAntiPenumbra[i]))
					return false;
			}
			
			// clone and trim current portal to visible antiPenumbra
			clone = currentNGon.clone();
			
			i = len;
			while (--i >= 0) {
				clone.trim(currAntiPenumbra[i]);
				if (clone.vertices.length < 3 || clone.area < BSPTree.EPSILON) return false;
			}
			
			// create new antiPenumbra for the trimmed portal
			currentPortal._currentAntiPenumbra = generateAntiPenumbra(clone);
			
			return true;
		}
		
		private function notifyComplete() : void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}

		private function generateAntiPenumbra(targetNGon : NGon) : Vector.<Plane3D>
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
					
					if (	(classification1 == Plane3D.FRONT && classification2 == Plane3D.BACK) ||
							(classification1 == Plane3D.BACK && classification2 == Plane3D.FRONT)) {
/*					if (	(classification1 != Plane3D.INTERSECT && classification2 != Plane3D.INTERSECT) &&
							(classification1 != classification2)) {*/
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
			if (frontOrder <= 0) return;
			return;
			
			var current : BSPPortal;
			var i : int = portals.length;
			var len : int = neighbours.length;
			var count : int;
			var j : int;
			
			while (--i >= 0) {
				current = portals[i];
				count = 0;
				// only check if not neighbour and already in front list
				if (isInList(frontList, i) && neighbours.indexOf(current) != -1) {
					j = len;
					while (--j >= 0)
						if (!current.checkAgainstAntiPenumbra(antiPenumbrae[neighbours[j].index]))
							++count;
					
					// not visible from portal through any neighbour
					if (count == len) {
						removeFromList(frontList, i);
						frontOrder--;
					}
				}
			}
		}
		
		public function propagateVisibility() : void
		{
			var j : int;
			var k : int;
			var list : Vector.<uint> = new Vector.<uint>(listLen);
			var neighbour : BSPPortal;
			var neighList : Vector.<uint>;
			var neighIndex : int;
			
			if (frontOrder <= 0) return;
			
			j = neighbours.length-1;
			
			// find all portals visible from any neighbour
			// first in list, copy front list
			neighbour = neighbours[j];
			neighList = neighbour.frontList;
			k = listLen;
			while (--k >= 0)
				list[k] = neighList[k];

			neighIndex = neighbour.index;
			list[neighIndex >> 3] |=  (1 << (neighIndex & 0x7));
			
			// add other neighbours' visible lists into the mix
			while (--j >= 0) {
				neighbour = neighbours[j];
				neighList = neighbour.frontList;
				k = listLen;
				while (--k >= 0)
					list[k] |= neighList[k];

				neighIndex = neighbour.index;
				list[neighIndex >> 3] |=  (1 << (neighIndex & 0x7));
			}
			
			k = listLen;
			// only visible if visible from neighbours and visible from current
			while (--k >= 0)
				frontList[k] &= list[k];
			
			frontOrder = 0;
			k = listLen;
			while (--k >= 0)
				frontOrder += _sizeLookUp[frontList[k]];
		}

		private function checkAgainstAntiPenumbra(antiPenumbra : Vector.<Plane3D>) : Boolean
		{
			var i : int = antiPenumbra.length;
			
			while (--i >= 0) {
				if (!nGon.classifyForPortalFront(antiPenumbra[i])) return false;
				/*if (nGon.classifyToPlane(antiPenumbra[i]) == Plane3D.BACK ||
					nGon.classifyToPlane(antiPenumbra[i]) == -2)
					return false;*/
			}
			return true;
			
		}
		
		private static var _coincFront : Vector.<Boolean>;
		private static var _coincBack : Vector.<Boolean>;
		private static var _subs : Vector.<NGon>;
		private static var _newPortals : Vector.<BSPPortal>;
		
		public function cutSolids() : Vector.<BSPPortal>
		{
			var i : int;
			var faces : Array;
			var face : Face;
			var isCoinciding : Boolean;
			var portal : BSPPortal;
			
			var cloneNGon : NGon = nGon.clone();
			
			// trim ngon by front leaf's triangles, if not coinciding with portal
			faces = frontNode._mesh._geometry.faces;
			i = faces.length;
			
			if (_coincFront)
				_coincFront.length = i;
			else
				_coincFront = new Vector.<Boolean>(i, false);
				
			while (--i >= 0) {
				face = faces[i];
				_coincFront[i] = isCoinciding = isFaceCoinciding(face);
				if (!isCoinciding) cloneNGon.trim(face.plane);
				// will return empty
				if (cloneNGon.vertices.length < 3) return null;
			}
			
			// trim ngon by back leaf's triangles, if not coinciding with portal
			faces = backNode._mesh._geometry.faces;
			i = faces.length;
			
			if (_coincBack)
				_coincBack.length = i;
			else
				_coincBack = new Vector.<Boolean>(i, false);
			
			while (--i >= 0) {
				face = faces[i];
				_coincBack[i] = isCoinciding = isFaceCoinciding(face);
				if (!isCoinciding) cloneNGon.trim(face.plane);
				// will return empty
				if (cloneNGon.vertices.length < 3) return null;
			}
			
			if (!_subs) _subs = new Vector.<NGon>();
			_subs.push(cloneNGon);
			
			/**
			 * Cut out solid coinciding triangles from portal
			 */
			faces = frontNode._mesh.geometry.faces;
			i = faces.length;
			
			while (--i >= 0)
				if (_coincFront[i]) _subs = cutToFace(_subs, faces[i]);
			
			faces = backNode._mesh.geometry.faces;
			i = faces.length;
			while (--i >= 0)
				if (_coincBack[i]) _subs = cutToFace(_subs, faces[i]);
			
			i = _subs.length;
			if(!_newPortals)
				_newPortals = new Vector.<BSPPortal>(i);
			else
				_newPortals.length = i;
				
			while (--i >= 0) {
				portal = new BSPPortal();
				portal.frontNode = frontNode;
				portal.backNode = backNode;
				portal.nGon = _subs[i];
				_newPortals[i] = portal;
			}
			
			_subs.length = 0;
			return _newPortals;
		}
		
		// TO DO: do not create newSubs
		private function cutToFace(subs : Vector.<NGon>, face : Face) : Vector.<NGon>
		{
			var newSubs : Vector.<NGon> = new Vector.<NGon>();
			var splits : Vector.<NGon>;
			var i : int = subs.length;
			var ngon : NGon;
			
//			face.generateEdgePlanes();
			
			while (--i >= 0) {
				splits = subs[i].split(face._edgePlane01);
				ngon = splits[1];
				if (ngon && ngon.area > BSPTree.EPSILON) newSubs.push(ngon);
				ngon = splits[0];
				if (ngon && ngon.area > BSPTree.EPSILON) {
					splits = ngon.split(face._edgePlane12);
					ngon = splits[1];
					if (ngon && ngon.area > BSPTree.EPSILON) newSubs.push(ngon);
					ngon = splits[0];
					if (ngon && ngon.area > BSPTree.EPSILON) {
						splits = ngon.split(face._edgePlane20);
						ngon = splits[1];
						if (ngon && ngon.area > BSPTree.EPSILON) newSubs.push(ngon);
					}
				}
			}
			
			return newSubs;
		}
		
		private function isFaceCoinciding(face : Face) : Boolean
		{
			var plane : Plane3D = nGon.plane;
			var dot : Number;
			var v : Vertex;
			
			v = face._v0;
			if (plane._alignment == Plane3D.X_AXIS)
				dot = v._x*plane.a + plane.d;
			else if (plane._alignment == Plane3D.Y_AXIS)
				dot = v._y*plane.b + plane.d;
			else if (plane._alignment == Plane3D.Z_AXIS)
				dot = v._z*plane.c + plane.d;
			else
				dot = v._x*plane.a + v._y*plane.b + v._z*plane.c + plane.d;
				
			if (dot < -BSPTree.EPSILON || dot > BSPTree.EPSILON) return false;
			
			v = face._v1;
			if (plane._alignment == Plane3D.X_AXIS)
				dot = v._x*plane.a + plane.d;
			else if (plane._alignment == Plane3D.Y_AXIS)
				dot = v._y*plane.b + plane.d;
			else if (plane._alignment == Plane3D.Z_AXIS)
				dot = v._z*plane.c + plane.d;
			else
				dot = v._x*plane.a + v._y*plane.b + v._z*plane.c + plane.d;
				
			if (dot < -BSPTree.EPSILON || dot > BSPTree.EPSILON) return false;
			
			v = face._v2;
			if (plane._alignment == Plane3D.X_AXIS)
				dot = v._x*plane.a + plane.d;
			else if (plane._alignment == Plane3D.Y_AXIS)
				dot = v._y*plane.b + plane.d;
			else if (plane._alignment == Plane3D.Z_AXIS)
				dot = v._z*plane.c + plane.d;
			else
				dot = v._x*plane.a + v._y*plane.b + v._z*plane.c + plane.d;
				
			if (dot < -BSPTree.EPSILON || dot > BSPTree.EPSILON) return false;
			
			return true;
		}
	}
}