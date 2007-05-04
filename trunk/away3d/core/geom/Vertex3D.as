package away3d.core.geom
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;

    public class Vertex3D
    {
        public var x:Number;
        public var y:Number;
        public var z:Number;

        // An object that contains user defined properties.
        public var extra:Object;

        private var projected:Vertex2D;
        private var projection:Projection;

        public function project(projection:Projection):Vertex2D
        {
            if (this.projection == projection)
                return this.projected;

            this.projection = projection;

            var projected:Vertex2D = this.projected;
            if (projected == null) 
            {           
                this.projected = new Vertex2D();
                projected = this.projected;
            }

            var vx:Number = this.x;
            var vy:Number = this.y;
            var vz:Number = this.z;
    
            var sz:Number = vx * projection.n31 + vy * projection.n32 + vz * projection.n33 + projection.n34;
    
            if (sz*2 <= -projection.focus)
            {
                projected.visible = false;
                return projected;
            }
            else
                projected.visible = true;

            var sx:Number = vx * projection.n11 + vy * projection.n12 + vz * projection.n13 + projection.n14;
            var sy:Number = vx * projection.n21 + vy * projection.n22 + vz * projection.n23 + projection.n24;

            var persp:Number = projection.focus / (projection.focus + sz) * projection.zoom;

            projected.x = sx * persp;
            projected.y = sy * persp;
            projected.z = sz;

            return projected;
        }
        
        public function perspective(focus:Number):Vertex2D
        {
            var persp:Number = focus / (focus + z);

            return new Vertex2D(x * persp, y * persp, z);
        }                     

        public function Vertex3D(x:Number = 0, y:Number = 0, z:Number = 0)
        {
            this.x = x;
            this.y = y;
            this.z = z;
        }

        public function set(x:Number, y:Number, z:Number):void
        {
            this.x = x;
            this.y = y;
            this.z = z;
        }

        public static function median(a:Vertex3D, b:Vertex3D):Vertex3D
        {
            return new Vertex3D((a.x + b.x)/2, (a.y + b.y)/2, (a.z + b.z)/2);
        }

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
