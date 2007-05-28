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
        public var hud:Sprite;

        public var scene:Scene3D;
        public var camera:Camera3D;
        public var clip:Clipping;
        public var renderer:IRenderer;

        public var events:Object3DEvents;

        public function View3D(scene:Scene3D, camera:Camera3D, renderer:IRenderer = null)
        {
            this.scene = scene;
            this.camera = camera;
            this.renderer = renderer || new BasicRenderer();
            
            events = new Object3DEvents();

            background = new Sprite();
            addChild(background);
            canvas = new Sprite();
            addChild(canvas);
            hud = new Sprite();
            addChild(hud);
            
            addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
            mouseChildren = false;
        }

        public function clear():void
        {
            if (canvas != null)
                removeChild(canvas);

            canvas = new Sprite();
            addChildAt(canvas, 1);
        }

        public function render():void
        {
            clear();

            //renderer.render(scene, camera, canvas, clip || Clipping.screen(this));
            var oldclip:Clipping = clip;

            clip = clip || Clipping.screen(this);

            renderer.render(this);

            clip = oldclip;

            fireMouseMoveEvent();
        }

        private var mousedown:Boolean;

        public function onMouseDown(e:MouseEvent):void
        {
            mousedown = true;
            onMouseEvent(MouseEvent.MOUSE_DOWN, e.localX, e.localY);
        }

        public function onMouseUp(e:MouseEvent):void
        {
            mousedown = false;
            onMouseEvent(MouseEvent.MOUSE_UP, e.localX, e.localY);
        }

        public function onMouseOut(e:MouseEvent):void
        {
            if (mousedown)
            {
                mousedown = false;
                onMouseEvent(MouseEvent.MOUSE_UP, e.localX, e.localY);
            }
        }

        public function fireMouseMoveEvent():void
        {
            onMouseEvent(MouseEvent.MOUSE_MOVE, mouseX, mouseY);
        }

        public function onMouseEvent(type:String, x:Number, y:Number):void
        {
            var findhit:FindHitTraverser = new FindHitTraverser(this, x, y);
            scene.traverse(findhit);
            var event:MouseEvent3D = findhit.getMouseEvent(type);
            //if (event == null)
            //    return;

            events.dispatchEvent(event);

            var target:Object3D = event.object;
            while (target != null)
            {
                if (target.hasEvents)
                    target.events.dispatchEvent(event);
                target = target.parent;
            }
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
