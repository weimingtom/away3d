package away3d.primitives;

import away3d.primitives.data.CubeMaterialsData;
import away3d.core.utils.ValueObject;
import away3d.materials.IMaterial;
import flash.events.EventDispatcher;
import away3d.materials.ITriangleMaterial;
import flash.events.Event;
import away3d.events.MaterialEvent;
import away3d.core.base.Face;
import away3d.core.utils.Init;
import away3d.core.base.UV;
import away3d.core.base.Vertex;
import away3d.core.base.Element;


// use namespace arcane;

/**
 * Creates a 3d Cube primitive.
 */
class Cube extends AbstractPrimitive  {
	public var width(getWidth, setWidth) : Float;
	public var height(getHeight, setHeight) : Float;
	public var depth(getDepth, setDepth) : Float;
	public var segmentsW(getSegmentsW, setSegmentsW) : Float;
	public var map6(getMap6, setMap6) : Bool;
	public var flip(getFlip, setFlip) : Bool;
	public var segmentsH(getSegmentsH, setSegmentsH) : Float;
	public var cubeMaterials(getCubeMaterials, setCubeMaterials) : CubeMaterialsData;
	
	private var _width:Float;
	private var _height:Float;
	private var _depth:Float;
	private var _segmentsW:Int;
	private var _segmentsH:Int;
	private var _flip:Bool;
	private var _cubeMaterials:CubeMaterialsData;
	private var _leftFaces:Array<Dynamic>;
	private var _rightFaces:Array<Dynamic>;
	private var _bottomFaces:Array<Dynamic>;
	private var _topFaces:Array<Dynamic>;
	private var _frontFaces:Array<Dynamic>;
	private var _backFaces:Array<Dynamic>;
	private var _cubeFace:Face;
	private var _cubeFaceArray:Array<Dynamic>;
	private var _map6:Bool;
	private var _offset:Float;
	private var _dbv:Array<Dynamic>;
	private var _dbu:Array<Dynamic>;
	

	private function onCubeMaterialChange(event:MaterialEvent):Void {
		
		switch (event.extra) {
			case "left" :
				_cubeFaceArray = _leftFaces;
			case "right" :
				_cubeFaceArray = _rightFaces;
			case "bottom" :
				_cubeFaceArray = _bottomFaces;
			case "top" :
				_cubeFaceArray = _topFaces;
			case "front" :
				_cubeFaceArray = _frontFaces;
			case "back" :
				_cubeFaceArray = _backFaces;
			

		}
		for (__i in 0..._cubeFaceArray.length) {
			_cubeFace = _cubeFaceArray[__i];

			if (_cubeFace != null) {
				_cubeFace.material = cast(event.material, ITriangleMaterial);
			}
		}

	}

	private function buildCube():Void {
		
		_leftFaces = [];
		_rightFaces = [];
		_bottomFaces = [];
		_topFaces = [];
		_frontFaces = [];
		_backFaces = [];
		var aVs:Array<Dynamic> = [];
		var aVds:Array<Dynamic> = [];
		var hw:Float = _width * .5;
		var hh:Float = _height * .5;
		var hd:Float = _depth * .5;
		var i:Int;
		_dbv = [];
		_dbu = [];
		var v0:Vertex;
		var v1:Vertex;
		var v2:Vertex;
		var uv0:UV;
		var uv1:UV;
		var uv2:UV;
		var face:Face;
		var stepW:Float = _width / _segmentsW;
		i = 0;
		while (i <= _segmentsW) {
			aVs[i] = createVertex(-hw + (i * stepW), hh, -hd);
			aVds[i] = createVertex(-hw + (i * stepW), -hh, -hd);
			
			// update loop variables
			++i;
		}

		buildSide([aVds, aVs], _cubeMaterials.back, _backFaces, "b");
		aVds = [];
		aVs = [];
		var offU:Float = (_map6) ? _offset : 0;
		var offV:Float = (_map6) ? .5 : 0;
		i = 0;
		while (i < _backFaces.length) {
			face = _backFaces[i];
			v0 = makeVertex(face.v0.x, face.v0.y, -face.v0.z);
			v1 = makeVertex(face.v1.x, face.v1.y, -face.v1.z);
			v2 = makeVertex(face.v2.x, face.v2.y, -face.v2.z);
			uv0 = makeUV(1 - (face.uv0.u + offU), face.uv0.v + offV);
			uv1 = makeUV(1 - (face.uv1.u + offU), face.uv1.v + offV);
			uv2 = makeUV(1 - (face.uv2.u + offU), face.uv2.v + offV);
			addFace(createFace(v1, v0, v2, _cubeMaterials.front, uv1, uv0, uv2));
			_frontFaces.push(faces[faces.length - 1]);
			
			// update loop variables
			++i;
		}

		stepW = _depth / _segmentsW;
		i = 0;
		while (i <= _segmentsW) {
			aVs[i] = makeVertex(hw, hh, -hd + (i * stepW));
			aVds[i] = makeVertex(hw, -hh, -hd + (i * stepW));
			
			// update loop variables
			++i;
		}

		buildSide([aVds, aVs], _cubeMaterials.left, _leftFaces, "l");
		aVs = [];
		aVds = [];
		offU = (_map6) ? .5 : 0;
		i = 0;
		while (i < _leftFaces.length) {
			face = _leftFaces[i];
			v0 = makeVertex(-face.v0.x, face.v0.y, face.v0.z);
			v1 = makeVertex(-face.v1.x, face.v1.y, face.v1.z);
			v2 = makeVertex(-face.v2.x, face.v2.y, face.v2.z);
			uv0 = makeUV((1 - face.uv0.u), face.uv0.v);
			uv1 = makeUV((1 - face.uv1.u), face.uv1.v);
			uv2 = makeUV((1 - face.uv2.u), face.uv2.v);
			addFace(createFace(v1, v0, v2, _cubeMaterials.right, uv1, uv0, uv2));
			_rightFaces.push(faces[faces.length - 1]);
			
			// update loop variables
			++i;
		}

		stepW = (_map6) ? _depth / _segmentsW : _width / _segmentsW;
		i = 0;
		while (i <= _segmentsW) {
			if (_map6) {
				aVs[i] = makeVertex(-hw, hh, hd - (i * stepW));
				aVds[i] = makeVertex(hw, hh, hd - (i * stepW));
			} else {
				aVs[i] = makeVertex(hw - (i * stepW), hh, hd);
				aVds[i] = makeVertex(hw - (i * stepW), hh, -hd);
			}
			
			// update loop variables
			++i;
		}

		buildSide([aVs, aVds], _cubeMaterials.top, _topFaces, "t");
		offU = (_map6) ? _offset : 0;
		i = 0;
		while (i < _topFaces.length) {
			face = _topFaces[i];
			v0 = makeVertex(face.v0.x, -face.v0.y, face.v0.z);
			v1 = makeVertex(face.v1.x, -face.v1.y, face.v1.z);
			v2 = makeVertex(face.v2.x, -face.v2.y, face.v2.z);
			uv0 = makeUV((1 - face.uv0.u) + offU, face.uv0.v);
			uv1 = makeUV((1 - face.uv1.u) + offU, face.uv1.v);
			uv2 = makeUV((1 - face.uv2.u) + offU, face.uv2.v);
			addFace(createFace(v1, v0, v2, _cubeMaterials.bottom, uv1, uv0, uv2));
			_bottomFaces.push(faces[faces.length - 1]);
			
			// update loop variables
			++i;
		}

		aVs = aVds = _dbv = _dbu = null;
	}

	private function makeVertex(x:Float, y:Float, z:Float):Vertex {
		
		var i:Int = 0;
		while (i < _dbv.length) {
			if (_dbv[i].x == x && _dbv[i].y == y && _dbv[i].z == z) {
				return _dbv[i];
			}
			
			// update loop variables
			++i;
		}

		var v:Vertex = createVertex(x, y, z);
		_dbv[_dbv.length] = v;
		return v;
	}

	private function makeUV(u:Float, v:Float):UV {
		
		var i:Int = 0;
		while (i < _dbu.length) {
			if (_dbu[i].u == u && _dbu[i].v == v) {
				return _dbu[i];
			}
			
			// update loop variables
			++i;
		}

		var uv:UV = createUV(u, v);
		_dbu[_dbu.length] = uv;
		return uv;
	}

	private function buildSide(aVs:Array<Dynamic>, material:ITriangleMaterial, aFs:Array<Dynamic>, side:String):Void {
		
		var uvlength:Int = aVs.length - 1;
		var i:Int = 0;
		while (i < uvlength) {
			generateFaces(aVs[i], aVs[i + 1], (1 / uvlength) * i, uvlength, material, aFs, side);
			
			// update loop variables
			i++;
		}

	}

	private function generateFaces(aPt1:Array<Dynamic>, aPt2:Array<Dynamic>, vscale:Float, indexv:Int, material:ITriangleMaterial, aFs:Array<Dynamic>, side:String):Void {
		
		var varr:Array<Dynamic> = [];
		var i:Int;
		var j:Int;
		var stepx:Float;
		var stepy:Float;
		var stepz:Float;
		var uva:UV;
		var uvb:UV;
		var uvc:UV;
		var uvd:UV;
		var va:Vertex;
		var vb:Vertex;
		var vc:Vertex;
		var vd:Vertex;
		var u1:Float;
		var u2:Float;
		var index:Int = 0;
		var bu:Float = 0;
		var bincu:Float = 1 / (aPt1.length - 1);
		var v1:Float = 0;
		var v2:Float = 0;
		i = 0;
		while (i < aPt1.length) {
			stepx = (aPt2[i].x - aPt1[i].x) / _segmentsH;
			stepy = (aPt2[i].y - aPt1[i].y) / _segmentsH;
			stepz = (aPt2[i].z - aPt1[i].z) / _segmentsH;
			j = 0;
			while (j < _segmentsH + 1) {
				varr.push(makeVertex(aPt1[i].x + (stepx * j), aPt1[i].y + (stepy * j), aPt1[i].z + (stepz * j)));
				
				// update loop variables
				j++;
			}

			
			// update loop variables
			++i;
		}

		i = 0;
		while (i < aPt1.length - 1) {
			u1 = bu;
			bu += bincu;
			u2 = bu;
			if (_map6) {
				switch (side) {
					case "b" :
						u1 *= _offset;
						u2 *= _offset;
					case "l" :
						u1 *= _offset;
						u2 *= _offset;
					default :
						u1 = (u1 * _offset) + _offset;
						u2 = (u2 * _offset) + _offset;
					

				}
			}
			j = 0;
			while (j < _segmentsH) {
				v1 = vscale + ((j / _segmentsH) / indexv);
				v2 = vscale + (((j + 1) / _segmentsH) / indexv);
				if (_map6) {
					switch (side) {
						case "b" :
							v1 *= .5;
							v2 *= .5;
						case "l" :
							v1 = (v1 * .5) + .5;
							v2 = (v2 * .5) + .5;
						case "t" :
							v1 *= .5;
							v2 *= .5;
						

					}
				}
				uva = makeUV(u1, v1);
				uvb = makeUV(u1, v2);
				uvc = makeUV(u2, v2);
				uvd = makeUV(u2, v1);
				va = varr[index + j];
				vb = varr[(index + j) + 1];
				vc = varr[((index + j) + (_segmentsH + 2))];
				vd = varr[((index + j) + (_segmentsH + 1))];
				if (_flip) {
					addFace(createFace(va, vb, vc, material, uva, uvb, uvc));
					addFace(createFace(va, vc, vd, material, uva, uvc, uvd));
				} else {
					addFace(createFace(vb, va, vc, material, uvb, uva, uvc));
					addFace(createFace(vc, va, vd, material, uvc, uva, uvd));
				}
				aFs.push(faces[faces.length - 2]);
				aFs.push(faces[faces.length - 1]);
				
				// update loop variables
				++j;
			}

			index += _segmentsH + 1;
			
			// update loop variables
			++i;
		}

	}

	/**
	 * Defines the width of the cube. Defaults to 100.
	 */
	public function getWidth():Float {
		
		return _width;
	}

	public function setWidth(val:Float):Float {
		
		if (_width == val) {
			return val;
		}
		_width = val;
		_primitiveDirty = true;
		return val;
	}

	/**
	 * Defines the height of the cube. Defaults to 100.
	 */
	public function getHeight():Float {
		
		return _height;
	}

	public function setHeight(val:Float):Float {
		
		if (_height == val) {
			return val;
		}
		_height = val;
		_primitiveDirty = true;
		return val;
	}

	/**
	 * Defines the depth of the cube. Defaults to 100.
	 */
	public function getDepth():Float {
		
		return _depth;
	}

	public function setDepth(val:Float):Float {
		
		if (_depth == val) {
			return val;
		}
		_depth = val;
		_primitiveDirty = true;
		return val;
	}

	/**
	 * Defines the number of horizontal segments that make up the cube. Defaults 1.
	 */
	public function getSegmentsW():Float {
		
		return _segmentsW;
	}

	public function setSegmentsW(val:Float):Float {
		
		if (_segmentsW == val) {
			return val;
		}
		_segmentsW = Std.int(val);
		_primitiveDirty = true;
		return val;
	}

	/**
	 * Defines if the cube should use a single (3 cols/2 rows) map spreaded over the whole cube.
	 * topleft: left, topcenter:front, topright:right
	 * downleft:back, downcenter:top, downright: bottom
	 * Default is false.
	 */
	public function getMap6():Bool {
		
		return _map6;
	}

	public function setMap6(b:Bool):Bool {
		
		_map6 = b;
		return b;
	}

	/**
	 * Defines if the cube faces should be reversed, like a skybox. Default is false.
	 */
	public function getFlip():Bool {
		
		return _flip;
	}

	public function setFlip(b:Bool):Bool {
		
		_flip = b;
		return b;
	}

	/**
	 * Defines the number of vertical segments that make up the cube. Defaults 1.
	 */
	public function getSegmentsH():Float {
		
		return _segmentsH;
	}

	public function setSegmentsH(val:Float):Float {
		
		if (_segmentsH == val) {
			return val;
		}
		_segmentsH = Std.int(val);
		_primitiveDirty = true;
		return val;
	}

	/**
	 * Defines the face materials of the cube.
	 */
	public function getCubeMaterials():CubeMaterialsData {
		
		return _cubeMaterials;
	}

	public function setCubeMaterials(val:CubeMaterialsData):CubeMaterialsData {
		
		if (_cubeMaterials == val) {
			return val;
		}
		if ((_cubeMaterials != null)) {
			_cubeMaterials.addOnMaterialChange(onCubeMaterialChange);
		}
		_cubeMaterials = val;
		_cubeMaterials.addOnMaterialChange(onCubeMaterialChange);
		return val;
	}

	/**
	 * Creates a new <code>Cube</code> object.
	 *
	 * @param	init			[optional]	An initialisation object for specifying default instance properties.
	 * Properties of the init object: width, height, depth, segmentsH, segmentsW, flip, map6, material or faces (as CubeMaterialsData)
	 */
	public function new(?init:Dynamic=null) {
		this._offset = 1 / 3;
		
		
		super(init);
		_width = ini.getNumber("width", 100, {min:0});
		_height = ini.getNumber("height", 100, {min:0});
		_depth = ini.getNumber("depth", 100, {min:0});
		_flip = ini.getBoolean("flip", false);
		_cubeMaterials = ini.getCubeMaterials("faces");
		_segmentsW = ini.getInt("segmentsW", 1, {min:1});
		_segmentsH = ini.getInt("segmentsH", 1, {min:1});
		_map6 = ini.getBoolean("map6", false);
		if (_cubeMaterials == null) {
			_cubeMaterials = ini.getCubeMaterials("cubeMaterials");
		}
		if (_cubeMaterials == null) {
			_cubeMaterials = new CubeMaterialsData();
		}
		_cubeMaterials.addOnMaterialChange(onCubeMaterialChange);
		buildCube();
		type = "Cube";
		url = "primitive";
	}

	/**
	 * @inheritDoc
	 */
	public override function buildPrimitive():Void {
		
		super.buildPrimitive();
		buildCube();
	}

}

