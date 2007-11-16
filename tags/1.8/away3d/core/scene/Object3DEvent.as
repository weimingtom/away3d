package away3d.core.scene
{
    import away3d.core.draw.*;
    import away3d.core.mesh.*;
    import away3d.core.render.*;
    import away3d.core.material.*;
    
    import flash.display.Sprite;
    import flash.utils.getTimer;
    import flash.utils.Dictionary;
    import flash.events.MouseEvent;
    import flash.events.Event;
    
    public class Object3DEvent extends Event
    {
        public var object:Object3D;

        public function Object3DEvent(type:String, object:Object3D)
        {
            super(type);
            this.object = object;
        }

        public override function clone():Event
        {
            return new Object3DEvent(type, object);
        }
    }
}
