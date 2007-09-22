package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;
	import away3d.core.stats.*;
	
    import flash.geom.*;
    import flash.display.*;

    /** Renderer that uses quadrant tree for storing and operating drawing primitives. Quadrant tree speeds up all proximity based calculations. */
    public class QuadrantRenderer implements IRenderer
    {
        private var qdrntfilters:Array;

        public function QuadrantRenderer(...params)
        {
            qdrntfilters = [];

            for each (var filter:IPrimitiveQuadrantFilter in params)
                qdrntfilters.push(filter);
        }

        public function render(view:View3D):void
        {
            var scene:Scene3D = view.scene;
            var camera:Camera3D = view.camera;
            var container:Sprite = view.canvas;
            var clip:Clipping = view.clip;
            
            var graphics:Graphics = container.graphics;
            
            var pritree:PrimitiveQuadrantTree = new PrimitiveQuadrantTree(clip);
            var lightarray:LightArray = new LightArray();
            var pritraverser:PrimitiveTraverser = new PrimitiveTraverser(pritree, lightarray, view);

            scene.traverse(pritraverser);

            var session:RenderSession = new RenderSession(scene, camera, container, clip, lightarray);

            for each (var qdrntfilter:IPrimitiveQuadrantFilter in qdrntfilters)
                qdrntfilter.filter(pritree, scene, camera, container, clip);

            pritree.render(session);
            
            //dispatch stats
            var statsEvent:StatsEvent = new StatsEvent(StatsEvent.RENDER);
			statsEvent.totalfaces = pritree.list().length;
			statsEvent.camera = camera;
			view.dispatchEvent(statsEvent);
        }

        public function desc():String
        {
            return "Quadrant ["+qdrntfilters.join("+")+"]";
        }

        public function stats():String
        {
            return "";
        }

    }
}
