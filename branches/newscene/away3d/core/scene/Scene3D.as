package away3d.core.scene
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.geom.*;
    import away3d.core.render.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    
    import flash.display.Sprite;
    import flash.utils.getTimer;
    import flash.utils.Dictionary;
    import flash.events.MouseEvent;
    import flash.events.Event;
    
    /** Scene that gets rendered */
    public class Scene3D extends ObjectContainer3D
    {
        public var physics:IPhysicsScene;

        public function Scene3D(init:Object = null, ...objects)
        {
            if (init != null)
                if (init is Object3D)                          
                {
                    addChild(init as Object3D);
                    init = null;
                }

            init = Init.parse(init);

            var ph:Object = init.getObject("physics");
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
            if (time == -1)
                time = getTimer();
            traverse(new TickTraverser(time));
            if (physics != null)
                physics.updateTime(time);
        }

        public override function set parent(value:ObjectContainer3D):void
        {
            if (value != null)
                throw new Error("Scene can't be parented");
        }

        public override function get world():Matrix3D
        {
            return transform;
        }

    }
}
