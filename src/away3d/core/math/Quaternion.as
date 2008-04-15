package away3d.core.math
{
    /** Quaternion */
    public final class Quaternion
    {
        public var x:Number;
        public var y:Number;
        public var z:Number;
        public var w:Number;
        
        internal var w1:Number;
        internal var w2:Number;
        internal var x1:Number;
        internal var x2:Number;
        internal var y1:Number;
        internal var y2:Number;
        internal var z1:Number;
        internal var z2:Number;
        
	    public function multiply(qa:Quaternion, qb:Quaternion):void
	    {
	        w1 = qa.w;  x1 = qa.x;  y1 = qa.y;  z1 = qa.z;
	        w2 = qb.w;  x2 = qb.x;  y2 = qb.y;  z2 = qb.z;
	   
	        w = w1*w2 - x1*x2 - y1*y2 - z1*z2;
	        x = w1*x2 + x1*w2 + y1*z2 - z1*y2;
	        y = w1*y2 + y1*w2 + z1*x2 - x1*z2;
	        z = w1*z2 + z1*w2 + x1*y2 - y1*x2;
	    }
	    
	    internal var sin_a:Number;
	    internal var cos_a:Number;
	    
	    public function axis2quaternion(x:Number, y:Number, z:Number, angle:Number):void
	    {
	        sin_a = Math.sin(angle / 2);
	        cos_a = Math.cos(angle / 2);
	   
	        this.x = x*sin_a;
	        this.y = y*sin_a;
	        this.z = z*sin_a;
	        w = cos_a;
			normalize();
	    }
	    
	    private var fSinPitch      :Number;
        private var fCosPitch      :Number;
        private var fSinYaw        :Number;
        private var fCosYaw        :Number;
        private var fSinRoll       :Number;
        private var fCosRoll       :Number;
        private var fCosPitchCosYaw:Number;
        private var fSinPitchSinYaw:Number;
        
        private var q:Quaternion;
        
        public function euler2quaternion(ax:Number, ay:Number, az:Number):void
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
	        
	    public function get magnitude():Number
	    {
	        return(Math.sqrt(w*w + x*x + y*y + z*z));
	    }
	    
	    public function normalize(val:Number = 1):void
	    {
	        var mag:Number = magnitude*val;
	   
	        x /= mag;
	        y /= mag;
	        z /= mag;
	        w /= mag;
	    }
	    
	    public function toString(): String
        {
            return "{x:" + x + " y:" + y + " z:" + z + " w:" + w + "}";
        }
    }
}