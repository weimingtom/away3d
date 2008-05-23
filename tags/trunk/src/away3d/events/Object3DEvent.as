package away3d.events
{
    import away3d.core.base.*;

    import flash.events.Event;
    
    /**
    * Passed as a parameter when a 3d object event occurs
    */
    public class Object3DEvent extends Event
    {
    	/**
    	 * Defines the value of the type property of a transformchanged event object.
    	 */
    	public static const TRANSFORM_CHANGED:String = "transformchanged";
    	
    	/**
    	 * Defines the value of the type property of a scenetransformchanged event object.
    	 */
    	public static const SCENETRANSFORM_CHANGED:String = "scenetransformchanged";
    	
    	/**
    	 * Defines the value of the type property of a scenechanged event object.
    	 */
    	public static const SCENE_CHANGED:String = "scenechanged";
    	
    	/**
    	 * Defines the value of the type property of a radiuschanged event object.
    	 */
    	public static const RADIUS_CHANGED:String = "radiuschanged";
    	
    	/**
    	 * Defines the value of the type property of a dimensionschanged event object.
    	 */
    	public static const DIMENSIONS_CHANGED:String = "dimensionschanged";
    	
    	/**
    	 * A reference to the 3d object that is relevant to the event.
    	 */
        public var object:Object3D;
		
		/**
		 * Creates a new <code>MaterialEvent</code> object.
		 * 
		 * @param	type		The type of the event. Possible values are: <code>Object3DEvent.TRANSFORM_CHANGED</code>, <code>Object3DEvent.SCENETRANSFORM_CHANGED</code>, <code>Object3DEvent.SCENE_CHANGED</code>, <code>Object3DEvent.RADIUS_CHANGED</code> and <code>Object3DEvent.DIMENSIONS_CHANGED</code>.
		 * @param	object		A reference to the 3d object that is relevant to the event.
		 */
        public function Object3DEvent(type:String, object:Object3D)
        {
            super(type);
            this.object = object;
        }
		
		/**
		 * Creates a copy of the Object3DEvent object and sets the value of each property to match that of the original.
		 */
        public override function clone():Event
        {
            return new Object3DEvent(type, object);
        }
    }
}
