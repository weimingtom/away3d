package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.block.*;
    import away3d.core.draw.*;
    import away3d.core.scene.*;

    /** Array for storing drawing primitives */
    public class PrimitiveArray implements IPrimitiveConsumer
    {
        private var primitives:Array = [];
        private var materials:Array = [];
		private var containers:Array = [];
		
        private var _clip:Clipping;
        private var _blockers:Array;
		
		public function set clip(val:Clipping):void
		{
			_clip = val;
			primitives = [];
		}
		public function set blockers(val:Array):void
		{
			_blockers = val;
		}
		
        public function PrimitiveArray()
        {
        }

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
                primitives.push(pri);
            }
        }
		
        public function list():Array
        {
            var primitives:Array = this.primitives;
            this.primitives = null;
            return primitives;
        }
    }
}
