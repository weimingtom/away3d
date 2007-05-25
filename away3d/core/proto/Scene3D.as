package away3d.core.proto
{
    import away3d.core.draw.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.render.*;
    import away3d.core.material.*;
    
    import flash.display.Sprite;
    import flash.utils.getTimer;
    import flash.utils.Dictionary;
    import flash.events.MouseEvent;
    import flash.events.Event;
    
    public class Scene3D extends ObjectContainer3D
    {
        public function Scene3D(...objects)
        {
            for each (var object:Object3D in objects)
                addChild(object);
        }

        public function updateTime(time:int = -1):void
        {
            if (time == -1)
                time = getTimer();
            traverse(new TickTraverser(time));
        }

    }
}
