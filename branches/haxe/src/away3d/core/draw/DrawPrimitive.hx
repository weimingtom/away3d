package away3d.core.draw;

    import away3d.containers.*;
    import away3d.core.base.*;
    import away3d.core.render.*;

    /**
    * Abstract class for all drawing primitives
    */
    class DrawPrimitive
     {
    	/**
    	 * The view 3d object of the drawing primitive.
    	 */
        
    	/**
    	 * The view 3d object of the drawing primitive.
    	 */
        public var view:View3D;
        
    	/**
    	 * The parent 3d object of the drawing primitive.
    	 */
        public var source:Object3D;
        
        /**
        * Placeholder function for creating new drawing primitives from a cache of objects.
        * Saves recreating objects and GC problems.
        */
		public var create:Dynamic;
		
		/**
		 * Indicates the minimum z value of the drawing primitive.
		 */
        public var minZ:Float;
		
		/**
		 * Indicates the maximum z value of the drawing primitive.
		 */
        public var maxZ:Float;
		
		/**
		 * Indicates the screen z value of the drawing primitive (used for z-sorting).
		 */
        public var screenZ:Float;
		
		/**
		 * Indicates the minimum x value of the drawing primitive.
		 */
        public var minX:Float;
		
		/**
		 * Indicates the maximum x value of the drawing primitive.
		 */
        public var maxX:Float;
		
		/**
		 * Indicates the minimum y value of the drawing primitive.
		 */
        public var minY:Float;
		
		/**
		 * Indicates the maximum y value of the drawing primitive.
		 */
        public var maxY:Float;
				
		/**
		 * Reference to the last quadrant used by the drawing primitive. Used in <code>PrimitiveQuadrantTree</code>
		 * 
		 * @see away3d.core.render.PrimitiveQuadrantTree
		 */
		public var quadrant:PrimitiveQuadrantTreeNode;
		
		/**
		 * Calculates the min, max and screen properties required for rendering the drawing primitive.
		 */
        public function calc():Void
        {
            throw new Error("Not implemented");
        }
        
		/**
		 * Draws the primitive to the view.
		 */
        public function render():Void
        {
            throw new Error("Not implemented");
        }
		
		/**
		 * Determines whether the given point lies inside the drawing primitive
		 * 
		 * @param	x	The x position of the point to be tested.
		 * @param	y	The y position of the point to be tested.
		 * @return		The result of the test.
		 */
        public function contains(x:Float, y:Float):Bool
        {   
            throw new Error("Not implemented");
        }
		
		/**
		 * Cuts the drawing primitive into 4 equally sized drawing primitives. Used in z-sorting correction.
		 * 
		 * @param	focus	The focus value of the camera being used in the view.
		 * 
		 * @see away3d.cameras.Camera3D
		 */
        public function quarter(focus:Float):Array<Dynamic>
        {
            throw new Error("Not implemented");
        }
		
		/**
		 * Calulates the screen z value of a precise point on the drawing primitive.
		 * 
		 * @param	x	The x position of the point to be tested.
		 * @param	y	The y position of the point to be tested.
		 * @return		The screen z value (used in z-sorting).
		 */
        public function getZ(x:Float, y:Float):Float
        {
            return screenZ;
        }
		
		/**
		 * Deletes the data currently held by the drawing primitive.
		 */
        public function clear():Void
        {
            throw new Error("Not implemented");
        }
		
		/**
		 * Used to trace the values of a drawing primitive.
		 * 
		 * @return	A string representation of the drawing primitive.
		 */
        public function toString():String
        {
            return "P{ screenZ = " + screenZ + ", minZ = " + minZ + ", maxZ = " + maxZ + " }";
        }
    }
