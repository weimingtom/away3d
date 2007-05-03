package away3d.core.proto
{
    import away3d.core.draw.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.render.*;
    
    import flash.display.Sprite;
    import flash.utils.getTimer;
    import flash.utils.Dictionary;
    
    public class Scene3D extends ObjectContainer3D
    {
        // The Sprite that you draw into when rendering.
        public var container:Sprite;
    
        public function Scene3D(...objects)
        {
            this.container = new Sprite();
    
            for each (var object:Object3D in objects)
                addChild(object);
        }

        public function clear():void
        {
            container.graphics.clear();
        }

/*
        public function findHit(camera:Camera3D, x:Number, y:Number):OldFindHitCallback
        {
            var callback:OldFindHitCallback = new OldFindHitCallback(x, y, 0);
            renderCamera(camera, callback);
            return callback;
        }

        public function findNearest(camera:Camera3D, x:Number, y:Number):OldFindHitCallback
        {
            var callback:OldFindHitCallback = new OldFindHitCallback(x, y);
            renderCamera(camera, callback);
            return callback;
        }
*/
        protected var clip:Clipping;

        public function render(camera:Camera3D, ...renderers):void
        {
            // updateBitmaps

            container.graphics.clear();

            if (renderers.length == 0)
                renderers.push(new BasicRenderer());

            for each (var renderer:IRenderer in renderers)
                renderer.render(this, camera, container, clip || Clipping.screen(container));
        }

        public function updateTime(time:int = -1):void
        {
            if (time == -1)
                time = getTimer();
            traverse(new TickTraverser(time));
        }

    }
}
