package away3d.core.proto
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.math.*;

    /** Container that is drawn only if its scaling to to perspective fall within given range */ 
    public class LODObject extends ObjectContainer3D implements ILODObject
    {
        public var maxp:Number;
        public var minp:Number;

        public function LODObject(minp:Number, maxp:Number, init:Object = null, ...childarray)
        {
            super(init);

            this.maxp = maxp;
            this.minp = minp;

            for each (var child:Object3D in childarray)
                addChild(child);
        }

        public function matchLOD(view:View3D, transform:Matrix3D):Boolean
        {
            var proj:Matrix3D = project(transform);
            var z:Number = proj.n34;
            var persp:Number = view.camera.zoom / (1 + z / view.camera.focus);

            if (persp < minp)
                return false;
            if (persp >= maxp)
                return false;

            return true;
        }
    }
}
