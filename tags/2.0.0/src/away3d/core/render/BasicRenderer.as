package away3d.core.render
{
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.*;
	import away3d.core.base.*;
	import away3d.core.block.*;
	import away3d.core.draw.*;
	import away3d.core.filter.*;
	import away3d.core.light.*;
	import away3d.core.stats.*;
	import away3d.core.traverse.*;
	import away3d.materials.*;
	
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
    
    	// TODO: Should be in AbstractRenderer perhaps?
        protected var _session:AbstractRenderSession;
	
        public function set renderSession(value:AbstractRenderSession):void
        {
        	this._session = value;
        }

        public function get renderSession():AbstractRenderSession
        {
        	return this._session
        }
        
        protected var primitive:DrawPrimitive;
        protected var triangle:DrawTriangle;
        protected var object:Object;               
        
        private var clip:Clipping;
        
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
            blocktraverser.consumer = blockerarray
            blocktraverser.view = view;
            scene.traverse(blocktraverser);
            blockers = blockerarray.list();
            
            // clear lights
            lightarray.clear();
            
            //setup session
            _session.view = view;
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
