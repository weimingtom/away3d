package away3d.haxeutils;

class Hashable implements IHashable {
	
	public var hashcode(getHashcode, null):UInt;
	
	private var _hashcode:UInt;
	
	public function new() {
		this._hashcode = HashCode.nextHash();
	}

	private inline function getHashcode():UInt {
		return _hashcode;
	}

}