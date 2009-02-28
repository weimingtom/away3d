package nochump.util.zip;

import flash.events.Event;


class ZipErrorEvent extends Event  {
	
	// Event constants
	public static inline var PARSE_ERROR:String = "entryParseError";
	private var err:Int;
	

	public function new(_type:String, ?_bubbles:Bool=false, ?_cancelable:Bool=false, ?_err:Int=0) {
		this.err = 0;
		
		
		super(_type, _bubbles, _cancelable);
		err = _err;
	}

	public override function clone():Event {
		
		return new ZipErrorEvent(type);
	}

}

