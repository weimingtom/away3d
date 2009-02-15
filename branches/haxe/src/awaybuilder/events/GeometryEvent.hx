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
		
		super(type, bubbles, cancelable);
	}

}

