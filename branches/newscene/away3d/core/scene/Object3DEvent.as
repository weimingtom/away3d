package away3d.core.scene
{
    import away3d.core.draw.*;
    import away3d.core.geom.*;
    import away3d.core.render.*;
    import away3d.core.material.*;
    
    import flash.display.Sprite;
    import flash.utils.getTimer;
    import flash.utils.Dictionary;
    import flash.events.MouseEvent;
    import flash.events.Event;
    
    public class Object3DEvent extends Event
    {
        public var object3D:Object3D;

        public function Object3DEvent(type:String, object3D:Object3D)
        {
            super(type);
            this.object3D = object3D;
        }

        public override function clone():Event
        {
            return new Object3DEvent(type, object3D);
        }
    }
}
