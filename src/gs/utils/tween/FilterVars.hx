package gs.utils.tween;



class FilterVars extends SubVars  {
	
	public var remove:Bool;
	public var index:Int;
	public var addFilter:Bool;
	

	public function new(?$remove:Bool=false, ?$index:Int=-1, ?$addFilter:Bool=false) {
		
		
		super();
		this.remove = $remove;
		if ($index > -1) {
			this.index = $index;
		}
		this.addFilter = $addFilter;
	}

}

