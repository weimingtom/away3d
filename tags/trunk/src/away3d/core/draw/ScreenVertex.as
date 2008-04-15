package away3d.core.draw
{
    import away3d.core.base.*;

    /** Vertex in the screen space */
    public final class ScreenVertex
    {
        public var x:Number;
        public var y:Number;
        public var z:Number;
    	
    	/** A property containing the view x position. */
    	public var vx:Number;
    	/** A property containing the view y position. */
    	public var vy:Number;
    	
        /** An object that contains user defined properties. */
//        public var extra:Object;
        public var num:Number;
    
        /** Indicates whether the vertex is visible after projection. */
        public var visible:Boolean;
    
        public function ScreenVertex(x:Number = 0, y:Number = 0, z:Number = 0)
        {
            this.x = x;
            this.y = y;
            this.z = z;
    
            this.visible = false;
        }

        public function toString(): String
        {
            return "new ScreenVertex("+x+', '+y+', '+z+")";
        }
		
		internal var persp:Number;
		
        public function deperspective(focus:Number):Vertex
        {
            persp = 1 + z / focus;

            return new Vertex(x * persp, y * persp, z);
        }

        public function distanceSqr(b:ScreenVertex):Number
        {
            return (x - b.x)*(x - b.x) + (y - b.y)*(y - b.y);
        }

        public function distance(b:ScreenVertex):Number
        {
            return Math.sqrt((x - b.x)*(x - b.x) + (y - b.y)*(y - b.y));
        }
		
		internal var faz:Number;
		internal var fbz:Number;
		internal var ifmz2:Number;
		internal var mx2:Number;
		internal var my2:Number;
		internal var dx:Number;
		internal var dy:Number;
		
        public function distortSqr(b:ScreenVertex, focus:Number):Number
        {
            faz = focus + z;
            fbz = focus + z;
            ifmz2 = 2 / (faz + fbz);
            mx2 = (x*faz + b.x*fbz)*ifmz2;
            my2 = (y*faz + b.y*fbz)*ifmz2;

            dx = x + b.x - mx2;
            dy = y + b.y - my2;

            return 50*(dx*dx + dy+dy); // (distort*10)^2
        }

        public static function weighted(a:ScreenVertex, b:ScreenVertex, aw:Number, bw:Number, focus:Number):ScreenVertex
        {
            if ((bw == 0) && (aw == 0))
                throw new Error("Zero weights");

            if (bw == 0)
                return new ScreenVertex(a.x, a.y, a.z);
            else
            if (aw == 0)
                return new ScreenVertex(b.x, b.y, b.z);

            var d:Number = aw + bw;
            var ak:Number = aw / d;
            var bk:Number = bw / d;

            var x:Number = a.x*ak + b.x*bk;
            var y:Number = a.y*ak + b.y*bk;

            var azf:Number = a.z / focus;
            var bzf:Number = b.z / focus;

            var faz:Number = 1 + azf;
            var fbz:Number = 1 + bzf;

            var axf:Number = a.x*faz - x*azf;
            var bxf:Number = b.x*fbz - x*bzf;
            var ayf:Number = a.y*faz - y*azf;
            var byf:Number = b.y*fbz - y*bzf;

            var det:Number = axf*byf - bxf*ayf;
            var da:Number = x*byf - bxf*y;
            var db:Number = axf*y - x*ayf;

            return new ScreenVertex(x, y, (da*a.z + db*b.z) / det);
        }

        public static function median(a:ScreenVertex, b:ScreenVertex, focus:Number):ScreenVertex
        {
            var mz:Number = (a.z + b.z) / 2;

            var faz:Number = focus + a.z;
            var fbz:Number = focus + b.z;
            var ifmz:Number = 1 / (focus + mz) / 2;

            return new ScreenVertex((a.x*faz + b.x*fbz)*ifmz, (a.y*faz + b.y*fbz)*ifmz, mz);

            // ap = focus / (focus + saz) * zoom
            // bp = focus / (focus + sbz) * zoom
            // 
            // ax = sax / ap
            // bx = sbx / bp
            //
            // ay = say / ap
            // by = sby / bp
            //
            // az = saz
            // bz = sbz
            //
            // mx = (ax + bx) / 2
            // my = (ay + by) / 2
            // mz = (az + bz) / 2
            //
            // mp = focus / (focus + mz) * zoom
            // smx = mx * mp
            // smy = my * mp
            // smz = mz
            //
            // smz = (saz + sbz) / 2
            // smx = (ax + bx) * focus / (focus + smz) * zoom 
            //     = (sax / ap + sbx / bp) * focus / (focus + smz) * zoom
            //     = (sax / focus / zoom * (focus + saz) + sbx / focus / zoom * (focus + sbz)) * focus / (focus + smz) * zoom
            //     = (sax * (focus + saz) + sbx * (focus + sbz)) / (focus + smz)
            // smy = (say * (focus + saz) + sby * (focus + sbz)) / (focus + smz)

        }
    }
}
