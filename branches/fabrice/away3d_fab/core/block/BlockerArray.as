package away3d.core.block
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;

    import flash.geom.*;

    /** Array for storing blockers */
    public class BlockerArray implements IBlockerConsumer
    {
        private var blockers:Array;
        private var clip:Clipping;

        public function BlockerArray(clip:Clipping)
        {
            this.clip = clip;
            this.blockers = [];
        }

        public function blocker(pri:Blocker):void
        {
            if (clip.check(pri))
            {
                blockers.push(pri);
            }
        }

        public function list():Array
        {
            var blockers:Array = this.blockers;
            this.blockers = null;
            blockers.sortOn("screenZ", Array.NUMERIC);
            return blockers;
        }

    }
}
