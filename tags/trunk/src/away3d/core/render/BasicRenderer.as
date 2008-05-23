package away3d.core.render
{
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.block.*;
	import away3d.core.clip.*;
	import away3d.core.draw.*;
	import away3d.core.filter.*;
	import away3d.core.light.*;
	import away3d.core.stats.*;
	import away3d.core.traverse.*;
	import away3d.materials.*;
	
	import flash.utils.*;
    
    /** 
    * Default renderer for a view.
    * Contains the main render loop for rendering a scene to a view,
    * which resolves the projection, culls any drawing primitives that are occluded or outside the viewport,
    * and then z-sorts and renders them to screen.
    */
    public class BasicRenderer implements IRenderer
    {
        private var filters:Array;
        private var filter:IPrimitiveFilter;
        private var scene:Scene3D;
        private var camera:Camera3D;
        private var projtraverser:ProjectionTraverser = new ProjectionTraverser();
        private var blockerarray:BlockerArray = new BlockerArray();
        private var blocktraverser:BlockerTraverser = new BlockerTraverser();
        private var blockers:Array;
        private var priarray:PrimitiveArray = new PrimitiveArray();
        private var lightarray:LightArray = new LightArray();
        private var pritraverser:PrimitiveTraverser = new PrimitiveTraverser();
        private var primitives:Array;
        private var materials:Dictionary;
        private var primitive:DrawPrimitive;
        private var triangle:DrawTriangle;
        private var object:Object;
        private var clip:Clipping;
        private var _session:AbstractRenderSession;
        
		/**
		 * @inheritDoc
		 */
        public function get session():AbstractRenderSession
        {
        	return _session;
        }
        
        public function set session(value:AbstractRenderSession):void
        {
        	_session = value;
        }

		/**
		 * Creates a new <code>BasicRenderer</code> object.
		 *
		 * @param	filters	[optional]	An array of filters to use on projected drawing primitives before rendering them to screen.
		 */
        public function BasicRenderer(...filters)
        {
            this.filters = filters;
            this.filters.push(new ZSortFilter());
        }
        
		/**
		 * @inheritDoc
		 */
        public function render(view:View3D):Array
        {
            scene = view.scene;
            camera = view.camera;
            clip = view.clip;
            // resolve projection
            projtraverser.view = view;
            scene.traverse(projtraverser);
                    
            // get blockers for occlusion culling
            blockerarray.clip = clip;
            blocktraverser.consumer = blockerarray;
            blocktraverser.view = view;
            scene.traverse(blocktraverser);
            blockers = blockerarray.list();
            
            // clear lights
            lightarray.clear();
            _session.lightarray = lightarray;
			
			//setup primitives consumer
            priarray.clip = clip;
            priarray.blockers = blockers;
            
            //traverse primitives
            pritraverser.consumer = priarray;
            pritraverser.session = _session;
            scene.traverse(pritraverser);
            primitives = priarray.list();
            
            // apply filters
            for each (filter in filters)
                primitives = filter.filter(primitives, scene, camera, clip);

			//update materials
			materials = new Dictionary(true);
			for each (primitive in primitives)
				if(primitive is DrawTriangle) {
					triangle = primitive as DrawTriangle;
					if (!materials[triangle.source])
						materials[triangle.source] = new Dictionary(true);
					if (triangle.material is IUpdatingMaterial && !materials[triangle.source][triangle.material]) {
						(materials[triangle.source][triangle.material] = triangle.material as IUpdatingMaterial).updateMaterial(triangle.source, view);
					}
				}
			
			
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
        
		/**
		 * @inheritDoc
		 */
        public function toString():String
        {
            return "Basic ["+filters.join("+")+"]";
        }
    }
}
