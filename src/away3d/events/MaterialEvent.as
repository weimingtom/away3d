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
    
    public class MaterialEvent extends Event
    {
        public var material:IMaterial;

        public function MaterialEvent(type:String, material:IMaterial)
        {
            super(type);
            this.material = material;
        }

        public override function clone():Event
        {
            return new MaterialEvent(type, material);
        }
    }
}
