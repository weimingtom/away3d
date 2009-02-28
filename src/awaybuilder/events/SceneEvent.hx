package awaybuilder.events;

import flash.events.Event;


class SceneEvent extends Event  {
	
	static public inline var RENDER:String = "SceneEvent.RENDER";
	

	public function new(type:String, ?bubbles:Bool=true, ?cancelable:Bool=false) {
		
		
		super(type, bubbles, cancelable);
	}

}

