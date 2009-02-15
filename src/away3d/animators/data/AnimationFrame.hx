package away3d.animators.data;



// import away3d.core.base.*;
/**
 * Holds information about a single animation frame.
 */
class AnimationFrame  {
	
	/**
	 * Frame number.
	 */
	public var frame:Float;
	/**
	 * Time from the start of the animation.
	 */
	public var time:Int;
	/**
	 * An optional sort string used to order the animation frames.
	 */
	public var sort:String;
	

	/**
	 * Creates a new <code>AnimationFrame</code> object.
	 * 
	 * @param	frame		The number of the frame in it's sequence.
	 * @param	sort		An optional sort string used to order the animation frames.
	 */
	public function new(frame:Float, ?sort:String=null) {
		
		
		this.frame = frame;
		this.sort = sort;
	}

}

