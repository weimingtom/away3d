package away3d.core.base
{
    import away3d.core.*;
    import away3d.materials.*;
    import away3d.core.math.*;
    import away3d.core.base.*;
    
    import flash.geom.Matrix;
    import flash.events.Event;
    import flash.utils.*;
	
	/**
	 * Holds information about a single animation frame.
	 */
    public class AnimationFrame
    {
    	/**
    	 * A frame object containing the vertex information
    	 */
        public var frame:Frame;
        
        /**
        * Time from the start of the animation
        */
        public var time:uint;
        
        /**
        * An optional sort string used to order the animation frames
        */
        public var sort:String;
    	
		/**
		 * Creates a new <code>AnimationFrame</code> object.
		 * 
		 * @param	frame		The number of the frame in it's sequence.
		 * @param	sort		An optional sort string used to order the animation frames.
		 */
        public function AnimationFrame(frame:Frame, sort:String = null)
        {
            this.frame = frame;
            this.sort = sort;
        }
    }
}
