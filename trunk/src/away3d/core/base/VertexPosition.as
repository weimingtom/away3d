package away3d.core.base
{
    import away3d.core.*;
    import away3d.core.math.*;
	
	/**
	 * Vertex position value object.
	 */
    public class VertexPosition
    {
        use namespace arcane;
		
		private var vx:Number;
		private var vy:Number;
		private var vz:Number;
		
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
		
		/**
		 * Adjusts the position of the vertex object by Number3D.
		 *
		 * @param	value	Amount to add in Number3D format.
		 */
        public function add(value:Number3D):void
        {
			vertex._x += value.x;
			vertex._y += value.y;
			vertex._z += value.z;
        }
		
		/**
		 * Transforms the position of the vertex object by the given 3d matrix.
		 *
		 * @param	m	The 3d matrix to use.
		 */
        public function transform(m:Matrix3D):void
        {
        	vx = vertex._x;
        	vy = vertex._y;
        	vz = vertex._z;
        	
            vertex._x = vx * m.sxx + vy * m.sxy + vz * m.sxz + m.tx;
            vertex._y = vx * m.syx + vy * m.syy + vz * m.syz + m.ty;
            vertex._z = vx * m.szx + vy * m.szy + vz * m.szz + m.tz;
        }
        		
		/**
		 * Reset the position of the vertex object by Number3D.
		 */
        public function reset():void
        {
			vertex._x = 0;
			vertex._y = 0;
			vertex._z = 0;
        }
    }
}
