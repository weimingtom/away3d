package away3d.core.draw
{
    import away3d.core.mesh.*;

    /** Vertex in the screen space */
    public final class ScreenVertex
    {
        public var x:Number;
        public var y:Number;
        public var z:Number;
    
        /** An object that contains user defined properties. */
        public var extra:Object;
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

        public function deperspective(focus:Number):Vertex
        {
            var persp:Number = 1 + z / focus;

            return new Vertex(x * persp, y * persp, z);
        }

        public static function distanceSqr(a:ScreenVertex, b:ScreenVertex):Number
        {
            return (a.x-b.x)*(a.x-b.x) + (a.y-b.y)*(a.y-b.y);
        }

        public static function distance(a:ScreenVertex, b:ScreenVertex):Number
        {
            return Math.sqrt((a.x-b.x)*(a.x-b.x) + (a.y-b.y)*(a.y-b.y));
        }

        public static function distortSqr(a:ScreenVertex, b:ScreenVertex, focus:Number):Number
        {
            var faz:Number = focus + a.z;
            var fbz:Number = focus + b.z;
            var ifmz2:Number = 2 / (faz + fbz);
            var mx2:Number = (a.x*faz + b.x*fbz)*ifmz2;
            var my2:Number = (a.y*faz + b.y*fbz)*ifmz2;

            var dx:Number = a.x + b.x - mx2;
            var dy:Number = a.y + b.y - my2;

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
