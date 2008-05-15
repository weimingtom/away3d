package away3d.events
{
    import away3d.core.base.*;
    
    import flash.events.Event;
    
    public class SegmentEvent extends Event
    {
    	static public var MATERIAL_CHANGED:String = "materialchanged";
    	
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
