package away3d.events;

import flash.events.Event;
import away3d.core.base.Face;
import away3d.core.base.Element;


/**
 * Passed as a parameter when a face event occurs
 */
class FaceEvent extends Event  {
	
	/**
	 * Defines the value of the type property of a mappingChanged event object.
	 */
	public static inline var MAPPING_CHANGED:String = "mappingChanged";
	/**
	 * A reference to the face object that is relevant to the event.
	 */
	public var face:Face;
	

	/**
	 * Creates a new <code>FaceEvent</code> object.
	 * 
	 * @param	type	The type of the event. Possible values are: <code>FaceEvent.MAPPING_CHANGED</code> and <code>FaceEvent.MATERIAL_CHANGED</code>.
	 * @param	face	A reference to the face object that is relevant to the event.
	 */
	public function new(type:String, face:Face) {
		
		
		super(type);
		this.face = face;
	}

	/**
	 * Creates a copy of the FaceEvent object and sets the value of each property to match that of the original.
	 */
	public override function clone():Event {
		
		return new FaceEvent(type, face);
	}

}

