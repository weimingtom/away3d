package away3d.core.geom
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.math.*;
    import away3d.core.physics.*;

	/** A vertex in 3D space */
    public class Vertex3D extends Particle3D
    {
        /** An object that contains user defined properties. @default null */
        public var extra:Object;
		
        private var projected:Vertex2D;
        private var projection:Projection;
        
        protected var _x:Number;
        protected var _y:Number;
        protected var _z:Number;
		
		// An Number that sets the X coordinate of a vertex relative to the scene coordinate system.
        public function get x():Number
        {
            return _x;
        }
    
        public function set x(value:Number):void
        {
            _x = oldPosition.x = value;
        }
    
        // An Number that sets the Y coordinate of a vertex relative to the scene coordinates.
        public function get y():Number
        {
            return _y;
        }
    
        public function set y(value:Number):void
        {
            _y = oldPosition.y = value;
        }
    
        // An Number that sets the Z coordinate of a vertex relative to the scene coordinates.
        public function get z():Number
        {
            return _z;
        }
    
        public function set z(value:Number):void
        {
            _z = oldPosition.z = value;
        }
        
		/** Project a point to the screen space */
        public function project(projection:Projection):Vertex2D
        {
            if (this.projection == projection)
                return projected;

            this.projection = projection;

            if (projected == null) 
                projected = new Vertex2D();
            
            var view:Matrix3D = projection.view;
    
            var sz:Number = x * view.n31 + y * view.n32 + z * view.n33 + view.n34;
    
            if (sz*2 <= -projection.focus)
            {
                projected.visible = false;
                return projected;
            } else
                projected.visible = true;

            var persp:Number = projection.zoom / (1 + sz / projection.focus);

            projected.z = sz;
            projected.x = (x * view.n11 + y * view.n12 + z * view.n13 + view.n14) * persp;
            projected.y = (x * view.n21 + y * view.n22 + z * view.n23 + view.n24) * persp;

            return projected;
        }
        
		 /** Apply perspective distortion */
        public function perspective(focus:Number):Vertex2D
        {
            var persp:Number = 1 / (1 + z / focus);

            return new Vertex2D(x * persp, y * persp, z);
        }                     
		
		/**  */
        public function Vertex3D(x:Number = 0, y:Number = 0, z:Number = 0)
        {
        	super();
            _x = x;
            _y = y;
            _z = z;
            oldPosition = position;
        }
        
        public override function get position():Number3D
        {
            return new Number3D(x, y, z);
        }
    
        public override function set position(val:Number3D):void
        {
            x = val.x;
            y = val.y;
            z = val.z;
            updateBoundingBox();
        }
        
        public override function get velocity():Number3D
        {
        	return Number3D.sub(position, oldPosition);
        }
        
        public override function set velocity(val:Number3D):void
        {
        	oldPosition = Number3D.sub(position, val);
        }
        
        /** Set vertex coordinates */
        public function set(x:Number, y:Number, z:Number):void
        {
            this.x = x;
            this.y = y;
            this.z = z;
        }
        
        public override function set mass(val:Number):void
		{
			if (val < 0)
				val = 0;
			_mass = val;
			invMass = val? 1/val : 10000;
		}
		
		public override function get mass():Number
		{
			return _mass;
		}
		
		/** Get the middle-point of two vertices */
        public static function median(a:Vertex3D, b:Vertex3D):Vertex3D
        {
            return new Vertex3D((a.x + b.x)/2, (a.y + b.y)/2, (a.z + b.z)/2);
        }
		
		/** Get the weighted average of two vertices */
        public static function weighted(a:Vertex3D, b:Vertex3D, aw:Number, bw:Number):Vertex3D
        {                
            var d:Number = aw + bw;
            var ak:Number = aw / d;
            var bk:Number = bw / d;
            return new Vertex3D(a.x*ak+b.x*bk, a.y*ak + b.y*bk, a.z*ak + b.z*bk);
        }

        public function toString(): String
        {
            return "new Vertex3D("+x+', '+y+', '+z+")";
        }
		
		
    }
}
