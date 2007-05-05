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
        public var container:Sprite;
        private var camera:Camera3D;
    
        public function Scene3D(...objects)
        {
            container = new Sprite();
    
            for each (var object:Object3D in objects)
                addChild(object);

            container.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }

        public function onAddedToStage(e:Event):void
        {
            container.addEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
            container.addEventListener(MouseEvent.MOUSE_UP, onMouseEvent);
            //container.addEventListener(MouseEvent.MOUSE_MOVE, onMouseEvent);
        }

        public function onMouseEvent(e:MouseEvent):void
        {
            var findhit:FindHitTraverser = new FindHitTraverser(camera, e.localX, e.localY);
            traverse(findhit);
            var event:MouseEvent3D = findhit.getMouseEvent(e.type);
            if (event == null)
                return;

            var target:Object3D = event.object;
            while (target != null)
            {
                if (target.hasEvents)
                    target.events.dispatchEvent(event);
                target = target.parent;
            }
        }
/*
        public function onMouseUp(e:MouseEvent):void
        {
            var findhit:FindHitTraverser = new FindHitTraverser(camera, e.localX, e.localY);
            traverse(findhit);

            if (findhit.object != null)
            {
                if (findhit.object is Mesh3D)
                {
                    (findhit.object as Mesh3D).material = new WireColorMaterial(0xFFFFFF, 0);
                }
            }
        }
*/
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

            /*
            if (this.camera == null)
            {
                container.addEventListener(MouseEvent.CLICK, onMouseDown);
                container.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            }
            */
            this.camera = camera;

            container.graphics.clear();

            if (renderers.length == 0)
                renderers.push(new BasicRenderer());

            for each (var renderer:IRenderer in renderers)
                renderer.render(this, camera, container, clip || Clipping.screen(container));
        
            var e:MouseEvent = new MouseEvent(MouseEvent.MOUSE_MOVE);
            e.localX = container.mouseX;
            e.localY = container.mouseY;
            onMouseEvent(e);
        }

        public function updateTime(time:int = -1):void
        {
            if (time == -1)
                time = getTimer();
            traverse(new TickTraverser(time));
        }

    }
}
