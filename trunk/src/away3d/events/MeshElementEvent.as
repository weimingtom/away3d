package away3d.events
{
    import away3d.core.base.*;
    
    import flash.events.Event;
    
    public class MeshElementEvent extends Event
    {
    	static public var VERTEX_CHANGED:String = "vertexchanged";
    	static public var VERTEXVALUE_CHANGED:String = "vertexvaluechanged";
    	static public var VISIBLE_CHANGED:String = "visiblechanged";
    	
    	
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
