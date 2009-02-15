package away3d.primitives.data
{
	import away3d.core.base.Vertex;
	import away3d.core.math.Number3D;
	import away3d.core.utils.Init;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	/**
	 * PatchData definition for constructing BezierPatches.
	 */
	public class PatchData
	{
		public var controlPoints:Array;
		public var generatedPatch:Array;
		
		private var ini:Object;
		private var _nodes:Array = new Array();
		private var _vertices:Array = new Array();
		private var _uvs:Array = new Array();
		private var _patchInfo:Array = new Array();
		private var _patchCache:Dictionary = new Dictionary();
		private var _dirtyVertices:Boolean;
		
		private var tempV:Vertex = new Vertex();

		/**
		 * The nodes which represent the vertices making up the patch.  
		 */
		public function get nodes():Array { return _nodes; }
		public function set nodes(value:Array):void {
			_nodes = value;
			_dirtyVertices = true;
		}
		
		/**
		 * The vertices of the patch tha are referenced by the nodes  
		 */
		public function get vertices():Array { return _vertices; }
		public function set vertices(value:Array):void {
			_vertices = value;
			_dirtyVertices = true;
		}
		
		/**
		 * UV definitions for the orientations for the patch 
		 */
		public function get uvs():Array { return _uvs; }
		public function set uvs(value:Array):void {
			_uvs = value;
			_dirtyVertices = true;
		}
		
		/**
		 * Patch information to define segments, connectors, fills and orientations
		 */
		public function get patchInfo():Array { return _patchInfo; }
		public function set patchInfo(value:Array):void {
			
			// Initialize the patch and generated patch arrays
			controlPoints = new Array();
			generatedPatch = new Array();
			
			// Process each sub-patch in turn
			for each (var o:Object in value) {		
				// Get the properties of the current sub-patch
				var otmp:Object = objClone(o);
				ini = Init.parse(otmp);
				var key:String = ini.getString("key", "");
				
				// Store the patch properties for later
				_patchInfo[key] = new Object();
				_patchInfo[key].oSegW = ini.getInt("segmentsW", 5, {min:1});
				_patchInfo[key].oSegH = ini.getInt("segmentsH", 3, {min:1});
				_patchInfo[key].oSegC = ini.getInt("connectSegs", 3, {min:1});
				_patchInfo[key].oOr = ini.getInt("orientation", 1, {min:1});
				_patchInfo[key].oCL = ini.getInt("connectL", 0, {min:0});
				_patchInfo[key].oCR = ini.getInt("connectR", 0, {min:0});
				_patchInfo[key].oCT = ini.getInt("connectT", 0, {min:0});
				_patchInfo[key].oCB = ini.getInt("connectB", 0, {min:0});
				_patchInfo[key].fillPoints = ini.getArray("fillPoints");
				_patchInfo[key].xStp = 1 / patchInfo[key].oSegW;
				_patchInfo[key].yStp = 1 / patchInfo[key].oSegH;
				_patchInfo[key].patchCount = nodes[key].length / 16;				
			}
			
			// Data has changed so patch needs regenerating
			_dirtyVertices = true;
		}
		
		/**
		 * Set up the patch data
		 */
		public function PatchData(nodesPrms:Array, verticesPrms:Array, uvsPrms:Array, patchInfoPrms:Array, resize:Number = 1) {
			_nodes = nodesPrms;
			_vertices = verticesPrms;
			_uvs = uvsPrms;
			patchInfo = patchInfoPrms;
			_dirtyVertices = true;
			
			for each (var v:Vertex in _vertices) {
				v.x = v.x * resize;
				v.y = v.y * resize;
				v.z = v.z * resize;
			}
			
			build();
		}
		
		// Main function to construct the patches wire or solid
		public function build(refresh:Boolean = false):void {
			var start:int = getTimer();
				
			// Changes have been made to the vertices so the patch needs re-generating
			if (_dirtyVertices || refresh) {
				// Process each key in the patch
				for (var key:String in _patchInfo) {				
					// Refresh or create the control point cache
					if (controlPoints[key]) {			
						updateControlPoints(key);
					} else {				
						controlPoints[key] = new Array();
						cacheControlPoints(key);
					}
					
					// Refresh or create the generated patch
					if (generatedPatch[key][0][0]) {				
						updatePatchPoints(key);
					} else {				
						generatedPatch[key] = new Array();
						cachePatchPoints(key);
					}
				}
			}
			
			// Reset the dirty flags
			_dirtyVertices = false;
			
//trace("Generated/refreshed in : " + (getTimer() - start) + "ms\n\n");	
		}

		private function cacheControlPoints(key:String):void {
			// Cache the patch control vertices in controlPoints
			controlPoints[key] = new Array();
			generatedPatch[key] = new Array();
			_patchCache = new Dictionary();
			
			for (var p:int = 0; p < _patchInfo[key].patchCount; p++) {
				controlPoints[key][p] = new Array();
				generatedPatch[key][p] = new Array();
				for (var i:int = 0; i < 4; i++ ) {
					controlPoints[key][p][i] = new Array();
					for (var j:int = 0; j < 4; j++ ) {
						var v:Vertex = _vertices[_nodes[key][(p * 16) + i * 4 + j]];
						controlPoints[key][p][i][j] = new Vertex(v.x, v.y, v.z);
					}
				}
			}				
		}

		private function updateControlPoints(key:String):void {
			// Cache the patch control vertices in controlPoints
			for (var p:int = 0; p < patchInfo[key].patchCount; p++) {
				for (var i:int = 0; i < 4; i++ ) {
					for (var j:int = 0; j < 4; j++ ) {
						tempV = vertices[nodes[key][(p * 16) + i * 4 + j]];
						controlPoints[key][p][i][j] = new Vertex(tempV.x, tempV.y, tempV.z);
					}
				}
			}				
		}
		
		private function cachePatchPoints(key:String):void {
			// Create the patch with new array elements and vertices
			for (var pId:int = 0; pId < patchInfo[key].patchCount; pId++) {
				generatedPatch[key][pId] = new Array();
				for (var yId:int = 0; yId <= patchInfo[key].oSegH; yId++ ) {                                        
					generatedPatch[key][pId][yId] = new Array();
					for (var xId:int = 0; xId <= patchInfo[key].oSegW; xId++) {
						generatedPatch[key][pId][yId][xId] = new Vertex();
						getPatchPoint(generatedPatch[key][pId][yId][xId], key, pId, xId * patchInfo[key].xStp, yId * patchInfo[key].yStp) 
					} 
				}
			}
		}

		private function updatePatchPoints(key:String):void {
			// Re-calculate the patch point locations for the vertices
			_patchCache = new Dictionary();
			for (var pId:int = 0; pId < patchInfo[key].patchCount; pId++) {
				for (var yId:int = 0; yId <= patchInfo[key].oSegH; yId++ ) {
					for (var xId:int = 0; xId <= patchInfo[key].oSegW; xId++) {
						getPatchPoint(generatedPatch[key][pId][yId][xId], key, pId, xId * patchInfo[key].xStp, yId * patchInfo[key].yStp) 
					} 
				}
			}
		}
		
		private	var a:Vertex = new Vertex();
		private var b:Vertex = new Vertex();
		private var c:Vertex = new Vertex();
		private var c0:Vertex = new Vertex();
		private var c1:Vertex = new Vertex();
		private var c2:Vertex = new Vertex();
		private var c3:Vertex = new Vertex();
		private var p0:Vertex = new Vertex();
		private var p1:Vertex = new Vertex();
		private var p2:Vertex = new Vertex();
		private var p3:Vertex = new Vertex();		
		private var cacheKey:Object;		

		private function getCurvePoint( v:Vertex, pos:Number, pnts:Array ):void {
			p0 = pnts[0];
			p1 = pnts[1];
			p2 = pnts[2];
			p3 = pnts[3];
			if (_patchCache[pnts]) {
				c0.x = _patchCache[pnts][0].x; c0.y = _patchCache[pnts][0].y; c0.z = _patchCache[pnts][0].z;
				c1.x = _patchCache[pnts][1].x; c1.y = _patchCache[pnts][1].y; c1.z = _patchCache[pnts][1].z;
				c2.x = _patchCache[pnts][2].x; c2.y = _patchCache[pnts][2].y; c2.z = _patchCache[pnts][2].z;
				c3.x = _patchCache[pnts][3].x; c3.y = _patchCache[pnts][3].y; c3.z = _patchCache[pnts][3].z;
			} else {
				a.x = p0.x * 3;	a.y = p0.y * 3;	a.z = p0.z * 3;
				b.x = p1.x * 3;	b.y = p1.y * 3;	b.z = p1.z * 3;
				c.x = p2.x * 3;	c.y = p2.y * 3;	c.z = p2.z * 3;
				c0.x = p0.x;	c0.y = p0.y;	c0.z = p0.z;
				c1.x = b.x - a.x; c1.y = b.y - a.y; c1.z = b.z - a.z;
				c2.x = a.x - (2 * b.x) + c.x; c2.y = a.y - (2 * b.y) + c.y; c2.z = a.z - (2 * b.z) + c.z;
				c3.x = p3.x - p0.x + b.x - c.x; c3.y = p3.y - p0.y + b.y - c.y; c3.z = p3.z - p0.z + b.z - c.z; 
				_patchCache[pnts] = [new Vertex(c0.x, c0.y, c0.z), new Vertex(c1.x, c1.y, c1.z), new Vertex(c2.x, c2.y, c2.z), new Vertex(c3.x, c3.y, c3.z)];
			}
	
			v.x = c0.x + (pos * (c1.x + (pos * (c2.x + (pos * c3.x)))));
			v.y = c0.y + (pos * (c1.y + (pos * (c2.y + (pos * c3.y)))));
			v.z = c0.z + (pos * (c1.z + (pos * (c2.z + (pos * c3.z)))));
		}

		private var cv0:Vertex = new Vertex();
		private var cv1:Vertex = new Vertex();
		private var cv2:Vertex = new Vertex();
		private var cv3:Vertex = new Vertex();
		private var vn:Vertex = new Vertex();
		
		private function getPatchPoint( v:Vertex, k:String, p:Number, s:Number, t:Number ):void {
			cacheKey = k + "/" + p + "/" + s;
			if (_patchCache[cacheKey]) {
				cv0 = _patchCache[cacheKey][0];
				cv1 = _patchCache[cacheKey][1];
				cv2 = _patchCache[cacheKey][2];
				cv3 = _patchCache[cacheKey][3];
			} else {
				getCurvePoint(cv0, s, controlPoints[k][p][0]);
				getCurvePoint(cv1, s, controlPoints[k][p][1]);
				getCurvePoint(cv2, s, controlPoints[k][p][2]);
				getCurvePoint(cv3, s, controlPoints[k][p][3]);
				_patchCache[cacheKey] = [cv0.clone(), cv1.clone(), cv2.clone(), cv3.clone()];
			}
			getCurvePoint(vn, t, [cv0, cv1, cv2, cv3]);	
			v.x = vn.x; v.y = vn.y; v.z = vn.z;
		}

		// Get the point in the patch based on the s, t (0-1) coordinate.
		private function getPatchPoint1( v:Vertex, k:String, p:Number, s:Number, t:Number ):void {
			var i:int;
			var j:int;
			var n1:Number3D = new Number3D();
			var n2:Number3D = new Number3D();
			var t1:Number3D = new Number3D();
			var t2:Number3D = new Number3D();	
			var nd:Number3D = new Number3D();
			
			
			// Copy our vectors into a temporary array
			var tmp:Array = new Array();
			var ntmp:Array = new Array();
			var n3D:Number3D = new Number3D();
			for (i = 0; i < 4; i++) {
				tmp[i] = new Array();
				ntmp[i] = new Array();
				for (j = 0; j < 4; j++) {					
					ntmp[i][j] = VtoN(controlPoints[k][p][i][j]);
				}
			}

			// The sum the patch point
			for (var size:int = 3; size > 0; size--) {
				for (i = 0; i < size; i++) {
					for (j = 0; j < size; j++) {
						n1.sub(ntmp[i + 1][j], ntmp[i][j]);
						n2.sub(ntmp[i + 1][j + 1], ntmp[i][j + 1]);
						n1.scale(n1, t);
						n2.scale(n2, t);
						t1.add(ntmp[i][j], n1);
						t2.add(ntmp[i][j + 1], n2);
						nd.sub(t2, t1);
						nd.scale(nd, s);
						ntmp[i][j].add(t1, nd);
					}
				}
			}
		
			// After that loop, tmp[0,0] will contain the requested point
			v.x = ntmp[0][0].x;
			v.y = ntmp[0][0].y;
			v.z = ntmp[0][0].z;
		}
		
		// Convert Vertex to Number3D
		private function VtoN(v:Vertex):Number3D {
			return new Number3D(v.x, v.y, v.z);
		}
		
		// Deep clone an object
		public function objClone(source:Object):* {
				var copier:ByteArray = new ByteArray();
				copier.writeObject(source);
				copier.position = 0;
				return(copier.readObject());
		}
		
		private function vInt(v:Vertex):String {
			return Math.floor(v.x) + "," + Math.floor(v.y) + "," + Math.floor(v.z);
		}
	}
}