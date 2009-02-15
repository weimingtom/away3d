package away3d.extrusions;

import away3d.animators.data.CurveSegment;
import away3d.animators.data.Path;
import away3d.animators.utils.PathUtils;
import away3d.core.math.Matrix3D;
import away3d.core.math.Number3D;
import away3d.core.utils.Init;
import away3d.materials.IMaterial;
import flash.events.EventDispatcher;
import away3d.materials.ITriangleMaterial;
import away3d.core.base.Face;
import away3d.core.base.Object3D;
import away3d.core.base.Mesh;
import away3d.core.base.UV;
import away3d.core.base.Vertex;
import away3d.core.base.Element;


class PathDuplicator extends Mesh  {
	public var subdivision(getSubdivision, setSubdivision) : Int;
	public var scaling(getScaling, setScaling) : Float;
	public var recenter(getRecenter, setRecenter) : Bool;
	public var closepath(getClosepath, setClosepath) : Bool;
	public var aligntopath(getAligntopath, setAligntopath) : Bool;
	public var smoothscale(getSmoothscale, setSmoothscale) : Bool;
	public var path(getPath, setPath) : Path;
	public var mesh(getMesh, setMesh) : Object3D;
	public var scales(getScales, setScales) : Array<Dynamic>;
	public var meshes(getMeshes, setMeshes) : Array<Dynamic>;
	public var segmentspread(getSegmentspread, setSegmentspread) : Bool;
	public var texture(getTexture, setTexture) : ITriangleMaterial;
	public var rotations(getRotations, setRotations) : Array<Dynamic>;
	
	// use namespace arcane;

	private var xAxis:Number3D;
	private var yAxis:Number3D;
	private var zAxis:Number3D;
	private var _worldAxis:Number3D;
	private var _transform:Matrix3D;
	private var _path:Path;
	private var _points:Array<Dynamic>;
	private var _uvs:Array<Dynamic>;
	private var _materials:Array<Dynamic>;
	private var _mesh:Object3D;
	private var _meshes:Array<Dynamic>;
	private var _meshesindex:Int;
	private var _scales:Array<Dynamic>;
	private var _rotations:Array<Dynamic>;
	private var _subdivision:Int;
	private var _scaling:Float;
	private var _recenter:Bool;
	private var _closepath:Bool;
	private var _aligntopath:Bool;
	private var _smoothscale:Bool;
	private var _segmentspread:Bool;
	private var _material:ITriangleMaterial;
	

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

	private function getGeomInfo():Void {
		
		_points = [];
		_uvs = [];
		_materials = [];
		var face:Face;
		if (_mesh != null) {
			for (__i in 0...(cast(_mesh, Mesh)).faces.length) {
				face = (cast(_mesh, Mesh)).faces[__i];

				_points.push(face.v0, face.v1, face.v2);
				_uvs.push(face.uv0, face.uv1, face.uv2);
				_materials.push(face.material, null, null);
			}

		} else {
			for (__i in 0...(cast(_meshes[_meshesindex], Mesh)).faces.length) {
				face = (cast(_meshes[_meshesindex], Mesh)).faces[__i];

				_points.push(face.v0, face.v1, face.v2);
				_uvs.push(face.uv0, face.uv1, face.uv2);
				_materials.push(face.material, null, null);
			}

			_meshesindex = (_meshesindex + 1 < _meshes.length) ? _meshesindex + 1 : 0;
		}
	}

	private function generate(aPointList:Array<Dynamic>):Void {
		
		var uva:UV;
		var uvb:UV;
		var uvc:UV;
		var va:Vertex;
		var vb:Vertex;
		var vc:Vertex;
		var m:Mesh = (_mesh == null) ? cast(_meshes[_meshesindex], Mesh) : cast(_mesh, Mesh);
		var i:Int = 0;
		while (i < aPointList.length) {
			uva = new UV();
			uvb = new UV();
			uvc = new UV();
			va = new Vertex();
			vb = new Vertex();
			vc = new Vertex();
			if (_material == null) {
				if (_materials[i] != null) {
					addFace(new Face());
				} else {
					addFace(new Face());
				}
			} else {
				addFace(new Face());
			}
			
			// update loop variables
			i += 3;
		}

	}

	function new(?path:Path=null, ?mesh:Object3D=null, ?scales:Array<Dynamic>=null, ?rotations:Array<Dynamic>=null, ?init:Dynamic=null) {
		this.xAxis = new Number3D();
		this.yAxis = new Number3D();
		this.zAxis = new Number3D();
		this._worldAxis = new Number3D();
		this._transform = new Matrix3D();
		this._meshes = [];
		this._meshesindex = 0;
		this._subdivision = 2;
		this._scaling = 1;
		this._recenter = false;
		this._closepath = false;
		this._aligntopath = true;
		this._smoothscale = true;
		this._segmentspread = false;
		
		
		_path = path;
		_mesh = mesh;
		_scales = scales;
		_rotations = rotations;
		init = Init.parse(init);
		super(init);
		_subdivision = init.getInt("subdivision", 2, {min:2});
		_scaling = init.getNumber("scaling", 1);
		_recenter = init.getBoolean("recenter", false);
		_closepath = init.getBoolean("closepath", false);
		_aligntopath = init.getBoolean("aligntopath", true);
		_smoothscale = init.getBoolean("smoothscale", true);
		_segmentspread = init.getBoolean("segmentspread", false);
		_meshes = init.getArray("meshes");
		_material = cast(ini.getMaterial("material"), ITriangleMaterial);
		if (_path != null && (_mesh != null || _meshes[0] != null)) {
			build();
		}
	}

	public function build():Void {
		
		var m:Mesh = (_mesh == null) ? cast(_meshes[0], Mesh) : cast(_mesh, Mesh);
		if (_path.length != 0 && m.faces != null) {
			_worldAxis = _path.worldAxis;
			/*if(_closepath){
			 var ref:CurveSegment = _path.array[_path.array.length-1];
			 var vc:Number3D = new Number3D(  (_path.array[0].vc.x+ref.vc.x)*.5,  (_path.array[0].vc.y+ref.vc.y)*.5, (_path.array[0].vc.z+ref.vc.z)*.5   );
			 _path.add( new CurveSegment( _path.array[0].v1, vc, _path.array[0].v0 )   );
			 if(_path.smoothed){
			 var tpv1:Number3D = new Number3D((_path.array[0].v0.x+_path.array[_path.length-1].v0.x)*.5, (_path.array[0].v0.y+_path.array[_path.length-1].v0.y)*.5, (_path.array[0].v0.z+_path.array[_path.length-1].v0.z)*.5);
			 var tpv2:Number3D = new Number3D((_path.array[0].v0.x+_path.array[0].v1.x)*.5, (_path.array[0].v0.y+_path.array[0].v1.y)*.5, (_path.array[0].v0.z+_path.array[0].v1.z)*.5);
			 _path.array[_path.length-1].vc.x = tpv1.x;
			 _path.array[_path.length-1].vc.y = tpv1.y;
			 _path.array[_path.length-1].vc.z = tpv1.z;
			 _path.array[_path.length-1].v1.x = (_path.array[0].v0.x+_path.array[0].v1.x)*.5;
			 _path.array[_path.length-1].v1.y = (_path.array[0].v0.y+_path.array[0].v1.y)*.5;
			 _path.array[_path.length-1].v1.z = (_path.array[0].v0.z+_path.array[0].v1.z)*.5;
			 _path.array[0].v0.x = _path.array[_path.length-1].vc.x;
			 _path.array[0].v0.y = _path.array[_path.length-1].vc.y;
			 _path.array[0].v0.z = _path.array[_path.length-1].vc.z;
			 _path.array[0].vc.x = tpv2.x;
			 _path.array[0].vc.y = tpv2.y;
			 _path.array[0].vc.z = tpv2.z;
			 tpv1 = null;
			 tpv2 = null;
			 } 
			 }*/
			var aSegPoints:Array<Dynamic> = PathUtils.getPointsOnCurve(_path, _subdivision);
			var aPointlist:Array<Dynamic> = [];
			var aSegresult:Array<Dynamic> = [];
			var atmp:Array<Dynamic>;
			var tmppt:Number3D = new Number3D();
			var i:Int;
			var j:Int;
			var k:Int;
			var nextpt:Number3D;
			var lastscale:Number3D = new Number3D();
			var rescale:Bool = (_scales != null);
			var rotate:Bool = (_rotations != null);
			if (rotate && _rotations.length > 0) {
				var lastrotate:Number3D = _rotations[0];
				var nextrotate:Number3D;
				var aRotates:Array<Dynamic> = [];
				var tweenrot:Number3D;
			}
			if (_smoothscale && rescale) {
				var nextscale:Number3D = new Number3D();
			}
			var aTs:Array<Dynamic> = [];
			if (_meshes.length == 0) {
				getGeomInfo();
			}
			i = 0;
			while (i < aSegPoints.length) {
				if (_meshes.length > 0 && !_segmentspread) {
					getGeomInfo();
				}
				if (rotate && i < aSegPoints.length) {
					lastrotate = (_rotations[i] == null) ? lastrotate : _rotations[i];
					nextrotate = (_rotations[i + 1] == null) ? lastrotate : _rotations[i + 1];
					aRotates = [lastrotate];
					aRotates = aRotates.concat(PathUtils.step(lastrotate, nextrotate, _subdivision));
				}
				if (rescale) {
					lastscale = (_scales[i] == null) ? lastscale : _scales[i];
				}
				if (_smoothscale && rescale && i < aSegPoints.length) {
					nextscale = (_scales[i + 1] == null) ? lastscale : _scales[i + 1];
					aTs = aTs.concat(PathUtils.step(lastscale, nextscale, _subdivision));
				}
				j = 0;
				while (j < aSegPoints[i].length) {
					if (_meshes.length > 0 && _segmentspread) {
						getGeomInfo();
					}
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
					while (k < atmp.length) {
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
							aPointlist.push(tmppt);
						} else {
							tmppt = new Number3D();
							aPointlist.push(tmppt);
						}
						if (rescale && !_smoothscale) {
							tmppt.x *= lastscale.x;
							tmppt.y *= lastscale.y;
							tmppt.z *= lastscale.z;
						}
						
						// update loop variables
						k++;
					}

					if (_scaling != 1) {
						k = 0;
						while (k < aPointlist.length) {
							aPointlist[k].x *= _scaling;
							aPointlist[k].y *= _scaling;
							aPointlist[k].z *= _scaling;
							
							// update loop variables
							k++;
						}

					}
					generate(aPointlist);
					
					// update loop variables
					j++;
				}

				
				// update loop variables
				i++;
			}

			if (rotate) {
				aRotates = null;
			}
			if (_meshes.length > 0) {
				_meshes = null;
			}
			/*
			 if(rescale && _smoothscale){
			 for (i = 0; i < aTs.length; i++) {
			 for (j = 0;j < aSegresult[i].length; j++) {
			 aSegresult[i][j].x *= aTs[i].x;
			 aSegresult[i][j].y *= aTs[i].y;
			 aSegresult[i][j].z *= aTs[i].z;
			 }
			 }
			 aTs = null;
			 }
			 */
			aSegPoints = null;
			if (_recenter) {
				applyPosition((this.minX + this.maxX) * .5, (this.minY + this.maxY) * .5, (this.minZ + this.maxZ) * .5);
			}
			/*else {
			 x =  _path.array[0].v1.x;
			 y =  _path.array[0].v1.y;
			 z =  _path.array[0].v1.z;
			 }*/
			type = "PathDuplicator";
			url = "Extrude";
		} else {
			trace("PathDuplicator error: mesh must be a valid Object3D of Mesh Type (same for meshes array). Path definition requires at least 1 object with 3 parameters: {v0:Number3D, va:Number3D ,v1:Number3D}, all properties being Number3D.");
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
	 * Sets and defines the Array of Number3D's (the profile information to be projected according to the Path object). Required if you do not pass a meshes array.
	 */
	public function setMesh(m:Object3D):Object3D {
		
		_mesh = m;
		return m;
	}

	public function getMesh():Object3D {
		
		return _mesh;
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
	 * Sets and defines the optional Array of meshes. A series of meshes to be placed to be duplicated within each CurveSegments. When the last one in the array is reached, the first in the array will be used until the class reaches the last segment.
	 */
	public function setMeshes(aR:Array<Dynamic>):Array<Dynamic> {
		
		_meshes = aR;
		return aR;
	}

	public function getMeshes():Array<Dynamic> {
		
		return _meshes;
	}

	/**
	 * if the optional Array of meshes is passed, segmentspread define if the meshes[index] is repeated per segments or duplicated after each others. default = false.
	 */
	public function setSegmentspread(b:Bool):Bool {
		
		_segmentspread = b;
		return b;
	}

	public function getSegmentspread():Bool {
		
		return _segmentspread;
	}

	/**
	 * Sets and defines the optional material to apply on each duplicated mesh information, according to source mesh.
	 */
	public function setTexture(mat:ITriangleMaterial):ITriangleMaterial {
		
		_material = mat;
		return mat;
	}

	public function getTexture():ITriangleMaterial {
		
		return _material;
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

}

