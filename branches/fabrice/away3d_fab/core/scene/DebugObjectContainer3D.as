package away3d.core.scene
{
    import away3d.core.*;
    import away3d.core.render.*;
    import away3d.objects.*;

    public class DebugObjectContainer3D extends ObjectContainer3D implements IPrimitiveProvider
    {
        public var debugbb:Boolean = false;
        public var debugbs:Boolean = false;

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

        private var _debugboundingbox:WireCube;
        private var _debugboundingsphere:WireSphere;

        public function primitives(projection:Projection, consumer:IPrimitiveConsumer):void
        {
            if (children.length == 0)
                return;

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
                _debugboundingbox.primitives(projection, consumer);
            }

            if (debugbs)
            {
                _debugboundingsphere = new WireSphere({material:"#cyan", radius:radius, segmentsW:16, segmentsH:12});
                _debugboundingsphere.primitives(projection, consumer);
            }
        }
    }
}
