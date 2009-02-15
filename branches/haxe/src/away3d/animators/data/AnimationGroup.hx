package away3d.animators.data;



/**
 * Holds information about a list of animation sequences.
 */
class AnimationGroup  {
	
	/**
	 * An array of animation sequence objects.
	 */
	public var playlist:Array<Dynamic>;
	/**
	 * Determines if the last animation sequence should be looped.
	 */
	public var loopLast:Bool;
	/**
	 * Determines whether the animation sequence should loop.
	 */
	public var loop:Bool;
	/**
	 * Determines the speed of playback in frames per second.
	 */
	public var fps:Int;
	

	/**
	 * Creates a new <code>AnimationSequence</code> object.
	 * 
	 * @param	playlist		An array of animation sequence objects.
	 * @param	loopLast		Determines if the last animation sequence should be looped.
	 */
	public function new(?playlist:Array<Dynamic>=null, ?loopLast:Bool=false) {
		
		
		this.playlist = playlist;
		this.loopLast = loopLast;
	}

}

