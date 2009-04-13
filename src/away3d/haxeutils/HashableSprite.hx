package away3d.haxeutils;

import flash.display.Sprite;

class HashableSprite extends Sprite, implements IHashable {
	
	public var hashcode(getHashcode, null):UInt;
	
	private var _hashcode:UInt;
	
	public function new() {
		super();
		this._hashcode = HashCode.nextHash();
	}

	private inline function getHashcode():UInt {
		return _hashcode;
	}

}