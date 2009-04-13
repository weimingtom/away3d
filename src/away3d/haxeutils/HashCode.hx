package away3d.haxeutils;

class HashCode {
	
	private static var _hashCounter:UInt = 0;
	
	public function new() {
	}

	public static inline function nextHash():UInt {
		return _hashCounter++;
	}


}