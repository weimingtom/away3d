package away3d.core.math;

    /**
    * A Quaternion object.
    */
    public final class Quaternion
     {
    	public var magnitude(getMagnitude, null) : Float
	    ;
    	
    	var w1:Float;
        var w2:Float;
        var x1:Float;
        var x2:Float;
        var y1:Float;
        var y2:Float;
        var z1:Float;
        var z2:Float;
	    var sin_a:Float;
	    var cos_a:Float;
	    var fSinPitch:Float;
        var fCosPitch:Float;
        var fSinYaw:Float;
        var fCosYaw:Float;
        var fSinRoll:Float;
        var fCosRoll:Float;
        var fCosPitchCosYaw:Float;
        var fSinPitchSinYaw:Float;
	    
        
    	/**
    	 * The x value of the quatertion.
    	 */
        public var x:Float;
        
        /**
    	 * The y value of the quatertion.
    	 */
        public var y:Float;
        
        /**
    	 * The z value of the quatertion.
    	 */
        public var z:Float;
        
        /**
    	 * The w value of the quatertion.
    	 */
        public var w:Float;
        
	    /**
	    * Returns the magnitude of the quaternion object.
	    */
	    public function getMagnitude():Float
	    {
	        return(Math.sqrt(w*w + x*x + y*y + z*z));
	    }
	    
        /**
        * Fills the quaternion object with the result from a multipication of two quaternion objects.
        * 
        * @param	qa	The first quaternion in the multipication.
        * @param	qb	The second quaternion in the multipication.
        */
	    public function multiply(qa:Quaternion, qb:Quaternion):Void
	    {
	        w1 = qa.w;  x1 = qa.x;  y1 = qa.y;  z1 = qa.z;
	        w2 = qb.w;  x2 = qb.x;  y2 = qb.y;  z2 = qb.z;
	   
	        w = w1*w2 - x1*x2 - y1*y2 - z1*z2;
	        x = w1*x2 + x1*w2 + y1*z2 - z1*y2;
	        y = w1*y2 + y1*w2 + z1*x2 - x1*z2;
	        z = w1*z2 + z1*w2 + x1*y2 - y1*x2;
	    }
	    
    	/**
    	 * Fills the quaternion object with values representing the given rotation around a vector.
    	 * 
    	 * @param	x		The x value of the rotation vector.
    	 * @param	y		The y value of the rotation vector.
    	 * @param	z		The z value of the rotation vector.
    	 * @param	angle	The angle in radians of the rotation.
    	 */
	    public function axis2quaternion(x:Float, y:Float, z:Float, angle:Float):Void
	    {
	        sin_a = Math.sin(angle / 2);
	        cos_a = Math.cos(angle / 2);
	   
	        this.x = x*sin_a;
	        this.y = y*sin_a;
	        this.z = z*sin_a;
	        w = cos_a;
			normalize();
	    }
	    
    	/**
    	 * Fills the quaternion object with values representing the given euler rotation.
    	 * 
    	 * @param	ax		The angle in radians of the rotation around the x axis.
    	 * @param	ay		The angle in radians of the rotation around the y axis.
    	 * @param	az		The angle in radians of the rotation around the z axis.
    	 */
        public function euler2quaternion(ax:Float, ay:Float, az:Float):Void
        {
            fSinPitch       = Math.sin(ax * 0.5);
            fCosPitch       = Math.cos(ax * 0.5);
            fSinYaw         = Math.sin(ay * 0.5);
            fCosYaw         = Math.cos(ay * 0.5);
            fSinRoll        = Math.sin(az * 0.5);
            fCosRoll        = Math.cos(az * 0.5);
            fCosPitchCosYaw = fCosPitch * fCosYaw;
            fSinPitchSinYaw = fSinPitch * fSinYaw;
    
            x = fSinRoll * fCosPitchCosYaw     - fCosRoll * fSinPitchSinYaw;
            y = fCosRoll * fSinPitch * fCosYaw + fSinRoll * fCosPitch * fSinYaw;
            z = fCosRoll * fCosPitch * fSinYaw - fSinRoll * fSinPitch * fCosYaw;
            w = fCosRoll * fCosPitchCosYaw     + fSinRoll * fSinPitchSinYaw;
        }
        
        /**
        * Normalises the quaternion object.
        */
	    public function normalize(?val:Int = 1):Void
	    {
	        var mag:Int = magnitude*val;
	   
	        x /= mag;
	        y /= mag;
	        z /= mag;
	        w /= mag;
	    }
		
		/**
		 * Used to trace the values of a quaternion.
		 * 
		 * @return A string representation of the quaternion object.
		 */
	    public function toString(): String
        {
            return "{x:" + x + " y:" + y + " z:" + z + " w:" + w + "}";
        }
    }
