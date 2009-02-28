package gs.plugins;



class RoundPropsPlugin extends TweenPlugin  {
	
	public static inline var VERSION:Float = 1.0;
	//If the API/Framework for plugins changes in the future, this number helps determine compatibility
	public static inline var API:Float = 1.0;
	

	public function new() {
		
		
		super();
		this.propName = "roundProps";
		this.overwriteProps = [];
		this.round = true;
	}

	public function add($object:Dynamic, $propName:String, $start:Float, $change:Float):Void {
		
		addTween($object, $propName, $start, $start + $change, $propName);
		this.overwriteProps[this.overwriteProps.length] = $propName;
	}

}

