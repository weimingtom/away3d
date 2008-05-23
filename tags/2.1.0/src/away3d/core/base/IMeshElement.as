package away3d.core.base
{
    /**
    * Interface for objects that define a 3d element of a mesh
    */
    public interface IMeshElement
    {
        function get vertices():Array;
        		
		/**
		 * Defines whether the 3d element is visible in the scene.
		 */
        function get visible():Boolean;
        function set visible(value:Boolean):void;
		
		/**
		 * Returns the squared bounding radius of the 3d element
		 */
        function get radius2():Number;
		
		/**
		 * Returns the maximum x value of the 3d element
		 */
        function get maxX():Number;
		
		/**
		 * Returns the minimum x value of the 3d element
		 */
        function get minX():Number;
		
		/**
		 * Returns the minimum y value of the 3d element
		 */
        function get maxY():Number;
		
		/**
		 * Returns the maximum y value of the 3d element
		 */
        function get minY():Number;
		
		/**
		 * Returns the minimum z value of the 3d element
		 */
        function get maxZ():Number;
		
		/**
		 * Returns the maximum z value of the 3d element
		 */
        function get minZ():Number;
		
		/**
		 * Default method for adding a vertexchanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        function addOnVertexChange(listener:Function):void;
		
		/**
		 * Default method for removing a vertexchanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        function removeOnVertexChange(listener:Function):void;
		
		/**
		 * Default method for adding a vertexvaluechanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        function addOnVertexValueChange(listener:Function):void;
		
		/**
		 * Default method for removing a vertexvaluechanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        function removeOnVertexValueChange(listener:Function):void;
		
		/**
		 * Default method for adding a visiblechanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        function addOnVisibleChange(listener:Function):void;
		
		/**
		 * Default method for removing a visiblechanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        function removeOnVisibleChange(listener:Function):void;
    }
}
