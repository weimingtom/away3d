package away3d.core.math
{
    /** 3D transformation 4x3 matrix */
    public class Matrix3D
    {
        public var n11:Number, n12:Number, n13:Number, n14:Number, n21:Number, n22:Number, n23:Number, n24:Number, n31:Number, n32:Number, n33:Number, n34:Number;

        public function Matrix3D()
        {
            n11 = n22 = n33 = 1;
            n12 = n13 = n14 = n21 = n23 = n24 = n31 = n32 = n34 = 0;
        }

        public static function fromArray(ar:Array):Matrix3D
        {
            var m:Matrix3D = new Matrix3D();
            if (ar.length >= 12)
            {
                m.n11 = ar[0];  
                m.n12 = ar[1];  
                m.n13 = ar[2];  
                m.n14 = ar[3];
                m.n21 = ar[4];  
                m.n22 = ar[5];  
                m.n23 = ar[6];  
                m.n24 = ar[7];
                m.n31 = ar[8];  
                m.n32 = ar[9];  
                m.n33 = ar[10]; 
                m.n34 = ar[11];
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
        
            s += int(n11*1000) / 1000 + "\t\t" + int(n12*1000) / 1000 + "\t\t" + int(n13*1000) / 1000 + "\t\t" + int(n14*1000) / 1000 + "\n";
            s += int(n21*1000) / 1000 + "\t\t" + int(n22*1000) / 1000 + "\t\t" + int(n23*1000) / 1000 + "\t\t" + int(n24*1000) / 1000 + "\n";
            s += int(n31*1000) / 1000 + "\t\t" + int(n32*1000) / 1000 + "\t\t" + int(n33*1000) / 1000 + "\t\t" + int(n34*1000) / 1000 + "\n";
        
            return s;
        }

        public static function multiply3x3(m1:Matrix3D, m2:Matrix3D):Matrix3D
        {
            var dest:Matrix3D = new Matrix3D();
            var m111:Number = m1.n11; var m211:Number = m2.n11;
            var m121:Number = m1.n21; var m221:Number = m2.n21;
            var m131:Number = m1.n31; var m231:Number = m2.n31;
            var m112:Number = m1.n12; var m212:Number = m2.n12;
            var m122:Number = m1.n22; var m222:Number = m2.n22;
            var m132:Number = m1.n32; var m232:Number = m2.n32;
            var m113:Number = m1.n13; var m213:Number = m2.n13;
            var m123:Number = m1.n23; var m223:Number = m2.n23;
            var m133:Number = m1.n33; var m233:Number = m2.n33;
        
            dest.n11 = m111 * m211 + m112 * m221 + m113 * m231;
            dest.n12 = m111 * m212 + m112 * m222 + m113 * m232;
            dest.n13 = m111 * m213 + m112 * m223 + m113 * m233;
        
            dest.n21 = m121 * m211 + m122 * m221 + m123 * m231;
            dest.n22 = m121 * m212 + m122 * m222 + m123 * m232;
            dest.n23 = m121 * m213 + m122 * m223 + m123 * m233;
        
            dest.n31 = m131 * m211 + m132 * m221 + m133 * m231;
            dest.n32 = m131 * m212 + m132 * m222 + m133 * m232;
            dest.n33 = m131 * m213 + m132 * m223 + m133 * m233;
        
            dest.n14 = m1.n14;
            dest.n24 = m1.n24;
            dest.n34 = m1.n34;
        
            return dest;
        }
        
        public static function multiply(m1:Matrix3D, m2:Matrix3D):Matrix3D
        {
            var result:Matrix3D = new Matrix3D();
        
            var m111:Number = m1.n11; var m211:Number = m2.n11;
            var m121:Number = m1.n21; var m221:Number = m2.n21;
            var m131:Number = m1.n31; var m231:Number = m2.n31;
            var m112:Number = m1.n12; var m212:Number = m2.n12;
            var m122:Number = m1.n22; var m222:Number = m2.n22;
            var m132:Number = m1.n32; var m232:Number = m2.n32;
            var m113:Number = m1.n13; var m213:Number = m2.n13;
            var m123:Number = m1.n23; var m223:Number = m2.n23;
            var m133:Number = m1.n33; var m233:Number = m2.n33;
            var m114:Number = m1.n14; var m214:Number = m2.n14;
            var m124:Number = m1.n24; var m224:Number = m2.n24;
            var m134:Number = m1.n34; var m234:Number = m2.n34;
        
            result.n11 = m111 * m211 + m112 * m221 + m113 * m231;
            result.n12 = m111 * m212 + m112 * m222 + m113 * m232;
            result.n13 = m111 * m213 + m112 * m223 + m113 * m233;
            result.n14 = m111 * m214 + m112 * m224 + m113 * m234 + m114;
        
            result.n21 = m121 * m211 + m122 * m221 + m123 * m231;
            result.n22 = m121 * m212 + m122 * m222 + m123 * m232;
            result.n23 = m121 * m213 + m122 * m223 + m123 * m233;
            result.n24 = m121 * m214 + m122 * m224 + m123 * m234 + m124;
        
            result.n31 = m131 * m211 + m132 * m221 + m133 * m231;
            result.n32 = m131 * m212 + m132 * m222 + m133 * m232;
            result.n33 = m131 * m213 + m132 * m223 + m133 * m233;
            result.n34 = m131 * m214 + m132 * m224 + m133 * m234 + m134;
        
            return result;
        }
        
		public function transformPoint(val:Number3D):Number3D
        {
        	var x:Number = val.x;
        	var y:Number = val.y;
        	var z:Number = val.z;
        	return new Number3D(n11*x + n12*y + n13*z + n14, n21*x + n22*y + n23*z + n24, n31*x + n32*y + n33*z + n34);
        }
    
        public function scale(x:Number, y:Number, z:Number):void
        {
            n11 *= x;
            n21 *= x;
            n31 *= x;
            n12 *= y;
            n22 *= y;
            n32 *= y;
            n13 *= z;
            n23 *= z;
            n33 *= z;
        }

        public function copy3x3(m:Matrix3D):Matrix3D
        {
            n11 = m.n11;   n12 = m.n12;   n13 = m.n13;
            n21 = m.n21;   n22 = m.n22;   n23 = m.n23;
            n31 = m.n31;   n32 = m.n32;   n33 = m.n33;
    
            return this;
        }
    
    
        public function clone():Matrix3D
        {
            var m:Matrix3D = new Matrix3D();

            m.n11 = n11;   m.n12 = n12;   m.n13 = n13;   m.n14 = n14;
            m.n21 = n21;   m.n22 = n22;   m.n23 = n23;   m.n24 = n24;
            m.n31 = n31;   m.n32 = n32;   m.n33 = n33;   m.n34 = n34;
                            
            return m;
        }
    
        public static function matrix2euler(mat:Matrix3D):Number3D
        {
            var angle:Number3D = new Number3D();
    
            var d :Number = -Math.asin(Math.max(-1, Math.min(1, mat.n13))); // Calculate Y-axis angle
            var c :Number =  Math.cos(d);
    
            angle.y = d * toDEGREES;
    
            var trX:Number, trY:Number;
    
            if (Math.abs(c) > 0.005)  // Gimball lock?
            {
                trX =  mat.n33 / c;  // No, so get X-axis angle
                trY = -mat.n23 / c;
    
                angle.x = Math.atan2(trY, trX) * toDEGREES;
    
                trX =  mat.n11 / c;  // Get Z-axis angle
                trY = -mat.n12 / c;
    
                angle.z = Math.atan2(trY, trX) * toDEGREES;
            }
            else  // Gimball lock has occurred
            {
                angle.x = 0;  // Set X-axis angle to zero
    
                trX = mat.n22;  // And calculate Z-axis angle
                trY = mat.n21;
    
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
    
            m.n11 =  nCos + u * u * scos;
            m.n12 = -sw   + suv;
            m.n13 =  sv   + suw;
    
            m.n21 =  sw   + suv;
            m.n22 =  nCos + v * v * scos;
            m.n23 = -su   + svw;
    
            m.n31 = -sv   + suw;
            m.n32 =  su   + svw;
            m.n33 =  nCos + w * w * scos;
    
            return m;
        }
    
        public static function translationMatrix(u:Number, v:Number, w:Number):Matrix3D
        {
            var m:Matrix3D = new Matrix3D();
    
            m.n14 = u;
            m.n24 = v;
            m.n34 = w;
    
            return m;
        }
    
        public static function scaleMatrix(u:Number, v:Number, w:Number):Matrix3D
        {
            var m:Matrix3D = new Matrix3D();
    
            m.n11 = u;
            m.n22 = v;
            m.n33 = w;
    
            return m;
        }
    
        public function get det():Number
        {
            return  (n11 * n22 - n21 * n12) * n33 
                  - (n11 * n32 - n31 * n12) * n23 
                  + (n21 * n32 - n31 * n22) * n13;
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
    
            var m11:Number = m.n11; var m21:Number = m.n21; var m31:Number = m.n31;
            var m12:Number = m.n12; var m22:Number = m.n22; var m32:Number = m.n32;
            var m13:Number = m.n13; var m23:Number = m.n23; var m33:Number = m.n33;
            var m14:Number = m.n14; var m24:Number = m.n24; var m34:Number = m.n34;
    
            var inv:Matrix3D = new Matrix3D();
            inv.n11 = d * (m22 * m33 - m32 * m23),
            inv.n12 = -d* (m12 * m33 - m32 * m13),
            inv.n13 = d * (m12 * m23 - m22 * m13),
            inv.n14 = -d* (m12 * (m23*m34 - m33*m24) - m22 * (m13*m34 - m33*m14) + m32 * (m13*m24 - m23*m14)),
            inv.n21 = -d* (m21 * m33 - m31 * m23),
            inv.n22 = d * (m11 * m33 - m31 * m13),
            inv.n23 = -d* (m11 * m23 - m21 * m13),
            inv.n24 = d * (m11 * (m23*m34 - m33*m24) - m21 * (m13*m34 - m33*m14) + m31 * (m13*m24 - m23*m14)),
            inv.n31 = d * (m21 * m32 - m31 * m22),
            inv.n32 = -d* (m11 * m32 - m31 * m12),
            inv.n33 = d * (m11 * m22 - m21 * m12),
            inv.n34 = -d* (m11 * (m22*m34 - m32*m24) - m21 * (m12*m34 - m32*m14) + m31 * (m12*m24 - m22*m14))
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
    
            m.n11 = 1 - 2 * (yy + zz);
            m.n12 =     2 * (xy - zw);
            m.n13 =     2 * (xz + yw);
    
            m.n21 =     2 * (xy + zw);
            m.n22 = 1 - 2 * (xx + zz);
            m.n23 =     2 * (yz - xw);
    
            m.n31 =     2 * (xz - yw);
            m.n32 =     2 * (yz + xw);
            m.n33 = 1 - 2 * (xx + yy);
    
            return m;
        }
    
        static private var toDEGREES:Number = 180 / Math.PI;
        static private var toRADIANS:Number = Math.PI / 180;
    }
}