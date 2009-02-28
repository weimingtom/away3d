package gs;

import gs.TweenLite;


class ReverseProxy  {
	
	private var _tween:TweenLite;
	

	public function new($tween:TweenLite) {
		
		
		_tween = $tween;
	}

	public function reverseEase($t:Float, $b:Float, $c:Float, $d:Float):Float {
		
		return _tween.vars.ease($d - $t, $b, $c, $d);
	}

}

