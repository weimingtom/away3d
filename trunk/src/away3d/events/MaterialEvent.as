package away3d.events
{
    import away3d.materials.*;
 
    import flash.events.Event;
    
    public class MaterialEvent extends Event
    {
    	static public var RESIZED:String = "materialresize";
    	
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
