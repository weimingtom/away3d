package away3d.events;

import away3d.core.base.Animation;
import flash.events.Event;
import flash.events.EventDispatcher;


/**
 * Passed as a parameter when an animation event occurs
 */
class AnimationEvent extends Event  {
	
	/**
	 * Defines the value of the type property of a cycle event object.
	 */
	public static inline var CYCLE:String = "cycle";
	/**
	 * Defines the value of the type property of a sequenceUpdate event object.
	 */
	public static inline var SEQUENCE_UPDATE:String = "sequenceUpdate";
	/**
	 * Defines the value of the type property of a sequenceDone event object.
	 */
	public static inline var SEQUENCE_DONE:String = "sequenceDone";
	/**
	 * A reference to the animation object that is relevant to the event.
	 */
	public var animation:Animation;
	

	/**
	 * Creates a new <code>AnimationEvent</code> object.
	 * 
	 * @param	type		The type of the event. Possible values are: <code>AnimationEvent.CYCLE</code>, <code>AnimationEvent.SEQUENCE_UPDATE</code> and <code>AnimationEvent.SEQUENCE_DONE</code>.
	 * @param	animation	A reference to the animation object that is relevant to the event.
	 */
	public function new(type:String, animation:Animation) {
		
		
		super(type);
		this.animation = animation;
	}

	/**
	 * Creates a copy of the AnimationEvent object and sets the value of each property to match that of the original.
	 */
	public override function clone():Event {
		
		return new AnimationEvent();
	}

}

