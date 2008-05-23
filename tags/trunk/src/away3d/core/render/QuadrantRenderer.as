package away3d.core.render
{
	import away3d.cameras.*;
	import away3d.containers.*;
    import away3d.core.base.*;
    import away3d.core.clip.*;
    import away3d.core.draw.*;
    import away3d.core.light.*;
    import away3d.core.filter.*;
    import away3d.materials.IUpdatingMaterial;
    import away3d.core.traverse.*;
    import away3d.core.stats.*;
    
    import flash.utils.Dictionary;
    

    /** Renderer that uses quadrant tree for storing and operating drawing primitives. Quadrant tree speeds up all proximity based calculations. */
    public class QuadrantRenderer implements IRenderer
    {
        private var qdrntfilters:Array;
        private var qdrntfilter:IPrimitiveQuadrantFilter;
		private var scene:Scene3D;
        private var camera:Camera3D;
        private var clip:Clipping;
        private var projtraverser:ProjectionTraverser = new ProjectionTraverser();
        private var pritree:PrimitiveQuadrantTree = new PrimitiveQuadrantTree();
        private var lightarray:LightArray = new LightArray();
        private var pritraverser:PrimitiveTraverser = new PrimitiveTraverser();
        private var primitives:Array;
        private var materials:Dictionary;
        private var _session:AbstractRenderSession;
        private var primitive:DrawPrimitive;
        private var triangle:DrawTriangle;
        private var object:Object3D;
        
		/**
		 * @inheritDoc
		 */
        public function get session():AbstractRenderSession
        {
        	return this._session;
        }
        
        public function set session(value:AbstractRenderSession):void
        {
        	this._session = value;
        }
		
		/**
		 * Creates a new <code>QuadrantRenderer</code> object.
		 *
		 * @param	filters	[optional]	An array of filters to use on projected drawing primitives before rendering them to screen.
		 */
        public function QuadrantRenderer(...filters)
        {
            qdrntfilters = [];

            for each (var filter:IPrimitiveQuadrantFilter in filters)
                qdrntfilters.push(filter);
            clip = new Clipping();
        }
        
		/**
		 * @inheritDoc
		 */
        public function render(view:View3D):Array
        {
            scene = view.scene;
            camera = view.camera;
            
            // resolve projection
			projtraverser.view = view;
			scene.traverse(projtraverser);
            
            // clear lights
            lightarray.clear();
            
            //setup session
            _session.view = view;
            _session.lightarray = lightarray;
            
            //setup primitives consumer
            pritree.clip = clip;
            
            //traverse primitives
            pritraverser.consumer = pritree;
            pritraverser.session = _session;
            scene.traverse(pritraverser);
			primitives = pritree.list();
			
			//apply filters
            for each (qdrntfilter in qdrntfilters)
                qdrntfilter.filter(pritree, scene, camera, clip);
            
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
			
			//render all primitives
            pritree.render();
            /*
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
            return "Quadrant ["+qdrntfilters.join("+")+"]";
        }
    }
}
