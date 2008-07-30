package away3d.animators
{
	import away3d.animators.skin.*;
	import away3d.core.utils.*;
	
	import flash.utils.*;
	
	public class SkinAnimation implements IMeshAnimation
    {
        private var _channels:Array;
        
    	/**
    	 * Defines wether the animation will loop
    	 */
		public var loop:Boolean;
		
		/**
		 * Defines the total length of the animation in seconds
		 */
        public var length:Number;
        
		
        public function SkinAnimation()
        {
            Debug.trace(" + SkinAnimation");
			_channels = [];
            loop = true;
            length = 0;
        }
		
		/**
		 * Updates all channels in the animation with the given time in seconds.
		 * 
		 * @param Defines the time in seconds of the playhead of the animation.
		 */
        public function update(time:Number):void
        {
			if (time > length) {
                if (loop) {
                    time = time % length;
                }else{
                    time = length;
                }
            }
            
            for each (var channel:Channel in _channels)
                channel.update(time);
        }
		
		/**
		 * Adds an animation channel to the animation timeline.
		 */
        public function appendChannel(channel:Channel) : void
        {
			_channels.push(channel);
        }
    }
}
