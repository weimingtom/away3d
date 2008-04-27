package away3d.core.block
{
    import away3d.core.render.*;

    /** Array for storing blockers */
    public class BlockerArray implements IBlockerConsumer
    {
        private var _blockers:Array;
        private var _clip:Clipping;
		
		public function set clip(val:Clipping):void
		{
			_clip = val;
			_blockers = [];
		}
		
        public function BlockerArray()
        {
        }

        public function blocker(pri:Blocker):void
        {
            if (_clip.check(pri))
            {
                _blockers.push(pri);
            }
        }
		
		internal var blockers:Array;
		
        public function list():Array
        {
            blockers = _blockers;
            _blockers = null;
            blockers.sortOn("screenZ", Array.NUMERIC);
            return blockers;
        }

    }
}
