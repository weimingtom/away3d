package away3d.core.geom
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.render.*;
    import away3d.core.draw.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.block.*;
    
    import flash.geom.*;
    
    /** Convex object blocking all drawing primitives under it */
    public class ConvexBlock extends Vertices3D implements IBlockerProvider, IPrimitiveProvider
    {
        public var debug:Boolean;
    
        public function ConvexBlock(vertices:Array, init:Object = null)
        {
            super(init);

            this.vertices = vertices;

            init = Init.parse(init);

            debug = init.getBoolean("debug", false);
        }
    
        public function blockers(projection:Projection, consumer:IBlockerConsumer):void
        {
            consumer.blocker(blocker(projection));
        }

        public function primitives(projection:Projection, consumer:IPrimitiveConsumer):void
        {
            if (debug)
                consumer.primitive(blocker(projection));
        }

        public function blocker(projection:Projection):Blocker
        {
            if (vertices.length < 3)
                return null;

            var points:Array = [];
            var base:Vertex2D = null;
            var v:Vertex2D;
            for each (var vr:Vertex3D in vertices)
            {
                v = vr.project(projection);

                if (base == null)
                    base = v;
                else
                if (base.y > v.y)
                    base = v;
                else
                if (base.y == v.y)
                    if (base.x > v.x)
                        base = v;

                points.push(v);
            }

            for each (v in points)
                v.num = (v.x - base.x) / (v.y - base.y);
            base.num = -Infinity;

            points.sortOn("num", Array.NUMERIC);
            
            var result:Array = [points[0], points[1]];
            var o:Number;

            for (var i:int = 2; i < points.length; i++)
            {
                o = cross(result[result.length-2], result[result.length-1], points[i]);
                while (o > 0)
                {
                    result.pop();
                    if (result.length == 2)
                        break;
                    o = cross(result[result.length-2], result[result.length-1], points[i]);
                }
                result.push(points[i]);
            }
            o = cross(result[result.length-2], result[result.length-1], result[0]);
            if (o > 0)
                result.pop();

            return new ConvexBlocker(result);
        }

        private static function cross(a:Vertex2D, b:Vertex2D, c:Vertex2D):Number
        {
            return (b.x - a.x)*(c.y - a.y) - (c.x - a.x)*(b.y - a.y);
        }
    }
}
