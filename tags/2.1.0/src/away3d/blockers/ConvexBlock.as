package away3d.blockers
{
    import away3d.core.*;
    import away3d.core.base.*;
    import away3d.core.block.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;
    
    /**
    * Convex hull blocking all drawing primitives underneath.
    */
    public class ConvexBlock extends Object3D implements IBlockerProvider, IPrimitiveProvider
    {
    	private var _cb:ConvexBlocker = new ConvexBlocker();
    	
        private function cross(a:ScreenVertex, b:ScreenVertex, c:ScreenVertex):Number
        {
            return (b.x - a.x)*(c.y - a.y) - (c.x - a.x)*(b.y - a.y);
        }
        
        /**
        * Toggles debug mode: blocker is visualised in the scene.
        */
        public var debug:Boolean;
        
        /**
        * Verticies to use for calculating the convex hull.
        */
        public var vertices:Array = [];
		
		/**
		 * Creates a new <code>ConvexBlock</code> object.
		 * 
		 * @param	verticies				An Array of vertices to use for calculating the convex hull.
		 * @param	init		[optional]	An initialisation object for specifying default instance properties.
		 */
        public function ConvexBlock(vertices:Array, init:Object = null)
        {
            super(init);

            this.vertices = vertices;

            debug = ini.getBoolean("debug", false);
            
            _cb.source = this;
        }
        
		/**
		 * @inheritDoc
		 * 
    	 * @see	away3d.core.traverse.BlockerTraverser
    	 * @see	away3d.core.block.Blocker
		 */
        public function blockers(consumer:IBlockerConsumer):void
        {
        	if (vertices.length < 3)
                return;

            var points:Array = [];
            var base:ScreenVertex = null;
            var v:ScreenVertex;
            var s:String = "";
            var p:String = "";
            
            for each (var vr:Vertex in vertices)
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
			
			_cb.vertices = result;
			_cb.calc();
			
            consumer.blocker(_cb);
        }
        
		/**
		 * @inheritDoc
    	 * 
    	 * @see	away3d.core.traverse.PrimitiveTraverser
    	 * @see	away3d.core.draw.DrawPrimitive
		 */
        override public function primitives(consumer:IPrimitiveConsumer, session:AbstractRenderSession):void
        {
        	super.primitives(consumer, session);
        	
            if (debug)
                consumer.primitive(_cb);
        }
    }
}
