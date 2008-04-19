package away3d.events
{
    import away3d.core.draw.*;
    import away3d.core.base.*;
    import away3d.core.render.*;
    import away3d.materials.*;
    
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
