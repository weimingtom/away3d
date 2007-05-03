package away3d.core.render
{
    import away3d.core.draw.*;
    import flash.geom.*;
    import flash.display.*;

    public class Clipping
    {
        public function Clipping()
        {
        }

        public function check(pri:DrawPrimitive):Boolean
        {
            return true;
        }

        public function rect(minX:Number, minY:Number, maxX:Number, maxY:Number):Boolean
        {
            return true;
        }

        public function asRectangleClipping():RectangleClipping
        {
            return new RectangleClipping(-1000000, -1000000, 1000000, 1000000);
        }

        public static function screen(container:Sprite):Clipping
        {
            if (container.stage.align == StageAlign.TOP_LEFT)
            {
                var lt:Point = container.globalToLocal(new Point(0, 0));
                return new RectangleClipping(lt.x, lt.y, lt.x+container.stage.stageWidth, lt.y+container.stage.stageHeight);
            }
            else
                return new Clipping(); // no clipping
        }
    }
}