package away3d.core.geom;

import flash.events.EventDispatcher;
import away3d.core.base.Object3D;
import away3d.core.math.Number3D;
import away3d.core.math.Matrix3D;


class Frustum  {
	
	public static inline var LEFT:Int = 0;
	public static inline var RIGHT:Int = 1;
	public static inline var TOP:Int = 2;
	public static inline var BOTTOM:Int = 3;
	public static inline var NEAR:Int = 4;
	public static inline var FAR:Int = 5;
	//clasification
	public static inline var OUT:Int = 0;
	public static inline var IN:Int = 1;
	public static inline var INTERSECT:Int = 2;
	public var planes:Array<Dynamic>;
	private var _matrix:Matrix3D;
	private var _plane:Plane3D;
	private var _distance:Float;
	

	/**
	 * Creates a frustum consisting of 6 planes in 3d space.
	 */
	public function new() {
		this._matrix = new Matrix3D();
		
		
		planes = new Array<Dynamic>();
		planes[LEFT] = new Plane3D();
		planes[RIGHT] = new Plane3D();
		planes[TOP] = new Plane3D();
		planes[BOTTOM] = new Plane3D();
		planes[NEAR] = new Plane3D();
		planes[FAR] = new Plane3D();
	}

	/**
	 * Classify this Object3D against this frustum
	 * @return int Frustum.IN, Frustum.OUT or Frustum.INTERSECT
	 */
	public function classifyObject3D(obj:Object3D):Int {
		
		return classifySphere(obj.sceneTransform.position, obj.boundingRadius);
	}

	/**
	 * Classify this sphere against this frustum
	 * @return int Frustum.IN, Frustum.OUT or Frustum.INTERSECT
	 */
	public function classifySphere(center:Number3D, radius:Float):Int {
		
		for (__i in 0...planes.length) {
			_plane = planes[__i];

			if (_plane != null) {
				_distance = _plane.distance(center);
				if (_distance < -radius) {
					return OUT;
				}
				if (Math.abs(_distance) < radius) {
					return INTERSECT;
				}
			}
		}

		return IN;
	}

	/**
	 * Classify this radius against this frustum
	 * @return int Frustum.IN, Frustum.OUT or Frustum.INTERSECT
	 */
	public function classifyRadius(radius:Float):Int {
		
		for (__i in 0...planes.length) {
			_plane = planes[__i];

			if (_plane != null) {
				if (_plane.d < -radius) {
					return OUT;
				}
				if (Math.abs(_plane.d) < radius) {
					return INTERSECT;
				}
			}
		}

		return IN;
	}

	/**
	 * Classify this axis aligned bounding box against this frustum
	 * @return int Frustum.IN, Frustum.OUT or Frustum.INTERSECT
	 */
	public function classifyAABB(points:Array<Dynamic>):Int {
		
		var planesIn:Int = 0;
		var p:Int = 0;
		while (p < 6) {
			var plane:Plane3D = planes[p];
			var pointsIn:Int = 0;
			var i:Int = 0;
			while (i < 8) {
				if (plane.classifyPoint(points[i]) == Plane3D.FRONT) {
					pointsIn++;
				}
				
				// update loop variables
				i++;
			}

			if (pointsIn == 0) {
				return OUT;
			}
			if (pointsIn == 8) {
				planesIn++;
			}
			
			// update loop variables
			p++;
		}

		if (planesIn == 6) {
			return IN;
		}
		return INTERSECT;
	}

	/**
	 * Extract this frustum's plane from the 4x4 projection matrix m.
	 */
	public function extractFromMatrix(m:Matrix3D):Void {
		
		_matrix = m;
		var sxx:Float = m.sxx;
		var sxy:Float = m.sxy;
		var sxz:Float = m.sxz;
		var tx:Float = m.tx;
		var syx:Float = m.syx;
		var syy:Float = m.syy;
		var syz:Float = m.syz;
		var ty:Float = m.ty;
		var szx:Float = m.szx;
		var szy:Float = m.szy;
		var szz:Float = m.szz;
		var tz:Float = m.tz;
		var swx:Float = m.swx;
		var swy:Float = m.swy;
		var swz:Float = m.swz;
		var tw:Float = m.tw;
		var near:Plane3D = planes[NEAR];
		near.a = swx + szx;
		near.b = swy + szy;
		near.c = swz + szz;
		near.d = tw + tz;
		near.normalize();
		var far:Plane3D = planes[FAR];
		far.a = -szx + swx;
		far.b = -szy + swy;
		far.c = -szz + swz;
		far.d = -tz + tw;
		far.normalize();
		var left:Plane3D = planes[LEFT];
		left.a = swx + sxx;
		left.b = swy + sxy;
		left.c = swz + sxz;
		left.d = tw + tx;
		left.normalize();
		var right:Plane3D = planes[RIGHT];
		right.a = -sxx + swx;
		right.b = -sxy + swy;
		right.c = -sxz + swz;
		right.d = -tx + tw;
		right.normalize();
		var top:Plane3D = planes[TOP];
		top.a = swx + syx;
		top.b = swy + syy;
		top.c = swz + syz;
		top.d = tw + ty;
		top.normalize();
		var bottom:Plane3D = planes[BOTTOM];
		bottom.a = -syx + swx;
		bottom.b = -syy + swy;
		bottom.c = -syz + swz;
		bottom.d = -ty + tw;
		bottom.normalize();
	}

}

