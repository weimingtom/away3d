package away3d.haxeutils;

class Error  {
	
	public var message(getMessge, null):String;
	
	private var _message:String;

	public function new(message:String) {
		_message = message;
	}

	private function getMessge():String {
		return _message;
	}

	public function toString():String {
		return "Axay3d error : " + _message;
	}

}





