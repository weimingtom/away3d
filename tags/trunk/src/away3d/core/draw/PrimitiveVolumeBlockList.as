package away3d.core.draw
{
    import away3d.core.*;
    import away3d.core.base.*
    import away3d.core.render.*;

    import flash.utils.Dictionary;

    /** List of volume blocks for storing drawing primitives */
    public class PrimitiveVolumeBlockList implements IPrimitiveConsumer
    {
        private var blocksdict:Dictionary;
        private var rest:PrimitiveVolumeBlock;
        private var clip:Clipping;

        public function PrimitiveVolumeBlockList(clip:Clipping)
        {
            this.clip = clip;
            blocksdict = new Dictionary();
            rest = new PrimitiveVolumeBlock(null);
        }

        public function primitive(pri:DrawPrimitive):void
        {
            if (clip.check(pri))
            {
                if (pri.source == null)
                    rest.push(pri);
                else
                {
                    var block:PrimitiveVolumeBlock = blocksdict[pri.source];
                    if (block == null)
                    {
                        block = new PrimitiveVolumeBlock(pri.source);
                        blocksdict[pri.source] = block;
                    }
                    block.push(pri);
                }
            }
        }

        public function remove(pri:DrawPrimitive):void
        {
            if (pri.source == null)
                rest.remove(pri);
            else
            {
                var block:PrimitiveVolumeBlock = list[pri.source];
                if (block == null)
                    throw new Error("Can't remove");
                block.remove(pri);
            }
        }

        public function blocks():Array
        {   
            var result:Array = rest.list.length > 0 ? [rest] : [];
            for each (var block:PrimitiveVolumeBlock in blocksdict)
                result.push(block);
            return result;
        }

        public function list():Array
        {   
            var result:Array = [];
            for each (var rpri:DrawPrimitive in rest)
                if (rpri.screenZ != Infinity)
                    result.push(rpri);
            rest = null;

            var blocksdict:Dictionary = this.blocksdict;
            this.blocksdict = null;
            for each (var block:PrimitiveVolumeBlock in blocksdict)
            {
                var list:Array = block.list;
                block.list = null;
                for each (var pri:DrawPrimitive in list)
                    if (pri.screenZ != Infinity)
                        result.push(pri);
                delete blocksdict[block.source];
            }
            return result;
        }

        public function getTouching(target:PrimitiveVolumeBlock):Array
        {   
            var result:Array = [];
            for each (var block:PrimitiveVolumeBlock in blocks)
            {
                if (block.minZ > target.maxZ)
                    continue;
                if (block.maxZ < target.minZ)
                    continue;
                if (block.minX > target.maxX)
                    continue;
                if (block.maxX < target.minX)
                    continue;
                if (block.minY > target.maxY)
                    continue;
                if (block.maxY < target.minY)
                    continue;

                result.push(block);
            }
            return result;
        }
        
    }
}
