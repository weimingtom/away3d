package away3d.core.geom
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.math.*;

    public class Vertex3D extends Number3D
    {

        // An object that contains user defined properties.
        public var extra:Object;

        private var projected:Vertex2D;
        private var projection:Projection;

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
    
            var sz:Number = vx * view.n31 + vy * view.n32 + vz * view.n33 + view.n34;
    
            if (sz*2 <= -projection.focus)
            {
                projected.visible = false;
                return projected;
            }
            else
                projected.visible = true;

            var persp:Number = projection.zoom / (1 + sz / projection.focus);

            projected.z = sz;
            projected.x = (vx * view.n11 + vy * view.n12 + vz * view.n13 + view.n14) * persp;
            projected.y = (vx * view.n21 + vy * view.n22 + vz * view.n23 + view.n24) * persp;

            return projected;
        }
        
        public function perspective(focus:Number):Vertex2D
        {
            var persp:Number = 1 / (1 + z / focus);

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

        public override function toString(): String
        {
            return "new Vertex3D("+x+', '+y+', '+z+")";
        }

    }
}
