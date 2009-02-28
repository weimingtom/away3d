package nochump.util.zip;

import flash.events.Event;
import flash.utils.ByteArray;
import nochump.util.zip.ZipEntry;


class ZipEvent extends Event  {
	
	// Event constants
	public static inline var ENTRY_PARSED:String = "entryParsed";
	public var entry:ByteArray;
	

	public function new(_type:String, ?_bubbles:Bool=false, ?_cancelable:Bool=false, ?_entry:ByteArray=null) {
		
		
		super(_type, _bubbles, _cancelable);
		entry = _entry;
	}

	public override function clone():Event {
		
		return new ZipEvent(type);
	}

}

