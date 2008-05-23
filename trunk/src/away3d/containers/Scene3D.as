package away3d.containers
{
	import away3d.core.*;
	import away3d.core.base.*;
	import away3d.core.math.*;
	import away3d.core.traverse.*;
	import away3d.core.utils.*;
	
	import flash.utils.getTimer;
    
    /**
    * The root container of all 3d objects in a single scene
    */
    public class Scene3D extends ObjectContainer3D
    {
    	use namespace arcane;
    	
    	/**
    	 * Interface for physics (not implemented)
    	 */
        public var physics:IPhysicsScene;
        
		/**
		 * Traverser object for all custom <code>tick()</code> methods
		 * 
		 * @see away3d.core.base.Object3D#tick()
		 */
		public var tickTraverser:TickTraverser = new TickTraverser();
    	
		/**
		 * Creates a new <code>Scene3D</code> object
		 * 
		 * @param	init	[optional]	An initialisation object for specifying default instance properties
		 * @param	...objects				An array of 3d objects to be added as children on instatiation
		 */
        public function Scene3D(init:Object = null, ...objects)
        {
            if (init != null && init is Object3D) {
                addChild(init as Object3D);
                init = null;
            }
            
            ini = Init.parse(init);

            var ph:Object = ini.getObject("physics");
            if (ph is IPhysicsScene)
                physics = ph as IPhysicsScene;
            if (ph is Boolean)
                if (ph == true)
                    physics = null; // new RobPhysicsEngine();
            if (ph is Object)
                physics = null; // new RobPhysicsEngine(ph); // ph - init object

            for each (var object:Object3D in objects)
                addChild(object);
        }
		
		/**
		 * Calling manually will update 3d objects that execute updates on their <code>tick()</code> methods.
		 * Uses the <code>TickTraverser</code> to traverse all tick methods in the scene.
		 * 
		 * @see	away3d.core.base.Object3D#tick()
		 * @see	away3d.core.traverse.TickTraverser
		 */
        public function updateTime(time:int = -1):void
        {
        	//set current time
            if (time == -1)
                time = getTimer();
                
            //traverser scene ticks
            tickTraverser.now = time;
            traverse(tickTraverser);
            
            
            if (physics != null)
                physics.updateTime(time);
        }
        
		/**
		 * Cannot parent a <code>Scene3D</code> object
		 * 
		 * @throws	Error	Scene can't be parented
		 */
		public override function get parent():ObjectContainer3D
		{
			return super.parent;
		}
        public override function set parent(value:ObjectContainer3D):void
        {
            if (value != null)
                throw new Error("Scene can't be parented");
        }
        
		/**
		 * @inheritDoc
		 */
        public override function get sceneTransform():Matrix3D
        {
        	if (_transformDirty)
        		 _sceneTransformDirty = true;
        	if (_sceneTransformDirty) {
        		_sceneTransformDirty = false;
        		notifySceneTransformChange();
        	}
            return transform;
        }

    }
}
