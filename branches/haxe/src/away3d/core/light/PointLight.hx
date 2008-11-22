package away3d.core.light;

	import away3d.lights.*;

    /**
    * Point light primitive
    */
    class PointLight extends LightPrimitive {
    	/**
    	 * The x coordinates of the <code>PointLight3D</code> object.
    	 */
        
    	/**
    	 * The x coordinates of the <code>PointLight3D</code> object.
    	 */
        public var x:Float;
        
    	/**
    	 * The y coordinates of the <code>PointLight3D</code> object.
    	 */
        public var y:Float;
        
    	/**
    	 * The z coordinates of the <code>PointLight3D</code> object.
    	 */
        public var z:Float;
        
    	/**
    	 * A reference to the <code>PointLight3D</code> object used by the light primitive.
    	 */
        public var light:PointLight3D;
    }
