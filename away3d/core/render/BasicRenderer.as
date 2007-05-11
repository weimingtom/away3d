package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import flash.utils.*;
    import flash.geom.*;
    import flash.display.*;

    public class BasicRenderer implements IRenderer
    {
        private var filters:Array;

        public function BasicRenderer(...filters)
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
            var lightarray:LightArray = new LightArray();
            var pritraverser:PrimitiveTraverser = new PrimitiveTraverser(priarray, lightarray, camera);
                
                
            //////////  main traverse for transforms ////////////
            scene.traverse(pritraverser);

            info += (getTimer() - start) + "ms ";
            start = getTimer();

            var primitives:Array = priarray.list();

            for each (var filter:IPrimitiveFilter in filters)
                primitives = filter.filter(primitives, scene, camera, container, clip);

            tricount = primitives.length;

            info += (getTimer() - start) + "ms ";
            start = getTimer();

            
            var session:RenderSession = new RenderSession(scene, camera, container, clip, lightarray);

            //////// render graphics to the scene //////////
            for each (var primitive:DrawPrimitive in primitives)
                primitive.render(session);

            info += (getTimer() - start) + "ms ";
            start = getTimer();

        }

        public function desc():String
        {
            return "Basic ["+filters.join("+")+"]";
        }

        public function stats():String
        {
            return "";
            //return tricount+" triangles "+info;
        }
    }
}
