package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.block.*;
    import away3d.core.draw.*;
    import away3d.core.material.*;
    import away3d.core.mesh.*;
    import away3d.core.scene.*;
    import away3d.core.stats.*;
    
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.utils.*;
    
    /** Basic renderer implementation */
    public class BasicRenderer implements IRenderer
    {
        protected var filters:Array;

        public function BasicRenderer(...filters)
        {
            this.filters = filters;
            this.filters.push(new ZSortFilter());
        }

        protected var scene:Scene3D;
        protected var camera:Camera3D;
        protected var container:Sprite;
        protected var clip:Clipping;
        
        protected var projtraverser:ProjectionTraverser;
        
        protected var blockerarray:BlockerArray;
        protected var blocktraverser:BlockerTraverser;
        protected var blockers:Array;
        
        public var priarray:PrimitiveArray;
        protected var lightarray:LightArray;
        protected var pritraverser:PrimitiveTraverser;
        protected var primitives:Array;
        
        protected var filter:IPrimitiveFilter;
        
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
                    
            // get blockers for occlusion culling
            blockerarray = new BlockerArray(clip);
            blocktraverser = new BlockerTraverser(blockerarray, view);
            scene.traverse(blocktraverser);
            blockers = blockerarray.list();

            
            // get lights and drawing primitives
            priarray = new PrimitiveArray(clip, blockers);
            lightarray = new LightArray();
            session = new RenderSession(view, container, lightarray);
            pritraverser = new PrimitiveTraverser(priarray, lightarray, view, session);
            scene.traverse(pritraverser);
            primitives = priarray.list();
            
            //sort containers
            priarray.sortContainers(view);
            
            // apply filters
            for each (filter in filters)
                primitives = filter.filter(primitives, scene, camera, container, clip);


            // render all
            for each (primitive in primitives)
                primitive.render();
            
            //dispatch stats
            statsEvent = new StatsEvent(StatsEvent.RENDER);
            statsEvent.totalfaces = primitives.length;
            statsEvent.camera = camera;
            view.dispatchEvent(statsEvent);
            
            return primitives;
        }
        
        public function desc():String
        {
            return "Basic ["+filters.join("+")+"]";
        }

        public function stats():String
        {
            return "";
        }
    }
}
