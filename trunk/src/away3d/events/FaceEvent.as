package away3d.events
{
	import away3d.core.base.*;
	
    import flash.events.Event;
    
    public class FaceEvent extends Event
    {
    	static public var MAPPING_CHANGED:String = "mappingchanged";
    	static public var MATERIAL_CHANGED:String = "materialchanged";
    	
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
