package away3d.core.scene
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.scene.*;
    import away3d.core.mesh.*;
    import away3d.core.render.*;
    import away3d.core.material.*;
    import away3d.core.utils.*;
    
    import flash.display.Sprite;
    import flash.display.DisplayObject;
    import flash.utils.getTimer;
    import flash.utils.Dictionary;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import flash.display.Bitmap;

	import flash.utils.*;
	import away3d.core.stats.Stats;
	import flash.display.Stage;
	
    /** Repesent the drawing surface for the scene, that can be used to render 3D graphics */
    public class View3D extends Sprite
    {
        use namespace arcane;
		
		public var bmp:Bitmap;
        /** Background under the rendered scene */
        public var background:Sprite;
        /** Sprite that contains last rendered frame */
        public var canvas:Sprite;
        /** Head up display over the scene */
        public var hud:Sprite;

        /** Scene to be rendered */
        public var scene:Scene3D;
        /** Camera to render from */
        public var camera:Camera3D;
        /** Enables/Disables stats panel */
        public var stats:Boolean;
        /** Clipping area for the view */
        public var clip:Clipping;
        /** Renderer that is used for rendering <br> @see away3d.core.render.Renderer */
        public var renderer:IRenderer;

        /** Fire mouse move events even in case mouse pointer doesn't move */
        public var mouseZeroMove:Boolean;

        /** Keeps track of current object under the mouse */
        public var mouseObject:Object3D;
        
        /** Traverser used to find the current object under the mouse */
        public var findhit:FindHitTraverser
         
        /** Create a new View3D */
        public function View3D(init:Object = null)
        {
            init = Init.parse(init);
			
			stats = init.getBoolean("stats", true)
            scene = init.getObjectOrInit("scene", Scene3D) || new Scene3D();
            camera = init.getObjectOrInit("camera", Camera3D) || new Camera3D({x:0, y:0, z:1000, lookat:"center"});
            renderer = init.getObject("renderer") || new BasicRenderer();
            mouseChildren = init.getBoolean("mouseChildren", false);
            mouseZeroMove = init.getBoolean("mouseZeroMove", false);
            x = init.getNumber("x", 0);
            y = init.getNumber("y", 0);
            
            background = new Sprite();
            addChild(background);
            canvas = new Sprite();
            addChild(canvas);
            hud = new Sprite();
            addChild(hud);
            
            addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
            addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
            buttonMode = true;
            useHandCursor = false;
            
             if (stats){
				addEventListener(Event.ADDED_TO_STAGE, createStatsMenu);
			}
		}
        
		/** Create and registers new container for the stats panel */
		public function createStatsMenu(event:Event):void
		{
			var framerate:Number = stage.frameRate;
			Stats.instance.generateMenu(this, stage, framerate); 
		}
		
		
        /** Clear rendering area */
        public function clear():void
        {
            if (canvas != null)
                removeChild(canvas);
            canvas = new Sprite();
            addChildAt(canvas, 1);

            /* 
            canvas.graphics.clear();

            for (var i:int = 0; i < canvas.numChildren; i++)
                canvas.getChildAt(i).visible = false;
            */
        }

        /** Render frame */
        public function render():void
        {
            clear();

            var oldclip:Clipping = clip;

            clip = clip || Clipping.screen(this);

            renderer.render(this);

            clip = oldclip;

            Init.checkUnusedArguments();

            fireMouseMoveEvent();
        }

        protected var mousedown:Boolean;

        protected function onMouseDown(e:MouseEvent):void
        {
            mousedown = true;
            fireMouseEvent(MouseEvent.MOUSE_DOWN, e.localX, e.localY, e.ctrlKey, e.shiftKey);
        }

        private function onMouseUp(e:MouseEvent):void
        {
            mousedown = false;
            fireMouseEvent(MouseEvent.MOUSE_UP, e.localX, e.localY, e.ctrlKey, e.shiftKey);
        }

        private function onMouseOut(e:MouseEvent):void
        {
            var event:MouseEvent3D = findhit.getMouseEvent(MouseEvent.MOUSE_OUT+"3D");
            event.object = mouseObject;
            bubbleMouseEvent(event);
            mouseObject = null;
        }
        
        private function onMouseOver(e:MouseEvent):void
        {
            fireMouseEvent(MouseEvent.MOUSE_OVER, e.localX, e.localY, e.ctrlKey, e.shiftKey);
        }

        private var _lastmove_mouseX:Number;
        private var _lastmove_mouseY:Number;

        /** Manually fire mouse move event */
        public function fireMouseMoveEvent(force:Boolean = false):void
        {
            if (!(mouseZeroMove || force))
                if ((mouseX == _lastmove_mouseX) && (mouseY == _lastmove_mouseY))
                    return;

            fireMouseEvent(MouseEvent.MOUSE_MOVE, mouseX, mouseY);

             _lastmove_mouseX = mouseX;
             _lastmove_mouseY = mouseY;
        }

        /** Manually fire custom mouse event */
        public function fireMouseEvent(type:String, x:Number, y:Number, ctrlKey:Boolean = false, shiftKey:Boolean = false):void
        {
            findhit = new FindHitTraverser(this, x, y);
            scene.traverse(findhit);
            var event:MouseEvent3D = findhit.getMouseEvent(type+"3D");
            var target:Object3D = event.object;
            event.ctrlKey = ctrlKey;
            event.shiftKey = shiftKey;

            dispatchMouseEvent(event);
            bubbleMouseEvent(event);
            
            //catch rollover/rollout object3d events
            if (mouseObject != event.object) {
                if (mouseObject != null) {
                    event = findhit.getMouseEvent(MouseEvent.MOUSE_OUT+"3D");
                    event.object = mouseObject;
                    bubbleMouseEvent(event);
                }
                if (target != null) {
                    event = findhit.getMouseEvent(MouseEvent.MOUSE_OVER+"3D");
                    event.object = mouseObject = target;
                    bubbleMouseEvent(event);
                    useHandCursor = mouseObject.handCursor;
                }
            }
            
        }
        
        public function bubbleMouseEvent(event:MouseEvent3D):void
        {
            var target:Object3D = event.object;
            while (target != null)
            {
                if (target.dispatchMouseEvent(event))
                    break;
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

        public function addOnMouseMove(listener:Function):void
        {
            addEventListener(MouseEvent.MOUSE_MOVE+"3D", listener, false, 0, false);
        }
        public function removeOnMouseMove(listener:Function):void
        {
            removeEventListener(MouseEvent.MOUSE_MOVE+"3D", listener, false);
        }

        public function addOnMouseDown(listener:Function):void
        {
            addEventListener(MouseEvent.MOUSE_DOWN+"3D", listener, false, 0, false);
        }
        public function removeOnMouseDown(listener:Function):void
        {
            removeEventListener(MouseEvent.MOUSE_DOWN+"3D", listener, false);
        }

        public function addOnMouseUp(listener:Function):void
        {
            addEventListener(MouseEvent.MOUSE_UP+"3D", listener, false, 0, false);
        }
        public function removeOnMouseUp(listener:Function):void
        {
            removeEventListener(MouseEvent.MOUSE_UP+"3D", listener, false);
        }

        public function addOnMouseOver(listener:Function):void
        {
            addEventListener(MouseEvent.MOUSE_OVER+"3D", listener, false, 0, false);
        }
        public function removeOnMouseOver(listener:Function):void
        {
            removeEventListener(MouseEvent.MOUSE_OVER+"3D", listener, false);
        }

        public function addOnMouseOut(listener:Function):void
        {
            addEventListener(MouseEvent.MOUSE_OUT+"3D", listener, false, 0, false);
        }
        public function removeOnMouseOut(listener:Function):void
        {
            removeEventListener(MouseEvent.MOUSE_OUT+"3D", listener, false);
        }
                
        arcane function dispatchMouseEvent(event:MouseEvent3D):void
        {
            if (!hasEventListener(event.type))
                return;

            dispatchEvent(event);
        }

    }
}
