package away3d.core.base
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;

    /** A vertex in the 3D space */
    public class Vertex extends ValueObject
    {
        use namespace arcane;

        /** @private */
        arcane var _x:Number;
        /** @private */
        arcane var _y:Number;
        /** @private */
        arcane var _z:Number;
    
        /** Horizontal coordinate */ 
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
    
        /** Vertical coordinate */
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
    
        /** Depth coordinate */
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
    
        /** Create a new vertex */
        public function Vertex(x:Number = 0, y:Number = 0, z:Number = 0)
        {
            _x = _position.x = x;
            _y = _position.y = y;
            _z = _position.z = z;

            //if (defaultExtraClass != null)
            //    extra = new defaultExtraClass(this);
        }
    
        /** Duplicate instance */
        public function clone():Vertex
        {
            return new Vertex(_x, _y, _z);
        }
    
        /** @private */
        arcane function transform(m:Matrix3D):void
        {
            setValue(_x * m.sxx + _y * m.sxy + _z * m.sxz + m.tx, _x * m.syx + _y * m.syy + _z * m.syz + m.ty, _x * m.szx + _y * m.szy + _z * m.szz + m.tz);
        }
        
        private var _position:Number3D = new Number3D();
        
        /** Vertex position */
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
        
        /** An object that contains user defined properties. @default null */
        public var extra:Object;

        //public static var defaultExtraClass:Class;

        /** String representation */
        public function toString(): String
        {
            return "new Vertex("+_x+", "+_y+", "+z+")";
        }

        private var projected:ScreenVertex = new ScreenVertex();
        private var projectionTime:int;
		private var view:Matrix3D;
		private var sz:Number;
		private var persp:Number;
		
        /** Project a point to the screen space */
        public function project(projection:Projection):ScreenVertex
        {
        	//check if current projection has been already applied
            if (projectionTime == projection.time)
                return projected;
			
			//update projection time
            projectionTime = projection.time;
			
            view = projection.view;
    
            sz = _x * view.szx + _y * view.szy + _z * view.szz + view.tz;
    		/*/
    		//modified
    		var wx:Number = x * view.sxx + y * view.sxy + z * view.sxz + view.tx;
    		var wy:Number = x * view.syx + y * view.syy + z * view.syz + view.ty;
    		var wz:Number = x * view.szx + y * view.szy + z * view.szz + view.tz;
			var wx2:Number = Math.pow(wx, 2);
			var wy2:Number = Math.pow(wy, 2);
    		var c:Number = Math.sqrt(wx2 + wy2 + wz*wz);
			var c2:Number = (wx2 + wy2);
			persp = c2? projection.focus*(c - wz)/c2 : 0;
			sz = (c != 0 && wz != -c)? c*Math.sqrt(0.5 + 0.5*wz/c) : 0;
			//*/
    		//end modified
    		
            if (isNaN(sz))
                throw new Error("isNaN(sz)");

            if (sz*2 <= -projection.focus)
            {
                projected.visible = false;
                return projected;
            }
            else
                projected.visible = true;

         	persp = projection.zoom / (1 + sz / projection.focus);

            projected.x = (_x * view.sxx + _y * view.sxy + _z * view.sxz + view.tx) * persp;
            projected.y = (_x * view.syx + _y * view.syy + _z * view.syz + view.ty) * persp;
            projected.z = sz;
            /*
            projected.x = wx * persp;
            projected.y = wy * persp;
			*/				
            return projected;
        }
        
        /** @private Apply perspective distortion */
        arcane function perspective(focus:Number):ScreenVertex
        {
            persp = 1 / (1 + _z / focus);

            return new ScreenVertex(_x * persp, _y * persp, z);
        }                     

        /** @private Set vertex coordinates */
        arcane function setValue(x:Number, y:Number, z:Number):void
        {
            _x = _position.x = x;
            _y = _position.y = y;
            _z = _position.z = z;
            notifyChange();
        }

        /** @private Get the middle-point of two vertices */
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
    }
}
