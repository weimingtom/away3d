package gs.events;

import flash.events.Event;


class TweenEvent extends Event  {
	
	public static inline var version:Float = 0.9;
	public static inline var START:String = "start";
	public static inline var UPDATE:String = "update";
	public static inline var COMPLETE:String = "complete";
	public var info:Dynamic;
	

	public function new($type:String, ?$info:Dynamic=null, ?$bubbles:Bool=false, ?$cancelable:Bool=false) {
		
		
		super($type, $bubbles, $cancelable);
		this.info = $info;
	}

	public override function clone():Event {
		
		return new TweenEvent(this.type, this.info, this.bubbles, this.cancelable);
	}

}

