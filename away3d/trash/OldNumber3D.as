package away3d.trash
{
    import away3d.core.math.*;

    /** A point in 3D space. */
    public class OldNumber3D
    {
        /** Horizontal coordinate. */ 
        public var x:Number;
    
        /** Vertical coordinate. */
        public var y:Number;
    
        /** Depth coordinate */
        public var z:Number;
    
        public function OldNumber3D(x:Number = 0, y:Number = 0, z:Number = 0)
        {
            this.x = x;
            this.y = y;
            this.z = z;
        }
    
        public function clone():OldNumber3D
        {
            return new OldNumber3D(x, y, z);
        }
    
        public function get modulo():Number
        {
            return Math.sqrt(x*x + y*y + z*z);
        }
    
        public function get modulo2():Number
        {
            return x*x + y*y + z*z;
        }
    
        public static function scale(v:OldNumber3D, s:Number):OldNumber3D
        {
            return new OldNumber3D
            (
                v.x * s,
                v.y * s,
                v.z * s
            );
        }  
        
        public static function add(v:OldNumber3D, w:OldNumber3D):OldNumber3D
        {
            return new OldNumber3D
            (
                v.x + w.x,
                v.y + w.y,
                v.z + w.z
           );
        }
    
        public static function sub(v:OldNumber3D, w:OldNumber3D):OldNumber3D
        {
            return new OldNumber3D
            (
                v.x - w.x,
                v.y - w.y,
                v.z - w.z
           );
        }
    
        public static function distance(v:OldNumber3D, w:OldNumber3D):Number
        {
            return Math.sqrt((v.x - w.x)*(v.x - w.x) + (v.y - w.y)*(v.y - w.y) + (v.z - w.z)*(v.z - w.z));
        }
    
        public static function dot(v:OldNumber3D, w:OldNumber3D):Number
        {
            return (v.x * w.x + v.y * w.y + w.z * v.z);
        }
    
        public static function cross(v:OldNumber3D, w:OldNumber3D):OldNumber3D
        {
            return new OldNumber3D
            (
                (w.y * v.z) - (w.z * v.y),
                (w.z * v.x) - (w.x * v.z),
                (w.x * v.y) - (w.y * v.x)
           );
        }
    
        public static function getAngle(v:OldNumber3D, w:OldNumber3D = null):Number
        {
            if (w == null) w = new OldNumber3D();
            return Math.acos(OldNumber3D.dot(v, w)/(v.modulo*w.modulo));
        }
        
        public function normalize(val:Number = 1):void
        {
            var mod:Number = modulo*val;
    
            if (mod != 0 && mod != 1)
            {
                x /= mod;
                y /= mod;
                z /= mod;
            }
        }
    
        public function rotate(m:Matrix3D):OldNumber3D
        {
            var v:OldNumber3D = new OldNumber3D(
                    x * m.sxx + y * m.sxy + z * m.sxz,
                    x * m.syx + y * m.syy + z * m.syz,
                    x * m.szx + y * m.szy + z * m.szz);
            v.normalize();
            return v;
        }
        
        // Relative directions.
        public static var FORWARD :OldNumber3D = new OldNumber3D( 0,  0,  1);
        public static var BACKWARD:OldNumber3D = new OldNumber3D( 0,  0, -1);
        public static var LEFT    :OldNumber3D = new OldNumber3D(-1,  0,  0);
        public static var RIGHT   :OldNumber3D = new OldNumber3D( 1,  0,  0);
        public static var UP      :OldNumber3D = new OldNumber3D( 0,  1,  0);
        public static var DOWN    :OldNumber3D = new OldNumber3D( 0, -1,  0);
        
        
        public static function closestPointOnPlane(p:OldNumber3D, k:OldNumber3D, n:OldNumber3D):OldNumber3D
        {
            var distance:Number = OldNumber3D.dot(n, OldNumber3D.sub(p, k));
            return OldNumber3D.sub(p, OldNumber3D.scale(n, distance));
        }
    
        public function toString(): String
        {
            return 'x:' + x + ' y:' + y + ' z:' + z;
        }
    }
}