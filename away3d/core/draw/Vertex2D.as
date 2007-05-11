package away3d.core.draw
{
    import away3d.core.geom.*;

    // Vertices in screen space
    public class Vertex2D
    {
        public var x:Number;
        public var y:Number;
        public var z:Number;
    
        // An object that contains user defined properties.
        public var extra:Object;
    
        // A Boolean value that indicates whether the vertex is visible after projection.
        // If false, it indicates that the vertex is behind the camera plane.
        public var visible:Boolean;
    
        public function Vertex2D(x:Number = 0, y:Number = 0, z:Number = 0)
        {
            this.x = x;
            this.y = y;
            this.z = z;
    
            this.visible = false;
        }

        public function toString(): String
        {
            return "new Vertex2D("+x+', '+y+', '+z+")";
        }

        public function deperspective(focus:Number):Vertex3D
        {
            var persp:Number = 1 + z / focus;

            return new Vertex3D(x * persp, y * persp, z);
        }

        public static function distanceSqr(a:Vertex2D, b:Vertex2D):Number
        {
            return (a.x-b.x)*(a.x-b.x) + (a.y-b.y)*(a.y-b.y);
        }

        public static function distance(a:Vertex2D, b:Vertex2D):Number
        {
            return Math.sqrt((a.x-b.x)*(a.x-b.x) + (a.y-b.y)*(a.y-b.y));
        }

        public static function distortSqr(a:Vertex2D, b:Vertex2D, focus:Number):Number
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

        public static function weighted(a:Vertex2D, b:Vertex2D, aw:Number, bw:Number, focus:Number):Vertex2D
        {
            if ((bw == 0) && (aw == 0))
                throw new Error("Zero weights");

            if (bw == 0)
                return new Vertex2D(a.x, a.y, a.z);
            else
            if (aw == 0)
                return new Vertex2D(b.x, b.y, b.z);

            var d:Number = aw + bw;
            var ak:Number = aw / d;
            var bk:Number = bw / d;
            var x:Number = a.x*ak + b.x*bk;
            var y:Number = a.y*ak + b.y*bk;

            var faz:Number = focus + a.z;
            var fbz:Number = focus + b.z;

            var xfocus:Number = x * focus;
            var yfocus:Number = y * focus;

            var axf:Number = a.x*faz - x*a.z;
            var bxf:Number = b.x*fbz - x*b.z;
            var ayf:Number = a.y*faz - y*a.z;
            var byf:Number = b.y*fbz - y*b.z;

            var det:Number = axf*byf - bxf*ayf;
            var da:Number = xfocus*byf - bxf*yfocus;
            var db:Number = axf*yfocus - xfocus*ayf;

            return new Vertex2D(x, y, (da*a.z + db*b.z) / det);
        }

        public static function median(a:Vertex2D, b:Vertex2D, focus:Number):Vertex2D
        {
            var mz:Number = (a.z + b.z) / 2;

            var faz:Number = focus + a.z;
            var fbz:Number = focus + b.z;
            var ifmz:Number = 1 / (focus + mz) / 2;

            return new Vertex2D((a.x*faz + b.x*fbz)*ifmz, (a.y*faz + b.y*fbz)*ifmz, mz);

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
