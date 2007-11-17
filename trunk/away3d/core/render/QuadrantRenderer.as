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
		
		protected var scene:Scene3D;
        protected var camera:Camera3D;
        protected var container:Sprite;
        protected var clip:Clipping;
        
        protected var projtraverser:ProjectionTraverser;
        
        protected var pritree:PrimitiveQuadrantTree;
        protected var lightarray:LightArray;
        protected var pritraverser:PrimitiveTraverser;
        protected var primitives:Array;
        
        protected var qdrntfilter:IPrimitiveQuadrantFilter;
        
        protected var session:RenderSession;
        
        protected var primitive:DrawPrimitive;
        
        protected var statsEvent:StatsEvent;
        
        public function render(view:View3D):Array
        {
            scene = view.scene;
            camera = view.camera;
            container = view.canvas;
            clip = view.clip;
            
            // resolve projection
			projtraverser = new ProjectionTraverser(view);
			scene.traverse(projtraverser);
            
            pritree = new PrimitiveQuadrantTree(clip);
            lightarray = new LightArray();
            session = new RenderSession(view, container, lightarray);
            pritraverser = new PrimitiveTraverser(pritree, lightarray, view, session);
            scene.traverse(pritraverser);			
			primitives = pritree.list();
			
			//sort containers
			pritree.sortContainers(view);

            for each (qdrntfilter in qdrntfilters)
                qdrntfilter.filter(pritree, scene, camera, container, clip);

            pritree.render();
            
            //dispatch stats
            statsEvent = new StatsEvent(StatsEvent.RENDER);
			statsEvent.totalfaces = primitives.length;
			statsEvent.camera = camera;
			view.dispatchEvent(statsEvent);
			
			return primitives;
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
