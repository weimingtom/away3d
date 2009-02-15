package awaybuilder.events;

import awaybuilder.vo.SceneCameraVO;
import flash.events.Event;


class CameraEvent extends Event  {
	
	static public inline var ANIMATION_START:String = "CameraEvent.ANIMATION_START";
	static public inline var ANIMATION_COMPLETE:String = "CameraEvent.ANIMATION_COMPLETE";
	public var targetCamera:SceneCameraVO;
	

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

