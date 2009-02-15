package away3d.extrusions;

import away3d.haxeutils.Error;
import flash.display.BitmapData;
import flash.geom.Point;
import away3d.core.math.Number3D;
import away3d.core.base.Face;
import away3d.core.base.Object3D;
import away3d.core.base.Mesh;
import away3d.core.base.Vertex;
import away3d.core.base.Element;


// use namespace arcane;

class NormalUVModifier  {
	public var source(null, setSource) : BitmapData;
	public var maxLevel(getMaxLevel, setMaxLevel) : Float;
	
	private var _mesh:Mesh;
	private var _geom:Array<Dynamic>;
	private var _sourceBmd:BitmapData;
	private var _maxLevel:Float;
	

	private function updateVertex(orivertex:Vertex, vertex:Vertex, pt:Point, normal:Number3D, channel:String, factor:Float):Void {
		
		var color:Int = (channel == "a") ? _sourceBmd.getPixel32(pt.x, pt.y) : _sourceBmd.getPixel(pt.x, pt.y);
		var cha:Float;
		switch (channel) {
			case "a" :
				cha = color >> 24 & 0xFF;
			case "r" :
				cha = color >> 16 & 0xFF;
			case "g" :
				cha = color >> 8 & 0xFF;
			case "b" :
				cha = color & 0xFF;
			case "av" :
				cha = ((color >> 16 & 0xFF) * 0.212671) + ((color >> 8 & 0xFF) * 0.715160) + ((color >> 8 & 0xFF) * 0.072169);
			

		}
		if (cha <= _maxLevel) {
			var multi:Float = (cha * factor);
			vertex.x = orivertex.x + (normal.x * multi);
			vertex.y = orivertex.y + (normal.y * multi);
			vertex.z = orivertex.z + (normal.z * multi);
		}
	}

	private function setVertices():Void {
		
		var basevertices:Array<Dynamic> = [];
		_geom = [];
		var j:Int;
		var i:Int = 0;
		while (i < _mesh.vertices.length) {
			basevertices[i] = _mesh.vertices[i];
			
			// update loop variables
			++i;
		}

		var n0:Number3D;
		var n1:Number3D;
		var n2:Number3D;
		var v0:Vertex;
		var v1:Vertex;
		var v2:Vertex;
		var p0:Point;
		var p1:Point;
		var p2:Point;
		var m0:Bool;
		var m1:Bool;
		var m2:Bool;
		if (_sourceBmd != null) {
			var w:Int = _sourceBmd.width - 1;
			var h:Int = _sourceBmd.height - 1;
		}
		var face:Face;
		i = 0;
		while (i < _mesh.faces.length) {
			m0 = false;
			m1 = false;
			m2 = false;
			face = _mesh.faces[i];
			j = 0;
			while (j < basevertices.length) {
				if (basevertices[j] == face.v0) {
					n0 = _mesh.geometry.getVertexNormal(face.v0);
					v0 = face.v0;
					if (_sourceBmd != null) {
						p0 = new Point();
					} else {
						p0 = new Point();
					}
					basevertices.splice(j, 1);
					m0 = true;
					j--;
				}
				if (basevertices[j] == face.v1) {
					n1 = _mesh.geometry.getVertexNormal(face.v1);
					v1 = face.v1;
					if (_sourceBmd != null) {
						p1 = new Point();
					} else {
						p1 = new Point();
					}
					basevertices.splice(j, 1);
					m1 = true;
					j--;
				}
				if (basevertices[j] == face.v2) {
					n2 = _mesh.geometry.getVertexNormal(face.v2);
					v2 = face.v2;
					if (_sourceBmd != null) {
						p2 = new Point();
					} else {
						p2 = new Point();
					}
					basevertices.splice(j, 1);
					m2 = true;
					j--;
				}
				
				// update loop variables
				++j;
			}

			if (m0 || m1 || m2) {
				var oV:Dynamic = {};
				oV.n0 = (m0) ? n0 : null;
				oV.n1 = (m1) ? n1 : null;
				oV.n2 = (m2) ? n2 : null;
				oV.v0 = (m0) ? v0 : null;
				oV.v1 = (m1) ? v1 : null;
				oV.v2 = (m2) ? v2 : null;
				oV.v0o = (m0) ? new Vertex() : null;
				oV.v1o = (m1) ? new Vertex() : null;
				oV.v2o = (m2) ? new Vertex() : null;
				oV.p0 = (m0) ? p0 : null;
				oV.p1 = (m1) ? p1 : null;
				oV.p2 = (m2) ? p2 : null;
				_geom.push(oV);
			}
			if (basevertices.length == 0) {
				break;
			}
			
			// update loop variables
			++i;
		}

	}

	private function applyLevel(?refreshnormal:Bool=false):Void {
		
		var i:Int = 0;
		while (i < _geom.length) {
			if (_geom[i].v0 != null) {
				_geom[i].v0o.x = _geom[i].v0.x;
				_geom[i].v0o.y = _geom[i].v0.y;
				_geom[i].v0o.z = _geom[i].v0.z;
			}
			if (_geom[i].v1 != null) {
				_geom[i].v1o.x = _geom[i].v1.x;
				_geom[i].v1o.y = _geom[i].v1.y;
				_geom[i].v1o.z = _geom[i].v1.z;
			}
			if (_geom[i].v2 != null) {
				_geom[i].v2o.x = _geom[i].v2.x;
				_geom[i].v2o.y = _geom[i].v2.y;
				_geom[i].v2o.z = _geom[i].v2.z;
			}
			
			// update loop variables
			++i;
		}

		if (refreshnormal) {
			i = 0;
			while (i < _mesh.faces.length) {
				_mesh.faces[i].normalDirty = true;
				
				// update loop variables
				++i;
			}

		}
	}

	/**
	 * Class NormalUVModifier modifies the vertices of a mesh with a bitmap information along the face normal vector
	 * or rescale a model along the model faces normals.<NormalUVModifier></code>
	 * 
	 * @param	mesh						Object3D. The mesh Object3D to be updated.
	 * @param	sourcebmd				[optional] BitmapData. The bitmapdata used as source for the influence.
	 */
	public function new(mesh:Mesh, ?sourcebmd:BitmapData=null, ?maxlevel:Float=255) {
		this._maxLevel = 255;
		
		
		if ((cast(mesh, Mesh)).vertices != null) {
			maxLevel = maxlevel;
			_mesh = cast(mesh, Mesh);
			_sourceBmd = sourcebmd;
			setVertices();
		} else {
			throw new Error();
		}
	}

	/**
	 * Updates the vertexes with the color value found at the uv's coordinates multiplied by a factor along the normal vector.
	 *
	 * @param	factor				Number. The multiplier. (multiplier * 0/255).
	 * @param	channel				[optional] The channel of the source bitmapdata. Possible values, red channel:"r", green channel:"g", blue channel:"b", average:"av". Default is "r".
	 */
	public function update(factor:Float, ?channel:String="r"):Void {
		
		channel = channel.toLowerCase();
		var w:Float = _sourceBmd.width;
		var h:Float = _sourceBmd.height;
		var i:Int = 0;
		while (i < _geom.length) {
			if (_geom[i].v0 != null) {
				updateVertex(_geom[i].v0o, _geom[i].v0, _geom[i].p0, _geom[i].n0, channel, factor);
			}
			if (_geom[i].v1 != null) {
				updateVertex(_geom[i].v1o, _geom[i].v1, _geom[i].p1, _geom[i].n1, channel, factor);
			}
			if (_geom[i].v2 != null) {
				updateVertex(_geom[i].v2o, _geom[i].v2, _geom[i].p2, _geom[i].n2, channel, factor);
			}
			
			// update loop variables
			++i;
		}

	}

	/**
	 * Updates the vertexes alog the normal vectors according to a multiplier.
	 * The influence is applied on top of the original vertex values.
	 * @param	factor			Number. The multiplier.
	 */
	public function multiply(factor:Float):Void {
		
		var i:Int = 0;
		while (i < _geom.length) {
			if (_geom[i].v0 != null) {
				_geom[i].v0.x = _geom[i].v0o.x + (_geom[i].n0.x * factor);
				_geom[i].v0.y = _geom[i].v0o.y + (_geom[i].n0.y * factor);
				_geom[i].v0.z = _geom[i].v0o.z + (_geom[i].n0.z * factor);
			}
			if (_geom[i].v1 != null) {
				_geom[i].v1.x = _geom[i].v1o.x + (_geom[i].n1.x * factor);
				_geom[i].v1.y = _geom[i].v1o.y + (_geom[i].n1.y * factor);
				_geom[i].v1.z = _geom[i].v1o.z + (_geom[i].n1.z * factor);
			}
			if (_geom[i].v2 != null) {
				_geom[i].v2.x = _geom[i].v2o.x + (_geom[i].n2.x * factor);
				_geom[i].v2.y = _geom[i].v2o.y + (_geom[i].n2.y * factor);
				_geom[i].v2.z = _geom[i].v2o.z + (_geom[i].n2.z * factor);
			}
			
			// update loop variables
			++i;
		}

	}

	/**
	 * Resets the vertexes to their original values
	 */
	public function resetVertices():Void {
		
		var i:Int = 0;
		while (i < _geom.length) {
			if (_geom[i].v0 != null) {
				_geom[i].v0.x = _geom[i].v0o.x;
				_geom[i].v0.y = _geom[i].v0o.y;
				_geom[i].v0.z = _geom[i].v0o.z;
			}
			if (_geom[i].v1 != null) {
				_geom[i].v1.x = _geom[i].v1o.x;
				_geom[i].v1.y = _geom[i].v1o.y;
				_geom[i].v1.z = _geom[i].v1o.z;
			}
			if (_geom[i].v2 != null) {
				_geom[i].v2.x = _geom[i].v2o.x;
				_geom[i].v2.y = _geom[i].v2o.y;
				_geom[i].v2.z = _geom[i].v2o.z;
			}
			
			// update loop variables
			++i;
		}

	}

	/**
	 * Set a new source bitmapdata for the class
	 */
	public function setSource(nSource:BitmapData):BitmapData {
		
		var nw:Int = nSource.width;
		var nh:Int = nSource.height;
		if (_sourceBmd != null) {
			var w:Int = _sourceBmd.width;
			var h:Int = _sourceBmd.height;
		}
		_sourceBmd = nSource;
		var i:Int = 0;
		while (i < _geom.length) {
			if (_geom[i].p0 != null) {
				_geom[i].p0.x = (_sourceBmd != null) ? (_geom[i].p0.x / w) * nw : _geom[i].p0.x = _geom[i].p0.x * nw;
				_geom[i].p0.y = (_sourceBmd != null) ? (_geom[i].p0.y / h) * nh : _geom[i].p0.y = _geom[i].p0.y * nh;
			}
			if (_geom[i].p1 != null) {
				_geom[i].p1.x = (_sourceBmd != null) ? (_geom[i].p1.x / w) * nw : _geom[i].p1.x = _geom[i].p1.x * nw;
				_geom[i].p1.y = (_sourceBmd != null) ? (_geom[i].p1.y / h) * nh : _geom[i].p1.y = _geom[i].p1.y * nh;
			}
			if (_geom[i].p2 != null) {
				_geom[i].p2.x = (_sourceBmd != null) ? (_geom[i].p2.x / w) * nw : _geom[i].p2.x = _geom[i].p2.x * nw;
				_geom[i].p2.y = (_sourceBmd != null) ? (_geom[i].p2.y / h) * nh : _geom[i].p2.y = _geom[i].p2.y * nh;
			}
			
			// update loop variables
			++i;
		}

		return nSource;
	}

	/**
	 * Defines a maximum level of influence. Values required are 0 to 1. If above or equal that level the influence is not applyed.
	 */
	public function setMaxLevel(val:Float):Float {
		
		val = (val < 0) ? 0 : ((val > 1) ? 1 : val);
		_maxLevel = 255 * val;
		return val;
	}

	public function getMaxLevel():Float {
		
		return 1 / _maxLevel;
	}

	/**
	 * Apply the actual displacement and sets it as new base for further displacements.
	 * @param	refreshnormal	s			[optional] Recalculates the normals of the Mesh. Default = false;
	 */
	public function apply(?refreshnormal:Bool=false):Void {
		
		applyLevel(refreshnormal);
	}

}

