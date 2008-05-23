package away3d.containers
{
    import away3d.core.base.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.primitives.*;
    
    /**
    * Extension of <code>ObjectContainer3D</code> used in debugging.
    * 
    * Gives the option for displaying a bounding box and bounding sphere of the contained object tree.
    * 
    * @see	away3d.containers.ObjectContainer3D
    */
    public class DebugObjectContainer3D extends ObjectContainer3D implements IPrimitiveProvider
    {
        private var _debugboundingbox:WireCube;
        private var _debugboundingsphere:WireSphere;

        /**
        * defines whether a bounding box for the child 3d objects is displayed
        */
        public var debugbb:Boolean = false;
        
        /**
        * defines whether a bounding sphere for the child 3d objects is displayed
        */
        public var debugbs:Boolean = false;
    	
	    /**
	    * Creates a new <code>DebugObjectContainer3D</code> object
	    * 
	    * @param	init			[optional]	An initialisation object for specifying default instance properties
	    * @param	...childarray				An array of children to be added on instatiation
	    */
        public function DebugObjectContainer3D(init:Object = null, ...childarray)
        {
            if (init != null)
                if (init is Object3D)                          
                {
                    addChild(init as Object3D);
                    init = null;
                }

            super(init);

            for each (var child:Object3D in childarray)
                addChild(child);
        }
        
		/**
		 * @inheritDoc
    	 * 
    	 * @see	away3d.core.traverse.PrimitiveTraverser
    	 * @see	away3d.core.draw.DrawPrimitive
		 */
        override public function primitives(consumer:IPrimitiveConsumer, session:AbstractRenderSession):void
        {
            if (children.length == 0)
                return;
			
			super.primitives(consumer, session);
			
            if (debugbb)
            {
                if (_debugboundingbox == null)
                    _debugboundingbox = new WireCube({material:"#cyan|2"});
                _debugboundingbox.v000.x = minX;
                _debugboundingbox.v001.x = minX;
                _debugboundingbox.v010.x = minX;
                _debugboundingbox.v011.x = minX;
                _debugboundingbox.v100.x = maxX;
                _debugboundingbox.v101.x = maxX;
                _debugboundingbox.v110.x = maxX;
                _debugboundingbox.v111.x = maxX;
                _debugboundingbox.v000.y = minY;
                _debugboundingbox.v001.y = minY;
                _debugboundingbox.v010.y = maxY;
                _debugboundingbox.v011.y = maxY;
                _debugboundingbox.v100.y = minY;
                _debugboundingbox.v101.y = minY;
                _debugboundingbox.v110.y = maxY;
                _debugboundingbox.v111.y = maxY;
                _debugboundingbox.v000.z = minZ;
                _debugboundingbox.v001.z = maxZ;
                _debugboundingbox.v010.z = minZ;
                _debugboundingbox.v011.z = maxZ;
                _debugboundingbox.v100.z = minZ;
                _debugboundingbox.v101.z = maxZ;
                _debugboundingbox.v110.z = minZ;
                _debugboundingbox.v111.z = maxZ;
                _debugboundingbox.primitives(consumer, session);
            }

            if (debugbs)
            {
                _debugboundingsphere = new WireSphere({material:"#cyan", boundingRadius:boundingRadius, segmentsW:16, segmentsH:12});
                _debugboundingsphere.primitives(consumer, session);
            }
        }
    }
}
