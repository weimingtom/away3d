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
    
    public class View3D extends Sprite
    {
        public var background:Sprite;
        public var canvas:Sprite;

        public var scene:Scene3D;
        public var camera:Camera3D;
        public var clip:Clipping;
        public var renderer:IRenderer;

        public function View3D(scene:Scene3D, camera:Camera3D, renderer:IRenderer = null)
        {
            this.scene = scene;
            this.camera = camera;
            this.renderer = renderer || new BasicRenderer();

            background = new Sprite();
            addChild(background);
            canvas = new Sprite();
            addChild(canvas);
            
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }

        public function onAddedToStage(e:Event):void
        {
            addEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
            addEventListener(MouseEvent.MOUSE_UP, onMouseEvent);
        }

        public function clear():void
        {
            if (canvas != null)
                removeChild(canvas);

            canvas = new Sprite();
            addChild(canvas);
        }

        public function render():void
        {
            clear();

            renderer.render(scene, camera, canvas, clip || Clipping.screen(this));

            fireMouseMoveEvent();
        }

        public function onMouseEvent(e:MouseEvent):void
        {
            var findhit:FindHitTraverser = new FindHitTraverser(camera, e.localX, e.localY);
            scene.traverse(findhit);
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

        public function fireMouseMoveEvent():void
        {
            var e:MouseEvent = new MouseEvent(MouseEvent.MOUSE_MOVE);
            e.localX = this.mouseX;
            e.localY = this.mouseY;
            onMouseEvent(e);
        }

        /*
        public function findHit(x:Number, y:Number):Object3D
        {
            var callback:OldFindHitCallback = new OldFindHitCallback(x, y, 0);
            renderCamera(camera, callback);
            return callback;
        }

        public function findNearest(x:Number, y:Number):Object3D
        {
            var callback:OldFindHitCallback = new OldFindHitCallback(x, y);
            renderCamera(camera, callback);
            return callback;
        }
        */
    }
}
