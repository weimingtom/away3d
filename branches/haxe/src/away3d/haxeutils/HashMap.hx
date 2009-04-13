package away3d.haxeutils;

import flash.utils.Dictionary;

class HashMap<K:IHashable, V> extends Hashable {

	private var _keys:Dictionary;
	private var _values:Dictionary;
	
	public function new() {
		super();
		_keys = new Dictionary();
		_values = new Dictionary();
	}

	public inline function get(key:K):V {
		return untyped _values[key.hashcode];
	}
	
	public inline function put(key:K, value:V):V {
		untyped _values[key.hashcode] = value;
		untyped _keys[key.hashcode] = key;
		
		return value;
	}
	
	public inline function remove(key:K):Void {
		untyped __delete__(_keys, key.hashcode);
		untyped __delete__(_values, key.hashcode);
	}
	
	public inline function contains(key:K):Bool {
		return untyped _keys.hasOwnProperty(key.hashcode);
	}
	
	public inline function clear():Void {
		_keys = new Dictionary();
		_values = new Dictionary();
	}
	
	private inline function baseKeys():Iterator<UInt> {
		return untyped (__keys__(_keys)).iterator();
	}
	
	public function keys():Iterator<K> {
		return untyped {
			keys:_keys,
			it:baseKeys(),
			hasNext : function() { return this.it.hasNext(); },
			next : function() { var i:UInt = this.it.next(); return this.keys[i]; }
		};		
	}
	
	public function iterator():Iterator<V> {
		return untyped {
			values:_values,
			it:baseKeys(),
			hasNext : function() { return this.it.hasNext(); },
			next : function() { var i:UInt = this.it.next(); return this.values[i]; }
		};
	}

}