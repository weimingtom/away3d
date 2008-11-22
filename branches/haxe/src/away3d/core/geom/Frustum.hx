package away3d.core.geom;

	import away3d.core.base.*;
	import away3d.core.geom.*;
	import away3d.core.math.*;
	
	/** b at turbulent dot ca */
	/* based on Tim Knip and Don Picco's frustum works */
	
	class Frustum
	 {
		
		inline public static var NEAR:Int = 0;
		inline public static var LEFT:Int = 1;
		inline public static var RIGHT:Int = 2;
		inline public static var TOP:Int = 3;
		inline public static var BOTTOM:Int = 4;
		inline public static var FAR:Int = 5;
		
		public var planeNames:Array<Dynamic> ;
		
		//clasification
		inline public static var IN:Int = 1;
		inline public static var OUT:Int = -1;
		inline public static var INTERSECT:Int = 0;
		
		public var planes:Array<Dynamic>;
		
		var _matrix:Matrix3D ;
		
		/**
		 * Creates a frustum consisting of 6 planes in 3d space.
		 */
		public function new()
		{
			
			planeNames = ['NEAR','LEFT','RIGHT','TOP','BOTTOM','FAR'];
			_matrix = new Matrix3D();
			planes = new Array(6);
			planes[NEAR] = new Plane3D();
			planes[LEFT] = new Plane3D();
			planes[RIGHT] = new Plane3D();
			planes[TOP] = new Plane3D();
			planes[BOTTOM] = new Plane3D();
			planes[FAR] = new Plane3D();
		}
		
		/**
		 * Classify this Object3D against this frustum
		 * @return int Frustum.IN, Frustum.OUT or Frustum.INTERSECT
		 */
		public function classifyObject3D(obj:Object3D):Int
		{
			return classifySphere(obj.sceneTransform.position, obj.boundingRadius);
		}
		
		/**
		 * Classify this sphere against this frustum
		 * @return int Frustum.IN, Frustum.OUT or Frustum.INTERSECT
		 */
		public function classifySphere(center:Number3D, radius:Float):Int
		{
			var dist:Float;
			for(p in 0...6)
			{
				dist = Plane3D(planes[p]).distance(center);
				if(dist < -radius)
				{
					return OUT;
				}
				if(Math.abs(dist) < radius)
				{
					return INTERSECT;	
				}
				
			}
			return IN;
		}
		
		/**
		 * Classify this axis aligned bounding box against this frustum
		 * @return int Frustum.IN, Frustum.OUT or Frustum.INTERSECT
		 */		
		public function classifyAABB(points:Array<Dynamic>):Int
		{
			var planesIn:Int = 0;
			
			for(p in 0...6)
			{
				var plane:Plane3D = Plane3D(planes[p]);
				var pointsIn:Int = 0;	
				
				for( i in 0...8)
				{
					if(plane.classifyPoint( points[i]) == Plane3D.FRONT)
						pointsIn++;
				}
				
				if(pointsIn == 0) return OUT;
				
				if(pointsIn == 8) planesIn++;
			}	
			
			if(planesIn == 6) return IN;
			
			return INTERSECT;
		}
		
		
		/**
		 * Extract this frustum's plane from the 4x4 projection matrix m.
		 */	
		public function extractFromMatrix(m:Matrix3D):Void
		{
			_matrix = m;
			
			var sxx:Int = m.sxx, sxy:Int = m.sxy, sxz:Int = m.sxz, tx:Int = m.tx,
			    syx:Int = m.syx, syy:Int = m.syy, syz:Int = m.syz, ty:Int = m.ty,
			    szx:Int = m.szx, szy:Int = m.szy, szz:Int = m.szz, tz:Int = m.tz,
			    swx:Int = m.swx, swy:Int = m.swy, swz:Int = m.swz, tw:Int = m.tw;
			
			
			var near:Plane3D = Plane3D(planes[NEAR]);
			near.a = swx+szx;
			near.b = swy+szy;
			near.c = swz+szz;
			near.d = tw+tz;
			near.normalize();
			
			var far:Plane3D = Plane3D(planes[FAR]);
			far.a = -szx+swx;
			far.b = -szy+swy;
			far.c = -szz+swz;
			far.d = -tz+tw;
			far.normalize();
			
			var left:Plane3D = Plane3D(planes[LEFT]);
			left.a = swx+sxx;
			left.b = swy+sxy;
			left.c = swz+sxz;
			left.d = tw+tx;
			left.normalize();
			
			var right:Plane3D = Plane3D(planes[RIGHT]);
			right.a = -sxx+swx;
			right.b = -sxy+swy;
			right.c = -sxz+swz;
			right.d = -tx+tw;
			right.normalize();
			
			var top:Plane3D = Plane3D(planes[TOP]);
			top.a = swx+syx;
			top.b = swy+syy;
			top.c = swz+syz;
			top.d = tw+ty;
			top.normalize();
			
			var bottom:Plane3D = Plane3D(planes[BOTTOM]);
			bottom.a = -syx+swx;
			bottom.b = -syy+swy;
			bottom.c = -syz+swz;
			bottom.d = -ty+tw;	
			bottom.normalize();
		}
	}
