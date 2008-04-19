package away3d.core.base
{
    /** Texture coordinates value. <br/> Properties u and v represent the horizontal and vertical texture axes. */
    import away3d.core.*;
    import away3d.core.utils.*;

    public class UV extends ValueObject
    {
        use namespace arcane;

        arcane var _u:Number;
        arcane var _v:Number;
    
        public var extra:Object;

        public function get v():Number
        {
            return _v;
        }

        public function set v(value:Number):void
        {
            if (value == _v)
                return;

            _v = value;

            notifyChange();
        }

        public function get u():Number
        {
            return _u;
        }

        public function set u(value:Number):void
        {
            if (value == _u)
                return;

            _u = value;

            notifyChange();
        }

        public function UV(u:Number = 0, v:Number = 0)
        {
            _u = u;
            _v = v;
        }
    
        public function clone():UV
        {
            return new UV(_u, _v);
        }
    
        public function toString():String
        {
            return "new UV("+_u+", "+_v+")";
        }

        arcane static function median(a:UV, b:UV):UV
        {
            if (a == null)
                return null;
            if (b == null)
                return null;
            return new UV((a._u + b._u)/2, (a._v + b._v)/2);
        }

        arcane static function weighted(a:UV, b:UV, aw:Number, bw:Number):UV
        {                
            if (a == null)
                return null;
            if (b == null)
                return null;
            var d:Number = aw + bw;
            var ak:Number = aw / d;
            var bk:Number = bw / d;
            return new UV(a._u*ak+b._u*bk, a._v*ak + b._v*bk);
        }
    }
}