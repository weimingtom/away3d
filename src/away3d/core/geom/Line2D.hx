package away3d.core.geom;

	import away3d.core.draw.*;
	

    /** Line in 2D space */
    class Line2D
     {
        
        public var a:Float;
    
        public var b:Float;
    
        public var c:Float;

        public function new(a:Float, b:Float, c:Float)
        {
            this.a = a;
            this.b = b;
            this.c = c;
        }

        public static function from2points(v0:ScreenVertex, v1:ScreenVertex):Line2D
        {
            var a:Int = v1.y - v0.y;
            var b:Int = v0.x - v1.x;
            var c:Int = -(b*v0.y + a*v0.x);

            return new Line2D(a, b, c);
        }

        public static function cross(u:Line2D, v:Line2D):ScreenVertex
        {
            var det:Int = u.a*v.b - u.b*v.a;
            var xd:Int = u.b*v.c - u.c*v.b;
            var yd:Int = v.a*u.c - u.a*v.c;

            return new ScreenVertex(xd / det, yd / det, 0);
        }

        public function sideV(v:ScreenVertex):Float
        {
            return a*v.x + b*v.y + c;
        }

        public function side(x:Float, y:Float):Float
        {
            return a*x + b*y + c;
        }

        public function distance(v:ScreenVertex):Float
        {
            return sideV(v) / Math.sqrt(a*a + b*b);
        }

        public function toString():String
        {
            return "line{ a: "+a+" b: "+b+" c:"+c+" }";
        }
    }
