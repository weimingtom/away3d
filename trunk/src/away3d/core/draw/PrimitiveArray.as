package away3d.core.draw
{
    import away3d.core.block.*;
    import away3d.core.clip.*;
    import away3d.core.render.*;

    /**
    * Array for storing drawing primitives.
    */
    public class PrimitiveArray implements IPrimitiveConsumer
    {
        private var _primitives:Array;
        private var _clip:Clipping;
        private var _blockers:Array;
		
		/**
		 * Defines the clipping object to be used on the drawing primitives.
		 */
		public function set clip(val:Clipping):void
		{
			_clip = val;
			_primitives = [];
		}
		
		/**
		 * Defines the array of blocker primitives to be used on the drawing primitives.
		 */
		public function set blockers(val:Array):void
		{
			_blockers = val;
		}
        
		/**
		 * @inheritDoc
		 */
        public function primitive(pri:DrawPrimitive):void
        {
            if (_clip.check(pri))
            {
                var blockercount:int = _blockers.length;
                var i:int = 0;
                while (i < blockercount)
                {          
                    var blocker:Blocker = _blockers[i];
                    if (blocker.screenZ > pri.minZ)
                        break;
                    if (blocker.block(pri))
                        return;
                    i++;
                }
                _primitives.push(pri);
            }
        }
		
		/**
		 * A list of primitives that have been clipped and blocked.
		 * 
		 * @return	An array containing the primitives to be rendered.
		 */
        public function list():Array
        {
            return _primitives;
        }
    }
}
