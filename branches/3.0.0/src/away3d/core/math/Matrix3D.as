package away3d.core.math
{
    /**
    * A 3D transformation 4x3 matrix
    */
    public final class Matrix3D
    {
        private const toDEGREES:Number = 180 / Math.PI;
        private var _position:Number3D = new Number3D();
		private var m111:Number, m211:Number;
        private var m121:Number, m221:Number;
        private var m131:Number, m231:Number;
        private var m112:Number, m212:Number;
        private var m122:Number, m222:Number;
        private var m132:Number, m232:Number;
        private var m113:Number, m213:Number;
        private var m123:Number, m223:Number;
        private var m133:Number, m233:Number;
        private var m114:Number, m214:Number;
        private var m124:Number, m224:Number;
        private var m134:Number, m234:Number;
        
    	private var nCos:Number;
        private var nSin:Number;
        private var scos:Number;
    
        private var suv:Number;
        private var svw:Number;
        private var suw:Number;
        private var sw:Number;
        private var sv:Number;
        private var su:Number;
        
        private var d:Number;
        
        private var x:Number;
        private var y:Number;
        private var z:Number;
        private var w:Number;
        
    	private var xx:Number;
        private var xy:Number;
        private var xz:Number;
        private var xw:Number;
    
        private var yy:Number;
        private var yz:Number;
        private var yw:Number;
    
        private var zz:Number;
        private var zw:Number;
        
        
    	/**
    	 * The value in the first row and first column of the Matrix object,
    	 * which affect the rotation and scaling of a 3d object.
    	 */
        public var sxx:Number;
        
    	/**
    	 * The value in the first row and second column of the Matrix object,
    	 * which affect the rotation and scaling of a 3d object.
    	 */
        public var sxy:Number;
        
    	/**
    	 * The value in the first row and third column of the Matrix object,
    	 * which affect the rotation and scaling of a 3d object.
    	 */
        public var sxz:Number;
        
    	/**
    	 * The value in the first row and forth column of the Matrix object,
    	 * which affects the positioning along the x axis of a 3d object.
    	 */
        public var tx:Number;
        
    	/**
    	 * The value in the second row and first column of the Matrix object,
    	 * which affect the rotation and scaling of a 3d object.
    	 */
        public var syx:Number;
        
    	/**
    	 * The value in the second row and second column of the Matrix object,
    	 * which affect the rotation and scaling of a 3d object.
    	 */
        public var syy:Number;
        
    	/**
    	 * The value in the second row and third column of the Matrix object,
    	 * which affect the rotation and scaling of a 3d object.
    	 */
        public var syz:Number;
        
    	/**
    	 * The value in the second row and fourth column of the Matrix object,
    	 * which affects the positioning along the y axis of a 3d object.
    	 */
        public var ty:Number;
        
    	/**
    	 * The value in the third row and first column of the Matrix object,
    	 * which affects the rotation and scaling of a 3d object.
    	 */
        public var szx:Number;
        
    	/**
    	 * The value in the third row and second column of the Matrix object,
    	 * which affect the rotation and scaling of a 3d object.
    	 */
        public var szy:Number;
                
    	/**
    	 * The value in the third row and third column of the Matrix object,
    	 * which affect the rotation and scaling of a 3d object.
    	 */
        public var szz:Number;
        
    	/**
    	 * The value in the third row and fourth column of the Matrix object,
    	 * which affects the positioning along the z axis of a 3d object.
    	 */
        public var tz:Number;

        /**
        * Returns a 3d number representing the translation imposed by the 3dmatrix.
        */
        public function get position():Number3D
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
        public function get det():Number
        {
            return  (sxx * syy - syx * sxy) * szz 
                  - (sxx * szy - szx * sxy) * syz 
                  + (syx * szy - szx * syy) * sxz;
        }
        
		/**
		 * Creates a new <code>Matrix3D</code> object.
		 */
        public function Matrix3D()
        {
            sxx = syy = szz = 1;
            sxy = sxz = tx = syx = syz = ty = szx = szy = tz = 0;
        }
		
		/**
		 * Fills the 3d matrix object with values from an array with 3d matrix values
		 * ordered from right to left and up to down.
		 */
        public function array2matrix(ar:Array):void
        {
            if (ar.length >= 12)
            {
                sxx = ar[0];  
                sxy = ar[1];  
                sxz = ar[2];  
                tx = ar[3];
                syx = ar[4];  
                syy = ar[5];  
                syz = ar[6];  
                ty = ar[7];
                szx = ar[8];  
                szy = ar[9];  
                szz = ar[10]; 
                tz = ar[11];
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
        
            return s;
        }
        
        /**
        * Fills the 3d matrix object with the result from a 3x3 multipication of two 3d matrix objects.
        * The translation values are taken from the first matrix.
        * 
        * @param	m1	The first 3d matrix in the multipication.
        * @oaram	m2	The second 3d matrix in the multipication.
        */
        public function multiply3x3(m1:Matrix3D, m2:Matrix3D):void
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
        * Fills the 3d matrix object with the result from a 3x4 multipication of two 3d matrix objects.
        * 
        * @param	m1	The first 3d matrix in the multipication.
        * @oaram	m2	The second 3d matrix in the multipication.
        */
        public function multiply(m1:Matrix3D, m2:Matrix3D):void
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
    	 * @param	x	The scale value along the x axis.
    	 * @param	y	The scale value along the y axis.
    	 * @param	z	The scale value along the z axis.
    	 */
        public function scale(x:Number, y:Number, z:Number):void
        {
            sxx *= x;
            syx *= x;
            szx *= x;
            sxy *= y;
            syy *= y;
            szy *= y;
            sxz *= z;
            syz *= z;
            szz *= z;
        }
		
		/**
		 * Fill the 3d matrix with the 3x3 rotation matrix section of the given 3d matrix.
		 * 
		 * @param	m	THe 3d matrix to copy from.
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
		 * @param	m	THe 3d matrix to copy from.
		 */
        public function clone(m:Matrix3D):Matrix3D
        {
            sxx = m.sxx;   sxy = m.sxy;   sxz = m.sxz;   tx = m.tx;
            syx = m.syx;   syy = m.syy;   syz = m.syz;   ty = m.ty;
            szx = m.szx;   szy = m.szy;   szz = m.szz;   tz = m.tz;
                            
            return m;
        }
    	
    	/**
    	 * Returns the euler angle represented by the 3x3 matrix rotation.
    	 * 
    	 * @return		A 3d number representing the 3 euler angles.
    	 */
        public function matrix2euler():Number3D
        {
            var angle:Number3D = new Number3D();
    
            var d :Number = -Math.asin(Math.max(-1, Math.min(1, sxz))); // Calculate Y-axis angle
            var c :Number =  Math.cos(d);
    
            angle.y = d * toDEGREES;
    
            var trX:Number, trY:Number;
    
            if (Math.abs(c) > 0.005)  // Gimball lock?
            {
                trX =  szz / c;  // No, so get X-axis angle
                trY = -syz / c;
    
                angle.x = Math.atan2(trY, trX) * toDEGREES;
    
                trX =  sxx / c;  // Get Z-axis angle
                trY = -sxy / c;
    
                angle.z = Math.atan2(trY, trX) * toDEGREES;
            }
            else  // Gimball lock has occurred
            {
                angle.x = 0;  // Set X-axis angle to zero
    
                trX = syy;  // And calculate Z-axis angle
                trY = syx;
    
                angle.z = Math.atan2(trY, trX) * toDEGREES;
            }

            return angle;
        }
    	
    	/**
    	 * Fills the 3d matrix object with values representing the given rotation around a vector.
    	 * 
    	 * @param	u		The x value of the rotation vector.
    	 * @param	v		The y value of the rotation vector.
    	 * @param	w		The z value of the rotation vector.
    	 * @param	angle	The angle in radians of the rotation.
    	 */
        public function rotationMatrix(u:Number, v:Number, w:Number, angle:Number):void
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
        public function translationMatrix(u:Number, v:Number, w:Number):void
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
        public function scaleMatrix(u:Number, v:Number, w:Number):void
        {
        	tx = sxy = sxz = 0;
        	syz = ty = syz = 0;
        	szx = szy = tz = 0;
        	
            sxx = u;
            syy = v;
            szz = w;
        }
        
        /**
        * Fills the 3d matrix object with the result from the inverse calulation of the given 3d matrix.
        * 
        * @param	m	The 3d matrix object used for the inverse calulation.
        */
        public function inverse(m:Matrix3D):void
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
        * Fills the 3d matrix object with values representing the transformation made by the given quaternion.
        * 
        * @param	quarternion	The quarterion object to convert.
        */
        public function quaternion2matrix(quarternion:Quaternion):void
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
    }
}