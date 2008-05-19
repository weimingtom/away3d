package away3d.core.draw
{
    import away3d.core.render.*;
    import away3d.core.base.*;
	
	/**
	 * Group drawing primitive.
	 */
    public class DrawGroup extends DrawPrimitive implements IPrimitiveConsumer
    {
    	/**
    	 * The primitives contained in the group.
    	 */
        public var primitives:Array;
        
		/**
		 * @inheritDoc
		 */
        public override function clear():void
        {
        	primitives = [];
            minZ = Infinity;
            maxZ = -Infinity;
            minX =  100000;
            maxX = -100000;
            minY =  100000;
            maxY = -100000;
        }
		 
    	/**
    	 * Adds a drawing primitive to the primitive group
    	 *
		 * @param	pri		The drawing primitive to add.
		 */
        public function primitive(pri:DrawPrimitive):void
        {
            primitives.push(pri);

            if (minZ > pri.minZ)
                minZ = pri.minZ;
            if (maxZ < pri.maxZ)
                maxZ = pri.maxZ;

            if (minX > pri.minX)
                minX = pri.minX;
            if (maxX < pri.maxX)
                maxX = pri.maxX;

            if (minY > pri.minY)
                minY = pri.minY;
            if (maxY < pri.maxY)
                maxY = pri.maxY;

            screenZ = (maxZ + minZ) / 2;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function render():void
        {
            primitives.sortOn("screenZ", Array.DESCENDING | Array.NUMERIC);
            for each (var pri:DrawPrimitive in primitives)
                pri.render();
        }
        
		/**
		 * @inheritDoc
		 */
        public override function contains(x:Number, y:Number):Boolean
        {   
            for each (var pri:DrawPrimitive in primitives)
                if (pri.contains(x, y))
                    return true;

            return false;
        }

    }
}
