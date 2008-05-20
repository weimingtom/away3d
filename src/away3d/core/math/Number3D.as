package away3d.core.math
{
    /**
    * A point in 3D space.
    */
    public final class Number3D
    {
    	private var mod:Number;
        private var dist:Number;
        private var num:Number3D;
        
        /**
        * The horizontal coordinate of the 3d number object.
        */ 
        public var x:Number;
    
        /**
        * The vertical coordinate of the 3d number object.
        */ 
        public var y:Number;
    
        /**
        * The depth coordinate of the 3d number object.
        */ 
        public var z:Number;
    	
    	/**
    	 * The modulo of the 3d number object.
    	 */
        public function get modulo():Number
        {
            return Math.sqrt(x*x + y*y + z*z);
        }
    	
    	/**
    	 * The squared modulo of the 3d number object.
    	 */
        public function get modulo2():Number
        {
            return x*x + y*y + z*z;
        }
        
		/**
		 * Creates a new <code>Number3D</code> object.
		 *
		 * @param	x	[optional]	A default value for the horizontal coordinate of the 3d number object. Defaults to 0.
		 * @param	y	[optional]	A default value for the vertical coordinate of the 3d number object. Defaults to 0.
		 * @param	z	[optional]	A default value for the depth coordinate of the 3d number object. Defaults to 0.
		 * @param	n	[optional]	Determines of the resulting 3d number object should be normalised. Defaults to false.
		 */
        public function Number3D(x:Number = 0, y:Number = 0, z:Number = 0, n:Boolean = false)
        {
            this.x = x;
            this.y = y;
            this.z = z;
            
            if (n)
            	normalize();
        }
		
		/**
		 * Duplicates the 3d number's properties to another <code>Number3D</code> object
		 * 
		 * @return	The new 3d number instance with duplicated properties applied
		 */
        public function clone():Number3D
        {
            return new Number3D(x, y, z);
        }
		
    	/**
    	 * Fills the 3d number object with scaled values from the given 3d number.
    	 * 
    	 * @param	v	The 3d number object used for the scaling calculation.
    	 * @param	s	The scaling value.
    	 */
        public function scale(v:Number3D, s:Number):void
        {
            x = v.x * s;
            y = v.y * s;
            z = v.z * s;
        }  
		
    	/**
    	 * Fills the 3d number object with the result from an addition of two 3d numbers.
    	 * 
    	 * @param	v	The first 3d number in the addition.
    	 * @param	w	The second 3d number in the addition.
    	 */
        public function add(v:Number3D, w:Number3D):void
        {
            x = v.x + w.x;
            y = v.y + w.y;
            z = v.z + w.z;
        }
		
    	/**
    	 * Fills the 3d number object with the result from a subtraction of two 3d numbers.
    	 * 
    	 * @param	v	The starting 3d number in the subtraction.
    	 * @param	w	The subtracting 3d number in the subtraction.
    	 */
        public function sub(v:Number3D, w:Number3D):void
        {
            x = v.x - w.x;
            y = v.y - w.y;
            z = v.z - w.z;
        }
    	
    	/**
    	 * Calculates the distance from the 3d number object to the given 3d number.
    	 * 
    	 * @param	w	The 3d number object whose distance is calculated.
    	 */
        public function distance(w:Number3D):Number
        {
            return Math.sqrt((x - w.x)*(x - w.x) + (y - w.y)*(y - w.y) + (z - w.z)*(z - w.z));
        }
    	
    	/**
    	 * Calculates the dot product of the 3d number object with the given 3d number.
    	 * 
    	 * @param	w	The 3d number object to use in the calculation.
    	 * @return		The dot product result.
    	 */
        public function dot(w:Number3D):Number
        {
            return (x * w.x + y * w.y + z * w.z);
        }
		
    	/**
    	 * Fills the 3d number object with the result from an cross product of two 3d numbers.
    	 * 
    	 * @param	v	The first 3d number in the cross product calculation.
    	 * @param	w	The second 3d number in the cross product calculation.
    	 */
        public function cross(v:Number3D, w:Number3D):void
        {
        	if (this == v || this == w)
        		throw new Error("resultant cross product cannot be the same instance as an input");
        	x = w.y * v.z - w.z * v.y;
        	y = w.z * v.x - w.x * v.z;
        	z = w.x * v.y - w.y * v.x;
        }
    	
    	/**
    	 * Returns the angle in radians made between the 3d number obejct and the given 3d number.
    	 * 
    	 * @param	w	[optional]	The 3d number object to use in the calculation.
    	 * @return					An angle in radians representing the angle between the two 3d number objects. 
    	 */
        public function getAngle(w:Number3D = null):Number
        {
            if (w == null)
            	w = new Number3D();
            return Math.acos(dot(w)/(modulo*w.modulo));
        }
        
        /**
        * Normalises the 3d number object.
        * @param	val	[optional]	A normalisation coefficient representing the length of the resulting 3d number object. Defaults to 1.
        */
        public function normalize(val:Number = 1):void
        {
            mod = modulo/val;
    
            if (mod != 0 && mod != 1)
            {
                x /= mod;
                y /= mod;
                z /= mod;
            }
        }
    	
    	/**
    	 * Fills the 3d number object with the result of a 3d matrix rotation performed on a 3d number.
    	 * 
    	 * @param	The 3d number object to use in the calculation.
    	 * @param	The 3d matrix object representing the rotation.
    	 */
        public function rotate(v:Number3D, m:Matrix3D):void
        {
            x = v.x * m.sxx + v.y * m.sxy + v.z * m.sxz;
            y = v.x * m.syx + v.y * m.syy + v.z * m.syz;
            z = v.x * m.szx + v.y * m.szy + v.z * m.szz;
        }
    	
    	/**
    	 * Fills the 3d number object with the result of a 3d matrix tranformation performed on a 3d number.
    	 * 
    	 * @param	The 3d number object to use in the calculation.
    	 * @param	The 3d matrix object representing the tranformation.
    	 */
        public function transform(v:Number3D, m:Matrix3D):void
        {
            x = v.x * m.sxx + v.y * m.sxy + v.z * m.sxz + m.tx;
            y = v.x * m.syx + v.y * m.syy + v.z * m.syz + m.ty;
            z = v.x * m.szx + v.y * m.szy + v.z * m.szz + m.tz;
        }
        
        /**
        * A 3d number object representing a relative direction forward.
        */
        public static var FORWARD :Number3D = new Number3D( 0,  0,  1);
        
        /**
        * A 3d number object representing a relative direction backward.
        */
        public static var BACKWARD:Number3D = new Number3D( 0,  0, -1);
        
        /**
        * A 3d number object representing a relative direction left.
        */
        public static var LEFT    :Number3D = new Number3D(-1,  0,  0);
        
        /**
        * A 3d number object representing a relative direction right.
        */
        public static var RIGHT   :Number3D = new Number3D( 1,  0,  0);
        
        /**
        * A 3d number object representing a relative direction up.
        */
        public static var UP      :Number3D = new Number3D( 0,  1,  0);
        
        /**
        * A 3d number object representing a relative direction down.
        */
        public static var DOWN    :Number3D = new Number3D( 0, -1,  0);
        
        /**
        * Calculates a 3d number object representing the closest point on a given plane to a given 3d point.
        * 
        * @param	p	The 3d point used in teh calculation.
        * @param	k	The plane offset used in the calculation.
        * @param	n	The plane normal used in the calculation.
        * @return		The resulting 3d point.
        */
        public function closestPointOnPlane(p:Number3D, k:Number3D, n:Number3D):Number3D
        {
        	if (!num)
        		num = new Number3D();
        	
        	num.sub(p, k);
            dist = n.dot(num);
            num.scale(n, dist);
            num.sub(p, num);
            return num;
        }
		
		/**
		 * Used to trace the values of a 3d number.
		 * 
		 * @return A string representation of the 3d number object.
		 */
        public function toString(): String
        {
            return 'x:' + x + ' y:' + y + ' z:' + z;
        }
    }
}