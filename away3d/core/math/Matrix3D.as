package away3d.core.math
{
    /** 3D transformation 4x3 matrix */
    public class Matrix3D
    {
        public var sxx:Number;     public var sxy:Number;     public var sxz:Number;     public var tx:Number;
        public var syx:Number;     public var syy:Number;     public var syz:Number;     public var ty:Number;
        public var szx:Number;     public var szy:Number;     public var szz:Number;     public var tz:Number;

        public function Matrix3D()
        {
            sxx = syy = szz = 1;
            sxy = sxz = tx = syx = syz = ty = szx = szy = tz = 0;
        }

        public static function fromArray(ar:Array):Matrix3D
        {
            var m:Matrix3D = new Matrix3D();
            if (ar.length >= 12)
            {
                m.sxx = ar[0];  
                m.sxy = ar[1];  
                m.sxz = ar[2];  
                m.tx = ar[3];
                m.syx = ar[4];  
                m.syy = ar[5];  
                m.syz = ar[6];  
                m.ty = ar[7];
                m.szx = ar[8];  
                m.szy = ar[9];  
                m.szz = ar[10]; 
                m.tz = ar[11];
            }
            return m;
        }

        public static function get IDENTITY():Matrix3D
        {
            return new Matrix3D();
        }
        
        public function toString(): String
        {
            var s:String = "";
        
            s += int(sxx*1000) / 1000 + "\t\t" + int(sxy*1000) / 1000 + "\t\t" + int(sxz*1000) / 1000 + "\t\t" + int(tx*1000) / 1000 + "\n";
            s += int(syx*1000) / 1000 + "\t\t" + int(syy*1000) / 1000 + "\t\t" + int(syz*1000) / 1000 + "\t\t" + int(ty*1000) / 1000 + "\n";
            s += int(szx*1000) / 1000 + "\t\t" + int(szy*1000) / 1000 + "\t\t" + int(szz*1000) / 1000 + "\t\t" + int(tz*1000) / 1000 + "\n";
        
            return s;
        }

        public static function multiply3x3(m1:Matrix3D, m2:Matrix3D):Matrix3D
        {
            var dest:Matrix3D = new Matrix3D();
            var m111:Number = m1.sxx; var m211:Number = m2.sxx;
            var m121:Number = m1.syx; var m221:Number = m2.syx;
            var m131:Number = m1.szx; var m231:Number = m2.szx;
            var m112:Number = m1.sxy; var m212:Number = m2.sxy;
            var m122:Number = m1.syy; var m222:Number = m2.syy;
            var m132:Number = m1.szy; var m232:Number = m2.szy;
            var m113:Number = m1.sxz; var m213:Number = m2.sxz;
            var m123:Number = m1.syz; var m223:Number = m2.syz;
            var m133:Number = m1.szz; var m233:Number = m2.szz;
        
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
            var result:Matrix3D = new Matrix3D();
        
            var m111:Number = m1.sxx; var m211:Number = m2.sxx;
            var m121:Number = m1.syx; var m221:Number = m2.syx;
            var m131:Number = m1.szx; var m231:Number = m2.szx;
            var m112:Number = m1.sxy; var m212:Number = m2.sxy;
            var m122:Number = m1.syy; var m222:Number = m2.syy;
            var m132:Number = m1.szy; var m232:Number = m2.szy;
            var m113:Number = m1.sxz; var m213:Number = m2.sxz;
            var m123:Number = m1.syz; var m223:Number = m2.syz;
            var m133:Number = m1.szz; var m233:Number = m2.szz;
            var m114:Number = m1.tx; var m214:Number = m2.tx;
            var m124:Number = m1.ty; var m224:Number = m2.ty;
            var m134:Number = m1.tz; var m234:Number = m2.tz;
        
            result.sxx = m111 * m211 + m112 * m221 + m113 * m231;
            result.sxy = m111 * m212 + m112 * m222 + m113 * m232;
            result.sxz = m111 * m213 + m112 * m223 + m113 * m233;
            result.tx = m111 * m214 + m112 * m224 + m113 * m234 + m114;
        
            result.syx = m121 * m211 + m122 * m221 + m123 * m231;
            result.syy = m121 * m212 + m122 * m222 + m123 * m232;
            result.syz = m121 * m213 + m122 * m223 + m123 * m233;
            result.ty = m121 * m214 + m122 * m224 + m123 * m234 + m124;
        
            result.szx = m131 * m211 + m132 * m221 + m133 * m231;
            result.szy = m131 * m212 + m132 * m222 + m133 * m232;
            result.szz = m131 * m213 + m132 * m223 + m133 * m233;
            result.tz = m131 * m214 + m132 * m224 + m133 * m234 + m134;
        
            return result;
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
    
    
        public function clone():Matrix3D
        {
            var m:Matrix3D = new Matrix3D();

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
    
        public static function rotationMatrix(u:Number, v:Number, w:Number, angle:Number):Matrix3D
        {
            var m:Matrix3D = new Matrix3D();
    
            var nCos:Number = Math.cos(angle);
            var nSin:Number = Math.sin(angle);
            var scos:Number = 1 - nCos;
    
            var suv:Number = u * v * scos;
            var svw:Number = v * w * scos;
            var suw:Number = u * w * scos;
            var sw:Number = nSin * w;
            var sv:Number = nSin * v;
            var su:Number = nSin * u;
    
            m.sxx =  nCos + u * u * scos;       // nCos + u*u*(1-nCos)
            m.sxy = -sw   + suv;                                                         // -nSin * w
            m.sxz =  sv   + suw;                                                         // -nSin * v
    
            m.syx =  sw   + suv;                // nSin*w + u*v*(1-nCos)
            m.syy =  nCos + v * v * scos;
            m.syz = -su   + svw;
    
            m.szx = -sv   + suw;                // -nSin*v + u*w*(1-nCos)
            m.szy =  su   + svw;
            m.szz =  nCos + w * w * scos;
    
            return m;
        }
    
        public static function translationMatrix(u:Number, v:Number, w:Number):Matrix3D
        {
            var m:Matrix3D = new Matrix3D();
    
            m.tx = u;
            m.ty = v;
            m.tz = w;
    
            return m;
        }
    
        public static function scaleMatrix(u:Number, v:Number, w:Number):Matrix3D
        {
            var m:Matrix3D = new Matrix3D();
    
            m.sxx = u;
            m.syy = v;
            m.szz = w;
    
            return m;
        }
    
        public function get det():Number
        {
            return  (sxx * syy - syx * sxy) * szz 
                  - (sxx * szy - szx * sxy) * syz 
                  + (syx * szy - szx * syy) * sxz;
        }

        public static function inverse(m:Matrix3D):Matrix3D
        {
            var d:Number = m.det;
            if (Math.abs(d) < 0.001)
            {
                // Determinant zero, there's no inverse
                return null;
            }
    
            d = 1 / d;
    
            var m11:Number = m.sxx; var m21:Number = m.syx; var m31:Number = m.szx;
            var m12:Number = m.sxy; var m22:Number = m.syy; var m32:Number = m.szy;
            var m13:Number = m.sxz; var m23:Number = m.syz; var m33:Number = m.szz;
            var m14:Number = m.tx; var m24:Number = m.ty; var m34:Number = m.tz;
    
            var inv:Matrix3D = new Matrix3D();
            inv.sxx = d * (m22 * m33 - m32 * m23),
            inv.sxy = -d* (m12 * m33 - m32 * m13),
            inv.sxz = d * (m12 * m23 - m22 * m13),
            inv.tx = -d* (m12 * (m23*m34 - m33*m24) - m22 * (m13*m34 - m33*m14) + m32 * (m13*m24 - m23*m14)),
            inv.syx = -d* (m21 * m33 - m31 * m23),
            inv.syy = d * (m11 * m33 - m31 * m13),
            inv.syz = -d* (m11 * m23 - m21 * m13),
            inv.ty = d * (m11 * (m23*m34 - m33*m24) - m21 * (m13*m34 - m33*m14) + m31 * (m13*m24 - m23*m14)),
            inv.szx = d * (m21 * m32 - m31 * m22),
            inv.szy = -d* (m11 * m32 - m31 * m12),
            inv.szz = d * (m11 * m22 - m21 * m12),
            inv.tz = -d* (m11 * (m22*m34 - m32*m24) - m21 * (m12*m34 - m32*m14) + m31 * (m12*m24 - m22*m14))
            return inv;
        }
    
        public static function euler2quaternion(ax:Number, ay:Number, az:Number):Quaternion
        {
            var fSinPitch      :Number = Math.sin(ax * 0.5);
            var fCosPitch      :Number = Math.cos(ax * 0.5);
            var fSinYaw        :Number = Math.sin(ay * 0.5);
            var fCosYaw        :Number = Math.cos(ay * 0.5);
            var fSinRoll       :Number = Math.sin(az * 0.5);
            var fCosRoll       :Number = Math.cos(az * 0.5);
            var fCosPitchCosYaw:Number = fCosPitch * fCosYaw;
            var fSinPitchSinYaw:Number = fSinPitch * fSinYaw;
    
            var q:Quaternion = new Quaternion();
            q.x = fSinRoll * fCosPitchCosYaw     - fCosRoll * fSinPitchSinYaw;
            q.y = fCosRoll * fSinPitch * fCosYaw + fSinRoll * fCosPitch * fSinYaw;
            q.z = fCosRoll * fCosPitch * fSinYaw - fSinRoll * fSinPitch * fCosYaw;
            q.w = fCosRoll * fCosPitchCosYaw     + fSinRoll * fSinPitchSinYaw;
    
            return q;
        }
    
        public static function quaternion2matrix(x:Number, y:Number, z:Number, w:Number):Matrix3D
        {
            var xx:Number = x * x;
            var xy:Number = x * y;
            var xz:Number = x * z;
            var xw:Number = x * w;
    
            var yy:Number = y * y;
            var yz:Number = y * z;
            var yw:Number = y * w;
    
            var zz:Number = z * z;
            var zw:Number = z * w;
    
            var m:Matrix3D = new Matrix3D();
    
            m.sxx = 1 - 2 * (yy + zz);
            m.sxy =     2 * (xy - zw);
            m.sxz =     2 * (xz + yw);
    
            m.syx =     2 * (xy + zw);
            m.syy = 1 - 2 * (xx + zz);
            m.syz =     2 * (yz - xw);
    
            m.szx =     2 * (xz - yw);
            m.szy =     2 * (yz + xw);
            m.szz = 1 - 2 * (xx + yy);
    
            return m;
        }
    
        static private var toDEGREES:Number = 180 / Math.PI;
        static private var toRADIANS:Number = Math.PI / 180;
    }
}