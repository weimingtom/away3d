package gs.events;

import flash.events.Event;


class TweenEvent extends Event  {
	
	public static inline var version:Float = 0.9;
	public static inline var START:String = "start";
	public static inline var UPDATE:String = "update";
	public static inline var COMPLETE:String = "complete";
	public var info:Dynamic;
	

	public function new($type:String, ?$info:Dynamic=null, ?$bubbles:Bool=false, ?$cancelable:Bool=false) {
		
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
		
		super($type, $bubbles, $cancelable);
		this.info = $info;
	}

	public override function clone():Event {
		
		return new TweenEvent(this.type, this.info, this.bubbles, this.cancelable);
	}

}

