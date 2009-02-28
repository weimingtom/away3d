package away3d.events;

import flash.events.Event;
import away3d.core.base.Billboard;
import away3d.core.base.Element;


/**
 * Passed as a parameter when a segment event occurs
 */
class BillboardEvent extends Event  {
	
	/**
	 * Defines the value of the type property of a materialChanged event object.
	 */
	public static inline var MATERIAL_CHANGED:String = "materialChanged";
	/**
	 * A reference to the Billboard object that is relevant to the event.
	 */
	public var billboard:Billboard;
	

	/**
	 * Creates a new <code>BillboardEvent</code> object.
	 * 
	 * @param	type		The type of the event. Possible values are: <code>BillboardEvent.MATERIAL_CHANGED</code>.
	 * @param	Billboard	A reference to the Billboard object that is relevant to the event.
	 */
	public function new(type:String, billboard:Billboard) {
		
		
		super(type);
		this.billboard = billboard;
	}

	/**
	 * Creates a copy of the BillboardEvent object and sets the value of each property to match that of the original.
	 */
	public override function clone():Event {
		
		return new BillboardEvent(type, billboard);
	}

}

