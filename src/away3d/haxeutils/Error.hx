package away3d.haxeutils;

class Error  {
	public var message(getMessage, null):String;
	
	private var _message:String;

	public function new(message:String) {
		_message = message;
	}

	public function toString():String {
		return "Axay3d error : " + message;
	}

	public function getMessage():String {
		return _message;
	}

}





