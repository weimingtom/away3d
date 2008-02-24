package away3d.core.math
{
    /** A point in 3D space. */
    public final class Number3D
    {
        /** Horizontal coordinate. */ 
        public var x:Number;
    
        /** Vertical coordinate. */
        public var y:Number;
    
        /** Depth coordinate */
        public var z:Number;
    
        public function Number3D(x:Number = 0, y:Number = 0, z:Number = 0)
        {
            this.x = x;
            this.y = y;
            this.z = z;
        }
    
        public function clone():Number3D
        {
            return new Number3D(x, y, z);
        }
    
        public function get modulo():Number
        {
            return Math.sqrt(x*x + y*y + z*z);
        }
    
        public function get modulo2():Number
        {
            return x*x + y*y + z*z;
        }
    
        public function scale(v:Number3D, s:Number):void
        {
            x = v.x * s;
            y = v.y * s;
            z = v.z * s;
        }  
        
        public function add(v:Number3D, w:Number3D):void
        {
            x = v.x + w.x;
            y = v.y + w.y;
            z = v.z + w.z;
        }
    
        public function sub(v:Number3D, w:Number3D):void
        {
            x = v.x - w.x;
            y = v.y - w.y;
            z = v.z - w.z;
        }
    
        public function distance(w:Number3D):Number
        {
            return Math.sqrt((x - w.x)*(x - w.x) + (y - w.y)*(y - w.y) + (z - w.z)*(z - w.z));
        }
    
        public function dot(w:Number3D):Number
        {
            return (x * w.x + y * w.y + z * w.z);
        }
    
        public function cross(v:Number3D, w:Number3D):void
        {
        	if (this == v || this == w)
        		throw new Error("resultant cross product cannot be the same instance as an input");
        	x = w.y * v.z - w.z * v.y;
        	y = w.z * v.x - w.x * v.z;
        	z = w.x * v.y - w.y * v.x;
        }
    
        public function getAngle(w:Number3D = null):Number
        {
            if (w == null)
            	w = new Number3D();
            return Math.acos(dot(w)/(modulo*w.modulo));
        }
        
        private var mod:Number;
        
        public function normalize(val:Number = 1):void
        {
            mod = modulo/val;
    
            if (mod != 0 && mod != 1)
            {
                x /= mod;
                y /= mod;
                z /= mod;
            }
        }
    
        public function rotate(v:Number3D, m:Matrix3D):void
        {
            x = v.x * m.sxx + v.y * m.sxy + v.z * m.sxz;
            y = v.x * m.syx + v.y * m.syy + v.z * m.syz;
            z = v.x * m.szx + v.y * m.szy + v.z * m.szz;
        }
        
        // Relative directions.
        public static var FORWARD :Number3D = new Number3D( 0,  0,  1);
        public static var BACKWARD:Number3D = new Number3D( 0,  0, -1);
        public static var LEFT    :Number3D = new Number3D(-1,  0,  0);
        public static var RIGHT   :Number3D = new Number3D( 1,  0,  0);
        public static var UP      :Number3D = new Number3D( 0,  1,  0);
        public static var DOWN    :Number3D = new Number3D( 0, -1,  0);
        
        private var dist:Number;
        private var num:Number3D;
        
        public function closestPointOnPlane(p:Number3D, k:Number3D, n:Number3D):Number3D
        {
        	if (!num)
        		num = new Number3D();
        	
        	num.sub(p, k);
            dist = n.dot(num);
            num.scale(n, dist);
            num.sub(p, num);
            return num;
        }
    
        public function toString(): String
        {
            return 'x:' + x + ' y:' + y + ' z:' + z;
        }
    }
}