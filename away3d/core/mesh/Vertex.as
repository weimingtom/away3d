package away3d.core.mesh
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.math.*;
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
            _x = x;
            _y = y;
            _z = z;
        }
    
        /** Duplicate instance */
        public function clone():Vertex
        {
            return new Vertex(_x, _y, _z);
        }
    
        /** @private */
        arcane function transform(m:Matrix3D):void
        {
            set(_x * m.sxx + _y * m.sxy + _z * m.sxz + m.tx, _x * m.syx + _y * m.syy + _z * m.syz + m.ty, _x * m.szx + _y * m.szy + _z * m.szz + m.tz);
        }
        
        /** Vertex position */
        public function get position():Number3D
        {
            return new Number3D(_x, _y, _z);
        }
        
        public function set position(value:Number3D):void
        {
            _x = value.x;
            _y = value.y;
            _z = value.z;

            notifyChange();
        }
        
        /** An object that contains user defined properties. @default null */
        public var extra:Object;

        /** String representation */
        public function toString(): String
        {
            return "new Vertex("+_x+", "+_y+", "+z+")";
        }

        private var projected:ScreenVertex;
        private var projection:Projection;

        /** Project a point to the screen space */
        public function project(projection:Projection):ScreenVertex
        {
            if (this.projection == projection)
                return projected;

            this.projection = projection;

            if (projected == null) 
                projected = new ScreenVertex();

            var vx:Number = x;
            var vy:Number = y;
            var vz:Number = z;

            var view:Matrix3D = projection.view;
    
            var sz:Number = vx * view.szx + vy * view.szy + vz * view.szz + view.tz;
    
            if (isNaN(sz))
                throw new Error("isNaN(sz)");

            if (sz*2 <= -projection.focus)
            {
                projected.visible = false;
                return projected;
            }
            else
                projected.visible = true;

            var persp:Number = projection.zoom / (1 + sz / projection.focus);

            projected.z = sz;
            projected.x = (vx * view.sxx + vy * view.sxy + vz * view.sxz + view.tx) * persp;
            projected.y = (vx * view.syx + vy * view.syy + vz * view.syz + view.ty) * persp;

            return projected;
        }
        
        /** @private Apply perspective distortion */
        arcane function perspective(focus:Number):ScreenVertex
        {
            var persp:Number = 1 / (1 + z / focus);

            return new ScreenVertex(x * persp, y * persp, z);
        }                     

        /** @private Set vertex coordinates */
        arcane function set(x:Number, y:Number, z:Number):void
        {
            _x = x;
            _y = y;
            _z = z;
            notifyChange();
        }

        /** @private Get the middle-point of two vertices */
        arcane static function median(a:Vertex, b:Vertex):Vertex
        {
            return new Vertex((a._x + b._x)/2, (a._y + b._y)/2, (a._z + b._z)/2);
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
