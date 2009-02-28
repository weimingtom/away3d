package gs.utils.tween;

import flash.geom.Point;


class TransformAroundCenterVars extends TransformAroundPointVars  {
	
	

	public function new(?$scaleX:Float=Math.NaN, ?$scaleY:Float=Math.NaN, ?$rotation:Float=Math.NaN, ?$width:Float=Math.NaN, ?$height:Float=Math.NaN, ?$shortRotation:Dynamic=null, ?$x:Float=Math.NaN, ?$y:Float=Math.NaN) {
		
		
		super(null, $scaleX, $scaleY, $rotation, $width, $height, $shortRotation, $x, $y);
	}

	//for parsing values that are passed in as generic Objects, like blurFilter:{blurX:5, blurY:3} (typically via the constructor)
	public static function createFromGeneric($vars:Dynamic):TransformAroundCenterVars {
		
		if (Std.is($vars, TransformAroundCenterVars)) {
			return cast($vars, TransformAroundCenterVars);
		}
		return new TransformAroundCenterVars($vars.scaleX, $vars.scaleY, $vars.rotation, $vars.width, $vars.height, $vars.shortRotation, $vars.x, $vars.y);
	}

}

