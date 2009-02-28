package awaybuilder.collada;



class ColladaUtil  {
	
	

	public function new() {
		
		
	}

	public static function removeNamespaces(data:String):Xml {
		
		var exp:EReg = /xmlns=".*?"/g;
		var result:String = data.replace(exp, "");
		var xml:Xml = new XML(result);
		return xml;
	}

}

