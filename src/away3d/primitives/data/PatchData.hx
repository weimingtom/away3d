package away3d.primitives.data;

import away3d.core.base.Vertex;
import away3d.core.math.Number3D;
import away3d.core.utils.Init;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.getTimer;


/**
 * PatchData definition for constructing BezierPatches.
 */
class PatchData  {
	public var nodes(getNodes, setNodes) : Array<Dynamic>;
	public var vertices(getVertices, setVertices) : Array<Dynamic>;
	public var uvs(getUvs, setUvs) : Array<Dynamic>;
	public var patchInfo(getPatchInfo, setPatchInfo) : Array<Dynamic>;
	
	public var controlPoints:Array<Dynamic>;
	public var generatedPatch:Array<Dynamic>;
	private var ini:Dynamic;
	private var _nodes:Array<Dynamic>;
	private var _vertices:Array<Dynamic>;
	private var _uvs:Array<Dynamic>;
	private var _patchInfo:Array<Dynamic>;
	private var _patchCache:Dictionary;
	private var _dirtyVertices:Bool;
	private var tempV:Vertex;
	private var a:Vertex;
	private var b:Vertex;
	private var c:Vertex;
	private var c0:Vertex;
	private var c1:Vertex;
	private var c2:Vertex;
	private var c3:Vertex;
	private var p0:Vertex;
	private var p1:Vertex;
	private var p2:Vertex;
	private var p3:Vertex;
	private var cacheKey:Dynamic;
	private var cv0:Vertex;
	private var cv1:Vertex;
	private var cv2:Vertex;
	private var cv3:Vertex;
	private var vn:Vertex;
	

	/**
	 * The nodes which represent the vertices making up the patch.  
	 */
	public function getNodes():Array<Dynamic> {
		
		return _nodes;
	}

	public function setNodes(value:Array<Dynamic>):Array<Dynamic> {
		
		_nodes = value;
		_dirtyVertices = true;
		return value;
	}

	/**
	 * The vertices of the patch tha are referenced by the nodes  
	 */
	public function getVertices():Array<Dynamic> {
		
		return _vertices;
	}

	public function setVertices(value:Array<Dynamic>):Array<Dynamic> {
		
		_vertices = value;
		_dirtyVertices = true;
		return value;
	}

	/**
	 * UV definitions for the orientations for the patch 
	 */
	public function getUvs():Array<Dynamic> {
		
		return _uvs;
	}

	public function setUvs(value:Array<Dynamic>):Array<Dynamic> {
		
		_uvs = value;
		_dirtyVertices = true;
		return value;
	}

	/**
	 * Patch information to define segments, connectors, fills and orientations
	 */
	public function getPatchInfo():Array<Dynamic> {
		
		return _patchInfo;
	}

	public function setPatchInfo(value:Array<Dynamic>):Array<Dynamic> {
		// Initialize the patch and generated patch arrays
		
		controlPoints = new Array<Dynamic>();
		generatedPatch = new Array<Dynamic>();
		// Process each sub-patch in turn
		for (__i in 0...value.length) {
			var o:Dynamic = value[__i];

			var otmp:Dynamic = objClone(o);
			ini = Init.parse(otmp);
			var key:String = ini.getString("key", "");
			// Store the patch properties for later
			Reflect.setField(_patchInfo, key, new Dynamic());
			Reflect.setField(_patchInfo, key, ini.getInt("segmentsW", 5, {min:1}));
			Reflect.setField(_patchInfo, key, ini.getInt("segmentsH", 3, {min:1}));
			Reflect.setField(_patchInfo, key, ini.getInt("connectSegs", 3, {min:1}));
			Reflect.setField(_patchInfo, key, ini.getInt("orientation", 1, {min:1}));
			Reflect.setField(_patchInfo, key, ini.getInt("connectL", 0, {min:0}));
			Reflect.setField(_patchInfo, key, ini.getInt("connectR", 0, {min:0}));
			Reflect.setField(_patchInfo, key, ini.getInt("connectT", 0, {min:0}));
			Reflect.setField(_patchInfo, key, ini.getInt("connectB", 0, {min:0}));
			Reflect.setField(_patchInfo, key, ini.getArray("fillPoints"));
			Reflect.setField(_patchInfo, key, 1 / Reflect.field(patchInfo, key).oSegW);
			Reflect.setField(_patchInfo, key, 1 / Reflect.field(patchInfo, key).oSegH);
			Reflect.setField(_patchInfo, key, Reflect.field(nodes, key).length / 16);
		}

		// Data has changed so patch needs regenerating
		_dirtyVertices = true;
		return value;
	}

	/**
	 * Set up the patch data
	 */
	public function new(nodesPrms:Array<Dynamic>, verticesPrms:Array<Dynamic>, uvsPrms:Array<Dynamic>, patchInfoPrms:Array<Dynamic>, ?resize:Float=1) {
		this._nodes = new Array<Dynamic>();
		this._vertices = new Array<Dynamic>();
		this._uvs = new Array<Dynamic>();
		this._patchInfo = new Array<Dynamic>();
		this._patchCache = new Dictionary();
		this.tempV = new Vertex();
		this.a = new Vertex();
		this.b = new Vertex();
		this.c = new Vertex();
		this.c0 = new Vertex();
		this.c1 = new Vertex();
		this.c2 = new Vertex();
		this.c3 = new Vertex();
		this.p0 = new Vertex();
		this.p1 = new Vertex();
		this.p2 = new Vertex();
		this.p3 = new Vertex();
		this.cv0 = new Vertex();
		this.cv1 = new Vertex();
		this.cv2 = new Vertex();
		this.cv3 = new Vertex();
		this.vn = new Vertex();
		
		OPPOSITE_OR[X | X] = N;
		OPPOSITE_OR[XY | X] = Y;
		OPPOSITE_OR[XZ | X] = Z;
		OPPOSITE_OR[XYZ | X] = YZ;
		OPPOSITE_OR[Y | Y] = N;
		OPPOSITE_OR[XY | Y] = X;
		OPPOSITE_OR[XYZ | Y] = XZ;
		OPPOSITE_OR[YZ | Y] = Z;
		OPPOSITE_OR[Z | Z] = N;
		OPPOSITE_OR[XZ | Z] = X;
		OPPOSITE_OR[XYZ | Z] = XY;
		OPPOSITE_OR[YZ | Z] = Y;
		SCALINGS[1] = [1, 1, 1];
		SCALINGS[2] = [-1, 1, 1];
		SCALINGS[4] = [-1, 1, -1];
		SCALINGS[8] = [1, 1, -1];
		SCALINGS[16] = [1, -1, 1];
		SCALINGS[32] = [-1, -1, 1];
		SCALINGS[64] = [-1, -1, -1];
		SCALINGS[128] = [1, -1, -1];
		
		_nodes = nodesPrms;
		_vertices = verticesPrms;
		_uvs = uvsPrms;
		patchInfo = patchInfoPrms;
		_dirtyVertices = true;
		for (__i in 0..._vertices.length) {
			var v:Vertex = _vertices[__i];

			v.x = v.x * resize;
			v.y = v.y * resize;
			v.z = v.z * resize;
		}

		build();
	}

	// Main function to construct the patches wire or solid
	public function build(?refresh:Bool=false):Void {
		
		var start:Int = flash.Lib.getTimer();
		// Changes have been made to the vertices so the patch needs re-generating
		if (_dirtyVertices || refresh) {
			var key:String;
			for (key in _patchInfo) {
				if ((Reflect.field(controlPoints, key) != null)) {
					updateControlPoints(key);
				} else {
					Reflect.setField(controlPoints, key, new Array<Dynamic>());
					cacheControlPoints(key);
				}
				// Refresh or create the generated patch
				if ((Reflect.field(generatedPatch, key)[0][0] != null)) {
					updatePatchPoints(key);
				} else {
					Reflect.setField(generatedPatch, key, new Array<Dynamic>());
					cachePatchPoints(key);
				}
				
			}

		}
		// Reset the dirty flags
		_dirtyVertices = false;
		//trace("Generated/refreshed in : " + (getTimer() - start) + "ms\n\n");
		
	}

	private function cacheControlPoints(key:String):Void {
		// Cache the patch control vertices in controlPoints
		
		Reflect.setField(controlPoints, key, new Array<Dynamic>());
		Reflect.setField(generatedPatch, key, new Array<Dynamic>());
		_patchCache = new Dictionary();
		var p:Int = 0;
		while (p < Reflect.field(_patchInfo, key).patchCount) {
			Reflect.setField(controlPoints, key, new Array<Dynamic>());
			Reflect.setField(generatedPatch, key, new Array<Dynamic>());
			var i:Int = 0;
			while (i < 4) {
				Reflect.setField(controlPoints, key, new Array<Dynamic>());
				var j:Int = 0;
				while (j < 4) {
					var v:Vertex = _vertices[Reflect.field(_nodes, key)[(p * 16) + i * 4 + j]];
					Reflect.setField(controlPoints, key, new Vertex());
					
					// update loop variables
					j++;
				}

				
				// update loop variables
				i++;
			}

			
			// update loop variables
			p++;
		}

	}

	private function updateControlPoints(key:String):Void {
		// Cache the patch control vertices in controlPoints
		
		var p:Int = 0;
		while (p < Reflect.field(patchInfo, key).patchCount) {
			var i:Int = 0;
			while (i < 4) {
				var j:Int = 0;
				while (j < 4) {
					tempV = vertices[Reflect.field(nodes, key)[(p * 16) + i * 4 + j]];
					Reflect.setField(controlPoints, key, new Vertex());
					
					// update loop variables
					j++;
				}

				
				// update loop variables
				i++;
			}

			
			// update loop variables
			p++;
		}

	}

	private function cachePatchPoints(key:String):Void {
		// Create the patch with new array elements and vertices
		
		var pId:Int = 0;
		while (pId < Reflect.field(patchInfo, key).patchCount) {
			Reflect.setField(generatedPatch, key, new Array<Dynamic>());
			var yId:Int = 0;
			while (yId <= Reflect.field(patchInfo, key).oSegH) {
				Reflect.setField(generatedPatch, key, new Array<Dynamic>());
				var xId:Int = 0;
				while (xId <= Reflect.field(patchInfo, key).oSegW) {
					Reflect.setField(generatedPatch, key, new Vertex());
					getPatchPoint(Reflect.field(generatedPatch, key)[pId][yId][xId], key, pId, xId * Reflect.field(patchInfo, key).xStp, yId * Reflect.field(patchInfo, key).yStp);
					
					// update loop variables
					xId++;
				}

				
				// update loop variables
				yId++;
			}

			
			// update loop variables
			pId++;
		}

	}

	private function updatePatchPoints(key:String):Void {
		// Re-calculate the patch point locations for the vertices
		
		_patchCache = new Dictionary();
		var pId:Int = 0;
		while (pId < Reflect.field(patchInfo, key).patchCount) {
			var yId:Int = 0;
			while (yId <= Reflect.field(patchInfo, key).oSegH) {
				var xId:Int = 0;
				while (xId <= Reflect.field(patchInfo, key).oSegW) {
					getPatchPoint(Reflect.field(generatedPatch, key)[pId][yId][xId], key, pId, xId * Reflect.field(patchInfo, key).xStp, yId * Reflect.field(patchInfo, key).yStp);
					
					// update loop variables
					xId++;
				}

				
				// update loop variables
				yId++;
			}

			
			// update loop variables
			pId++;
		}

	}

	private function getCurvePoint(v:Vertex, pos:Float, pnts:Array<Dynamic>):Void {
		
		p0 = pnts[0];
		p1 = pnts[1];
		p2 = pnts[2];
		p3 = pnts[3];
		if ((_patchCache[cast pnts] != null)) {
			c0.x = _patchCache[cast pnts][cast 0].x;
			c0.y = _patchCache[cast pnts][cast 0].y;
			c0.z = _patchCache[cast pnts][cast 0].z;
			c1.x = _patchCache[cast pnts][cast 1].x;
			c1.y = _patchCache[cast pnts][cast 1].y;
			c1.z = _patchCache[cast pnts][cast 1].z;
			c2.x = _patchCache[cast pnts][cast 2].x;
			c2.y = _patchCache[cast pnts][cast 2].y;
			c2.z = _patchCache[cast pnts][cast 2].z;
			c3.x = _patchCache[cast pnts][cast 3].x;
			c3.y = _patchCache[cast pnts][cast 3].y;
			c3.z = _patchCache[cast pnts][cast 3].z;
		} else {
			a.x = p0.x * 3;
			a.y = p0.y * 3;
			a.z = p0.z * 3;
			b.x = p1.x * 3;
			b.y = p1.y * 3;
			b.z = p1.z * 3;
			c.x = p2.x * 3;
			c.y = p2.y * 3;
			c.z = p2.z * 3;
			c0.x = p0.x;
			c0.y = p0.y;
			c0.z = p0.z;
			c1.x = b.x - a.x;
			c1.y = b.y - a.y;
			c1.z = b.z - a.z;
			c2.x = a.x - (2 * b.x) + c.x;
			c2.y = a.y - (2 * b.y) + c.y;
			c2.z = a.z - (2 * b.z) + c.z;
			c3.x = p3.x - p0.x + b.x - c.x;
			c3.y = p3.y - p0.y + b.y - c.y;
			c3.z = p3.z - p0.z + b.z - c.z;
			_patchCache[cast pnts] = [new Vertex(), new Vertex(), new Vertex(), new Vertex()];
		}
		v.x = c0.x + (pos * (c1.x + (pos * (c2.x + (pos * c3.x)))));
		v.y = c0.y + (pos * (c1.y + (pos * (c2.y + (pos * c3.y)))));
		v.z = c0.z + (pos * (c1.z + (pos * (c2.z + (pos * c3.z)))));
	}

	private function getPatchPoint(v:Vertex, k:String, p:Float, s:Float, t:Float):Void {
		
		cacheKey = k + "/" + p + "/" + s;
		if ((_patchCache[cast cacheKey] != null)) {
			cv0 = _patchCache[cast cacheKey][cast 0];
			cv1 = _patchCache[cast cacheKey][cast 1];
			cv2 = _patchCache[cast cacheKey][cast 2];
			cv3 = _patchCache[cast cacheKey][cast 3];
		} else {
			getCurvePoint(cv0, s, Reflect.field(controlPoints, k)[p][0]);
			getCurvePoint(cv1, s, Reflect.field(controlPoints, k)[p][1]);
			getCurvePoint(cv2, s, Reflect.field(controlPoints, k)[p][2]);
			getCurvePoint(cv3, s, Reflect.field(controlPoints, k)[p][3]);
			_patchCache[cast cacheKey] = [cv0.clone(), cv1.clone(), cv2.clone(), cv3.clone()];
		}
		getCurvePoint(vn, t, [cv0, cv1, cv2, cv3]);
		v.x = vn.x;
		v.y = vn.y;
		v.z = vn.z;
	}

	// Get the point in the patch based on the s, t (0-1) coordinate.
	private function getPatchPoint1(v:Vertex, k:String, p:Float, s:Float, t:Float):Void {
		
		var i:Int;
		var j:Int;
		var n1:Number3D = new Number3D();
		var n2:Number3D = new Number3D();
		var t1:Number3D = new Number3D();
		var t2:Number3D = new Number3D();
		var nd:Number3D = new Number3D();
		// Copy our vectors into a temporary array
		var tmp:Array<Dynamic> = new Array<Dynamic>();
		var ntmp:Array<Dynamic> = new Array<Dynamic>();
		var n3D:Number3D = new Number3D();
		i = 0;
		while (i < 4) {
			tmp[i] = new Array<Dynamic>();
			ntmp[i] = new Array<Dynamic>();
			j = 0;
			while (j < 4) {
				ntmp[i][j] = VtoN(Reflect.field(controlPoints, k)[p][i][j]);
				
				// update loop variables
				j++;
			}

			
			// update loop variables
			i++;
		}

		// The sum the patch point
		var size:Int = 3;
		while (size > 0) {
			i = 0;
			while (i < size) {
				j = 0;
				while (j < size) {
					n1.sub(ntmp[i + 1][j], ntmp[i][j]);
					n2.sub(ntmp[i + 1][j + 1], ntmp[i][j + 1]);
					n1.scale(n1, t);
					n2.scale(n2, t);
					t1.add(ntmp[i][j], n1);
					t2.add(ntmp[i][j + 1], n2);
					nd.sub(t2, t1);
					nd.scale(nd, s);
					ntmp[i][j].add(t1, nd);
					
					// update loop variables
					j++;
				}

				
				// update loop variables
				i++;
			}

			
			// update loop variables
			size--;
		}

		// After that loop, tmp[0,0] will contain the requested point
		v.x = ntmp[0][0].x;
		v.y = ntmp[0][0].y;
		v.z = ntmp[0][0].z;
	}

	// Convert Vertex to Number3D
	private function VtoN(v:Vertex):Number3D {
		
		return new Number3D();
	}

	// Deep clone an object
	public function objClone(source:Dynamic):Dynamic {
		
		var copier:ByteArray = new ByteArray();
		copier.writeObject(source);
		copier.position = 0;
		return (copier.readObject());
	}

	private function vInt(v:Vertex):String {
		
		return Math.floor(v.x) + "," + Math.floor(v.y) + "," + Math.floor(v.z);
	}

}

