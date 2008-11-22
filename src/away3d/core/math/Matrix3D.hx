package away3d.core.math;

	import flash.geom.Matrix;
	
    /**
    * A 3D transformation 4x4 matrix
    */
    public final class Matrix3D
     {
        public var det(getDet, null) : Float
        ;
        public var det4x4(getDet4x4, null) : Float
		;
        public var forward(getForward, setForward) : Number3D;
        public var position(getPosition, null) : Number3D
        ;
        public var right(getRight, setRight) : Number3D;
        public var up(getUp, setUp) : Number3D;
        
        var toDEGREES:Int ;
        var _position:Number3D ;
        
        //vectors
        var _forward:Number3D ;
        var _up:Number3D ;
        var _right:Number3D ;
        
		var m111:Float, m211:Float;
        var m121:Float, m221:Float;
        var m131:Float, m231:Float;
        var m112:Float, m212:Float;
        var m122:Float, m222:Float;
        var m132:Float, m232:Float;
        var m113:Float, m213:Float;
        var m123:Float, m223:Float;
        var m133:Float, m233:Float;
        var m114:Float, m214:Float;
        var m124:Float, m224:Float;
        var m134:Float, m234:Float;
        var m141:Float, m241:Float;
        var m142:Float, m242:Float;
        var m143:Float, m243:Float;
        var m144:Float, m244:Float;
        
    	var nCos:Float;
        var nSin:Float;
        var scos:Float;
    
        var suv:Float;
        var svw:Float;
        var suw:Float;
        var sw:Float;
        var sv:Float;
        var su:Float;
        
        var d:Float;
        
        var x:Float;
        var y:Float;
        var z:Float;
        var w:Float;
        
    	var xx:Float;
        var xy:Float;
        var xz:Float;
        var xw:Float;
    
        var yy:Float;
        var yz:Float;
        var yw:Float;
    
        var zz:Float;
        var zw:Float;
        
        
    	/**
    	 * The value in the first row and first column of the Matrix object,
    	 * which affect the rotation and scaling of a 3d object.
    	 */
        public var sxx:Int ;
        
    	/**
    	 * The value in the first row and second column of the Matrix object,
    	 * which affect the rotation and scaling of a 3d object.
    	 */
        public var sxy:Int ;
        
    	/**
    	 * The value in the first row and third column of the Matrix object,
    	 * which affect the rotation and scaling of a 3d object.
    	 */
        public var sxz:Int ;
        
    	/**
    	 * The value in the first row and forth column of the Matrix object,
    	 * which affects the positioning along the x axis of a 3d object.
    	 */
        public var tx:Int ;
        
    	/**
    	 * The value in the second row and first column of the Matrix object,
    	 * which affect the rotation and scaling of a 3d object.
    	 */
        public var syx:Int ;
        
    	/**
    	 * The value in the second row and second column of the Matrix object,
    	 * which affect the rotation and scaling of a 3d object.
    	 */
        public var syy:Int ;
        
    	/**
    	 * The value in the second row and third column of the Matrix object,
    	 * which affect the rotation and scaling of a 3d object.
    	 */
        public var syz:Int ;
        
    	/**
    	 * The value in the second row and fourth column of the Matrix object,
    	 * which affects the positioning along the y axis of a 3d object.
    	 */
        public var ty:Int ;
        
    	/**
    	 * The value in the third row and first column of the Matrix object,
    	 * which affects the rotation and scaling of a 3d object.
    	 */
        public var szx:Int ;
        
    	/**
    	 * The value in the third row and second column of the Matrix object,
    	 * which affect the rotation and scaling of a 3d object.
    	 */
        public var szy:Int ;
                
    	/**
    	 * The value in the third row and third column of the Matrix object,
    	 * which affect the rotation and scaling of a 3d object.
    	 */
        public var szz:Int ;
        
    	/**
    	 * The value in the third row and fourth column of the Matrix object,
    	 * which affects the positioning along the z axis of a 3d object.
    	 */
        public var tz:Int ;

    	/**
    	 * The value in the 4th row and first column of the Matrix object,
    	 * --
    	 */
		public var swx:Int ;
		
		 /**
    	 * The value in the 4th row and second column of the Matrix object,
    	 * --
    	 */
		public var swy:Int ;
		
		 /**
    	 * The value in the 4th row and third column of the Matrix object,
    	 * --
    	 */
		public var swz:Int ;
		
		/**
    	 * The value in the 4th row and 4th column of the Matrix object,
    	 * --
    	 */
		public var tw:Int ;
		
		
        /**
        * Returns a 3d number representing the translation imposed by the 3dmatrix.
        */
        public function getPosition():Number3D
        {
        	_position.x = tx;
        	_position.y = ty;
        	_position.z = tz;
        	
            return _position;
        }
        
    	/**
    	 * Returns the 3d matrix object's determinant.
    	 * 
    	 * @return	The determinant of the 3d matrix.
    	 */
        public function getDet():Float
        {
            return  (sxx * syy - syx * sxy) * szz 
                  - (sxx * szy - szx * sxy) * syz 
                  + (syx * szy - szx * syy) * sxz;
        }
        
     	public function getDet4x4():Float
		{
			return (sxx * syy - syx * sxy) * (szz * tw - swz * tz)
			- (sxx * szy - szx * sxy) * (syz * tw - swz * ty)
			+ (sxx * swy - swx * sxy) * (syz * tz - szz * ty)
			+ (syx * szy - szx * syy) * (sxz * tw - swz * tx)
			- (syx * swy - swx * syy) * (sxz * tz - szz * tx)
			+ (szx * swy - swx * szy) * (sxz * ty - syz * tx);
		}
		
		/**
		 * Creates a new <code>Matrix3D</code> object.
		 */
        public function new()
        {
        
        toDEGREES = 180 / Math.PI;
        _position = new Number3D();
        _forward = new Number3D();
        _up = new Number3D();
        _right = new Number3D();
        sxx = 1;
        sxy = 0;
        sxz = 0;
        tx = 0;
        syx = 0;
        syy = 1;
        syz = 0;
        ty = 0;
        szx = 0;
        szy = 0;
        szz = 1;
        tz = 0;
        swx = 0;
        swy = 0;
        swz = 0;
        tw = 1;
        }
		
		/**
		 * Fills the 3d matrix object with values from an array with 3d matrix values
		 * ordered from right to left and up to down.
		 */
        public function array2matrix(ar:Array<Dynamic>, yUp:Bool, scaling:Float):Void
        {
            if (ar.length >= 12)
            {
            	if (yUp) {
            		
	                sxx = ar[0];
	                sxy = -ar[1];
	                sxz = -ar[2];
	                tx = -ar[3]*scaling;
	                syx = -ar[4];
	                syy = ar[5];
	                syz = ar[6];
	                ty = ar[7]*scaling;
	                szx = -ar[8];
	                szy = ar[9];
	                szz = ar[10];
	                tz = ar[11]*scaling;
            	} else {
            		sxx = ar[0];
	                sxz = ar[1];
	                sxy = ar[2];
	                tx = ar[3]*scaling;
	                szx = ar[4];
	                szz = ar[5];
	                szy = ar[6];
	                tz = ar[7]*scaling;
	                syx = ar[8];
	                syz = ar[9];
	                syy = ar[10];
	                ty = ar[11]*scaling;
            	}
            }
            if(ar.length >= 16)
            {               
            	swx = ar[12];
                swy = ar[13];
                swz = ar[14];
                tw =  ar[15];
            }
            else
            {
            	swx = swy = swz = 0;
            	tw = 1;
            }
        }
		
		/**
		 * Used to trace the values of a 3d matrix.
		 * 
		 * @return A string representation of the 3d matrix object.
		 */
        public function toString(): String
        {
            var s:String = "";
        
            s += int(sxx*1000) / 1000 + "\t\t" + int(sxy*1000) / 1000 + "\t\t" + int(sxz*1000) / 1000 + "\t\t" + int(tx*1000) / 1000 + "\n";
            s += int(syx*1000) / 1000 + "\t\t" + int(syy*1000) / 1000 + "\t\t" + int(syz*1000) / 1000 + "\t\t" + int(ty*1000) / 1000 + "\n";
            s += int(szx*1000) / 1000 + "\t\t" + int(szy*1000) / 1000 + "\t\t" + int(szz*1000) / 1000 + "\t\t" + int(tz*1000) / 1000 + "\n";
         	s += int(swx*1000) / 1000 + "\t\t" + int(swy*1000) / 1000 + "\t\t" + int(swz*1000) / 1000 + "\t\t" + int(tw*1000) / 1000 + "\n";
        
            return s;
        }
        
        /**
        * Fills the 3d matrix object with the result from a 3x3 multipication of two 3d matrix objects.
        * The translation values are taken from the first matrix.
        * 
        * @param	m1	The first 3d matrix in the multipication.
        * @oaram	m2	The second 3d matrix in the multipication.
        */
        public function multiply3x3(m1:Matrix3D, m2:Matrix3D):Void
        {
            m111 = m1.sxx; m211 = m2.sxx;
            m121 = m1.syx; m221 = m2.syx;
            m131 = m1.szx; m231 = m2.szx;
            m112 = m1.sxy; m212 = m2.sxy;
            m122 = m1.syy; m222 = m2.syy;
            m132 = m1.szy; m232 = m2.szy;
            m113 = m1.sxz; m213 = m2.sxz;
            m123 = m1.syz; m223 = m2.syz;
            m133 = m1.szz; m233 = m2.szz;
        
            sxx = m111 * m211 + m112 * m221 + m113 * m231;
            sxy = m111 * m212 + m112 * m222 + m113 * m232;
            sxz = m111 * m213 + m112 * m223 + m113 * m233;
        
            syx = m121 * m211 + m122 * m221 + m123 * m231;
            syy = m121 * m212 + m122 * m222 + m123 * m232;
            syz = m121 * m213 + m122 * m223 + m123 * m233;
        
            szx = m131 * m211 + m132 * m221 + m133 * m231;
            szy = m131 * m212 + m132 * m222 + m133 * m232;
            szz = m131 * m213 + m132 * m223 + m133 * m233;
        
            tx = m1.tx;
            ty = m1.ty;
            tz = m1.tz;
        }
        
        /**
        * Fills the 3d matrix object with the result from a 4x3 multipication of two 3d matrix objects.
        * 
        * @param	m1	The first 3d matrix in the multipication.
        * @oaram	m2	The second 3d matrix in the multipication.
        */
        public function multiply4x3(m1:Matrix3D, m2:Matrix3D):Void
        {
            m111 = m1.sxx; m211 = m2.sxx;
            m121 = m1.syx; m221 = m2.syx;
            m131 = m1.szx; m231 = m2.szx;
            m112 = m1.sxy; m212 = m2.sxy;
            m122 = m1.syy; m222 = m2.syy;
            m132 = m1.szy; m232 = m2.szy;
            m113 = m1.sxz; m213 = m2.sxz;
            m123 = m1.syz; m223 = m2.syz;
            m133 = m1.szz; m233 = m2.szz;
            m114 = m1.tx; m214 = m2.tx;
            m124 = m1.ty; m224 = m2.ty;
            m134 = m1.tz; m234 = m2.tz;
        	m141 = m1.swx; m241 = m2.swx;
        	m142 = m1.swy; m242 = m2.swy;
        	m143 = m1.swz; m243 = m2.swz;
        	m144 = m1.tw; m244 = m2.tw;
        	
            sxx = m111 * m211 + m112 * m221 + m113 * m231;
            sxy = m111 * m212 + m112 * m222 + m113 * m232;
            sxz = m111 * m213 + m112 * m223 + m113 * m233;
            tx = m111 * m214 + m112 * m224 + m113 * m234 + m114;
        
            syx = m121 * m211 + m122 * m221 + m123 * m231;
            syy = m121 * m212 + m122 * m222 + m123 * m232;
            syz = m121 * m213 + m122 * m223 + m123 * m233;
            ty = m121 * m214 + m122 * m224 + m123 * m234 + m124;
        
            szx = m131 * m211 + m132 * m221 + m133 * m231;
            szy = m131 * m212 + m132 * m222 + m133 * m232;
            szz = m131 * m213 + m132 * m223 + m133 * m233;
            tz = m131 * m214 + m132 * m224 + m133 * m234 + m134;
            
            swx = m141 * m211 + m142 * m221 + m143 * m231;
            swy = m141 * m212 + m142 * m222 + m143 * m232;
            swz = m141 * m213 + m142 * m223 + m143 * m233;
            tw =  m141 * m214 + m142 * m224 + m143 * m234 + m144;
        }

       /**
        * Fills the 3d matrix object with the result from a 4x4 multipication of two 3d matrix objects.
        * 
        * @param	m1	The first 3d matrix in the multipication.
        * @oaram	m2	The second 3d matrix in the multipication.
        */
        public function multiply4x4(m1:Matrix3D, m2:Matrix3D):Void
        {
            m111 = m1.sxx; m211 = m2.sxx;
            m121 = m1.syx; m221 = m2.syx;
            m131 = m1.szx; m231 = m2.szx;
            m141 = m1.swx; m241 = m2.swx;
        	
            m112 = m1.sxy; m212 = m2.sxy;
            m122 = m1.syy; m222 = m2.syy;
            m132 = m1.szy; m232 = m2.szy;
            m142 = m1.swy; m242 = m2.swy;
        	
            m113 = m1.sxz; m213 = m2.sxz;
            m123 = m1.syz; m223 = m2.syz;
            m133 = m1.szz; m233 = m2.szz;
            m143 = m1.swz; m243 = m2.swz;
        	
            m114 = m1.tx; m214 = m2.tx;
            m124 = m1.ty; m224 = m2.ty;
            m134 = m1.tz; m234 = m2.tz;
        	m144 = m1.tw; m244 = m2.tw;
        	
			sxx = m111 * m211 + m112 * m221 + m113 * m231 + m114 * m241;
			sxy = m111 * m212 + m112 * m222 + m113 * m232 + m114 * m242;
			sxz = m111 * m213 + m112 * m223 + m113 * m233 + m114 * m243;
			 tx = m111 * m214 + m112 * m224 + m113 * m234 + m114 * m244;

			syx = m121 * m211 + m122 * m221 + m123 * m231 + m124 * m241;
			syy = m121 * m212 + m122 * m222 + m123 * m232 + m124 * m242;
			syz = m121 * m213 + m122 * m223 + m123 * m233 + m124 * m243;
			 ty = m121 * m214 + m122 * m224 + m123 * m234 + m124 * m244;

			szx = m131 * m211 + m132 * m221 + m133 * m231 + m134 * m241;
			szy = m131 * m212 + m132 * m222 + m133 * m232 + m134 * m242;
			szz = m131 * m213 + m132 * m223 + m133 * m233 + m134 * m243;
			 tz = m131 * m214 + m132 * m224 + m133 * m234 + m134 * m244;

			swx = m141 * m211 + m142 * m221 + m143 * m231 + m144 * m241;
			swy = m141 * m212 + m142 * m222 + m143 * m232 + m144 * m242;
			swz = m141 * m213 + m142 * m223 + m143 * m233 + m144 * m243;
			 tw = m141 * m214 + m142 * m224 + m143 * m234 + m144 * m244;
        }
              
         /**
        * Fills the 3d matrix object with the result from a 3x4 multipication of two 3d matrix objects.
        * 
        * @param	m1	The first 3d matrix in the multipication.
        * @oaram	m2	The second 3d matrix in the multipication.
        */
        public function multiply(m1:Matrix3D, m2:Matrix3D):Void
        {
            m111 = m1.sxx; m211 = m2.sxx;
            m121 = m1.syx; m221 = m2.syx;
            m131 = m1.szx; m231 = m2.szx;
            m112 = m1.sxy; m212 = m2.sxy;
            m122 = m1.syy; m222 = m2.syy;
            m132 = m1.szy; m232 = m2.szy;
            m113 = m1.sxz; m213 = m2.sxz;
            m123 = m1.syz; m223 = m2.syz;
            m133 = m1.szz; m233 = m2.szz;
            m114 = m1.tx; m214 = m2.tx;
            m124 = m1.ty; m224 = m2.ty;
            m134 = m1.tz; m234 = m2.tz;
        
            sxx = m111 * m211 + m112 * m221 + m113 * m231;
            sxy = m111 * m212 + m112 * m222 + m113 * m232;
            sxz = m111 * m213 + m112 * m223 + m113 * m233;
            tx = m111 * m214 + m112 * m224 + m113 * m234 + m114;
        
            syx = m121 * m211 + m122 * m221 + m123 * m231;
            syy = m121 * m212 + m122 * m222 + m123 * m232;
            syz = m121 * m213 + m122 * m223 + m123 * m233;
            ty = m121 * m214 + m122 * m224 + m123 * m234 + m124;
        
            szx = m131 * m211 + m132 * m221 + m133 * m231;
            szy = m131 * m212 + m132 * m222 + m133 * m232;
            szz = m131 * m213 + m132 * m223 + m133 * m233;
            tz = m131 * m214 + m132 * m224 + m133 * m234 + m134;

        }
    	
    	/**
    	 * Scales the 3d matrix by the given amount in each dimension
    	 * 
		 * @param	m	The 3d matrix to scale from.
    	 * @param	x	The scale value along the x axis.
    	 * @param	y	The scale value along the y axis.
    	 * @param	z	The scale value along the z axis.
    	 */
        public function scale(m1:Matrix3D, x:Float, y:Float, z:Float):Void
        {
            sxx = m1.sxx*x;
            syx = m1.syx*x;
            szx = m1.szx*x;
            sxy = m1.sxy*y;
            syy = m1.syy*y;
            szy = m1.szy*y;
            sxz = m1.sxz*z;
            syz = m1.syz*z;
            szz = m1.szz*z;
        }
		
		/**
		 * Fill the 3d matrix with the 3x3 rotation matrix section of the given 3d matrix.
		 * 
		 * @param	m	The 3d matrix to copy from.
		 */
        public function copy3x3(m:Matrix3D):Matrix3D
        {
            sxx = m.sxx;   sxy = m.sxy;   sxz = m.sxz;
            syx = m.syx;   syy = m.syy;   syz = m.syz;
            szx = m.szx;   szy = m.szy;   szz = m.szz;
    
            return this;
        }
		
		/**
		 * Fill the 3d matrix with all matrix values of the given 3d matrix.
		 * 
		 * @param	m	The 3d matrix to copy from.
		 */
        public function clone(m:Matrix3D):Matrix3D
        {
            sxx = m.sxx;   sxy = m.sxy;   sxz = m.sxz;   tx = m.tx;
            syx = m.syx;   syy = m.syy;   syz = m.syz;   ty = m.ty;
            szx = m.szx;   szy = m.szy;   szz = m.szz;   tz = m.tz;
            swx = m.swx;   swy = m.swy;   swz = m.swz;   tw = m.tw;
                            
            return m;
        }
    	
    	/**
    	 * Fills the 3d matrix object with values representing the given rotation around a vector.
    	 * 
    	 * @param	u		The x value of the rotation vector.
    	 * @param	v		The y value of the rotation vector.
    	 * @param	w		The z value of the rotation vector.
    	 * @param	angle	The angle in radians of the rotation.
    	 */
        public function rotationMatrix(u:Float, v:Float, w:Float, angle:Float):Void
        {
            nCos = Math.cos(angle);
            nSin = Math.sin(angle);
            scos = 1 - nCos;
    
            suv = u * v * scos;
            svw = v * w * scos;
            suw = u * w * scos;
            sw = nSin * w;
            sv = nSin * v;
            su = nSin * u;
    
            sxx =  nCos + u * u * scos;       // nCos + u*u*(1-nCos)
            sxy = -sw   + suv;                                                         // -nSin * w
            sxz =  sv   + suw;                                                         // -nSin * v
    
            syx =  sw   + suv;                // nSin*w + u*v*(1-nCos)
            syy =  nCos + v * v * scos;
            syz = -su   + svw;
    
            szx = -sv   + suw;                // -nSin*v + u*w*(1-nCos)
            szy =  su   + svw;
            szz =  nCos + w * w * scos;
        }
    	
    	/**
    	 * Fills the 3d matrix object with values representing the given translation.
    	 * 
    	 * @param	u		The translation along the x axis.
    	 * @param	v		The translation along the y axis.
    	 * @param	w		The translation along the z axis..
    	 */
        public function translationMatrix(u:Float, v:Float, w:Float):Void
        {
        	sxx = syy = szz = 1;
        	sxy = sxz = syz = syz = szx = szy = 0;
        	
            tx = u;
            ty = v;
            tz = w;
        }
    	
    	/**
    	 * Fills the 3d matrix object with values representing the given scaling.
    	 * 
    	 * @param	u		The scale along the x axis.
    	 * @param	v		The scale along the y axis.
    	 * @param	w		The scale along the z axis..
    	 */
        public function scaleMatrix(u:Float, v:Float, w:Float):Void
        {
        	tx = sxy = sxz = 0;
        	syz = ty = syz = 0;
        	szx = szy = tz = 0;
        	
            sxx = u;
            syy = v;
            szz = w;
        }
    	/**
    	 * Clears the 3d matrix object and fills it with the identity matrix.
    	 */
        public function clear():Void
        {
        	tx = sxy = sxz = syz = ty = syz = szx = szy = tz = 0;
            sxx = syy = szz = 1;
        }
        
        public function compare(m:Matrix3D):Bool
        {
        	if (sxx != m.sxx || sxy != m.sxy || sxz != m.sxz || tx != m.tx || syx != m.syx || syy != m.syy || syz != m.syz || ty != m.ty || szx != m.szx || szy != m.szy || szz != m.szz || tz != m.tz)
        		return false;
        	
        	return true;
        }
        
        /**
         * Fills the 3d matrix with a 4x4 transformation that produces a perspective projection.
		 * 
		 * @param	fov
		 * @param	aspect
		 * @param	near
		 * @param	far
		 * @return
		 */
		public function perspectiveProjectionMatrix( fov:Float, aspect:Float, near:Float, far:Float ):Void
		{
			var fov2:Int = (fov/2) * (Math.PI/180);
			var tan:Int = Math.tan(fov2);
			var f:Int = 1 / tan;
			
			sxx = f/aspect;
			sxy = sxz = tx = 0;
			syy = f;
			syx = syz = ty = 0;
			szx = szy = 0;
			//negate for left hand
			szz = -((near+far)/(near-far));
			tz = (2*far*near)/(near-far);
			swx = swy = tw = 0;
			swz = 1;
		}	
        
        
		/**
		 * Fills the 3d matrix with a 4x4 transformation that produces an orthographic projection.
		 * 
		 * @param	left
		 * @param	right
		 * @param	bottom
		 * @param	top
		 * @param	near
		 * @param	far
		 * @return
		 */
		public function orthographicProjectionMatrix( left:Float, right:Float, bottom:Float, top:Float, near:Float, far:Float):Void
		{
			sxx = 2/(right-left);
			sxy = sxz = 0;
			tx = (right+left)/(right-left);
			
			
			syy = 2/(top-bottom)
			syx = syz = 0;
			ty = (top+bottom)/(top-bottom);
			
			szx = szy = 0;
			szz = -2/(far-near);
			tz = (far+near)/(far-near);
			
			swx = swy = swz = 0;
			tw = 1;
			
			//go to left handed
			var flipY:Matrix3D = new Matrix3D();
			flipY.scaleMatrix(1,1,-1);
			
			this.multiply(flipY, this);
		}
		
        
        
        /**
        * Fills the 3d matrix object with the result from the inverse 3x3 calulation of the given 3d matrix.
        * 
        * @param	m	The 3d matrix object used for the inverse calulation.
        */
        public function inverse(m:Matrix3D):Void
        {
            d = m.det;
            if (Math.abs(d) < 0.001) {
                // Determinant zero, there's no inverse
                return;
            }
    
            d = 1 / d;
    
            m111 = m.sxx; m121 = m.syx; m131 = m.szx;
            m112 = m.sxy; m122 = m.syy; m132 = m.szy;
            m113 = m.sxz; m123 = m.syz; m133 = m.szz;
            m114 = m.tx;  m124 = m.ty;  m134 = m.tz;
            
            sxx = d * (m122 * m133 - m132 * m123),
            sxy = -d* (m112 * m133 - m132 * m113),
            sxz = d * (m112 * m123 - m122 * m113),
            tx = -d* (m112 * (m123*m134 - m133*m124) - m122 * (m113*m134 - m133*m114) + m132 * (m113*m124 - m123*m114)),
            syx = -d* (m121 * m133 - m131 * m123),
            syy = d * (m111 * m133 - m131 * m113),
            syz = -d* (m111 * m123 - m121 * m113),
            ty = d * (m111 * (m123*m134 - m133*m124) - m121 * (m113*m134 - m133*m114) + m131 * (m113*m124 - m123*m114)),
            szx = d * (m121 * m132 - m131 * m122),
            szy = -d* (m111 * m132 - m131 * m112),
            szz = d * (m111 * m122 - m121 * m112),
            tz = -d* (m111 * (m122*m134 - m132*m124) - m121 * (m112*m134 - m132*m114) + m131 * (m112*m124 - m122*m114));
        }
       
       /**
        * Fills the 3d matrix object with the result from the inverse 4x4 calulation of the given 3d matrix.
        * 
        * @param	m	The 3d matrix object used for the inverse calulation.
        */
        public function inverse4x4(m:Matrix3D):Void
        {
            d = m.det4x4;
            
            if (Math.abs(d) < 0.001) {
                // Determinant zero, there's no inverse
                return;
            }
    
            d = 1 / d;
    
            m111 = m.sxx; m121 = m.syx; m131 = m.szx; m141 = m.swx;
            m112 = m.sxy; m122 = m.syy; m132 = m.szy; m142 = m.swy;
            m113 = m.sxz; m123 = m.syz; m133 = m.szz; m143 = m.swz;
            m114 = m.tx;  m124 = m.ty;  m134 = m.tz;  m144 = m.tw;
            
			sxx = d * ( m122*(m133*m144 - m143*m134) - m132*(m123*m144 - m143*m124) + m142*(m123*m134 - m133*m124) );
			sxy = -d* ( m112*(m133*m144 - m143*m134) - m132*(m113*m144 - m143*m114) + m142*(m113*m134 - m133*m114) );
			sxz = d * ( m112*(m123*m144 - m143*m124) - m122*(m113*m144 - m143*m114) + m142*(m113*m124 - m123*m114) );
			tx = -d* ( m112*(m123*m134 - m133*m124) - m122*(m113*m134 - m133*m114) + m132*(m113*m124 - m123*m114) );

			syx = -d* ( m121*(m133*m144 - m143*m134) - m131*(m123*m144 - m143*m124) + m141*(m123*m134 - m133*m124) );
			syy = d * ( m111*(m133*m144 - m143*m134) - m131*(m113*m144 - m143*m114) + m141*(m113*m134 - m133*m114) );
			syz = -d* ( m111*(m123*m144 - m143*m124) - m121*(m113*m144 - m143*m114) + m141*(m113*m124 - m123*m114) );
			ty = d * ( m111*(m123*m134 - m133*m124) - m121*(m113*m134 - m133*m114) + m131*(m113*m124 - m123*m114) );

			szx = d * ( m121*(m132*m144 - m142*m134) - m131*(m122*m144 - m142*m124) + m141*(m122*m134 - m132*m124) );
			szy = -d* ( m111*(m132*m144 - m142*m134) - m131*(m112*m144 - m142*m114) + m141*(m112*m134 - m132*m114) );
			szz = d * ( m111*(m122*m144 - m142*m124) - m121*(m112*m144 - m142*m114) + m141*(m112*m124 - m122*m114) );
			tz = -d* ( m111*(m122*m134 - m132*m124) - m121*(m112*m134 - m132*m114) + m131*(m112*m124 - m122*m114) );

			swx = -d* ( m121*(m132*m143 - m142*m133) - m131*(m122*m143 - m142*m123) + m141*(m122*m133 - m132*m123) );
			swy = d * ( m111*(m132*m143 - m142*m133) - m131*(m112*m143 - m142*m113) + m141*(m112*m133 - m132*m113) );
			swz = -d* ( m111*(m122*m143 - m142*m123) - m121*(m112*m143 - m142*m113) + m141*(m112*m123 - m122*m113) );
			tw = d * ( m111*(m122*m133 - m132*m123) - m121*(m112*m133 - m132*m113) + m131*(m112*m123 - m122*m113) );
        }
  
   
        /**
        * Fills the 3d matrix object with values representing the transformation made by the given quaternion.
        * 
        * @param	quarternion	The quarterion object to convert.
        */
        public function quaternion2matrix(quarternion:Quaternion):Void
        {
        	x = quarternion.x;
        	y = quarternion.y;
        	z = quarternion.z;
        	w = quarternion.w;
        	
            xx = x * x;
            xy = x * y;
            xz = x * z;
            xw = x * w;
    
            yy = y * y;
            yz = y * z;
            yw = y * w;
    
            zz = z * z;
            zw = z * w;
    
            sxx = 1 - 2 * (yy + zz);
            sxy =     2 * (xy - zw);
            sxz =     2 * (xz + yw);
    
            syx =     2 * (xy + zw);
            syy = 1 - 2 * (xx + zz);
            syz =     2 * (yz - xw);
    
            szx =     2 * (xz - yw);
            szy =     2 * (yz + xw);
            szz = 1 - 2 * (xx + yy);
        }
       
       /**
        * normalizes the axis vectors of the given 3d matrix.
        * 
        * @param	m	The 3d matrix object used for the normalize calulation.
        */
        public function normalize(m1:Matrix3D):Void
        {
        	d = Math.sqrt(sxx*sxx + sxy*sxy + sxz*sxz);
			sxx /= d;
			sxy /= d;
			sxz /= d;
			d = Math.sqrt(syx*syx + syy*syy + syz*syz);
			syx /= d;
			syy /= d;
			syz /= d;
        	d = Math.sqrt(szx*szx + szy*szy + szz*szz);
			szx /= d;
			szy /= d;
			szz /= d;
        }
        
     	/**
        * Returns a Number3D representing the forward vector of this matrix.
        */
        public function getForward():Number3D{
        	_forward.x = szx;
        	_forward.y = szy;
        	_forward.z = szz;
        	return _forward;
        }
     	
     	/**
        * Set the forward vector (row3) of this matrix.
        */
     	public function setForward(n:Number3D):Number3D{
     		this.szx = n.x;
     		this.szy = n.y;
     		this.szz = n.z;
     		return n;
     	}   
     	
     	/**
        * Returns a Number3D representing the up vector of this matrix.
        */
        public function getUp():Number3D{
        	_up.x = syx;
        	_up.y = syy;
        	_up.z = syz;
        	return _up;
        }
        
        /**
        * Set the up vector (row2) of this matrix.
        */
     	public function setUp(n:Number3D):Number3D{
     		this.syx = n.x;
     		this.syy = n.y;
     		this.syz = n.z;
     		return n;
     	}   
     	
     	/**
        * Returns a Number3D representing the right vector of this matrix.
        */
        public function getRight():Number3D{
        	_right.x = sxx;
        	_right.y = sxy;
        	_right.z = sxz;
        	return _right;
        }
        
        /**
        * Set the right vector (row1) of this matrix.
        */
     	public function setRight(n:Number3D):Number3D{
     		this.sxx = n.x;
     		this.sxy = n.y;
     		this.sxz = n.z;
     		return n;
     	}   
    }
