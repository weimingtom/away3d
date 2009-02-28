package nochump.util.zip;

import flash.events.Event;
import flash.utils.ByteArray;
import nochump.util.zip.ZipEntry;


class ZipEvent extends Event  {
	
	// Event constants
	public static inline var ENTRY_PARSED:String = "entryParsed";
	public var entry:ByteArray;
	

	public function new(_type:String, ?_bubbles:Bool=false, ?_cancelable:Bool=false, ?_entry:ByteArray=null) {
		
		OPPOSITE_OR[X | X] = N;
		OPPOSITE_OR[XY | X] = Y;
		OPPOSITE_OR[XZ | X] = Z;
		OPPOSITE_OR[XYZ | X] = YZ;
		OPPOSITE_OR[Y | Y] = N;
		OPPOSITE_OR[XY | Y] = X;
		OPPOSITE_OR[XYZ | Y] = XZ;
		OPPOSITE_OR[YZ | Y] = Z;
		OPPOSITE_OR[Z | Z] = N;
		OPPOSITE_OR[XZ | Z] = X;
		OPPOSITE_OR[XYZ | Z] = XY;
		OPPOSITE_OR[YZ | Z] = Y;
		SCALINGS[1] = [1, 1, 1];
		SCALINGS[2] = [-1, 1, 1];
		SCALINGS[4] = [-1, 1, -1];
		SCALINGS[8] = [1, 1, -1];
		SCALINGS[16] = [1, -1, 1];
		SCALINGS[32] = [-1, -1, 1];
		SCALINGS[64] = [-1, -1, -1];
		SCALINGS[128] = [1, -1, -1];
		
		super(_type, _bubbles, _cancelable);
		entry = _entry;
	}

	public override function clone():Event {
		
		return new ZipEvent(type);
	}

}

