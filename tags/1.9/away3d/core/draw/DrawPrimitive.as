package away3d.core.draw
{
    import away3d.core.*;
    import away3d.core.render.*;
    import away3d.core.scene.*;
    import away3d.core.mesh.*;
    import away3d.core.render.*;

    import flash.display.Graphics;

    /** Abstract class for all drawing primitives */
    public class DrawPrimitive
    {
        public var projection:Projection;

        public var source:Object3D;

        public var minZ:Number;
        public var maxZ:Number;
        public var screenZ:Number;
        public var minX:int;
        public var maxX:int;
        public var minY:int;
        public var maxY:int;

        //public var flag:int;

        public function render(session:RenderSession):void
        {
            throw new Error("Not implemented");
        }

        public function contains(x:Number, y:Number):Boolean
        {   
            return false;
        }

        public function quarter(focus:Number):Array
        {
            return null;
        }

        public function riddle(another:DrawTriangle, focus:Number):Array
        {
            return null;
        }

        public function getZ(x:Number, y:Number):Number
        {
            return screenZ;
        }

        public function clear():void
        {
        }

        public function toString():String
        {
            return "P{ screenZ = " + screenZ + ", minZ = " + minZ + ", maxZ = " + maxZ + " }";
        }

        protected static function assert(statement:Boolean, message:String = "Assert failure"):void
        {
            if (!statement)
                throw new Error(message);
        }
    }
}
