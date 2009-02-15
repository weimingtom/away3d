package away3d.animators.data;



/**
 * Holds information about a sequence of animation frames.
 */
class AnimationSequence  {
	
	/**
	 * The prefix string defining frames in the sequence.
	 */
	public var prefix:String;
	/**
	 * Determines if the animation should be smoothed (interpolated) between frames.
	 */
	public var smooth:Bool;
	/**
	 * Determines whether the animation sequence should loop.
	 */
	public var loop:Bool;
	/**
	 * Determines the speed of playback in frames per second.
	 */
	public var fps:Float;
	

	/**
	 * Creates a new <code>AnimationSequence</code> object.
	 * 
	 * @param	prefix		The prefix string defining frames in the sequence.
	 * @param	smooth		[optional] Determines if the animation should be smoothed (interpolated) between frames. Default = true;
	 * @param	loop			[optional] Determines whether the animation sequence should loop. Default = false;
	 * @param	fps			[optional] Determines the speed of playback in keyframes of per second.  Default = 3;
	 */
	public function new(prefix:String, ?smooth:Bool=true, ?loop:Bool=false, ?fps:Float=3) {
		
		
		this.prefix = (prefix == null) ? "" : prefix;
		this.smooth = smooth;
		this.loop = loop;
		this.fps = fps;
		if (this.prefix == "") {
			trace("Prefix is null, this might cause enter endless loop");
		}
	}

}

