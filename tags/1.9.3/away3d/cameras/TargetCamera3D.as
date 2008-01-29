package away3d.cameras
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.utils.*;

    /** Camera that targets an object */
    public class TargetCamera3D extends Camera3D
    {
        /** Object the camera always targets */
        public var target:Object3D;

        public function TargetCamera3D(init:Object = null)
        {
            super(init);
    
            init = Init.parse(init);

            target = init.getObject3D("target") || new Object3D();
        }

        public override function get view():Matrix3D
        {
            if (target != null)
                lookAt(target.scene ? target.scenePosition : target.position);
    
            return super.view;
        }

        public override function set parent(value:ObjectContainer3D):void
        {
            if (value != null)
                throw new Error("TargetCamera can't be parented");
        }

    }

}   
