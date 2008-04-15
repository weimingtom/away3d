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
    
    public class SegmentEvent extends Event
    {
        public var segment:Segment;

        public function SegmentEvent(type:String, segment:Segment)
        {
            super(type);
            this.segment = segment;
        }

        public override function clone():Event
        {
            return new SegmentEvent(type, segment);
        }
    }
}
