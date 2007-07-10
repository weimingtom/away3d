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
    
    public class MeshElementEvent extends Event
    {
        public var element:IMeshElement;

        public function MeshElementEvent(type:String, element:IMeshElement)
        {
            super(type);
            this.element = element;
        }

        public override function clone():Event
        {
            return new MeshElementEvent(type, element);
        }
    }
}
