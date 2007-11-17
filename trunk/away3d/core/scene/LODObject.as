package away3d.core.scene
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.utils.*;

    /** Container that is drawn only if its scaling to to perspective fall within given range */ 
    public class LODObject extends ObjectContainer3D implements ILODObject
    {
        public var maxp:Number;
        public var minp:Number;

        public function LODObject(init:Object = null, ...childarray)
        {
            super(init);

            init = Init.parse(init);
            maxp = init.getNumber("maxp", Infinity);
            minp = init.getNumber("minp", 0);

            for each (var child:Object3D in childarray)
                addChild(child);
        }

        public function matchLOD(view:View3D):Boolean
        {
            var z:Number = viewTransform.tz;
            var persp:Number = view.camera.zoom / (1 + z / view.camera.focus);

            if (persp < minp)
                return false;
            if (persp >= maxp)
                return false;

            return true;
        }
    }
}
