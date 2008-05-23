package away3d.core.base
{
    import away3d.core.*;
    import away3d.core.base.*;
	
	/**
	 * Vertex position value object.
	 */
    public class VertexPosition
    {
        use namespace arcane;
        
    	/**
    	 * Defines the x coordinate.
    	 */
        public var x:Number;
        
    	/**
    	 * Defines the y coordinate.
    	 */
        public var y:Number;
        
    	/**
    	 * Defines the z coordinate.
    	 */
        public var z:Number;

        public var vertex:Vertex;
    	
		/**
		 * Creates a new <code>VertexPosition</code> object.
		 *
		 * @param	vertex	The vertex object used to define the default x, y and z values.
		 */
        public function VertexPosition(vertex:Vertex)
        {
            this.vertex = vertex;
            this.x = 0;
            this.y = 0;
            this.z = 0;
        }
        
		/**
		 * Adjusts the position of the vertex object incrementally.
		 * 
		 * @param	k	The fraction by which to adjust the vertex values.
		 */
        public function adjust(k:Number = 1):void
        {
            vertex._x = vertex._x * (1 - k) + x * k;
            vertex._y = vertex._y * (1 - k) + y * k;
            vertex._z = vertex._z * (1 - k) + z * k;
        }
    }
}
