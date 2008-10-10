package away3d.events
{
	import away3d.core.base.Shape3D;
	
	import flash.events.Event;
	
	/* Li */
	/**
    * Passed as a parameter when a Shape3D event occurs
    */
	public class ShapeEvent extends Event
	{
		/**
    	 * Defines the value of the type property of a materialChanged event object.
    	 */
    	public static const MATERIAL_CHANGED:String = "materialChanged";
    	
    	/**
    	 * A reference to the Shape3D object that is relevant to the event.
    	 */
        public var shape:Shape3D;
		
		/**
		 * Creates a new <code>ShapeEvent</code> object.
		 * 
		 * @param	type		The type of the event. Possible values are: <code>ShapeEvent.MATERIAL_CHANGED</code>.
		 * @param	shape		A reference to the shape3D object that is relevant to the event.
		 */
		public function ShapeEvent(type:String, shape:Shape3D)
		{
			super(type);
            this.shape = shape;
		}
		
		/**
		 * Creates a copy of the ShapeEvent object and sets the value of each property to match that of the original.
		 */
        public override function clone():Event
        {
            return new ShapeEvent(type, shape);
        }
	}
}