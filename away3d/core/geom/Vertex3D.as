package away3d.core.geom
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.math.*;

    /** A vertex in 3D space */
    public class Vertex3D extends Number3D
    {

        /** An object that contains user defined properties. @default null */
        public var extra:Object;

        private var projected:Vertex2D;
        private var projection:Projection;

        /** Project a point to the screen space */
        public function project(projection:Projection):Vertex2D
        {
            if (this.projection == projection)
                return projected;

            this.projection = projection;

            if (projected == null) 
                projected = new Vertex2D();

            var vx:Number = this.x;
            var vy:Number = this.y;
            var vz:Number = this.z;

            var view:Matrix3D = projection.view;
    
            var sz:Number = vx * view.szx + vy * view.szy + vz * view.szz + view.tz;
    
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
        
        /** Apply perspective distortion */
        public function perspective(focus:Number):Vertex2D
        {
            var persp:Number = 1 / (1 + z / focus);

            return new Vertex2D(x * persp, y * persp, z);
        }                     

        /**  */
        public function Vertex3D(x:Number = 0, y:Number = 0, z:Number = 0)
        {
            this.x = x;
            this.y = y;
            this.z = z;
        }

        /** Set vertex coordinates */
        public function set(x:Number, y:Number, z:Number):void
        {
            this.x = x;
            this.y = y;
            this.z = z;
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

        /**  */
        public override function toString(): String
        {
            return "new Vertex3D("+x+', '+y+', '+z+")";
        }

    }
}
