package away3d.events
{
    import away3d.core.base.*;
    
    import flash.events.Event;
    
    /**
    * Passed as a parameter when a meshelement event occurs
    */
    public class MeshElementEvent extends Event
    {
    	/**
    	 * Defines the value of the type property of a vertexchanged event object.
    	 */
    	public static const VERTEX_CHANGED:String = "vertexchanged";
    	
    	/**
    	 * Defines the value of the type property of a vertexvaluechanged event object.
    	 */
    	public static const VERTEXVALUE_CHANGED:String = "vertexvaluechanged";
    	
    	/**
    	 * Defines the value of the type property of a visiblechanged event object.
    	 */
    	public static const VISIBLE_CHANGED:String = "visiblechanged";
    	
    	/**
    	 * A reference to the element object that is relevant to the event.
    	 */
        public var element:IMeshElement;
		
		/**
		 * Creates a new <code>MeshElementEvent</code> object.
		 * 
		 * @param	type		The type of the event. Possible values are: <code>MeshElementEvent.VERTEX_CHANGED</code>, <code>MeshElementEvent.VERTEXVALUE_CHANGED</code> and <code>MeshElementEvent.VISIBLE_CHANGED</code>.
		 * @param	element		A reference to the element object that is relevant to the event.
		 */
        public function MeshElementEvent(type:String, element:IMeshElement)
        {
            super(type);
            this.element = element;
        }
		
		/**
		 * Creates a copy of the MeshElementEvent object and sets the value of each property to match that of the original.
		 */
        public override function clone():Event
        {
            return new MeshElementEvent(type, element);
        }
    }
}
