package away3d.core.proto
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.proto.*;
    import away3d.core.physics.*;
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
    	
        public function Scene3D(init:Object = null, ...childarray)
        {
        	fixed = true;
        	innerCollisions = true;
        	if (init != null && init is Object3D) {
                childarray.push(init);
                init = null;
            }
        	super(init);
        	
        	for each (child in childarray)
            	addChild(child);
        }

        public function updateTime(time:int = -1):void
        {
            if (time == -1)
                time = getTimer();
            traverse(new TickTraverser(time));
        }
        
        public function updatePhysics(dt:Number):void
        {
        	traverse(new AccelerateTraverser(accelerations));
        	traverse(new VerletTraverser(dt));
            traverse(new CollisionTraverser());
        }
    }
}
