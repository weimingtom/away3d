package awaybuilder.events;

import flash.events.Event;
import awaybuilder.vo.SceneGeometryVO;


class GeometryEvent extends Event  {
	
	static public inline var DOWN:String = "GeometryInteractionEvent.DOWN";
	static public inline var MOVE:String = "GeometryInteractionEvent.MOVE";
	static public inline var OUT:String = "GeometryInteractionEvent.OUT";
	static public inline var OVER:String = "GeometryInteractionEvent.OVER";
	static public inline var UP:String = "GeometryInteractionEvent.UP";
	public var geometry:SceneGeometryVO;
	

	public function new(type:String, ?bubbles:Bool=true, ?cancelable:Bool=false) {
		
		
		super(type, bubbles, cancelable);
	}

}

