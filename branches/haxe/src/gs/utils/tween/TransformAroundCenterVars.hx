package gs.utils.tween;

import flash.geom.Point;


class TransformAroundCenterVars extends TransformAroundPointVars  {
	
	

	public function new(?$scaleX:Float=Math.NaN, ?$scaleY:Float=Math.NaN, ?$rotation:Float=Math.NaN, ?$width:Float=Math.NaN, ?$height:Float=Math.NaN, ?$shortRotation:Dynamic=null, ?$x:Float=Math.NaN, ?$y:Float=Math.NaN) {
		
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
		
		super(null, $scaleX, $scaleY, $rotation, $width, $height, $shortRotation, $x, $y);
	}

	//for parsing values that are passed in as generic Objects, like blurFilter:{blurX:5, blurY:3} (typically via the constructor)
	public static function createFromGeneric($vars:Dynamic):TransformAroundCenterVars {
		
		if (Std.is($vars, TransformAroundCenterVars)) {
			return cast($vars, TransformAroundCenterVars);
		}
		return new TransformAroundCenterVars();
	}

}

