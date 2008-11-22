package away3d.core.block;

	import away3d.core.clip.*;
    import away3d.core.render.*;

    /**
    * Array for storing blocker objects
    */
    class BlockerArray implements IBlockerConsumer {
        public var clip(getClip, setClip) : Clipping;
        public function new() {
        _blockers = [];
        }
        
        var _blockers:Array<Dynamic> ;
        var _clip:Clipping;
		
		/**
		 * Determines the viewport clipping to be used on blocker primitives.
		 */
		public function getClip():Clipping{
			return _clip;
		}
		
		public function setClip(val:Clipping):Clipping{
			_clip = val;
			_blockers = [];
			return val;
		}
        
		/**
		 * @inheritDoc
		 */
        public function blocker(pri:Blocker):Void
        {
            if (_clip.check(pri))
            {
                _blockers.push(pri);
            }
        }
		
		/**
		 * Returns a sorted list of blocker primitives for use in <code>BasicRender</code>
		 * 
		 * @see away3d.core.render.BasicRender
		 */
        public function list():Array<Dynamic>
        {
            _blockers.sortOn("screenZ", Array.NUMERIC);
            return _blockers;
        }

    }
