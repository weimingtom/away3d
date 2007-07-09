package away3d.core.scene
{
    import away3d.core.*;

    public class DebugObjectContainer3D extends ObjectContainer3D
    {
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


    }
}
