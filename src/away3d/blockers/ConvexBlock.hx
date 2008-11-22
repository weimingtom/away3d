package away3d.blockers;

    import away3d.containers.*;
    import away3d.core.base.*;
    import away3d.core.block.*;
    import away3d.core.draw.*;
    import away3d.core.project.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;
    
    import flash.utils.*;
    
    /**
    * Convex hull blocking all drawing primitives underneath.
    */
    class ConvexBlock extends Object3D {
        /**
        * Toggles debug mode: blocker is visualised in the scene.
        */
        
        /**
        * Toggles debug mode: blocker is visualised in the scene.
        */
        public var debug:Bool;
        
        /**
        * Verticies to use for calculating the convex hull.
        */
        public var vertices:Array<Dynamic> ;
		
		/**
		 * Creates a new <code>ConvexBlock</code> object.
		 * 
		 * @param	verticies				An Array of vertices to use for calculating the convex hull.
		 * @param	init		[optional]	An initialisation object for specifying default instance properties.
		 */
        public function new(vertices:Array<Dynamic>, ?init:Dynamic = null)
        {
            
            vertices = [];
            super(init);
			
            this.vertices = vertices;
			
            debug = ini.getBoolean("debug", false);
            projector = cast( ini.getObject("projector", IPrimitiveProvider), IPrimitiveProvider);
            
            if (!projector)
            	projector = new ConvexBlockProjector();
        }
    }
