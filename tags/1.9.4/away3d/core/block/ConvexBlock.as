package away3d.core.block
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.mesh.*;
    import away3d.core.render.*;
    import away3d.core.scene.*;
    import away3d.core.utils.*;
    
    import flash.geom.*;
    
    /** Convex object blocking all drawing primitives under it */
    public class ConvexBlock extends Object3D implements IBlockerProvider, IPrimitiveProvider
    {
        use namespace arcane;

        public var debug:Boolean;
        public var vertices:Array = [];
    	
        public function ConvexBlock(vertices:Array, init:Object = null)
        {
            super(init);

            this.vertices = vertices;

            init = Init.parse(init);

            debug = init.getBoolean("debug", false);
        }
    
        public function blockers(consumer:IBlockerConsumer):void
        {
            consumer.blocker(blocker());
        }

        override public function primitives(consumer:IPrimitiveConsumer, session:RenderSession):void
        {
        	super.primitives(consumer, session);
        	
            if (debug)
                consumer.primitive(blocker());
        }

        public function blocker():Blocker
        {
            if (vertices.length < 3)
                return null;

            var points:Array = [];
            var base:ScreenVertex = null;
            var v:ScreenVertex;
            var s:String = "";
            var p:String = "";
            for each (var vr:* /*Vertex*/ in vertices)
            {
                s += vr.toString() + "\n";

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
                p += v.toString() + "\n";
            }

//            throw new Error(s + p);

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
			
			var blkr:ConvexBlocker = new ConvexBlocker(result);
			blkr.source = this;
            return blkr;
        }

        private static function cross(a:ScreenVertex, b:ScreenVertex, c:ScreenVertex):Number
        {
            return (b.x - a.x)*(c.y - a.y) - (c.x - a.x)*(b.y - a.y);
        }
    }
}
