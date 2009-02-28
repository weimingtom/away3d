package away3d.materials;

import away3d.haxeutils.Error;
import flash.display.BitmapData;
import away3d.containers.View3D;
import flash.geom.Rectangle;
import flash.geom.Point;
import away3d.core.base.Object3D;
import flash.geom.Matrix;
import flash.geom.ColorTransform;
import away3d.core.utils.Init;
import away3d.core.utils.FaceVO;
import away3d.core.utils.Debug;
import away3d.core.utils.FaceMaterialVO;
import away3d.core.math.Number3D;
import away3d.core.draw.DrawTriangle;
import away3d.core.draw.DrawPrimitive;
import flash.display.Shape;
import flash.display.Graphics;


// use namespace arcane;

/** Basic bitmap texture material */
class TransformBitmapMaterial extends BitmapMaterial, implements ITriangleMaterial, implements IUVMaterial {
	public var throughProjection(getThroughProjection, setThroughProjection) : Bool;
	public var globalProjection(getGlobalProjection, setGlobalProjection) : Bool;
	public var transform(getTransform, setTransform) : Matrix;
	public var scaleX(getScaleX, setScaleX) : Float;
	public var scaleY(getScaleY, setScaleY) : Float;
	public var offsetX(getOffsetX, setOffsetX) : Float;
	public var offsetY(getOffsetY, setOffsetY) : Float;
	public var rotation(getRotation, setRotation) : Float;
	public var projectionVector(getProjectionVector, setProjectionVector) : Number3D;
	
	/** @private */
	public var _transform:Matrix;
	private var _scaleX:Float;
	private var _scaleY:Float;
	private var _offsetX:Float;
	private var _offsetY:Float;
	private var _rotation:Float;
	private var _projectionVector:Number3D;
	private var _projectionDirty:Bool;
	private var _N:Number3D;
	private var _M:Number3D;
	private var DOWN:Number3D;
	private var RIGHT:Number3D;
	private var _transformDirty:Bool;
	private var _throughProjection:Bool;
	private var _globalProjection:Bool;
	private var faceVO:FaceVO;
	private var __x:Float;
	private var __y:Float;
	private var px:Float;
	private var py:Float;
	private var w:Float;
	private var h:Float;
	private var normalR:Number3D;
	private var _u0:Float;
	private var _u1:Float;
	private var _u2:Float;
	private var _v0:Float;
	private var _v1:Float;
	private var _v2:Float;
	private var v0x:Float;
	private var v0y:Float;
	private var v0z:Float;
	private var v1x:Float;
	private var v1y:Float;
	private var v1z:Float;
	private var v2x:Float;
	private var v2y:Float;
	private var v2z:Float;
	private var v0:Number3D;
	private var v1:Number3D;
	private var v2:Number3D;
	private var t:Matrix;
	private var _invtexturemapping:Matrix;
	private var fPoint1:Point;
	private var fPoint2:Point;
	private var fPoint3:Point;
	private var fPoint4:Point;
	private var mapa:Float;
	private var mapb:Float;
	private var mapc:Float;
	private var mapd:Float;
	private var maptx:Float;
	private var mapty:Float;
	private var mPoint1:Point;
	private var mPoint2:Point;
	private var mPoint3:Point;
	private var mPoint4:Point;
	private var overlap:Bool;
	private var i:String;
	private var dot:Float;
	private var line:Point;
	private var zero:Float;
	private var sign:Float;
	private var point:Point;
	private var point1:Point;
	private var point2:Point;
	private var point3:Point;
	private var flag:Bool;
	

	private function updateTransform():Void {
		
		_transformDirty = false;
		//check to see if no transformation exists
		if (_scaleX == 1 && _scaleY == 1 && _offsetX == 0 && _offsetY == 0 && _rotation == 0) {
			_transform = null;
		} else {
			_transform = new Matrix();
			_transform.scale(_scaleX, _scaleY);
			_transform.rotate(_rotation);
			_transform.translate(_offsetX, _offsetY);
		}
		_materialDirty = true;
	}

	private function projectUV(tri:DrawTriangle):Matrix {
		
		faceVO = tri.faceVO;
		if (globalProjection) {
			v0.transform(faceVO.v0.position, tri.source.sceneTransform);
			v1.transform(faceVO.v1.position, tri.source.sceneTransform);
			v2.transform(faceVO.v2.position, tri.source.sceneTransform);
		} else {
			v0 = faceVO.v0.position;
			v1 = faceVO.v1.position;
			v2 = faceVO.v2.position;
		}
		v0x = v0.x;
		v0y = v0.y;
		v0z = v0.z;
		v1x = v1.x;
		v1y = v1.y;
		v1z = v1.z;
		v2x = v2.x;
		v2y = v2.y;
		v2z = v2.z;
		_u0 = v0x * _N.x + v0y * _N.y + v0z * _N.z;
		_u1 = v1x * _N.x + v1y * _N.y + v1z * _N.z;
		_u2 = v2x * _N.x + v2y * _N.y + v2z * _N.z;
		_v0 = v0x * _M.x + v0y * _M.y + v0z * _M.z;
		_v1 = v1x * _M.x + v1y * _M.y + v1z * _M.z;
		_v2 = v2x * _M.x + v2y * _M.y + v2z * _M.z;
		// Fix perpendicular projections
		if ((_u0 == _u1 && _v0 == _v1) || (_u0 == _u2 && _v0 == _v2)) {
			if (_u0 > 0.05) {
				_u0 -= 0.05;
			} else {
				_u0 += 0.05;
			}
			if (_v0 > 0.07) {
				_v0 -= 0.07;
			} else {
				_v0 += 0.07;
			}
		}
		if (_u2 == _u1 && _v2 == _v1) {
			if (_u2 > 0.04) {
				_u2 -= 0.04;
			} else {
				_u2 += 0.04;
			}
			if (_v2 > 0.06) {
				_v2 -= 0.06;
			} else {
				_v2 += 0.06;
			}
		}
		t = new Matrix(_u1 - _u0, _v1 - _v0, _u2 - _u0, _v2 - _v0, _u0, _v0);
		t.invert();
		return t;
	}

	private function getContainerPoints(rect:Rectangle):Array<Dynamic> {
		
		return [rect.topLeft, new Point(rect.top, rect.right), rect.bottomRight, new Point(rect.bottom, rect.left)];
	}

	private function getFacePoints(map:Matrix):Array<Dynamic> {
		
		fPoint1.x = _u0 = map.tx;
		fPoint2.x = map.a + _u0;
		fPoint3.x = map.c + _u0;
		fPoint1.y = _v0 = map.ty;
		fPoint2.y = map.b + _v0;
		fPoint3.y = map.d + _v0;
		return [fPoint1, fPoint2, fPoint3];
	}

	private function getMappingPoints(map:Matrix):Array<Dynamic> {
		
		mapa = map.a * width;
		mapb = map.b * width;
		mapc = map.c * height;
		mapd = map.d * height;
		maptx = map.tx;
		mapty = map.ty;
		mPoint1.x = maptx;
		mPoint1.y = mapty;
		mPoint2.x = maptx + mapc;
		mPoint2.y = mapty + mapd;
		mPoint3.x = maptx + mapa + mapc;
		mPoint3.y = mapty + mapb + mapd;
		mPoint4.x = maptx + mapa;
		mPoint4.y = mapty + mapb;
		return [mPoint1, mPoint2, mPoint3, mPoint4];
	}

	private function findSeparatingAxis(points1:Array<Dynamic>, points2:Array<Dynamic>):Bool {
		
		if (checkEdge(points1, points2)) {
			return true;
		}
		if (checkEdge(points2, points1)) {
			return true;
		}
		return false;
	}

	private function checkEdge(points1:Array<Dynamic>, points2:Array<Dynamic>):Bool {
		
		for (i in points1) {
			point2 = Reflect.field(points1, i);
			//get point 2
			if (Std.int(i) == 0) {
				point1 = points1[points1.length - 1];
				point3 = points1[points1.length - 2];
			} else {
				point1 = points1[Std.int(i) - 1];
				if (Std.int(i) == 1) {
					point3 = points1[points1.length - 1];
				} else {
					point3 = points1[Std.int(i) - 2];
				}
			}
			//calulate perpendicular line
			line.x = point2.y - point1.y;
			line.y = point1.x - point2.x;
			zero = point1.x * line.x + point1.y * line.y;
			sign = zero - point3.x * line.x - point3.y * line.y;
			//calculate each projected value for points2
			flag = true;
			for (__i in 0...points2.length) {
				point = points2[__i];

				if (point != null) {
					dot = point.x * line.x + point.y * line.y;
					//return if zero is greater than dot
					if (zero * sign > dot * sign) {
						flag = false;
						break;
					}
				}
			}

			if (flag) {
				return true;
			}
			
		}

		return false;
	}

	/**
	 * @inheritDoc
	 */
	private override function getMapping(tri:DrawTriangle):Matrix {
		
		if (tri.generated) {
			if ((projectionVector != null)) {
				_texturemapping = projectUV(tri);
			} else {
				_texturemapping = tri.transformUV(this).clone();
				_texturemapping.invert();
			}
			//apply transform matrix if one exists
			if ((_transform != null)) {
				_mapping = _transform.clone();
				_mapping.concat(_texturemapping);
			} else {
				_mapping = _texturemapping;
			}
			return _mapping;
		}
		_faceMaterialVO = getFaceMaterialVO(tri.faceVO, tri.source);
		//check to see if rendering can be skipped
		if (!_faceMaterialVO.invalidated) {
			return _faceMaterialVO.texturemapping;
		}
		_faceMaterialVO.invalidated = false;
		//use projectUV if projection vector detected
		if ((projectionVector != null)) {
			_texturemapping = projectUV(tri);
		} else {
			_texturemapping = tri.transformUV(this).clone();
			_texturemapping.invert();
		}
		//apply transform matrix if one exists
		if ((_transform != null)) {
			_faceMaterialVO.texturemapping = _transform.clone();
			_faceMaterialVO.texturemapping.concat(_texturemapping);
			return _faceMaterialVO.texturemapping;
		}
		return _faceMaterialVO.texturemapping = _texturemapping;
	}

	/**
	 * Determines whether a projected texture is visble on the faces pointing away from the projection.
	 * 
	 * @see projectionVector
	 */
	public function getThroughProjection():Bool {
		
		return _throughProjection;
	}

	public function setThroughProjection(val:Bool):Bool {
		
		_throughProjection = val;
		_projectionDirty = true;
		return val;
	}

	/**
	 * Determines whether a projected texture uses offsetX, offsetY and projectionVector values relative to scene cordinates.
	 * 
	 * @see projectionVector
	 * @see offsetX
	 * @see offsetY
	 */
	public function getGlobalProjection():Bool {
		
		return _globalProjection;
	}

	public function setGlobalProjection(val:Bool):Bool {
		
		_globalProjection = val;
		_projectionDirty = true;
		return val;
	}

	/**
	 * Transforms the texture in uv-space
	 */
	public function getTransform():Matrix {
		
		return _transform;
	}

	public function setTransform(val:Matrix):Matrix {
		
		_transform = val;
		if ((_transform != null)) {
			_rotation = Math.atan2(_transform.b, _transform.a);
			//recalculate scale
			_scaleX = _transform.a / Math.cos(_rotation);
			_scaleY = _transform.d / Math.cos(_rotation);
			//recalculate offset
			_offsetX = _transform.tx;
			_offsetY = _transform.ty;
		} else {
			_scaleX = _scaleY = 1;
			_offsetX = _offsetY = _rotation = 0;
		}
		//_materialDirty = true;
		
		return val;
	}

	/**
	 * Scales the x coordinates of the texture in uv-space
	 */
	public function getScaleX():Float {
		
		return _scaleX;
	}

	public function setScaleX(val:Float):Float {
		
		if (Math.isNaN(val)) {
			throw new Error("isNaN(scaleX)");
		}
		if (val == Math.POSITIVE_INFINITY) {
			Debug.warning("scaleX == Infinity");
		}
		if (val == -Math.POSITIVE_INFINITY) {
			Debug.warning("scaleX == -Infinity");
		}
		if (val == 0) {
			Debug.warning("scaleX == 0");
		}
		_scaleX = val;
		_transformDirty = true;
		return val;
	}

	/**
	 * Scales the y coordinates of the texture in uv-space
	 */
	public function getScaleY():Float {
		
		return _scaleY;
	}

	public function setScaleY(val:Float):Float {
		
		if (Math.isNaN(val)) {
			throw new Error("isNaN(scaleY)");
		}
		if (val == Math.POSITIVE_INFINITY) {
			Debug.warning("scaleY == Infinity");
		}
		if (val == -Math.POSITIVE_INFINITY) {
			Debug.warning("scaleY == -Infinity");
		}
		if (val == 0) {
			Debug.warning("scaleY == 0");
		}
		_scaleY = val;
		_transformDirty = true;
		return val;
	}

	/**
	 * Offsets the x coordinates of the texture in uv-space
	 */
	public function getOffsetX():Float {
		
		return _offsetX;
	}

	public function setOffsetX(val:Float):Float {
		
		if (Math.isNaN(val)) {
			throw new Error("isNaN(offsetX)");
		}
		if (val == Math.POSITIVE_INFINITY) {
			Debug.warning("offsetX == Infinity");
		}
		if (val == -Math.POSITIVE_INFINITY) {
			Debug.warning("offsetX == -Infinity");
		}
		_offsetX = val;
		_transformDirty = true;
		return val;
	}

	/**
	 * Offsets the y coordinates of the texture in uv-space
	 */
	public function getOffsetY():Float {
		
		return _offsetY;
	}

	public function setOffsetY(val:Float):Float {
		
		if (Math.isNaN(val)) {
			throw new Error("isNaN(offsetY)");
		}
		if (val == Math.POSITIVE_INFINITY) {
			Debug.warning("offsetY == Infinity");
		}
		if (val == -Math.POSITIVE_INFINITY) {
			Debug.warning("offsetY == -Infinity");
		}
		_offsetY = val;
		_transformDirty = true;
		return val;
	}

	/**
	 * Rotates the texture in uv-space
	 */
	public function getRotation():Float {
		
		return _rotation;
	}

	public function setRotation(val:Float):Float {
		
		if (Math.isNaN(val)) {
			throw new Error("isNaN(rotation)");
		}
		if (val == Math.POSITIVE_INFINITY) {
			Debug.warning("rotation == Infinity");
		}
		if (val == -Math.POSITIVE_INFINITY) {
			Debug.warning("rotation == -Infinity");
		}
		_rotation = val;
		_transformDirty = true;
		return val;
	}

	/**
	 * Projects the texture in object space, ignoring the uv coordinates of the vertex objects.
	 * Texture renders normally when set to <code>null</code>.
	 */
	public function getProjectionVector():Number3D {
		
		return _projectionVector;
	}

	public function setProjectionVector(val:Number3D):Number3D {
		
		_projectionVector = val;
		if ((_projectionVector != null)) {
			_N.cross(_projectionVector, DOWN);
			if (_N.modulo == 0) {
				_N = RIGHT;
			}
			_M.cross(_N, _projectionVector);
			_N.cross(_M, _projectionVector);
			_N.normalize();
			_M.normalize();
		}
		_projectionDirty = true;
		return val;
	}

	/**
	 * @inheritDoc
	 */
	public override function getPixel32(u:Float, v:Float):Int {
		
		if ((_transform != null)) {
			__x = u * _bitmap.width;
			__y = (1 - v) * _bitmap.height;
			t = _transform.clone();
			t.invert();
			if (repeat) {
				px = (__x * t.a + __y * t.c + t.tx) % _bitmap.width;
				py = (__x * t.b + __y * t.d + t.ty) % _bitmap.height;
				if (px < 0) {
					px += _bitmap.width;
				}
				if (py < 0) {
					py += _bitmap.height;
				}
				return _bitmap.getPixel32(px, py);
			} else {
				return _bitmap.getPixel32(__x * t.a + __y * t.c + t.tx, __x * t.b + __y * t.d + t.ty);
			}
		}
		return super.getPixel32(u, v);
	}

	/**
	 * Creates a new <code>TransformBitmapMaterial</code> object.
	 * 
	 * @param	bitmap				The bitmapData object to be used as the material's texture.
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(bitmap:BitmapData, ?init:Dynamic=null) {
		this._transform = new Matrix();
		this._scaleX = 1;
		this._scaleY = 1;
		this._offsetX = 0;
		this._offsetY = 0;
		this._rotation = 0;
		this._N = new Number3D();
		this._M = new Number3D();
		this.DOWN = new Number3D(0, -1, 0);
		this.RIGHT = new Number3D(1, 0, 0);
		this.normalR = new Number3D();
		this.v0 = new Number3D();
		this.v1 = new Number3D();
		this.v2 = new Number3D();
		this.fPoint1 = new Point();
		this.fPoint2 = new Point();
		this.fPoint3 = new Point();
		this.fPoint4 = new Point();
		this.mPoint1 = new Point();
		this.mPoint2 = new Point();
		this.mPoint3 = new Point();
		this.mPoint4 = new Point();
		this.line = new Point();
		
		
		super(bitmap, init);
		transform = cast(ini.getObject("transform", Matrix), Matrix);
		scaleX = ini.getNumber("scaleX", _scaleX);
		scaleY = ini.getNumber("scaleY", _scaleY);
		offsetX = ini.getNumber("offsetX", _offsetX);
		offsetY = ini.getNumber("offsetY", _offsetY);
		rotation = ini.getNumber("rotation", _rotation);
		projectionVector = cast(ini.getObject("projectionVector", Number3D), Number3D);
		throughProjection = ini.getBoolean("throughProjection", true);
		globalProjection = ini.getBoolean("globalProjection", false);
	}

	/**
	 * @inheritDoc
	 */
	public override function updateMaterial(source:Object3D, view:View3D):Void {
		
		_graphics = null;
		clearShapeDictionary();
		if (_colorTransformDirty) {
			updateColorTransform();
		}
		if (_bitmapDirty) {
			updateRenderBitmap();
		}
		if (_projectionDirty || _transformDirty) {
			invalidateFaces();
		}
		if (_transformDirty) {
			updateTransform();
		}
		if (_materialDirty || _blendModeDirty) {
			clearFaces();
		}
		_projectionDirty = false;
		_blendModeDirty = false;
	}

	/**
	 * @inheritDoc
	 */
	public override function renderTriangle(tri:DrawTriangle):Void {
		
		if ((_projectionVector != null) && !throughProjection) {
			if (globalProjection) {
				normalR.rotate(tri.faceVO.face.normal, tri.source.sceneTransform);
				if (normalR.dot(_projectionVector) < 0) {
					return;
				}
			} else if (tri.faceVO.face.normal.dot(_projectionVector) < 0) {
				return;
			}
		}
		super.renderTriangle(tri);
	}

	/**
	 * @inheritDoc
	 */
	public override function renderBitmapLayer(tri:DrawTriangle, containerRect:Rectangle, parentFaceMaterialVO:FaceMaterialVO):FaceMaterialVO {
		//retrieve the transform
		
		if ((_transform != null)) {
			_mapping = _transform.clone();
		} else {
			_mapping = new Matrix();
		}
		//if not projected, draw the source bitmap once
		if (_projectionVector == null) {
			renderSource(tri.source, containerRect, _mapping);
		}
		//get the correct faceMaterialVO
		_faceMaterialVO = getFaceMaterialVO(tri.faceVO);
		//pass on resize value
		if (parentFaceMaterialVO.resized) {
			parentFaceMaterialVO.resized = false;
			_faceMaterialVO.resized = true;
		}
		//pass on invtexturemapping value
		_faceMaterialVO.invtexturemapping = parentFaceMaterialVO.invtexturemapping;
		//check to see if rendering can be skipped
		if (parentFaceMaterialVO.updated || _faceMaterialVO.invalidated || _faceMaterialVO.updated) {
			parentFaceMaterialVO.updated = false;
			//retrieve the bitmapRect
			_bitmapRect = tri.faceVO.bitmapRect;
			//reset booleans
			if (_faceMaterialVO.invalidated) {
				_faceMaterialVO.invalidated = false;
			} else {
				_faceMaterialVO.updated = true;
			}
			//store a clone
			_faceMaterialVO.bitmap = parentFaceMaterialVO.bitmap.clone();
			//update the transform based on scaling or projection vector
			if ((_projectionVector != null)) {
				_invtexturemapping = _faceMaterialVO.invtexturemapping;
				_mapping.concat(projectUV(tri));
				_mapping.concat(_invtexturemapping);
				normalR.clone(tri.faceVO.face.normal);
				if (_globalProjection) {
					normalR.rotate(normalR, tri.source.sceneTransform);
				}
				//check to see if the bitmap (non repeating) lies inside the drawtriangle area
				if ((throughProjection || normalR.dot(_projectionVector) >= 0) && (repeat || !findSeparatingAxis(getFacePoints(_invtexturemapping), getMappingPoints(_mapping)))) {
					if (_faceMaterialVO.cleared) {
						_faceMaterialVO.bitmap = parentFaceMaterialVO.bitmap.clone();
					}
					_faceMaterialVO.cleared = false;
					_faceMaterialVO.updated = true;
					//draw into faceBitmap
					_graphics = _s.graphics;
					_graphics.clear();
					_graphics.beginBitmapFill(_bitmap, _mapping, repeat, smooth);
					_graphics.drawRect(0, 0, _bitmapRect.width, _bitmapRect.height);
					_graphics.endFill();
					_faceMaterialVO.bitmap.draw(_s, null, _colorTransform, _blendMode, _faceMaterialVO.bitmap.rect);
				}
			} else {
				if (repeat && !findSeparatingAxis(getContainerPoints(containerRect), getMappingPoints(_mapping))) {
					_faceMaterialVO.cleared = false;
					_faceMaterialVO.updated = true;
					//draw into faceBitmap
					_faceMaterialVO.bitmap.copyPixels(_sourceVO.bitmap, _bitmapRect, _zeroPoint, null, null, true);
				}
			}
		}
		return _faceMaterialVO;
	}

}

