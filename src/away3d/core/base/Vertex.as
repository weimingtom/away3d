package away3d.core.base
{
    import away3d.animators.skin.SkinVertex;
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;

    /**
    * A vertex coordinate value object.
    * Properties x, y and z represent a 3d point in space.
    */
    public class Vertex extends ValueObject
    {
        use namespace arcane;
        /** @private */
        arcane var _x:Number;
        /** @private */
        arcane var _y:Number;
        /** @private */
        arcane var _z:Number;
        /** @private */
        arcane function transform(m:Matrix3D):void
        {
            setValue(_x * m.sxx + _y * m.sxy + _z * m.sxz + m.tx, _x * m.syx + _y * m.syy + _z * m.syz + m.ty, _x * m.szx + _y * m.szy + _z * m.szz + m.tz);
        }
        /** @private Applies perspective distortion */
        arcane function perspective(focus:Number):ScreenVertex
        {
            _persp = 1 / (1 + _z / focus);

            return new ScreenVertex(_x * _persp, _y * _persp, _z);
        }
        /** @private Sets the vertex coordinates */
        arcane function setValue(x:Number, y:Number, z:Number):void
        {
            _x = _position.x = x;
            _y = _position.y = y;
            _z = _position.z = z;
            notifyChange();
        }
        /** @private Returns the middle-point of two vertices */
        arcane static function median(a:Vertex, b:Vertex):Vertex
        {
            return new Vertex((a._x + b._x)/2, (a._y + b._y)/2, (a._z + b._z)/2);
        }

        /** @private Get the middle-point of two vertices */
        arcane static function distanceSqr(a:Vertex, b:Vertex):Number
        {
            return (a._x + b._x)*(a._x + b._x) + (a._y + b._y)*(a._y + b._y) + (a._z + b._z)*(a._z + b._z);
        }

        /** @private Get the weighted average of two vertices */
        arcane static function weighted(a:Vertex, b:Vertex, aw:Number, bw:Number):Vertex
        {                
            var d:Number = aw + bw;
            var ak:Number = aw / d;
            var bk:Number = bw / d;
            return new Vertex(a._x*ak+b._x*bk, a._y*ak + b._y*bk, a._z*ak + b._z*bk);
        }
		
        private var _position:Number3D = new Number3D();
        private var _persp:Number;
        
    	/**
    	 * Defines the x coordinate of the vertex relative to the local coordinates of the parent mesh object.
    	 */
        public function get x():Number
        {
            return _x;
        }

        public function set x(value:Number):void
        {
            if (value == _x)
                return;

            if (isNaN(value))
                Debug.warning("isNaN(x)");

            if (value == Infinity)
                Debug.warning("x == Infinity");

            if (value == -Infinity)
                Debug.warning("x == -Infinity");

            _x = value;

            notifyChange();
        }
    	
    	/**
    	 * Defines the y coordinate of the vertex relative to the local coordinates of the parent mesh object.
    	 */
        public function get y():Number
        {
            return _y;
        }

        public function set y(value:Number):void
        {
            if (value == _y)
                return;

            if (isNaN(value))
                Debug.warning("isNaN(y)");

            if (value == Infinity)
                Debug.warning("y == Infinity");

            if (value == -Infinity)
                Debug.warning("y == -Infinity");

            _y = value;

            notifyChange();
        }
        
    	/**
    	 * Defines the z coordinate of the vertex relative to the local coordinates of the parent mesh object.
    	 */
        public function get z():Number
        {
            return _z;
        }

        public function set z(value:Number):void
        {
            if (value == _z)
                return;

            if (isNaN(value))
                throw new Error("isNaN(z)");

            if (value == Infinity)
                Debug.warning("z == Infinity");

            if (value == -Infinity)
                Debug.warning("z == -Infinity");

            _z = value;

            notifyChange();
        }
    	
		/**
		 * Creates a new <code>Vertex</code> object.
		 *
		 * @param	x	[optional]	The local x position of the vertex. Defaults to 0.
		 * @param	y	[optional]	The local y position of the vertex. Defaults to 0.
		 * @param	z	[optional]	The local z position of the vertex. Defaults to 0.
		 */
        public function Vertex(x:Number = 0, y:Number = 0, z:Number = 0)
        {
            _x = _position.x = x;
            _y = _position.y = y;
            _z = _position.z = z;
        }
		
		/**
		 * Duplicates the vertex properties to another <code>Vertex</code> object
		 * 
		 * @return	The new vertex instance with duplicated properties applied
		 */
        public function clone():Vertex
        {
            return new Vertex(_x, _y, _z);
        }
        
        /**
        * The vertex position vector
        */
        public function get position():Number3D
        {
        	_position.x = _x;
        	_position.y = _y;
        	_position.z = _z;
            return _position;
        }
        
        public function set position(value:Number3D):void
        {
            _x = _position.x = value.x;
            _y = _position.y = value.y;
            _z = _position.z = value.z;

            notifyChange();
        }
        
        /**
        * An object that contains user defined properties. Defaults to  null.
        */
        public var extra:Object;
		
		/**
		 * Used to trace the values of a vertex object.
		 * 
		 * @return A string representation of the vertex object.
		 */
        public override function toString(): String
        {
            return "new Vertex("+_x+", "+_y+", "+z+")";
        }
    }
}
