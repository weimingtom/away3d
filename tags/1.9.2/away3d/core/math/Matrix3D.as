package away3d.core.math
{
    /** 3D transformation 4x3 matrix */
    public final class Matrix3D
    {
        public var sxx:Number;     public var sxy:Number;     public var sxz:Number;     public var tx:Number;
        public var syx:Number;     public var syy:Number;     public var syz:Number;     public var ty:Number;
        public var szx:Number;     public var szy:Number;     public var szz:Number;     public var tz:Number;

        public function Matrix3D()
        {
            sxx = syy = szz = 1;
            sxy = sxz = tx = syx = syz = ty = szx = szy = tz = 0;
        }

		private static var dest:Matrix3D;
		
        public static function fromArray(ar:Array):Matrix3D
        {
            dest = new Matrix3D();
            if (ar.length >= 12)
            {
                dest.sxx = ar[0];  
                dest.sxy = ar[1];  
                dest.sxz = ar[2];  
                dest.tx = ar[3];
                dest.syx = ar[4];  
                dest.syy = ar[5];  
                dest.syz = ar[6];  
                dest.ty = ar[7];
                dest.szx = ar[8];  
                dest.szy = ar[9];  
                dest.szz = ar[10]; 
                dest.tz = ar[11];
            }
            return dest;
        }

        public static function get IDENTITY():Matrix3D
        {
            return new Matrix3D();
        }
        
        public function get position():Number3D
        {
            return new Number3D(tx, ty, tz);
        }

        public function toString(): String
        {
            var s:String = "";
        
            s += int(sxx*1000) / 1000 + "\t\t" + int(sxy*1000) / 1000 + "\t\t" + int(sxz*1000) / 1000 + "\t\t" + int(tx*1000) / 1000 + "\n";
            s += int(syx*1000) / 1000 + "\t\t" + int(syy*1000) / 1000 + "\t\t" + int(syz*1000) / 1000 + "\t\t" + int(ty*1000) / 1000 + "\n";
            s += int(szx*1000) / 1000 + "\t\t" + int(szy*1000) / 1000 + "\t\t" + int(szz*1000) / 1000 + "\t\t" + int(tz*1000) / 1000 + "\n";
        
            return s;
        }
        
		private static var m111:Number, m211:Number;
        private static var m121:Number, m221:Number;
        private static var m131:Number, m231:Number;
        private static var m112:Number, m212:Number;
        private static var m122:Number, m222:Number;
        private static var m132:Number, m232:Number;
        private static var m113:Number, m213:Number;
        private static var m123:Number, m223:Number;
        private static var m133:Number, m233:Number;
        private static var m114:Number, m214:Number;
        private static var m124:Number, m224:Number;
        private static var m134:Number, m234:Number;
            
        public static function multiply3x3(m1:Matrix3D, m2:Matrix3D):Matrix3D
        {
            dest = new Matrix3D();
            m111 = m1.sxx; m211 = m2.sxx;
            m121 = m1.syx; m221 = m2.syx;
            m131 = m1.szx; m231 = m2.szx;
            m112 = m1.sxy; m212 = m2.sxy;
            m122 = m1.syy; m222 = m2.syy;
            m132 = m1.szy; m232 = m2.szy;
            m113 = m1.sxz; m213 = m2.sxz;
            m123 = m1.syz; m223 = m2.syz;
            m133 = m1.szz; m233 = m2.szz;
        
            dest.sxx = m111 * m211 + m112 * m221 + m113 * m231;
            dest.sxy = m111 * m212 + m112 * m222 + m113 * m232;
            dest.sxz = m111 * m213 + m112 * m223 + m113 * m233;
        
            dest.syx = m121 * m211 + m122 * m221 + m123 * m231;
            dest.syy = m121 * m212 + m122 * m222 + m123 * m232;
            dest.syz = m121 * m213 + m122 * m223 + m123 * m233;
        
            dest.szx = m131 * m211 + m132 * m221 + m133 * m231;
            dest.szy = m131 * m212 + m132 * m222 + m133 * m232;
            dest.szz = m131 * m213 + m132 * m223 + m133 * m233;
        
            dest.tx = m1.tx;
            dest.ty = m1.ty;
            dest.tz = m1.tz;
        
            return dest;
        }

        public static function multiply(m1:Matrix3D, m2:Matrix3D):Matrix3D
        {
            dest = new Matrix3D();
        
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
        
            dest.sxx = m111 * m211 + m112 * m221 + m113 * m231;
            dest.sxy = m111 * m212 + m112 * m222 + m113 * m232;
            dest.sxz = m111 * m213 + m112 * m223 + m113 * m233;
            dest.tx = m111 * m214 + m112 * m224 + m113 * m234 + m114;
        
            dest.syx = m121 * m211 + m122 * m221 + m123 * m231;
            dest.syy = m121 * m212 + m122 * m222 + m123 * m232;
            dest.syz = m121 * m213 + m122 * m223 + m123 * m233;
            dest.ty = m121 * m214 + m122 * m224 + m123 * m234 + m124;
        
            dest.szx = m131 * m211 + m132 * m221 + m133 * m231;
            dest.szy = m131 * m212 + m132 * m222 + m133 * m232;
            dest.szz = m131 * m213 + m132 * m223 + m133 * m233;
            dest.tz = m131 * m214 + m132 * m224 + m133 * m234 + m134;
        
            return dest;
        }
    
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

        public function copy3x3(m:Matrix3D):Matrix3D
        {
            sxx = m.sxx;   sxy = m.sxy;   sxz = m.sxz;
            syx = m.syx;   syy = m.syy;   syz = m.syz;
            szx = m.szx;   szy = m.szy;   szz = m.szz;
    
            return this;
        }
    
    	private var m:Matrix3D;
    	
        public function clone():Matrix3D
        {
            m = new Matrix3D();

            m.sxx = sxx;   m.sxy = sxy;   m.sxz = sxz;   m.tx = tx;
            m.syx = syx;   m.syy = syy;   m.syz = syz;   m.ty = ty;
            m.szx = szx;   m.szy = szy;   m.szz = szz;   m.tz = tz;
                            
            return m;
        }
    
        public static function matrix2euler(mat:Matrix3D):Number3D
        {
            var angle:Number3D = new Number3D();
    
            var d :Number = -Math.asin(Math.max(-1, Math.min(1, mat.sxz))); // Calculate Y-axis angle
            var c :Number =  Math.cos(d);
    
            angle.y = d * toDEGREES;
    
            var trX:Number, trY:Number;
    
            if (Math.abs(c) > 0.005)  // Gimball lock?
            {
                trX =  mat.szz / c;  // No, so get X-axis angle
                trY = -mat.syz / c;
    
                angle.x = Math.atan2(trY, trX) * toDEGREES;
    
                trX =  mat.sxx / c;  // Get Z-axis angle
                trY = -mat.sxy / c;
    
                angle.z = Math.atan2(trY, trX) * toDEGREES;
            }
            else  // Gimball lock has occurred
            {
                angle.x = 0;  // Set X-axis angle to zero
    
                trX = mat.syy;  // And calculate Z-axis angle
                trY = mat.syx;
    
                angle.z = Math.atan2(trY, trX) * toDEGREES;
            }

            return angle;
        }
    	
    	private static var nCos:Number;
        private static var nSin:Number;
        private static var scos:Number;
    
        private static var suv:Number;
        private static var svw:Number;
        private static var suw:Number;
        private static var sw:Number;
        private static var sv:Number;
        private static var su:Number;
    	
        public static function rotationMatrix(u:Number, v:Number, w:Number, angle:Number):Matrix3D
        {
            dest = new Matrix3D();
    
            nCos = Math.cos(angle);
            nSin = Math.sin(angle);
            scos = 1 - nCos;
    
            suv = u * v * scos;
            svw = v * w * scos;
            suw = u * w * scos;
            sw = nSin * w;
            sv = nSin * v;
            su = nSin * u;
    
            dest.sxx =  nCos + u * u * scos;       // nCos + u*u*(1-nCos)
            dest.sxy = -sw   + suv;                                                         // -nSin * w
            dest.sxz =  sv   + suw;                                                         // -nSin * v
    
            dest.syx =  sw   + suv;                // nSin*w + u*v*(1-nCos)
            dest.syy =  nCos + v * v * scos;
            dest.syz = -su   + svw;
    
            dest.szx = -sv   + suw;                // -nSin*v + u*w*(1-nCos)
            dest.szy =  su   + svw;
            dest.szz =  nCos + w * w * scos;
    
            return dest;
        }
    
        public static function translationMatrix(u:Number, v:Number, w:Number):Matrix3D
        {
            dest = new Matrix3D();
    
            dest.tx = u;
            dest.ty = v;
            dest.tz = w;
    
            return dest;
        }
    
        public static function scaleMatrix(u:Number, v:Number, w:Number):Matrix3D
        {
            dest = new Matrix3D();
    
            dest.sxx = u;
            dest.syy = v;
            dest.szz = w;
    
            return dest;
        }
    
        public function get det():Number
        {
            return  (sxx * syy - syx * sxy) * szz 
                  - (sxx * szy - szx * sxy) * syz 
                  + (syx * szy - szx * syy) * sxz;
        }
		
		private static var d:Number;
		private static var m11:Number, m21:Number, m31:Number;
        private static var m12:Number, m22:Number, m32:Number;
        private static var m13:Number, m23:Number, m33:Number;
        private static var m14:Number, m24:Number, m34:Number;
        
        public static function inverse(m:Matrix3D):Matrix3D
        {
            d = m.det;
            if (Math.abs(d) < 0.001)
            {
                // Determinant zero, there's no inverse
                return null;
            }
    
            d = 1 / d;
    
            m11 = m.sxx; m21 = m.syx; m31 = m.szx;
            m12 = m.sxy; m22 = m.syy; m32 = m.szy;
            m13 = m.sxz; m23 = m.syz; m33 = m.szz;
            m14 = m.tx;  m24 = m.ty;  m34 = m.tz;
    
            dest = new Matrix3D();
            dest.sxx = d * (m22 * m33 - m32 * m23),
            dest.sxy = -d* (m12 * m33 - m32 * m13),
            dest.sxz = d * (m12 * m23 - m22 * m13),
            dest.tx = -d* (m12 * (m23*m34 - m33*m24) - m22 * (m13*m34 - m33*m14) + m32 * (m13*m24 - m23*m14)),
            dest.syx = -d* (m21 * m33 - m31 * m23),
            dest.syy = d * (m11 * m33 - m31 * m13),
            dest.syz = -d* (m11 * m23 - m21 * m13),
            dest.ty = d * (m11 * (m23*m34 - m33*m24) - m21 * (m13*m34 - m33*m14) + m31 * (m13*m24 - m23*m14)),
            dest.szx = d * (m21 * m32 - m31 * m22),
            dest.szy = -d* (m11 * m32 - m31 * m12),
            dest.szz = d * (m11 * m22 - m21 * m12),
            dest.tz = -d* (m11 * (m22*m34 - m32*m24) - m21 * (m12*m34 - m32*m14) + m31 * (m12*m24 - m22*m14))
            return dest;
        }
    	
    	private static var fSinPitch      :Number;
        private static var fCosPitch      :Number;
        private static var fSinYaw        :Number;
        private static var fCosYaw        :Number;
        private static var fSinRoll       :Number;
        private static var fCosRoll       :Number;
        private static var fCosPitchCosYaw:Number;
        private static var fSinPitchSinYaw:Number;
        
        private static var q:Quaternion;
        
        public static function euler2quaternion(ax:Number, ay:Number, az:Number):Quaternion
        {
            fSinPitch       = Math.sin(ax * 0.5);
            fCosPitch       = Math.cos(ax * 0.5);
            fSinYaw         = Math.sin(ay * 0.5);
            fCosYaw         = Math.cos(ay * 0.5);
            fSinRoll        = Math.sin(az * 0.5);
            fCosRoll        = Math.cos(az * 0.5);
            fCosPitchCosYaw = fCosPitch * fCosYaw;
            fSinPitchSinYaw = fSinPitch * fSinYaw;
    
            q = new Quaternion();
            q.x = fSinRoll * fCosPitchCosYaw     - fCosRoll * fSinPitchSinYaw;
            q.y = fCosRoll * fSinPitch * fCosYaw + fSinRoll * fCosPitch * fSinYaw;
            q.z = fCosRoll * fCosPitch * fSinYaw - fSinRoll * fSinPitch * fCosYaw;
            q.w = fCosRoll * fCosPitchCosYaw     + fSinRoll * fSinPitchSinYaw;
    
            return q;
        }
        
    	private static var xx:Number;
        private static var xy:Number;
        private static var xz:Number;
        private static var xw:Number;
    
        private static var yy:Number;
        private static var yz:Number;
        private static var yw:Number;
    
        private static var zz:Number;
        private static var zw:Number;
            
        public static function quaternion2matrix(x:Number, y:Number, z:Number, w:Number):Matrix3D
        {
            xx = x * x;
            xy = x * y;
            xz = x * z;
            xw = x * w;
    
            yy = y * y;
            yz = y * z;
            yw = y * w;
    
            zz = z * z;
            zw = z * w;
    
            dest = new Matrix3D();
    
            dest.sxx = 1 - 2 * (yy + zz);
            dest.sxy =     2 * (xy - zw);
            dest.sxz =     2 * (xz + yw);
    
            dest.syx =     2 * (xy + zw);
            dest.syy = 1 - 2 * (xx + zz);
            dest.syz =     2 * (yz - xw);
    
            dest.szx =     2 * (xz - yw);
            dest.szy =     2 * (yz + xw);
            dest.szz = 1 - 2 * (xx + yy);
    
            return dest;
        }
    
        private static const toDEGREES:Number = 180 / Math.PI;
        private static const toRADIANS:Number = Math.PI / 180;
    }
}