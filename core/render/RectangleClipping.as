package away3d.core.render
{
    import away3d.core.draw.*;

    import flash.geom.*;

    public class RectangleClipping extends Clipping
    {
        public var minX:Number;
        public var maxX:Number;
        public var minY:Number;
        public var maxY:Number;

        public function RectangleClipping(minX:Number, minY:Number, maxX:Number, maxY:Number)
        {
            this.minX = minX;
            this.maxX = maxX;
            this.minY = minY;
            this.maxY = maxY;
        }

        public override function asRectangleClipping():RectangleClipping
        {
            return this;
        }

        public override function check(pri:DrawPrimitive):Boolean
        {
            if (pri.maxX < minX)
                return false;
            if (pri.minX > maxX)
                return false;
            if (pri.maxY < minY)
                return false;
            if (pri.minY > maxY)
                return false;

            return true;
        }

        public override function rect(minX:Number, minY:Number, maxX:Number, maxY:Number):Boolean
        {
            if (this.maxX < minX)
                return false;
            if (this.minX > maxX)
                return false;
            if (this.maxY < minY)
                return false;
            if (this.minY > maxY)
                return false;

            return true;
        }
    }
}