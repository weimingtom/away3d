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
        private var scene:Scene3D;
        private var camera:Camera3D;
        private var projtraverser:ProjectionTraverser = new ProjectionTraverser();
        private var blockerarray:BlockerArray = new BlockerArray();
        private var blocktraverser:BlockerTraverser = new BlockerTraverser();
        private var blockers:Array;
        private var priarray:PrimitiveArray = new PrimitiveArray();
        private var lightarray:LightArray = new LightArray();
        private var sessiontraverser:SessionTraverser = new SessionTraverser();
        private var pritraverser:PrimitiveTraverser = new PrimitiveTraverser();
        private var primitives:Array;
        private var object:Object;
        private var clip:Clipping;
        private var session:AbstractRenderSession;
		private var s:AbstractRenderSession;
		
		private function countFaces(session:AbstractRenderSession):int
		{
			var output:int = session.primitives.length;
			
			for each (s in session.sessions)
				output += countFaces(s);
				
			return output;
		}
		
		public function get primitiveConsumer():IPrimitiveConsumer
		{
			return priarray;
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
        public function render(view:View3D):void
        {
            scene = view.scene;
            camera = view.camera;
            clip = view.clip;
            session = view.session;
            
            view.scene.updateSession = new Dictionary(true);
            
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
            session.lightarray = lightarray;
			
			//setup primitives consumer
            priarray.blockers = blockers;
            
            //traverse sessions
            sessiontraverser.view = view;
            scene.traverse(sessiontraverser);
            
            session.clear();
            
            //traverse primitives
            pritraverser.view = view;
            scene.traverse(pritraverser);
            
            session.filter(filters);
			
			session.render();
			
            //dispatch stats
            if (view.statsOpen)
            	view.statsPanel.updateStats(countFaces(session), camera);
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
