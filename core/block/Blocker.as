package away3d.core.block
{
    import away3d.core.*;
    import away3d.core.render.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;

    import flash.display.Graphics;

    public class Blocker extends DrawPrimitive
    {
        /*
        public var screenZ:Number;
        public var minX:int;
        public var maxX:int;
        public var minY:int;
        public var maxY:int;

        public function contains(x:Number, y:Number):Boolean
        {   
            return false;
        }
        */
        public function block(pri:DrawPrimitive):Boolean
        {
            return false;
        }

    }
}
