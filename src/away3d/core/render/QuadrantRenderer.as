package away3d.core.render
{
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.clip.*;
	import away3d.core.draw.*;
	import away3d.core.filter.*;
	import away3d.core.light.*;
	import away3d.core.stats.*;
	import away3d.core.traverse.*;
	
	import flash.utils.Dictionary;
    

    /** Renderer that uses quadrant tree for storing and operating drawing primitives. Quadrant tree speeds up all proximity based calculations. */
    public class QuadrantRenderer implements IRenderer
    {
        private var qdrntfilters:Array;
		private var scene:Scene3D;
        private var camera:Camera3D;
        private var clip:Clipping;
        private var projtraverser:ProjectionTraverser = new ProjectionTraverser();
        private var pritree:PrimitiveQuadrantTree = new PrimitiveQuadrantTree();
        private var lightarray:LightArray = new LightArray();
        private var sessiontraverser:SessionTraverser = new SessionTraverser();
        private var pritraverser:PrimitiveTraverser = new PrimitiveTraverser();
        private var primitives:Array;
        private var materials:Dictionary;
        private var primitive:DrawPrimitive;
        private var triangle:DrawTriangle;
        private var object:Object3D;
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
			return pritree;
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
            
            // clear lights
            lightarray.clear();
            
            //setup session
            session.view = view;
            session.lightarray = lightarray;
            
            //traverse sessions
            sessiontraverser.view = view;
            scene.traverse(sessiontraverser);
			
			session.clear();
            
            //traverse primitives
            pritraverser.view = view;
            scene.traverse(pritraverser);
			
			session.filter(qdrntfilters);
			
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
            return "Quadrant ["+qdrntfilters.join("+")+"]";
        }
    }
}
