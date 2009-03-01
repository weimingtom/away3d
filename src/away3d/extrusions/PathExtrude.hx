package away3d.extrusions;

import away3d.core.math.Number3D;
import away3d.core.utils.Init;
import away3d.core.math.Matrix3D;
import away3d.animators.data.Path;
import away3d.animators.utils.PathUtils;
import away3d.animators.data.CurveSegment;
import away3d.materials.IMaterial;
import away3d.materials.ITriangleMaterial;
import away3d.core.base.Face;
import away3d.core.base.Mesh;
import away3d.core.base.UV;
import away3d.core.base.Vertex;


// use namespace arcane;

class PathExtrude extends Mesh  {
	public var subdivision(getSubdivision, setSubdivision) : Int;
	public var scaling(getScaling, setScaling) : Float;
	public var coverall(getCoverall, setCoverall) : Bool;
	public var coversegment(getCoversegment, setCoversegment) : Bool;
	public var mapfit(getMapfit, setMapfit) : Bool;
	public var recenter(getRecenter, setRecenter) : Bool;
	public var flip(getFlip, setFlip) : Bool;
	public var closepath(getClosepath, setClosepath) : Bool;
	public var aligntopath(getAligntopath, setAligntopath) : Bool;
	public var smoothscale(getSmoothscale, setSmoothscale) : Bool;
	public var path(getPath, setPath) : Path;
	public var points(getPoints, setPoints) : Array<Dynamic>;
	public var scales(getScales, setScales) : Array<Dynamic>;
	public var rotations(getRotations, setRotations) : Array<Dynamic>;
	public var materials(getMaterials, setMaterials) : Array<Dynamic>;
	
	private var varr:Array<Dynamic>;
	private var xAxis:Number3D;
	private var yAxis:Number3D;
	private var zAxis:Number3D;
	private var _worldAxis:Number3D;
	private var _transform:Matrix3D;
	private var _path:Path;
	private var _points:Array<Dynamic>;
	private var _scales:Array<Dynamic>;
	private var _rotations:Array<Dynamic>;
	private var _subdivision:Int;
	private var _scaling:Float;
	private var _coverall:Bool;
	private var _coversegment:Bool;
	private var _recenter:Bool;
	private var _flip:Bool;
	private var _closepath:Bool;
	private var _aligntopath:Bool;
	private var _smoothscale:Bool;
	private var _isClosedProfile:Bool;
	private var _doubles:Array<Dynamic>;
	private var _materialList:Array<Dynamic>;
	private var _matIndex:Int;
	private var _segIndex:Int;
	private var _segvstart:Float;
	private var _segv:Float;
	private var _mapfit:Bool;
	

	private function orientateAt(target:Number3D, position:Number3D):Void {
		
		zAxis.sub(target, position);
		zAxis.normalize();
		if (zAxis.modulo > 0.1) {
			xAxis.cross(zAxis, _worldAxis);
			xAxis.normalize();
			yAxis.cross(zAxis, xAxis);
			yAxis.normalize();
			_transform.sxx = xAxis.x;
			_transform.syx = xAxis.y;
			_transform.szx = xAxis.z;
			_transform.sxy = -yAxis.x;
			_transform.syy = -yAxis.y;
			_transform.szy = -yAxis.z;
			_transform.sxz = zAxis.x;
			_transform.syz = zAxis.y;
			_transform.szz = zAxis.z;
		}
	}

	private function generate(points:Array<Dynamic>, ?offsetV:Int=0, ?closedata:Bool=false):Void {
		
		var uvlength:Int = (points.length - 1) + offsetV;
		var i:Int = 0;
		while (i < points.length - 1) {
			varr = new Array();
			extrudePoints(points[i], points[i + 1], (1 / uvlength) * ((closedata) ? i + (uvlength - 1) : i), uvlength, ((closedata) ? i + (uvlength - 1) : i) / _subdivision);
			if (i == 0 && _isClosedProfile) {
				_doubles = varr.concat([]);
			}
			
			// update loop variables
			++i;
		}

		varr = null;
		_doubles = null;
	}

	private function extrudePoints(points1:Array<Dynamic>, points2:Array<Dynamic>, vscale:Float, indexv:Int, indexp:Int):Void {
		
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
		var countloop:Int = points1.length;
		if (_mapfit) {
			var dist:Float = 0;
			var tdist:Float;
			var bleft:Number3D;
			i = 0;
			while (i < countloop) {
				j = 0;
				while (j < countloop) {
					if (i != j) {
						tdist = points1[i].distance(points1[j]);
						if (tdist > dist) {
							dist = tdist;
							bleft = points1[i];
						}
					}
					
					// update loop variables
					++j;
				}

				
				// update loop variables
				++i;
			}

		} else {
			var bu:Float = 0;
			var bincu:Float = 1 / (countloop - 1);
		}
		var v1:Float = 0;
		var v2:Float = 0;
		function getDouble(x:Float, y:Float, z:Float):Vertex {
			var i:Int = 0;
			while (i < _doubles.length) {
				if (_doubles[i].x == x && _doubles[i].y == y && _doubles[i].z == z) {
					return _doubles[i];
				}
				
				// update loop variables
				++i;
			}

			return new Vertex(x, y, z);
		}

		i = 0;
		while (i < countloop) {
			stepx = points2[i].x - points1[i].x;
			stepy = points2[i].y - points1[i].y;
			stepz = points2[i].z - points1[i].z;
			j = 0;
			while (j < 2) {
				if (_isClosedProfile && _doubles.length > 0) {
					varr.push(getDouble(points1[i].x + (stepx * j), points1[i].y + (stepy * j), points1[i].z + (stepz * j)));
				} else {
					varr.push(new Vertex(points1[i].x + (stepx * j), points1[i].y + (stepy * j), points1[i].z + (stepz * j)));
				}
				
				// update loop variables
				++j;
			}

			
			// update loop variables
			++i;
		}

		var mat:ITriangleMaterial;
		if (_coversegment) {
			if (indexp > _segIndex) {
				_segIndex = indexp;
				_segvstart = 0;
				_segv = 1 / (_subdivision);
				if (_materialList != null) {
					_matIndex = (_matIndex + 1 > _materialList.length - 1) ? 0 : _matIndex + 1;
				}
			}
		} else {
			if (_materialList != null && _coverall == false) {
				_matIndex = (_matIndex + 1 > _materialList.length - 1) ? 0 : _matIndex + 1;
			}
		}
		mat = (_materialList != null && _coverall == false) ? _materialList[_matIndex] : null;
		var k:Int;
		i = 0;
		while (i < countloop - 1) {
			if (_mapfit) {
				u1 = points1[i].distance(bleft) / dist;
				u2 = points1[i + 1].distance(bleft) / dist;
			} else {
				u1 = bu;
				bu += bincu;
				u2 = bu;
			}
			v1 = (_coverall) ? vscale : ((_coversegment) ? _segvstart : 0);
			v2 = (_coverall) ? vscale + (1 / indexv) : ((_coversegment) ? _segvstart + _segv : 1);
			uva = new UV(u1, v1);
			uvb = new UV(u1, v2);
			uvc = new UV(u2, v2);
			uvd = new UV(u2, v1);
			va = varr[index];
			vb = varr[index + 1];
			vc = varr[index + 3];
			vd = varr[index + 2];
			if (flip) {
				addFace(new Face(vb, va, vc, mat, uvb, uva, uvc));
				addFace(new Face(vc, va, vd, mat, uvc, uva, uvd));
			} else {
				addFace(new Face(va, vb, vc, mat, uva, uvb, uvc));
				addFace(new Face(va, vc, vd, mat, uva, uvc, uvd));
			}
			if (_mapfit) {
				u1 = u2;
			}
			index += 2;
			
			// update loop variables
			++i;
		}

		if (_coversegment) {
			_segvstart += _segv;
		}
	}

	function new(?path:Path=null, ?points:Array<Dynamic>=null, ?scales:Array<Dynamic>=null, ?rotations:Array<Dynamic>=null, ?init:Dynamic=null) {
		this.xAxis = new Number3D();
		this.yAxis = new Number3D();
		this.zAxis = new Number3D();
		this._worldAxis = new Number3D(0, 1, 0);
		this._transform = new Matrix3D();
		this._subdivision = 2;
		this._scaling = 1;
		this._coverall = true;
		this._coversegment = false;
		this._recenter = false;
		this._flip = false;
		this._closepath = false;
		this._aligntopath = true;
		this._smoothscale = true;
		this._isClosedProfile = false;
		this._doubles = [];
		this._materialList = [];
		this._segIndex = -1;
		this._segvstart = 0;
		
		
		_path = path;
		_points = points;
		_scales = scales;
		_rotations = rotations;
		_materialList = (!init.materials) ? null : init.materials;
		_matIndex = (!init.materials) ? null : _materialList.length;
		init = Init.parse(init);
		super(init);
		_subdivision = init.getInt("subdivision", 1, {min:1});
		_scaling = init.getNumber("scaling", 1);
		_coverall = init.getBoolean("coverall", true);
		_coversegment = init.getBoolean("coversegment", false);
		_coverall = (_coversegment) ? false : _coverall;
		_recenter = init.getBoolean("recenter", false);
		_flip = init.getBoolean("flip", false);
		_closepath = init.getBoolean("closepath", false);
		_aligntopath = init.getBoolean("aligntopath", true);
		_smoothscale = init.getBoolean("smoothscale", true);
		_mapfit = init.getBoolean("mapfit", false);
		if (_points != null) {
			_isClosedProfile = (points[0].x == points[points.length - 1].x && points[0].y == points[points.length - 1].y && points[0].z == points[points.length - 1].z);
		}
		if (_path != null && _points != null) {
			build();
		}
	}

	/**
	 * Builds the PathExtrude object.
	 */
	public function build():Void {
		
		if (_path.length != 0 && _points.length >= 2) {
			_worldAxis = _path.worldAxis;
			var aSegPoints:Array<Dynamic> = PathUtils.getPointsOnCurve(_path, _subdivision);
			var aPointlist:Array<Dynamic> = [];
			var aSegresult:Array<Dynamic> = [];
			var atmp:Array<Dynamic>;
			var tmppt:Number3D = new Number3D(0, 0, 0);
			var i:Int;
			var j:Int;
			var k:Int;
			var nextpt:Number3D;
			if (_closepath) {
				var lastP:Array<Dynamic> = [];
			}
			var rescale:Bool = (_scales != null);
			if (rescale) {
				var lastscale:Number3D = (_scales[0] == null) ? new Number3D(1, 1, 1) : _scales[0];
			}
			var rotate:Bool = (_rotations != null);
			if (rotate && _rotations.length > 0) {
				var lastrotate:Number3D = _rotations[0];
				var nextrotate:Number3D;
				var aRotates:Array<Dynamic> = [];
				var tweenrot:Number3D;
			}
			if (_smoothscale && rescale) {
				var nextscale:Number3D = new Number3D(1, 1, 1);
				var aScales:Array<Dynamic> = [lastscale];
			}
			var tmploop:Int = _points.length;
			i = 0;
			while (i < aSegPoints.length) {
				if (rotate) {
					lastrotate = (_rotations[i] == null) ? lastrotate : _rotations[i];
					nextrotate = (_rotations[i + 1] == null) ? lastrotate : _rotations[i + 1];
					aRotates = [lastrotate];
					aRotates = aRotates.concat(PathUtils.step(lastrotate, nextrotate, _subdivision));
				}
				if (rescale) {
					lastscale = (_scales[i] == null) ? lastscale : _scales[i];
				}
				if (_smoothscale && rescale) {
					nextscale = (_scales[i + 1] == null) ? (_scales[i] == null) ? lastscale : _scales[i] : _scales[i + 1];
					aScales = aScales.concat(PathUtils.step(lastscale, nextscale, _subdivision));
				}
				j = 0;
				while (j < aSegPoints[i].length) {
					atmp = [];
					atmp = atmp.concat(_points);
					aPointlist = [];
					if (rotate) {
						tweenrot = aRotates[j];
					}
					if (_aligntopath) {
						_transform = new Matrix3D();
						if (i == aSegPoints.length - 1 && j == aSegPoints[i].length - 1) {
							if (_closepath) {
								nextpt = aSegPoints[0][0];
								orientateAt(nextpt, aSegPoints[i][j]);
							} else {
								nextpt = aSegPoints[i][j - 1];
								orientateAt(aSegPoints[i][j], nextpt);
							}
						} else {
							nextpt = (j < aSegPoints[i].length - 1) ? aSegPoints[i][j + 1] : aSegPoints[i + 1][0];
							orientateAt(nextpt, aSegPoints[i][j]);
						}
					}
					k = 0;
					while (k < tmploop) {
						if (_aligntopath) {
							tmppt = new Number3D();
							tmppt.x = atmp[k].x * _transform.sxx + atmp[k].y * _transform.sxy + atmp[k].z * _transform.sxz + _transform.tx;
							tmppt.y = atmp[k].x * _transform.syx + atmp[k].y * _transform.syy + atmp[k].z * _transform.syz + _transform.ty;
							tmppt.z = atmp[k].x * _transform.szx + atmp[k].y * _transform.szy + atmp[k].z * _transform.szz + _transform.tz;
							if (rotate) {
								tmppt = PathUtils.rotatePoint(tmppt, tweenrot);
							}
							tmppt.x += aSegPoints[i][j].x;
							tmppt.y += aSegPoints[i][j].y;
							tmppt.z += aSegPoints[i][j].z;
						} else {
							tmppt = new Number3D(atmp[k].x + aSegPoints[i][j].x, atmp[k].y + aSegPoints[i][j].y, atmp[k].z + aSegPoints[i][j].z);
						}
						aPointlist.push(tmppt);
						if (rescale && !_smoothscale) {
							tmppt.x *= lastscale.x;
							tmppt.y *= lastscale.y;
							tmppt.z *= lastscale.z;
						}
						
						// update loop variables
						++k;
					}

					if (_scaling != 1) {
						k = 0;
						while (k < aPointlist.length) {
							aPointlist[k].x *= _scaling;
							aPointlist[k].y *= _scaling;
							aPointlist[k].z *= _scaling;
							
							// update loop variables
							++k;
						}

					}
					if (_closepath && i == aSegPoints.length - 1 && j == aSegPoints[i].length - 1) {
						break;
					}
					if (_closepath) {
						lastP = aPointlist;
					}
					aSegresult.push(aPointlist);
					
					// update loop variables
					++j;
				}

				
				// update loop variables
				++i;
			}

			if (rescale && _smoothscale) {
				i = 0;
				while (i < aScales.length) {
					j = 0;
					while (j < aSegresult[i].length) {
						aSegresult[i][j].x *= aScales[i].x;
						aSegresult[i][j].y *= aScales[i].y;
						aSegresult[i][j].z *= aScales[i].z;
						
						// update loop variables
						++j;
					}

					
					// update loop variables
					++i;
				}

				aScales = null;
			}
			if (rotate) {
				aRotates = null;
			}
			if (_closepath) {
				var stepx:Float;
				var stepy:Float;
				var stepz:Float;
				var c:Array<Dynamic>;
				var c2:Array<Dynamic> = [[]];
				i = 1;
				while (i < _subdivision + 1) {
					c = [];
					j = 0;
					while (j < lastP.length) {
						stepx = (aSegresult[0][j].x - lastP[j].x) / _subdivision;
						stepy = (aSegresult[0][j].y - lastP[j].y) / _subdivision;
						stepz = (aSegresult[0][j].z - lastP[j].z) / _subdivision;
						c.push(new Number3D(lastP[j].x + (stepx * i), lastP[j].y + (stepy * i), lastP[j].z + (stepz * i)));
						
						// update loop variables
						++j;
					}

					c2.push(c);
					
					// update loop variables
					++i;
				}

				c2[0] = lastP;
				generate(c2, (_coverall) ? aSegresult.length : 0, _coverall);
				c = c2 = null;
			}
			generate(aSegresult, (_closepath && _coverall) ? 1 : 0, (_closepath && !_coverall));
			aSegPoints = null;
			varr = null;
			if (_recenter) {
				applyPosition((this.minX + this.maxX) * .5, (this.minY + this.maxY) * .5, (this.minZ + this.maxZ) * .5);
			}
			type = "PathExtrude";
			url = "Extrude";
		} else {
			trace("PathExtrude error: at least 2 Number3D are required in points. Path definition requires at least 1 object with 3 parameters: {v0:Number3D, va:Number3D ,v1:Number3D}, all properties being Number3D.");
		}
	}

	/**
	 * Defines the resolution beetween each CurveSegments. Default 2, minimum 2.
	 */
	public function setSubdivision(val:Int):Int {
		
		_subdivision = (val < 2) ? 2 : val;
		return val;
	}

	public function getSubdivision():Int {
		
		return _subdivision;
	}

	/**
	 * Defines the scaling of the final generated mesh. Not being considered while building the mesh. Default 1.
	 */
	public function setScaling(val:Float):Float {
		
		_scaling = val;
		return val;
	}

	public function getScaling():Float {
		
		return _scaling;
	}

	/**
	 * Defines if the texture(s) should cover the entire mesh or per steps between segments. Set coversegment to true to cover per segment. Default true.
	 */
	public function setCoverall(b:Bool):Bool {
		
		_coverall = b;
		return b;
	}

	public function getCoverall():Bool {
		
		return _coverall;
	}

	/**
	 * Defines if the texture(s) should applied per segment. Default false.
	 */
	public function setCoversegment(b:Bool):Bool {
		
		_coversegment = b;
		return b;
	}

	public function getCoversegment():Bool {
		
		return _coversegment;
	}

	/**
	 * Defines if the texture(s) should be projected on the geometry evenly spreaded over the source bitmapdata or using distance/percent. Default is false.
	 * Note that it is NOT suitable if a scale array is being used. The mapping considers first and last profile points are the most distant from each other. most left and most right on the map.
	 */
	public function setMapfit(b:Bool):Bool {
		
		_mapfit = b;
		return b;
	}

	public function getMapfit():Bool {
		
		return _mapfit;
	}

	/**
	 * Defines if the final mesh should have its pivot reset to its center after generation. Default false.
	 */
	public function setRecenter(b:Bool):Bool {
		
		_recenter = b;
		return b;
	}

	public function getRecenter():Bool {
		
		return _recenter;
	}

	/**
	 * Defines if the generated faces should be inversed. Default false.
	 */
	public function setFlip(b:Bool):Bool {
		
		_flip = b;
		return b;
	}

	public function getFlip():Bool {
		
		return _flip;
	}

	/**
	 * Defines if the last segment should join the first one and close the loop. Default false.
	 */
	public function setClosepath(b:Bool):Bool {
		
		_closepath = b;
		return b;
	}

	public function getClosepath():Bool {
		
		return _closepath;
	}

	/**
	 * Defines if the profile point array should be orientated on path or not. Default true. Note that Path object worldaxis property might need to be changed. default = 0,1,0.
	 */
	public function setAligntopath(b:Bool):Bool {
		
		_aligntopath = b;
		return b;
	}

	public function getAligntopath():Bool {
		
		return _aligntopath;
	}

	/**
	 * Defines if a scale array of number3d is passed if the scaling should be affecting the whole segment or spreaded from previous curvesegmentscale to the next curvesegmentscale. Default true.
	 */
	public function setSmoothscale(b:Bool):Bool {
		
		_smoothscale = b;
		return b;
	}

	public function getSmoothscale():Bool {
		
		return _smoothscale;
	}

	/**
	 * Sets and defines the Path object. See animators.data package. Required.
	 */
	public function setPath(p:Path):Path {
		
		_path = p;
		return p;
	}

	public function getPath():Path {
		
		return _path;
	}

	/**
	 * Sets and defines the Array of Number3D's (the profile information to be projected according to the Path object). Required.
	 */
	public function setPoints(aR:Array<Dynamic>):Array<Dynamic> {
		
		_points = aR;
		_isClosedProfile = (points[0].x == points[points.length - 1].x && points[0].y == points[points.length - 1].y && points[0].z == points[points.length - 1].z);
		return aR;
	}

	public function getPoints():Array<Dynamic> {
		
		return _points;
	}

	/**
	 * Sets and defines the optional Array of Number3D's. A series of scales to be set on each CurveSegments
	 */
	public function setScales(aR:Array<Dynamic>):Array<Dynamic> {
		
		_scales = aR;
		return aR;
	}

	public function getScales():Array<Dynamic> {
		
		return _scales;
	}

	/**
	 * Sets and defines the optional Array of Number3D's. A series of rotations to be set on each CurveSegments
	 */
	public function setRotations(aR:Array<Dynamic>):Array<Dynamic> {
		
		_rotations = aR;
		return aR;
	}

	public function getRotations():Array<Dynamic> {
		
		return _rotations;
	}

	/**
	 * Sets an optional Array of materials. The materials are applyed after each other when coverall is false. On each repeats if coversegment is false.
	 * Once the last material in array is reached while path is not finished yet, the material at index 0 will be used again, then 1, 2 etc... until the construction reaches the end of the path definition.
	 */
	public function setMaterials(aR:Array<Dynamic>):Array<Dynamic> {
		
		_materialList = aR;
		return aR;
	}

	public function getMaterials():Array<Dynamic> {
		
		return _materialList;
	}

}

