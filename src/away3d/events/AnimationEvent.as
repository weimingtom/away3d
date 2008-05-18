package away3d.events
{
    import away3d.core.base.*;
    
    import flash.events.Event;
    
    /**
    * Passed as a parameter when an animation event occurs
    */
    public class AnimationEvent extends Event
    {
    	/**
    	 * Defines the value of the type property of a cycle event object.
    	 */
    	public static const CYCLE:String = "cycle";
    	
    	/**
    	 * Defines the value of the type property of a sequence update event object.
    	 */
    	public static const SQUENCE_UPDATE:String = "squenceupdate";
    	
    	/**
    	 * Defines the value of the type property of a sequence done event object.
    	 */
    	public static const SQUENCE_DONE:String = "squencedone";
    	
    	/**
    	 * A reference to the animation object that is relevant to the event.
    	 */
        public var animation:Animation;
		
		/**
		 * Creates a new <code>AnimationEvent</code> object.
		 * 
		 * @param	type		The type of the event. Possible values are: <code>AnimationEvent.CYCLE</code>, <code>AnimationEvent.SQUENCE_UPDATE</code> and <code>AnimationEvent.SQUENCE_DONE</code>.
		 * @param	animation	A reference to the animation object that is relevant to the event.
		 */
        public function AnimationEvent(type:String, animation:Animation)
        {
            super(type);
            this.animation = animation;
        }
		
		/**
		 * Creates a copy of the AnimationEvent object and sets the value of each property to match that of the original.
		 */
        public override function clone():Event
        {
            return new AnimationEvent(type, animation);
        }
    }
}
