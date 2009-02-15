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
 * Creates a 3d roundedcube primitive.
 */
class RoundedCube extends AbstractPrimitive  {
	public var width(getWidth, setWidth) : Float;
	public var height(getHeight, setHeight) : Float;
	public var depth(getDepth, setDepth) : Float;
	public var radius(getRadius, setRadius) : Float;
	public var subdivision(getSubdivision, setSubdivision) : Float;
	public var cubicmapping(getCubicmapping, setCubicmapping) : Bool;
	public var cubeMaterials(getCubeMaterials, setCubeMaterials) : CubeMaterialsData;
	
	private var _width:Float;
	private var _radius:Float;
	private var _subdivision:Int;
	private var _height:Float;
	private var _depth:Float;
	private var _cubeMaterials:CubeMaterialsData;
	private var _leftFaces:Array<Dynamic>;
	private var _rightFaces:Array<Dynamic>;
	private var _bottomFaces:Array<Dynamic>;
	private var _topFaces:Array<Dynamic>;
	private var _frontFaces:Array<Dynamic>;
	private var _backFaces:Array<Dynamic>;
	private var _doubles:Array<Dynamic>;
	private var _cubeFace:Face;
	private var _cubeFaceArray:Array<Dynamic>;
	private var _rad:Float;
	private var _offcubic:Float;
	private var _cubicmapping:Bool;
	

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
			default :
			

		}
		for (__i in 0..._cubeFaceArray.length) {
			_cubeFace = _cubeFaceArray[__i];

			_cubeFace.material = cast(event.material, ITriangleMaterial);
		}

	}

	private function buildRoundedCube():Void {
		
		_leftFaces = [];
		_rightFaces = [];
		_bottomFaces = [];
		_topFaces = [];
		_frontFaces = [];
		_backFaces = [];
		function rotatePoint(v:Vertex, rotation:Float):Vertex {
			var x1:Float;
			var roty:Float = rotation * _rad;
			var siny:Float = Math.sin(roty);
			var cosy:Float = Math.cos(roty);
			x1 = v.x;
			v.x = x1 * cosy + v.z * siny;
			v.z = x1 * -siny + v.z * cosy;
			return v;
		}

		_radius = Math.min(_radius, _width, _height, _depth);
		if (!_cubicmapping) {
			_offcubic = _radius / 3.6;
		}
		_doubles = [];
		var prof:Array<Dynamic> = [];
		var h:Float = _height - _radius;
		var w:Float = _width - _radius;
		var d:Float = _depth - _radius;
		var steph:Float = h / _subdivision;
		var stepw:Float = w / _subdivision;
		var linear:Int = _subdivision;
		var pt:Vertex;
		var nRot:Float = 90;
		var even:Int = (_subdivision % 2 == 0) ? 0 : 1;
		var rayon:Float = _radius * .5;
		var halfsub:Int = Std.int((_subdivision + even) * .5);
		var i:Int;
		var j:Int;
		var inv:Int;
		i = 0;
		while (i <= 90) {
			pt = createVertex();
			pt.x = Math.cos(-i / 180 * Math.PI) * rayon;
			pt.y = (Math.sin(i / 180 * Math.PI) * rayon) + (h * .5);
			pt.z = 0;
			prof.push(pt);
			
			// update loop variables
			i += Std.int(90 / (_subdivision + even));
		}

		var tmpy:Float = prof[0].y;
		prof.reverse();
		inv = prof.length;
		prof[0].x = prof.z = 0;
		i = 1;
		while (i < _subdivision) {
			pt = createVertex();
			pt.x = rayon;
			pt.y = tmpy - (i * steph);
			pt.z = 0;
			prof.push(pt);
			
			// update loop variables
			++i;
		}

		var index:Int;
		i = 0;
		while (i < inv) {
			index = inv - 1 - i;
			prof.push(createVertex(prof[index].x, -prof[index].y, prof[index].z));
			
			// update loop variables
			++i;
		}

		var profilecount:Int = prof.length;
		var atmp:Array<Dynamic> = [];
		var atmp2:Array<Dynamic> = [];
		var atmp3:Array<Dynamic> = [];
		var atmp4:Array<Dynamic> = [];
		var step:Float = (45 / (linear + 1)) * 2;
		var step2:Float = step;
		var cornerdub:Array<Dynamic> = [];
		var acol1:Array<Dynamic>;
		var acol2:Array<Dynamic>;
		var acol3:Array<Dynamic>;
		var acol4:Array<Dynamic>;
		_subdivision += even;
		i = 0;
		while (i < ((_subdivision) * .5) + 1) {
			nRot = 45 - (i * step);
			acol1 = [];
			acol2 = [];
			acol3 = [];
			acol4 = [];
			j = 0;
			while (j < (_subdivision * .5) + 1) {
				pt = createVertex(prof[j].x, prof[j].y, prof[j].z);
				pt = rotatePoint(pt, nRot);
				pt.x += (_width * .5) - rayon;
				pt.z -= (_depth * .5) - rayon;
				atmp3.push(pt);
				pt = createVertex(pt.x, pt.y, -pt.z);
				acol3.push(pt);
				pt = createVertex(prof[j].x, prof[j].y, prof[j].z);
				pt = rotatePoint(pt, nRot);
				pt.x += (_depth * .5) - rayon;
				pt.z -= (_width * .5) - rayon;
				atmp4.push(pt);
				pt = createVertex(pt.x, pt.y, -pt.z);
				acol4.push(pt);
				
				// update loop variables
				++j;
			}

			j = Std.int((_subdivision * .5));
			while (j < profilecount - (_subdivision * .5)) {
				pt = createVertex(prof[j].x, prof[j].y, prof[j].z);
				pt = rotatePoint(pt, nRot);
				pt.x += (_width * .5) - rayon;
				pt.z -= (_depth * .5) - rayon;
				atmp.push(pt);
				pt = createVertex(pt.x, pt.y, -pt.z);
				acol1.push(pt);
				pt = createVertex(prof[j].x, prof[j].y, prof[j].z);
				pt = rotatePoint(pt, nRot);
				pt.x += (_depth * .5) - rayon;
				pt.z -= (_width * .5) - rayon;
				atmp2.push(pt);
				pt = createVertex(pt.x, pt.y, -pt.z);
				acol2.push(pt);
				
				// update loop variables
				++j;
			}

			cornerdub.push(acol1, acol2, acol3, acol4);
			
			// update loop variables
			++i;
		}

		//middlepart
		i = 1;
		while (i < linear) {
			step = (w / linear) * i;
			step2 = (d / linear) * i;
			j = 0;
			while (j < halfsub + 1) {
				pt = createVertex(prof[j].x, prof[j].y, prof[j].z);
				pt.x += (_width * .5) - rayon;
				pt.z -= (_depth * .5) - rayon + -(step2);
				atmp3.push(pt);
				pt = createVertex(prof[j].x, prof[j].y, prof[j].z);
				pt.x += (_depth * .5) - rayon;
				pt.z -= (_width * .5) - rayon + -(step);
				atmp4.push(pt);
				
				// update loop variables
				++j;
			}

			j = halfsub;
			while (j < profilecount - halfsub) {
				pt = createVertex(prof[j].x, prof[j].y, prof[j].z);
				pt.x += (_width * .5) - rayon;
				pt.z -= (_depth * .5) - rayon + -(step2);
				atmp.push(pt);
				pt = createVertex(prof[j].x, prof[j].y, prof[j].z);
				pt.x += (_depth * .5) - rayon;
				pt.z -= (_width * .5) - rayon + -(step);
				atmp2.push(pt);
				
				// update loop variables
				++j;
			}

			
			// update loop variables
			++i;
		}

		i = cornerdub.length - 1;
		while (i >= 0) {
			atmp4 = atmp4.concat(cornerdub[i]);
			atmp3 = atmp3.concat(cornerdub[i - 1]);
			atmp2 = atmp2.concat(cornerdub[i - 2]);
			atmp = atmp.concat(cornerdub[i - 3]);
			cornerdub[i] = null;
			cornerdub[i - 1] = null;
			cornerdub[i - 2] = null;
			cornerdub[i - 3] = null;
			i -= 3;
			
			// update loop variables
			--i;
		}

		nRot = 90;
		var face1:Array<Dynamic> = [];
		var face2:Array<Dynamic> = [];
		var face3:Array<Dynamic> = [];
		var face4:Array<Dynamic> = [];
		var face5:Array<Dynamic> = [];
		var face6:Array<Dynamic> = [];
		var topplane:Array<Dynamic> = [];
		var segs1:Array<Dynamic> = [];
		var segs2:Array<Dynamic> = [];
		var segs3:Array<Dynamic> = [];
		var segs4:Array<Dynamic> = [];
		var segs5:Array<Dynamic> = [];
		var segs6:Array<Dynamic> = [];
		j = 0;
		i = 0;
		while (i < atmp3.length) {
			segs3.push(atmp3[i]);
			pt = createVertex(-atmp3[i].x, atmp3[i].y, atmp3[i].z);
			segs4.push(pt);
			pt = createVertex(atmp4[i].x, atmp4[i].y, atmp4[i].z);
			pt = rotatePoint(pt, nRot);
			segs5.push(pt);
			pt = createVertex(pt.x, pt.y, -pt.z);
			segs6.push(pt);
			j++;
			if (j == (_subdivision * .5) + 1) {
				face3.push(segs3);
				face4.push(segs4.reverse());
				face5.push(segs5);
				face6.push(segs6.reverse());
				j = 0;
				if (i < atmp3.length - 1) {
					segs3 = [];
					segs4 = [];
					segs5 = [];
					segs6 = [];
				}
			}
			
			// update loop variables
			++i;
		}

		var tmp:Array<Dynamic>;
		var stepx:Float;
		var stepy:Float;
		var stepz:Float;
		var l:Int = face4[0].length - 1;
		i = 0;
		while (i < face4.length) {
			stepx = (face3[i][0].x - face4[i][l].x) / linear;
			stepz = (face3[i][0].z - face4[i][l].z) / linear;
			tmp = [];
			j = 0;
			while (j <= linear) {
				tmp.push(createVertex(face4[i][l].x + (stepx * j), _height * .5, face4[i][l].z + (stepz * j)));
				
				// update loop variables
				j++;
			}

			topplane.push(tmp);
			
			// update loop variables
			i++;
		}

		j = 0;
		i = 0;
		while (i < atmp.length) {
			segs1.push(atmp[i]);
			atmp2[i] = rotatePoint(atmp2[i], nRot);
			segs2.push(atmp2[i]);
			j++;
			if (j == profilecount - _subdivision) {
				face1.push(segs1);
				face2.push(segs2);
				j = 0;
				if (i < atmp.length - 1) {
					segs1 = [];
					segs2 = [];
				}
			}
			
			// update loop variables
			++i;
		}

		generate(face1, (_cubeMaterials.right == null) ? faceMaterial : _cubeMaterials.right, _rightFaces, 0);
		generate(face2, (_cubeMaterials.front == null) ? faceMaterial : _cubeMaterials.front, _frontFaces, 1);
		var topmat:ITriangleMaterial = (_cubeMaterials.top == null) ? faceMaterial : _cubeMaterials.top;
		generate(face3, topmat, _topFaces, 2);
		generate(face4, topmat, _topFaces, 2);
		generate(face5, topmat, _topFaces, 2);
		generate(face6, topmat, _topFaces, 2);
		generate(topplane, topmat, _topFaces, 2);
		var uva:UV;
		var uvb:UV;
		var uvc:UV;
		var va:Vertex;
		var vb:Vertex;
		var vc:Vertex;
		var propu:Float = _width;
		var propv:Float = _depth;
		if (!_cubicmapping) {
			propu -= _offcubic;
			propv -= _offcubic;
		}
		var offsetu:Float = propu * .5;
		var offsetv:Float = propv * .5;
		i = 0;
		while (i < ((_subdivision) * .5)) {
			j = 0;
			while (j < 2) {
				vb = (j == 0) ? face3[0][0] : face5[0][0];
				vc = (j == 0) ? face3[i][1] : face5[i][1];
				va = (j == 0) ? face3[i + 1][1] : face5[i + 1][1];
				uva = createUV((1 / (propu / (va.x + offsetu))), 1 / (propv / (va.z + offsetv)));
				uvb = createUV((1 / (propu / (vb.x + offsetu))), 1 / (propv / (vb.z + offsetv)));
				uvc = createUV((1 / (propu / (vc.x + offsetu))), 1 / (propv / (vc.z + offsetv)));
				addFace(createFace(va, vb, vc, topmat, uva, uvb, uvc));
				_topFaces.push(faces[faces.length - 2], faces[faces.length - 1]);
				vb = createVertex(vb.x, vb.y, -vb.z);
				vc = createVertex(vc.x, vc.y, -vc.z);
				va = createVertex(va.x, va.y, -va.z);
				uva = createUV((1 / (propu / (va.x + offsetu))), 1 / (propv / (va.z + offsetv)));
				uvb = createUV((1 / (propu / (vb.x + offsetu))), 1 / (propv / (vb.z + offsetv)));
				uvc = createUV((1 / (propu / (vc.x + offsetu))), 1 / (propv / (vc.z + offsetv)));
				addFace(createFace(vb, va, vc, topmat, uvb, uva, uvc));
				_topFaces.push(faces[faces.length - 2], faces[faces.length - 1]);
				vb = createVertex(-vb.x, vb.y, -vb.z);
				vc = createVertex(-vc.x, vc.y, -vc.z);
				va = createVertex(-va.x, va.y, -va.z);
				uva = createUV((1 / (propu / (va.x + offsetu))), 1 / (propv / (va.z + offsetv)));
				uvb = createUV((1 / (propu / (vb.x + offsetu))), 1 / (propv / (vb.z + offsetv)));
				uvc = createUV((1 / (propu / (vc.x + offsetu))), 1 / (propv / (vc.z + offsetv)));
				addFace(createFace(vb, va, vc, topmat, uvb, uva, uvc));
				_topFaces.push(faces[faces.length - 2], faces[faces.length - 1]);
				vb = createVertex(vb.x, vb.y, -vb.z);
				vc = createVertex(vc.x, vc.y, -vc.z);
				va = createVertex(va.x, va.y, -va.z);
				uva = createUV((1 / (propu / (va.x + offsetu))), 1 / (propv / (va.z + offsetv)));
				uvb = createUV((1 / (propu / (vb.x + offsetu))), 1 / (propv / (vb.z + offsetv)));
				uvc = createUV((1 / (propu / (vc.x + offsetu))), 1 / (propv / (vc.z + offsetv)));
				addFace(createFace(va, vb, vc, topmat, uva, uvb, uvc));
				_topFaces.push(faces[faces.length - 2], faces[faces.length - 1]);
				
				// update loop variables
				++j;
			}

			
			// update loop variables
			++i;
		}

		var v0:Vertex;
		var v1:Vertex;
		var v2:Vertex;
		var uv0:UV;
		var uv1:UV;
		var uv2:UV;
		var face:Face;
		i = 0;
		while (i < _rightFaces.length) {
			face = _rightFaces[i];
			v0 = createVertex(-face.v0.x, face.v0.y, face.v0.z);
			v1 = createVertex(-face.v1.x, face.v1.y, face.v1.z);
			v2 = createVertex(-face.v2.x, face.v2.y, face.v2.z);
			uv0 = new UV();
			uv1 = new UV();
			uv2 = new UV();
			addFace(createFace(v1, v0, v2, (_cubeMaterials.left == null) ? faceMaterial : _cubeMaterials.left, uv1, uv0, uv2));
			_leftFaces.push(faces[faces.length - 1]);
			
			// update loop variables
			++i;
		}

		i = 0;
		while (i < _frontFaces.length) {
			face = _frontFaces[i];
			v0 = createVertex(face.v0.x, face.v0.y, -face.v0.z);
			v1 = createVertex(face.v1.x, face.v1.y, -face.v1.z);
			v2 = createVertex(face.v2.x, face.v2.y, -face.v2.z);
			uv0 = new UV();
			uv1 = new UV();
			uv2 = new UV();
			addFace(createFace(v1, v0, v2, (_cubeMaterials.back == null) ? faceMaterial : _cubeMaterials.back, uv1, uv0, uv2));
			_backFaces.push(faces[faces.length - 1]);
			
			// update loop variables
			++i;
		}

		i = 0;
		while (i < _topFaces.length) {
			face = _topFaces[i];
			v0 = createVertex(face.v0.x, -face.v0.y, face.v0.z);
			v1 = createVertex(face.v1.x, -face.v1.y, face.v1.z);
			v2 = createVertex(face.v2.x, -face.v2.y, face.v2.z);
			uv0 = new UV();
			uv1 = new UV();
			uv2 = new UV();
			addFace(createFace(v1, v0, v2, (_cubeMaterials.bottom == null) ? faceMaterial : _cubeMaterials.bottom, uv1, uv0, uv2));
			_bottomFaces.push(faces[faces.length - 1]);
			
			// update loop variables
			++i;
		}

		_doubles = null;
		face1 = face2 = face3 = face4 = face5 = face6 = topplane = null;
		_subdivision -= even;
	}

	private function generate(aVertexes:Array<Dynamic>, material:ITriangleMaterial, arrayside:Array<Dynamic>, prop:Int):Void {
		
		var i:Int = 0;
		while (i < aVertexes.length - 1) {
			generateFaces(aVertexes[i], aVertexes[i + 1], prop, material, arrayside);
			
			// update loop variables
			++i;
		}

	}

	private function generateFaces(points1:Array<Dynamic>, points2:Array<Dynamic>, prop:Int, material:ITriangleMaterial, arrayside:Array<Dynamic>):Void {
		
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
		var propu:Float;
		var propv:Float;
		var p1:String;
		var p2:String;
		function getDouble(v:Vertex):Vertex {
			var i:Int = 0;
			while (i < _doubles.length) {
				if (_doubles[i].x == v.x && _doubles[i].y == v.y && _doubles[i].z == v.z) {
					return _doubles[i];
				}
				
				// update loop variables
				++i;
			}

			_doubles[_doubles.length] = v;
			return v;
		}

		switch (prop) {
			case 0 :
				propu = _depth;
				propv = _height;
				p1 = "z";
				p2 = "y";
			case 1 :
				propu = _width;
				propv = _height;
				p1 = "x";
				p2 = "y";
			case 2 :
				propu = _width;
				propv = _depth;
				p1 = "x";
				p2 = "z";
			

		}
		if (!_cubicmapping) {
			propu -= _offcubic;
			propv -= _offcubic;
		}
		var offsetu:Float = (propu * .5);
		var offsetv:Float = (propv * .5);
		i = 0;
		while (i < points1.length - 1) {
			va = getDouble(points1[i + 1]);
			vb = getDouble(points1[i]);
			vc = getDouble(points2[i]);
			vd = getDouble(points2[i + 1]);
			if (vb != va && va != vc && vc != vd && vd != va && vc != vb) {
				uva = createUV((1 / (propu / (Reflect.field(va, p1) + offsetu))), 1 / (propv / (Reflect.field(va, p2) + offsetv)));
				uvb = createUV((1 / (propu / (Reflect.field(vb, p1) + offsetu))), 1 / (propv / (Reflect.field(vb, p2) + offsetv)));
				uvc = createUV((1 / (propu / (Reflect.field(vc, p1) + offsetu))), 1 / (propv / (Reflect.field(vc, p2) + offsetv)));
				uvd = createUV((1 / (propu / (Reflect.field(vd, p1) + offsetu))), 1 / (propv / (Reflect.field(vd, p2) + offsetv)));
				addFace(createFace(vb, va, vc, material, uvb, uva, uvc));
				addFace(createFace(vc, va, vd, material, uvc, uva, uvd));
				arrayside.push(faces[faces.length - 2], faces[faces.length - 1]);
			}
			
			// update loop variables
			i++;
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
	 * Defines the radius of the corners of the cube. Defaults to 1/3 of the height.
	 * if the radius is found greater than width, height or depth. the radius is set the lowest value of those 3 variables.
	 */
	public function getRadius():Float {
		
		return _radius;
	}

	public function setRadius(val:Float):Float {
		
		if (_radius == val) {
			return val;
		}
		_radius = val;
		_primitiveDirty = true;
		return val;
	}

	/**
	 * Defines the geometrical subdivision of the roundedcube. Defaults to 2. Note that corners have an even subdivision to allow 6 materials evently spreaded.
	 */
	public function getSubdivision():Float {
		
		return _subdivision;
	}

	public function setSubdivision(val:Float):Float {
		
		if (_subdivision == val) {
			return val;
		}
		_subdivision = Std.int(val);
		_primitiveDirty = true;
		return val;
	}

	/**
	 * Defines if the textures are projected considering the whole cube or adjusting per sides depending on radius. Default is false.
	 */
	public function getCubicmapping():Bool {
		
		return _cubicmapping;
	}

	public function setCubicmapping(b:Bool):Bool {
		
		_cubicmapping = b;
		return b;
	}

	/**
	 * Defines the face materials of the cube. For single material, use 
	 */
	public function getCubeMaterials():CubeMaterialsData {
		
		return _cubeMaterials;
	}

	public function setCubeMaterials(val:CubeMaterialsData):CubeMaterialsData {
		
		if (_cubeMaterials == val) {
			return val;
		}
		_cubeMaterials = val;
		if (_cubeMaterials == null) {
			_cubeMaterials = new CubeMaterialsData();
		}
		if ((_cubeMaterials != null)) {
			_cubeMaterials.addOnMaterialChange(onCubeMaterialChange);
		}
		_cubeMaterials.addOnMaterialChange(onCubeMaterialChange);
		return val;
	}

	/**
	 * Creates a new <code>RoundedCube</code> object.
	 *
	 * @param	init			[optional]	An initialisation object for specifying default instance properties.
	 *  Properties are: width, height, depth, radius, subdivision, cubicmapping, material and faces(6 different materials as cubeMaterials object) ;
	 */
	public function new(?init:Dynamic=null) {
		this._rad = Math.PI / 180;
		
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
		
		super(init);
		_width = ini.getNumber("width", 100, {min:0});
		_height = ini.getNumber("height", 100, {min:0});
		_depth = ini.getNumber("depth", 100, {min:0});
		_radius = ini.getNumber("radius", _height / 3, {min:1, max:Math.min(_width, _height, _depth)});
		_subdivision = Std.int(ini.getNumber("subdivision", 2, {min:2}));
		_cubeMaterials = ini.getCubeMaterials("faces");
		_cubicmapping = ini.getBoolean("cubicmapping", false);
		if (_cubeMaterials == null) {
			_cubeMaterials = ini.getCubeMaterials("cubeMaterials");
		}
		if (_cubeMaterials == null) {
			_cubeMaterials = new CubeMaterialsData();
		}
		_cubeMaterials.addOnMaterialChange(onCubeMaterialChange);
		buildRoundedCube();
		type = "RoundedCube";
		url = "primitive";
	}

	/**
	 * @inheritDoc
	 */
	public override function buildPrimitive():Void {
		
		super.buildPrimitive();
		buildRoundedCube();
	}

}

