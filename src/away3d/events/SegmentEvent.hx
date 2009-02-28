package away3d.events;

import flash.events.Event;
import away3d.core.base.Segment;
import away3d.core.base.Element;


/**
 * Passed as a parameter when a segment event occurs
 */
class SegmentEvent extends Event  {
	
	/**
	 * Defines the value of the type property of a materialChanged event object.
	 */
	public static inline var MATERIAL_CHANGED:String = "materialChanged";
	/**
	 * A reference to the segment object that is relevant to the event.
	 */
	public var segment:Segment;
	

	/**
	 * Creates a new <code>SegmentEvent</code> object.
	 * 
	 * @param	type		The type of the event. Possible values are: <code>SegmentEvent.MATERIAL_CHANGED</code>.
	 * @param	segment		A reference to the segment object that is relevant to the event.
	 */
	public function new(type:String, segment:Segment) {
		
		
		super(type);
		this.segment = segment;
	}

	/**
	 * Creates a copy of the SegmentEvent object and sets the value of each property to match that of the original.
	 */
	public override function clone():Event {
		
		return new SegmentEvent(type, segment);
	}

}

