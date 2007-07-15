package away3d.core.geom
{
    /** Texture coordinates value. <br/> Properties u and v represent the horizontal and vertical texture axes. */
    public class NumberUV
    {
        /** Horizontal coordinate */
        public var u:Number;
    
        /** Vertical coordinate */
        public var v:Number;
    
        //@param u The horizontal coordinate value.
        //@param v The vertical coordinate value. 
        public function NumberUV(u:Number = 0, v:Number = 0)
        {
            this.u = u;
            this.v = v;
        }
    
        public function toString():String
        {
            return 'u:' + u + ' v:' + v;
        }

        public static function median(a:NumberUV, b:NumberUV):NumberUV
        {
            if (a == null)
                return null;
            if (b == null)
                return null;
            return new NumberUV((a.u + b.u)/2, (a.v + b.v)/2);
        }

        public static function weighted(a:NumberUV, b:NumberUV, aw:Number, bw:Number):NumberUV
        {                
            if (a == null)
                return null;
            if (b == null)
                return null;
            var d:Number = aw + bw;
            var ak:Number = aw / d;
            var bk:Number = bw / d;
            return new NumberUV(a.u*ak+b.u*bk, a.v*ak + b.v*bk);
        }
    }
}