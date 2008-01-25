package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.mesh.Mesh;
    import away3d.core.scene.*;
    import away3d.core.stats.*;
    
    import flash.display.*;
    import flash.geom.*;
    import flash.utils.Dictionary;

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
        
        protected var projtraverser:ProjectionTraverser = new ProjectionTraverser();
        
        protected var pritree:PrimitiveQuadrantTree = new PrimitiveQuadrantTree();
        protected var lightarray:LightArray = new LightArray();
        protected var pritraverser:PrimitiveTraverser = new PrimitiveTraverser();
        protected var primitives:Array;
        protected var materials:Dictionary;
        
        protected var qdrntfilter:IPrimitiveQuadrantFilter;
        
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
            
            // clear lights
            lightarray.clear();
            
            //setup session
            session.view = view;
            session.container = container;
            session.lightarray = lightarray;
            
            //setup primitives consumer
            pritree.clip = clip;
            
            //traverse primitives
            pritraverser.consumer = pritree;
            pritraverser.session = session;
            scene.traverse(pritraverser);			
			primitives = pritree.list();
			
			//apply filters
            for each (qdrntfilter in qdrntfilters)
                qdrntfilter.filter(pritree, scene, camera, container, clip);
			/*
			//update materials
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
