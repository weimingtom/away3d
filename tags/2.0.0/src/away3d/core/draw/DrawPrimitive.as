package away3d.core.draw
{
    import away3d.core.*;
    import away3d.core.base.*;
    import away3d.core.render.*;
    import away3d.core.base.*

    /** Abstract class for all drawing primitives */
    public class DrawPrimitive
    {
        public var source:Object3D;
        public var projection:Projection;
		public var create:Function;

        public var minZ:Number;
        public var maxZ:Number;
        public var screenZ:Number;
        public var minX:Number;
        public var maxX:Number;
        public var minY:Number;
        public var maxY:Number;
		
		public var quadrant:PrimitiveQuadrantTreeNode;
		
        //public var flag:int;

        public function render():void
        {
            throw new Error("Not implemented");
        }
        
        public function shade():void
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
