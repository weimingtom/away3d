package away3d.core.math
{
    /** A point in 3D space. */
    public class Number3D
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
    
        public static function scale( v:Number3D, s:Number ):Number3D
        {
            return new Number3D
            (
                v.x * s,
                v.y * s,
                v.z * s
            );
        }  
        
        public static function add(v:Number3D, w:Number3D):Number3D
        {
            return new Number3D
            (
                v.x + w.x,
                v.y + w.y,
                v.z + w.z
           );
        }
    
        public static function sub(v:Number3D, w:Number3D):Number3D
        {
            return new Number3D
            (
                v.x - w.x,
                v.y - w.y,
                v.z - w.z
           );
        }
    
        public static function dot(v:Number3D, w:Number3D):Number
        {
            return (v.x * w.x + v.y * w.y + w.z * v.z);
        }
    
        public static function cross(v:Number3D, w:Number3D):Number3D
        {
            return new Number3D
            (
                (w.y * v.z) - (w.z * v.y),
                (w.z * v.x) - (w.x * v.z),
                (w.x * v.y) - (w.y * v.x)
           );
        }
    
        public function normalize():void
        {
            var mod:Number = modulo;
    
            if (mod != 0 && mod != 1)
            {
                x /= mod;
                y /= mod;
                z /= mod;
            }
        }
    
        public function rotate(m:Matrix3D):Number3D
        {
            var x:Number = this.x;
            var y:Number = this.y;
            var z:Number = this.z;
            var v:Number3D = new Number3D(
                    x * m.n11 + y * m.n12 + z * m.n13,
                    x * m.n21 + y * m.n22 + z * m.n23,
                    x * m.n31 + y * m.n32 + z * m.n33);
            v.normalize();
            return v;
        }
        
        // Relative directions.
        public static var FORWARD :Number3D = new Number3D( 0,  0,  1);
        public static var BACKWARD:Number3D = new Number3D( 0,  0, -1);
        public static var LEFT    :Number3D = new Number3D(-1,  0,  0);
        public static var RIGHT   :Number3D = new Number3D( 1,  0,  0);
        public static var UP      :Number3D = new Number3D( 0,  1,  0);
        public static var DOWN    :Number3D = new Number3D( 0, -1,  0);
    
        public function toString(): String
        {
            return 'x:' + x + ' y:' + y + ' z:' + z;
        }
    }
}