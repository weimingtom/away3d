package away3d.core.draw
{
    import away3d.core.*;

    public class Line2D
    {
        public var a:Number;
    
        public var b:Number;
    
        public var c:Number;

        public function Line2D(a:Number, b:Number, c:Number)
        {
            this.a = a;
            this.b = b;
            this.c = c;
        }

        public static function from2points(v0:Vertex2D, v1:Vertex2D):Line2D
        {
            var a:Number = v1.y - v0.y;
            var b:Number = v0.x - v1.x;
            var c:Number = -(b*v0.y + a*v0.x);

            return new Line2D(a, b, c);
        }

        public static function cross(u:Line2D, v:Line2D):Vertex2D
        {
            var det:Number = u.a*v.b - u.b*v.a;
            var xd:Number = u.b*v.c - u.c*v.b;
            var yd:Number = v.a*u.c - u.a*v.c;

            return new Vertex2D(xd / det, yd / det, 0);
        }

        public function sideV(v:Vertex2D):Number
        {
            return a*v.x + b*v.y + c;
        }

        public function side(x:Number, y:Number):Number
        {
            return a*x + b*y + c;
        }

        public function distance(v:Vertex2D):Number
        {
            return sideV(v) / Math.sqrt(a*a + b*b);
        }

        public function toString():String
        {
            return "line{ a: "+a+" b: "+b+" c:"+c+" }";
        }
    }
}
