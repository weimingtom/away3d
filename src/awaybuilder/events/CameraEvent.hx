package awaybuilder.events;

import awaybuilder.vo.SceneCameraVO;
import flash.events.Event;


class CameraEvent extends Event  {
	
	static public inline var ANIMATION_START:String = "CameraEvent.ANIMATION_START";
	static public inline var ANIMATION_COMPLETE:String = "CameraEvent.ANIMATION_COMPLETE";
	public var targetCamera:SceneCameraVO;
	

	public function new(type:String, ?bubbles:Bool=true, ?cancelable:Bool=false) {
		
		
		super(type, bubbles, cancelable);
	}

}

