package away3d.containers
{
    import away3d.core.math.*;
    import away3d.core.base.*;
    import away3d.core.traverse.*;
    import away3d.core.utils.*;
    
    import flash.utils.getTimer;
    
    /** Scene that gets rendered */
    public class Scene3D extends ObjectContainer3D
    {
        public var physics:IPhysicsScene;
		public var tickTraverser:TickTraverser = new TickTraverser();
		
        public function Scene3D(init:Object = null, ...objects)
        {
            if (init != null)
                if (init is Object3D)                          
                {
                    addChild(init as Object3D);
                    init = null;
                }

            var ini:Init = Init.parse(init);

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

        public override function set parent(value:ObjectContainer3D):void
        {
            if (value != null)
                throw new Error("Scene can't be parented");
        }

        public override function get sceneTransform():Matrix3D
        {
            return transform;
        }

    }
}
