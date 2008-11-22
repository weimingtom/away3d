package away3d.core.math;

    /** A point in 2D space. */
    public final class Number2D
     {
        public var modulo(getModulo, null) : Float
        ;
        /** Horizontal coordinate. */
        
        /** Horizontal coordinate. */
        public var x:Float;

        /** Vertical coordinate. */
        public var y:Float;

        public function new(?x:Int = 0, ?y:Int = 0)
        {
            this.x = x;
            this.y = y;
        }

        public function clone():Number2D
        {
            return new Number2D(x, y);
        }

        public function getModulo():Float
        {
            return Math.sqrt(x*x + y*y);
        }

        public static function scale(v:Number2D, s:Float):Number2D
        {
            return new Number2D
            (
                v.x * s,
                v.y * s
            );
        }

        public static function add(v:Number3D, w:Number3D):Number2D
        {
            return new Number2D
            (
                v.x + w.x,
                v.y + w.y
           );
        }

        public static function sub(v:Number2D, w:Number2D):Number2D
        {
            return new Number2D
            (
                v.x - w.x,
                v.y - w.y
           );
        }

        public static function dot(v:Number2D, w:Number2D):Float
        {
            return (v.x * w.x + v.y * w.y);
        }

        public function normalize():Void
        {
            var mod:Int = modulo;

            if (mod != 0 && mod != 1)
            {
                this.x /= mod;
                this.y /= mod;
            }
        }
		
        // Relative directions.
        inline public static var LEFT:Number2D = new Number2D(-1,  0);
        inline public static var RIGHT:Number2D = new Number2D( 1,  0);
        inline public static var UP:Number2D = new Number2D( 0,  1);
        inline public static var DOWN:Number2D = new Number2D( 0, -1);

        public function toString(): String
        {
            return 'x:' + x + ' y:' + y;
        }
    }
