package away3d.core.proto
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.render.*;
    import away3d.core.draw.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    
    import flash.geom.*;
    
    /** Node that gets rendered only in one view */
    public class OneViewObject extends ObjectContainer3D implements ILODObject
    {
        public var view:View3D;

        public function OneViewObject(mesh:Mesh3D, init:Object = null)
        {
            super(init);

            init = Init.parse(init);

            addChild(mesh);
        }

        public function matchLOD(view:View3D, transform:Matrix3D):Boolean
        {
            return view == this.view;
        }

    }
}
