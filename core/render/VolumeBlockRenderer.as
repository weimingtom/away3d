package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;

    import flash.geom.*;
    import flash.display.*;
    import flash.utils.*;

    public class VolumeBlockRenderer implements IRenderer
    {
        private var vbfilters:Array;
        private var filters:Array;

        public function VolumeBlockRenderer(...params)
        {
            filters = new Array();
            vbfilters = new Array();

            for each (var filter:Object in params)
            {
                if (filter is IPrimitiveFilter)
                    filters.push(filter);
                else
                if (filter is IPrimitiveVolumeBlockFilter)
                {
                    if (filters.length > 0)
                        throw new Error("Quadrant filters should preceed array filters: "+filter);
                    vbfilters.push(filter);
                }
                else
                    throw new Error("Not supported filter type: "+filter);
            }

            filters.push(new ZSortFilter());
        }

        private var info:String;

        public function render(scene:Scene3D, camera:Camera3D, container:Sprite, clip:Clipping):void
        {
            var start:int = getTimer();
            info = "";

            var graphics:Graphics = container.graphics;
            
            var prilist:PrimitiveVolumeBlockList = new PrimitiveVolumeBlockList(clip);
            var pritraverser:PrimitiveTraverser = new PrimitiveTraverser(prilist, camera);

            info += (getTimer() - start) + "ms ";
            start = getTimer();

            scene.traverse(pritraverser);

            info += (getTimer() - start) + "ms ";
            start = getTimer();

            for each (var vbfilter:IPrimitiveVolumeBlockFilter in vbfilters)
                vbfilter.filter(prilist, scene, camera, container, clip);

            info += (getTimer() - start) + "ms ";
            start = getTimer();

            var primitives:Array = prilist.list();

            info += (getTimer() - start) + "ms ";
            start = getTimer();

            if (false)
            {
                for each (var filter:IPrimitiveFilter in filters)
                    primitives = filter.filter(primitives, scene, camera, container, clip);
            }
            else
            {
                primitives.sortOn("screenZ", Array.DESCENDING | Array.NUMERIC);
            }

            info += (getTimer() - start) + "ms ";
            start = getTimer();

            for each (var primitive:DrawPrimitive in primitives)
            {
                primitive.render(graphics);
                primitive.clear();
            }

            info += (getTimer() - start) + "ms ";
            start = getTimer();
        }

        public function desc():String
        {
            return "VolumeBlock ["+vbfilters.concat(filters).join("+")+"]";
        }

        public function stats():String
        {
            return info;
        }

    }
}
