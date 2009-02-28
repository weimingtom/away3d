package gs.utils.tween;



class TweenInfo  {
	
	public var target:Dynamic;
	public var property:String;
	public var start:Float;
	public var change:Float;
	public var name:String;
	public var isPlugin:Bool;
	

	public function new($target:Dynamic, $property:String, $start:Float, $change:Float, $name:String, $isPlugin:Bool) {
		
		
		this.target = $target;
		this.property = $property;
		this.start = $start;
		this.change = $change;
		this.name = $name;
		this.isPlugin = $isPlugin;
	}

}

