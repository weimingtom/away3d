package gs.plugins;

import flash.display.MovieClip;
import gs.TweenLite;


class FrameLabelPlugin extends FramePlugin  {
	
	public static inline var VERSION:Float = 1.0;
	//If the API/Framework for plugins changes in the future, this number helps determine compatibility
	public static inline var API:Float = 1.0;
	

	public function new() {
		
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
		
		super();
		this.propName = "frameLabel";
	}

	override public function onInitTween($target:Dynamic, $value:Dynamic, $tween:TweenLite):Bool {
		
		if (Std.is($tween.target == null, MovieClip)) {
			return false;
		}
		_target = cast($target, MovieClip);
		var labels:Array<Dynamic> = _target.currentLabels;
		var label:String = $value;
		var endFrame:Int = _target.currentFrame;
		var i:Int;
		i = labels.length - 1;
		while (i > -1) {
			if (labels[i].name == label) {
				endFrame = labels[i].frame;
				break;
			}
			
			// update loop variables
			i--;
		}

		if (_target.currentFrame != endFrame) {
			addTween(this, "frame", _target.currentFrame, endFrame, "frame");
		}
		return true;
	}

}

