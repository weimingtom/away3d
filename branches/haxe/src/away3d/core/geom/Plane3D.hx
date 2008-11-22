package away3d.core.geom;

    import away3d.core.base.*;
    import away3d.core.math.*;
    
    /** Plane in 3D space */
    class Plane3D
     {
    	
    	
    	
    	inline public static var FRONT:Int = 1;
    	inline public static var BACK:Int = -1;
    	inline public static var INTERSECT:Int = 0;
    	inline public static var EPSILON:Float = 0.001;
    	
    	
    	/**
    	 * The A coefficient of this plane. (Also the x dimension of the plane normal)
    	 */
        public var a:Float;

    	/**
    	 * The B coefficient of this plane. (Also the y dimension of the plane normal)
    	 */   
        public var b:Float;
    
    	/**
    	 * The C coefficient of this plane. (Also the z dimension of the plane normal)
    	 */    	
        public var c:Float;

    	/**
    	 * The D coefficient of this plane. (Also the inverse dot product between normal and point)
    	 */
        public var d:Float;
	
	
		//arbitrary point on this plane, only avail during closest computation
    	var _point:Number3D ;
		var _mt:Matrix3D ;
		
		/**
		 * Create a Plane3D with ABCD coefficients
		 */
        public function new(?a:Int=0, ?b:Int=0, ?c:Int=0, ?d:Int=0)
        {
            
            _point = new Number3D();
            _mt = new Matrix3D();
            this.a = a;
            this.b = b;
            this.c = c;
            this.d = d;
        }

		/**
		 * Fills this Plane3D with the coefficients from 3 points in 3d space.
		 * @param p0 Number3D
		 * @param p1 Number3D
		 * @param p2 Number3D
		 */
        public function from3points(p0:Number3D, p1:Number3D, p2:Number3D):Void
        {
            var d1x:Int = p1.x - p0.x;
            var d1y:Int = p1.y - p0.y;
            var d1z:Int = p1.z - p0.z;

            var d2x:Int = p2.x - p0.x;
            var d2y:Int = p2.y - p0.y;
            var d2z:Int = p2.z - p0.z;

            a = d1y*d2z - d1z*d2y;
            b = d1z*d2x - d1x*d2z;
            c = d1x*d2y - d1y*d2x;
            d = - (a*p0.x + b*p0.y + c*p0.z);
        }
        
        /**
		 * Fills this Plane3D with the coefficients from 3 vertices in 3d space.
		 * @param v0 Vertex
		 * @param v1 Vertex
		 * @param v2 Vertex
		 */
        public function from3vertices(v0:Vertex, v1:Vertex, v2:Vertex):Void
        {
            var d1x:Int = v1.x - v0.x;
            var d1y:Int = v1.y - v0.y;
            var d1z:Int = v1.z - v0.z;

            var d2x:Int = v2.x - v0.x;
            var d2y:Int = v2.y - v0.y;
            var d2z:Int = v2.z - v0.z;

            a = d1y*d2z - d1z*d2y;
            b = d1z*d2x - d1x*d2z;
            c = d1x*d2y - d1y*d2x;
            d = - (a*v0.x + b*v0.y + c*v0.z);
        }
        
        /**
		 * Fills this Plane3D with the coefficients from the plane's normal and a point in 3d space.
		 * @param normal Number3D
		 * @param point  Number3D
		 */
        public function fromNormalAndPoint( normal:Number3D, point:Number3D):Void
        {
        	a = normal.x;
        	b = normal.y;
        	c = normal.z;
        	d = -(a*point.x + b*point.y + c*point.z);
        }
	
		/**
		 * Normalize this Plane3D
		 * @return Plane3D This Plane3D.
		 */
		public function normalize():Plane3D
		{
			var len:Int = Math.sqrt(a*a + b*b + c*c);
			a /= len;
			b /= len;
			c /= len;
			d /= len;
			return this;
		}
		
		/**
		 * Returns the signed distance between this Plane3D and the point p.
		 * @param p Number3D
		 * @returns Number
		 */
        public function distance(p:Number3D):Float
        {
        	var len:Int = a*p.x + b*p.y + c*p.z + d;
        	if ((len > -EPSILON) && (len < EPSILON))
                len = 0;
            return len / Math.sqrt(a*a + b*b + c*c);
        }

		/**
		 * Classify a point against this Plane3D. (in front, back or intersecting)
		 * @param p Number3D
		 * @return int Plane3.FRONT or Plane3D.BACK or Plane3D.INTERSECT
		 */
		public function classifyPoint(p:Number3D):Int
		{
			var len:Int = a*p.x + b*p.y + c*p.z + d;
            if((len > -EPSILON) && (len < EPSILON)) 
            	return Plane3D.INTERSECT;
            else if(len < 0)
            	return Plane3D.BACK;
            else if(len > 0)
            	return Plane3D.FRONT;
            else 
            	return Plane3D.INTERSECT;
		}

		
		/**
		 * Finds the closest point on this Plane3 in relation to point.
		 * XXX Untested
		 * @param point Number3D
		 * @return Number3D
		 */
		public function closestPointFrom(point:Number3D):Number3D
		{
			//first find an arbitrary point on this plane
			_point.x = 0;
			_point.y = 0;
		
			if(c != 0)
				_point.z = -d/c;
			else
				_point.z = -d/b;
			
			//then compute
			var closest:Number3D = new Number3D();
			closest.sub(point, _point);
			
			var len:Int = (a*_point.x + b*_point.y + c*_point.z);
			
			closest.x -= len*a;
			closest.y -= len*b;
			closest.z -= len*c;
			
			return closest;
		}
		
		
		/**
		 * Transform this plane with the 4x4 transform matrix m4x4.
		 * XXX Untested
		 */
		public function transform(m4x4:Matrix3D):Void
		{
			var ta:Int = a;
			var tb:Int = b;
			var tc:Int = c;
			var td:Int = d;
			
			_mt.inverse4x4(m4x4);
			
			a = ta * _mt.sxx + tb * _mt.sxy + tc * _mt.sxz + _mt.tx;
			b = ta * _mt.syx + tb * _mt.syy + tc * _mt.syz + _mt.ty;
			c = ta * _mt.szx + tb * _mt.syz + tc * _mt.szz + _mt.tz;
			d = ta * _mt.swx + tb * _mt.swy + tc * _mt.swz + _mt.tw;
		}
    }
