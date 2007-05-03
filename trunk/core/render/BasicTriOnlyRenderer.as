package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import flash.utils.*;
    import flash.geom.*;
    import flash.display.*;

    public class BasicTriOnlyRenderer implements IRenderer
    {
        private var filters:Array;

        public function BasicTriOnlyRenderer(...filters)
        {
            this.filters = filters;
            this.filters.push(new ZSortFilter());
        }

        private var tricount:int;
        private var maxtriarea:Number;
        private var sumtriarea:int;
        private var info:String;

        public function render(scene:Scene3D, camera:Camera3D, container:Sprite, clip:Clipping):void
        {
            var start:int = getTimer();
            info = "";

            var graphics:Graphics = container.graphics;

            var priarray:PrimitiveArray = new PrimitiveArray(clip);
            var pritraverser:PrimitiveTraverser = new PrimitiveTraverser(priarray, camera);

            scene.traverse(pritraverser);

            info += (getTimer() - start) + "ms ";
            start = getTimer();

            var primitives:Array = priarray.list();

            if (true)
            {
                for each (var filter:IPrimitiveFilter in filters)
                    primitives = filter.filter(primitives, scene, camera, container, clip);
            }
            else
            {
                primitives.sortOn("screenZ", Array.DESCENDING | Array.NUMERIC);
            }

            tricount = primitives.length;

            info += (getTimer() - start) + "ms ";
            start = getTimer();

            maxtriarea = 0;
            sumtriarea = 0;

            for each (var primitive:DrawTriangle in primitives)
            {
                sumtriarea += primitive.area;
                if (primitive.area > maxtriarea)
                    maxtriarea = primitive.area;
                primitive.render(graphics);
                        
            }

            info += (getTimer() - start) + "ms ";
            start = getTimer();

        }

        public function desc():String
        {                
            return "TriOnly ["+filters.join("+")+"]";
        }

        public function stats():String
        {
            return tricount+" tris (total-area:"+Math.round(sumtriarea)+"px max-area:"+Math.round(maxtriarea)+"px) ";//+info;
        }
    }
}
