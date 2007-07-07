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
        use namespace arcane;

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
