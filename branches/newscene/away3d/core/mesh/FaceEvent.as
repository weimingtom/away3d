package away3d.core.mesh
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
    
    public class FaceEvent extends Event
    {
        public var face:Face;

        public function FaceEvent(type:String, face:Face)
        {
            super(type);
            this.face = face;
        }

        public override function clone():Event
        {
            return new FaceEvent(type, face);
        }
    }
}
