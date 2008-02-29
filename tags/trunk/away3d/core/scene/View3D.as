package away3d.core.scene
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.material.*;
    import away3d.core.mesh.*;
    import away3d.core.render.*;
    import away3d.core.stats.Stats;
    import away3d.core.utils.*;
    
    import flash.display.Bitmap;
    import flash.display.BlendMode;
    import flash.display.Sprite;
    import flash.events.*;
    import flash.utils.*;
	
    /** Repesent the drawing surface for the scene, that can be used to render 3D graphics */
    public class View3D extends Sprite
    {
        use namespace arcane;
		
		public var bmp:Bitmap;
        /** Background under the rendered scene */
        public var background:Sprite = new Sprite();
        /** Sprite that contains last rendered frame */
        public var canvas:Sprite = new Sprite();
        /** Bitmap that contains last rendered textures */
        public var bitmapTexture:Bitmap = new Bitmap();
         /** Bitmap that contains last rendered shaders */
        public var bitmapShader:Bitmap = new Bitmap();
		/** container for interactive materials over the scene */
        public var interactiveLayer:Sprite = new Sprite();
        /** Head up display over the scene */
        public var hud:Sprite = new Sprite();
        /** Scene to be rendered */
        public var scene:Scene3D;
        /** Camera to render from */
        public var camera:Camera3D;
        /** Enables/Disables stats panel */
        public var stats:Boolean;
        /** Determines whether stats panel is currently open */
        public var statsOpen:Boolean;
        /** Sprite instance for stats panel */
        public var statsPanel:Stats;
        /** Clipping area for the view */
        public var clip:Clipping;
        /** Default clipping area for the view */
        private var defaultclip:Clipping = new Clipping();
        /** Renderer that is used for rendering <br> @see away3d.core.render.Renderer */
        public var renderer:IRenderer;
		
		/** Array for storing old sprites to the canvas */
		public var canvasStore:Array = new Array();
		
		/** Array for storing added sprites to the canvas */
		public var canvasActive:Array = new Array();
		
        /** Fire mouse move events even in case mouse pointer doesn't move */
        public var mouseZeroMove:Boolean;

        /** Keeps track of current object under the mouse */
        public var mouseObject:Object3D;
        
        /** Keeps track of current material under the mouse */
        public var  mouseMaterial:IUVMaterial;
        
        public var primitives:Array;
        
        /** Traverser used to find the current object under the mouse */
        public var findhit:FindHit;
         
        /** Create a new View3D */
        public function View3D(init:Object = null)
        {
            init = Init.parse(init);
			
			stats = init.getBoolean("stats", true);
			clip = init.getObject("clip", Clipping);
            scene = init.getObjectOrInit("scene", Scene3D) || new Scene3D();
            camera = init.getObjectOrInit("camera", Camera3D) || new Camera3D({x:0, y:0, z:1000, lookat:"center"});
            renderer = init.getObject("renderer") || new BasicRenderer();
            mouseZeroMove = init.getBoolean("mouseZeroMove", false);
            x = init.getNumber("x", 0);
            y = init.getNumber("y", 0);
            
            addChild(background);
            addChild(canvas);
            addChild(bitmapTexture);
            addChild(bitmapShader);
            addChild(interactiveLayer);
            addChild(hud);
            interactiveLayer.blendMode = BlendMode.ALPHA;
            //bitmapShader.blendMode = BlendMode.ADD;
            
            addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
            addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
            
            if (!clip)
            	clip = defaultclip;
            
            if (stats){
				addEventListener(Event.ADDED_TO_STAGE, createStatsMenu);
			}
		}
        
		/** Create and registers new container for the stats panel */
		public function createStatsMenu(event:Event):void
		{
			statsPanel = new Stats(this, stage.frameRate); 
			statsOpen = false;
		}
		
        internal var i:int;
        internal var c:Sprite;
        
        /** Clear rendering area */
        public function clear():void
        {
        	//clear base canvas
            canvas.graphics.clear();
            
            //clear child canvases
            i = canvasActive.length;
            while (i--) {
            	c = canvasActive[i];
            	c.graphics.clear();
            	canvasStore.push(canvasActive.pop());
            }
            
            //remove all children
            i = canvas.numChildren;
			while (i--)
				canvas.removeChild(canvas.getChildAt(i));
        }

        /** Render frame */
        public function render():void
        {
            clear();

            var oldclip:Clipping = clip;
			
			if (clip == defaultclip)
            	clip = defaultclip.screen(this);

            primitives = renderer.render(this);

            clip = oldclip;

            Init.checkUnusedArguments();

            fireMouseMoveEvent();
        }

        protected var mousedown:Boolean;

        protected function onMouseDown(e:MouseEvent):void
        {
            mousedown = true;
            fireMouseEvent(MouseEvent3D.MOUSE_DOWN, e.localX, e.localY, e.ctrlKey, e.shiftKey);
        }

        private function onMouseUp(e:MouseEvent):void
        {
            mousedown = false;
            fireMouseEvent(MouseEvent3D.MOUSE_UP, e.localX, e.localY, e.ctrlKey, e.shiftKey);
        }

        private function onMouseOut(e:MouseEvent):void
        {
        	if (e.eventPhase != EventPhase.AT_TARGET)
        		return;
        	fireMouseEvent(MouseEvent3D.MOUSE_OUT, e.localX, e.localY, e.ctrlKey, e.shiftKey);
        }
        
        private function onMouseOver(e:MouseEvent):void
        {
        	if (e.eventPhase != EventPhase.AT_TARGET)
        		return;
            fireMouseEvent(MouseEvent3D.MOUSE_OVER, e.localX, e.localY, e.ctrlKey, e.shiftKey);
        }

        private var _lastmove_mouseX:Number;
        private var _lastmove_mouseY:Number;

        /** Manually fire mouse move event */
        public function fireMouseMoveEvent(force:Boolean = false):void
        {
            if (!(mouseZeroMove || force))
                if ((mouseX == _lastmove_mouseX) && (mouseY == _lastmove_mouseY))
                    return;

            fireMouseEvent(MouseEvent3D.MOUSE_MOVE, mouseX, mouseY);

             _lastmove_mouseX = mouseX;
             _lastmove_mouseY = mouseY;
        }
		
        /** Manually fire custom mouse event */
        public function fireMouseEvent(type:String, x:Number, y:Number, ctrlKey:Boolean = false, shiftKey:Boolean = false):void
        {
            findhit = new FindHit(this, primitives, x, y);
            var event:MouseEvent3D = findhit.getMouseEvent(type);
            var target:Object3D = event.object;
            var targetMaterial:IUVMaterial = event.material;
            event.ctrlKey = ctrlKey;
            event.shiftKey = shiftKey;

			if (type != MouseEvent3D.MOUSE_OUT && type != MouseEvent3D.MOUSE_OVER) {
	            dispatchMouseEvent(event);
	            bubbleMouseEvent(event);				
			}
            
            //catch rollover/rollout object3d events
            if (mouseObject != target || mouseMaterial != targetMaterial) {
                if (mouseObject != null) {
                    event = findhit.getMouseEvent(MouseEvent3D.MOUSE_OUT);
                    event.object = mouseObject;
                    event.material = mouseMaterial;
                    dispatchMouseEvent(event);
                    bubbleMouseEvent(event);
                    mouseObject = null;
                    buttonMode = false;
                }
                if (target != null && mouseObject == null) {
                    event = findhit.getMouseEvent(MouseEvent3D.MOUSE_OVER);
                    event.object = mouseObject = target;
                    event.material = mouseMaterial = targetMaterial;
                    dispatchMouseEvent(event);
                    bubbleMouseEvent(event);
                    buttonMode = mouseObject.useHandCursor;
                }
            }
            
        }
        
        public function bubbleMouseEvent(event:MouseEvent3D):void
        {
            var tar:Object3D = event.object;
            while (tar != null)
            {
                if (tar.dispatchMouseEvent(event))
                    break;
                tar = tar.parent;
            }       
        }

        public function addOnMouseMove(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_MOVE, listener, false, 0, false);
        }
        public function removeOnMouseMove(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_MOVE, listener, false);
        }

        public function addOnMouseDown(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_DOWN, listener, false, 0, false);
        }
        public function removeOnMouseDown(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_DOWN, listener, false);
        }

        public function addOnMouseUp(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_UP, listener, false, 0, false);
        }
        public function removeOnMouseUp(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_UP, listener, false);
        }

        public function addOnMouseOver(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_OVER, listener, false, 0, false);
        }
        public function removeOnMouseOver(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_OVER, listener, false);
        }

        public function addOnMouseOut(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_OUT, listener, false, 0, false);
        }
        public function removeOnMouseOut(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_OUT, listener, false);
        }
                
        arcane function dispatchMouseEvent(event:MouseEvent3D):void
        {
            if (!hasEventListener(event.type))
                return;

            dispatchEvent(event);
        }

    }
}
