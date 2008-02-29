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
        
        protected var projtraverser:ProjectionTraverser = new ProjectionTraverser();
        
        protected var blockerarray:BlockerArray = new BlockerArray();
        protected var blocktraverser:BlockerTraverser = new BlockerTraverser();
        protected var blockers:Array;
        
        protected var priarray:PrimitiveArray = new PrimitiveArray();
        protected var lightarray:LightArray = new LightArray();
        protected var pritraverser:PrimitiveTraverser = new PrimitiveTraverser();
        protected var primitives:Array;
        protected var materials:Dictionary;
        
        protected var filter:IPrimitiveFilter;
        
        protected var session:RenderSession = new RenderSession();
        
        protected var primitive:DrawPrimitive;
        protected var triangle:DrawTriangle;
        protected var object:Object;
        
        public function render(view:View3D):Array
        {
            
            scene = view.scene;
            camera = view.camera;
            container = view.canvas;
            clip = view.clip;
            
            // resolve projection
            projtraverser.view = view;
            scene.traverse(projtraverser);
                    
            // get blockers for occlusion culling
            blockerarray.clip = clip;
            blocktraverser.consumer = blockerarray
            blocktraverser.view = view;
            scene.traverse(blocktraverser);
            blockers = blockerarray.list();
            
            // clear lights
            lightarray.clear();
            
            //setup session
            session.view = view;
            session.container = container;
            session.lightarray = lightarray;
			
			//setup primitives consumer
            priarray.clip = clip;
            priarray.blockers = blockers;
            
            //traverse primitives
            pritraverser.consumer = priarray;
            pritraverser.session = session;
            scene.traverse(pritraverser);
            primitives = priarray.list();
            
            // apply filters
            for each (filter in filters)
                primitives = filter.filter(primitives, scene, camera, container, clip);

			//update object-based materials
			/*
			materials = new Dictionary();
			for each (primitive in primitives)
				if(primitive is DrawTriangle) {
					triangle = primitive as DrawTriangle;
					if (triangle.material is IUVMaterialContainer)
						materials[triangle.source] = triangle.material;
				}
			for (object in materials)
				materials[object].renderMaterial(object as Mesh);
			*/
			
            // render all primitives
            for each (primitive in primitives)
                primitive.render();
			/*
			//reset materials
			for (object in materials)
				materials[object].resetMaterial(object as Mesh);
			*/
            //dispatch stats
            if (view.statsOpen)
            	view.statsPanel.updateStats(primitives.length, camera);
            
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
