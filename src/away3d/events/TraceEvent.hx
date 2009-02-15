package away3d.events;

import flash.events.Event;


class TraceEvent extends Event  {
	
	public var procent:Float;
	/**
	 * Defines the value of the type property of a tracecomplete event object.
	 */
	public static inline var TRACE_COMPLETE:String = "tracecomplete";
	/**
	 * Defines the value of the type property of a traceprogress event object.
	 */
	public static inline var TRACE_PROGRESS:String = "traceprogress";
	

	function new(type:String, ?bubbles:Bool=false, ?cancelable:Bool=false) {
		this.procent = 0;
		
		
		super(type, bubbles, cancelable);
	}

}

