package away3d.core.draw
{
    import away3d.core.mesh.*;

    /** Plane in 3D space */
    public class Plane3D
    {
        public var a:Number;
    
        public var b:Number;
    
        public var c:Number;

        public var d:Number;

        public function Plane3D(a:Number, b:Number, c:Number, d:Number)
        {
            this.a = a;
            this.b = b;
            this.c = c;
            this.d = d;
        }

        public static function from3points(v0:Vertex, v1:Vertex, v2:Vertex):Plane3D
        {
            var d1x:Number = v1.x - v0.x;
            var d1y:Number = v1.y - v0.y;
            var d1z:Number = v1.z - v0.z;

            var d2x:Number = v2.x - v0.x;
            var d2y:Number = v2.y - v0.y;
            var d2z:Number = v2.z - v0.z;

            var a:Number = d1y*d2z - d1z*d2y;
            var b:Number = d1z*d2x - d1x*d2z;
            var c:Number = d1x*d2y - d1y*d2x;

            var d:Number = - (a*v0.x + b*v0.y + c*v0.z);

            return new Plane3D(a, b, c, d);
        }

        public function side(v:Vertex):Number
        {
            var result:Number = a*v.x + b*v.y + c*v.z + d;
            if ((result > -0.001) && (result < 0.001))
                return 0;
            return a*v.x + b*v.y + c*v.z + d;
        }

        public function distance(v:Vertex):Number
        {
            return side(v) / Math.sqrt(a*a + b*b + c*c);
        }

    }
}
