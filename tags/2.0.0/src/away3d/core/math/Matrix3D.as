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
        
        internal var _position:Number3D = new Number3D();
        
        public function get position():Number3D
        {
        	_position.x = tx;
        	_position.y = ty;
        	_position.z = tz;
        	
            return _position;
        }

        public function toString(): String
        {
            var s:String = "";
        
            s += int(sxx*1000) / 1000 + "\t\t" + int(sxy*1000) / 1000 + "\t\t" + int(sxz*1000) / 1000 + "\t\t" + int(tx*1000) / 1000 + "\n";
            s += int(syx*1000) / 1000 + "\t\t" + int(syy*1000) / 1000 + "\t\t" + int(syz*1000) / 1000 + "\t\t" + int(ty*1000) / 1000 + "\n";
            s += int(szx*1000) / 1000 + "\t\t" + int(szy*1000) / 1000 + "\t\t" + int(szz*1000) / 1000 + "\t\t" + int(tz*1000) / 1000 + "\n";
        
            return s;
        }
        
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
    	
    	private var nCos:Number;
        private var nSin:Number;
        private var scos:Number;
    
        private var suv:Number;
        private var svw:Number;
        private var suw:Number;
        private var sw:Number;
        private var sv:Number;
        private var su:Number;
        
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
    
        public function translationMatrix(u:Number, v:Number, w:Number):void
        {
        	sxx = syy = szz = 1;
        	sxy = sxz = syz = syz = szx = szy = 0;
        	
            tx = u;
            ty = v;
            tz = w;
        }
    
        public function scaleMatrix(u:Number, v:Number, w:Number):void
        {
        	tx = sxy = sxz = 0;
        	syz = ty = syz = 0;
        	szx = szy = tz = 0;
        	
            sxx = u;
            syy = v;
            szz = w;
        }
    
        public function get det():Number
        {
            return  (sxx * syy - syx * sxy) * szz 
                  - (sxx * szy - szx * sxy) * syz 
                  + (syx * szy - szx * syy) * sxz;
        }
		
		private var d:Number;
        
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
            tz = -d* (m111 * (m122*m134 - m132*m124) - m121 * (m112*m134 - m132*m114) + m131 * (m112*m124 - m122*m114))
        }
        
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
    
        private static const toDEGREES:Number = 180 / Math.PI;
        private static const toRADIANS:Number = Math.PI / 180;
    }
}