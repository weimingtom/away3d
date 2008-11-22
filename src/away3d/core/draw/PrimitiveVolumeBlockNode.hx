package away3d.core.draw;

    import away3d.core.base.*;
    
    /**
    * Volume block tree node
    */
    class PrimitiveVolumeBlockNode
     {
    	/**
    	 * Reference to the 3d object represented by the volume block node.
    	 */
        
    	/**
    	 * Reference to the 3d object represented by the volume block node.
    	 */
        public var source:Object3D;
        
        /**
        * The list of drawing primitives inside the volume block.
        */
        public var list:Array<Dynamic>;
        
    	/**
    	 * Returns the minimum z value of the drawing primitives contained in the volume block node.
    	 */
        public var minZ:Int ;
        
    	/**
    	 * Returns the maximum z value of the drawing primitives contained in the volume block node.
    	 */
        public var maxZ:Int ;
        
    	/**
    	 * Returns the minimum x value of the drawing primitives contained in the volume block node.
    	 */
        public var minX:Int ;
        
    	/**
    	 * Returns the maximum x value of the drawing primitives contained in the volume block node.
    	 */
        public var maxX:Int ;
        
    	/**
    	 * Returns the minimum y value of the drawing primitives contained in the volume block node.
    	 */
        public var minY:Int ;
        
    	/**
    	 * Returns the maximum y value of the drawing primitives contained in the volume block node.
    	 */
        public var maxY:Int ;
        
		
		/**
		 * Creates a new <code>PrimitiveQuadrantTreeNode</code> object.
		 * 
		 * @param	source	A reference to the 3d object represented by the volume block node.
		 */
        public function new(source:Object3D)
        {
            
            minZ = Infinity;
            maxZ = -Infinity;
            minX = Infinity;
            maxX = -Infinity;
            minY = Infinity;
            maxY = -Infinity;
            this.source = source;
            this.list = [];
        }
		
		/**
		 * Adds a primitive to the volume block
		 */
        public function push(pri:DrawPrimitive):Void
        {
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
            list.push(pri);
        }
		
		/**
		 * Removes a primitive from the volume block
		 */
        public function remove(pri:DrawPrimitive):Void
        {
            var index:Int = list.indexOf(pri);
            if (index == -1)
                throw new Error("Can't remove");
            list.splice(index, 1);
        }
    }
