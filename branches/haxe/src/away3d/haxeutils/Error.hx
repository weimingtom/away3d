package away3d.haxeutils;

class Error  {
	
	private var message:String;

	public function new(message:String) {
		this.message = message;
	}

	public function toString():String {
		return "Axay3d error : " + message;
	}

}





