package away3d.core.render
{
    import away3d.core.draw.*;

    /** Rectangle clipping */
    public class RectangleClipping extends Clipping
    {
        public function RectangleClipping(minX:Number = -1000000, minY:Number = -1000000, maxX:Number = 1000000, maxY:Number = 1000000)
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
        
        public function toString():String
        {
        	return "{minX:" + minX + " maxX:" + maxX + " minY:" + minY + " maxY:" + maxY + "}";
        }
    }
}