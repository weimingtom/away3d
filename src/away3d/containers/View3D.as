package away3d.containers
{
	import away3d.cameras.*;
	import away3d.core.*;
	import away3d.core.base.*;
	import away3d.core.render.*;
	import away3d.core.stats.Stats;
	import away3d.core.utils.*;
	import away3d.events.*;
	import away3d.materials.*;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.events.MouseEvent;
	
	public class View3D extends Sprite
	{
		use namespace arcane;
		
		internal var _session:AbstractRenderSession;
		internal var _renderer:IRenderer;
		
        /** Background under the rendered scene */
        public var background:Sprite = new Sprite();
		/** container for interactive materials over the scene */
        public var interactiveLayer:Sprite = new Sprite();
        /** Head up display over the scene */
        public var hud:Sprite = new Sprite();

        /** Enables/Disables stats panel */
        public var stats:Boolean;
        /** Determines whether stats panel is currently open */
        public var statsOpen:Boolean;
        /** Sprite instance for stats panel */
        public var statsPanel:Stats;        
		/** string for storing source url */
		public var sourceURL:String;
		
        public var primitives:Array;

        /** Fire mouse move events even in case mouse pointer doesn't move */
        public var mouseZeroMove:Boolean;

        /** Keeps track of current object under the mouse */
        public var mouseObject:Object3D;
        
        /** Keeps track of current material under the mouse */
        public var mouseMaterial:IUVMaterial;

       /** Scene to be rendered */
        public var scene:Scene3D;
        /** Camera to render from */
        public var camera:Camera3D;
        /** Clipping area for the view */
        public var clip:Clipping;
        /** Default clipping area for the view */
        private var defaultclip:Clipping = new Clipping();

        /** Traverser used to find the current object under the mouse */
        public var findhit:FindHit;
        
        public function set renderer(val:IRenderer):void
        {
        	_renderer = val;
        	_renderer.renderSession = _session;
        }
        
        public function get renderer():IRenderer
        {
        	return _renderer;
        }
        
        public function set session(val:AbstractRenderSession):void
        {
        	_session = val;
        	_renderer.renderSession = _session;
        	
        	//clear children
        	while (numChildren)
        		removeChildAt(0);
        	
        	//add children
        	addChild(background);
            addChild(_session.getContainer(this));
            addChild(interactiveLayer);
            addChild(hud);
        }
        
        public function get session():AbstractRenderSession
        {
        	return _session;
        }
        		
		public function View3D(init:Object = null)
		{
			var ini:Init = Init.parse(init) as Init;
			
            var stats:Boolean = ini.getBoolean("stats", true);
            scene = ini.getObjectOrInit("scene", Scene3D) as Scene3D || new Scene3D();
            camera = ini.getObjectOrInit("camera", Camera3D) as Camera3D || new Camera3D({x:0, y:0, z:1000, lookat:"center"});
			_renderer = ini.getObject("renderer") as IRenderer || new BasicRenderer();
			session = ini.getObject("session") as AbstractRenderSession || new SpriteRenderSession();
			clip = ini.getObject("clip", Clipping) as Clipping;
			x = ini.getNumber("x", 0);
			y = ini.getNumber("y", 0);
			
            interactiveLayer.blendMode = BlendMode.ALPHA;
            
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
		
        /** Clear rendering area */
        public function clear():void
        {
        	_session.clear();
        }
		
		public function getBitmapData():BitmapData
		{
			if (_session is BitmapRenderSession)
				return (_session as BitmapRenderSession).getBitmapData(this);
			else
				throw new Error("incorrect session object - require BitmapRenderSession");	
		}
				
         /** Render frame */
        public function render():void
        {
            var oldclip:Clipping = clip;
            
            //if clip set to default, determine screen clipping
			if (clip == defaultclip)
            	clip = defaultclip.screen(this);            
        	
        	//setup view in session
        	_session.view = this;
        	
            clear();
            
            primitives = _renderer.render(this);
            
			clip = oldclip;
			
			flush();
        	
            Init.checkUnusedArguments();

            fireMouseMoveEvent();
        }		
		
		/** renders contents of rendersession */
        public function flush():void
        {
        	_session.flush();
        }
        
		/** Create and registers new container for the stats panel */
		public function createStatsMenu(event:Event):void
		{
			statsPanel = new Stats(this, stage.frameRate); 
			statsOpen = false;
		}
		
		public function addSourceURL(url:String):void
		{
			sourceURL = url;
			if (statsPanel)
				statsPanel.addSourceURL(url);
		}
		
        protected var mousedown:Boolean;

        protected function onMouseDown(e:MouseEvent):void
        {
            mousedown = true;
            fireMouseEvent(MouseEvent3D.MOUSE_DOWN, mouseX, mouseY, e.ctrlKey, e.shiftKey);
        }

        private function onMouseUp(e:MouseEvent):void
        {
            mousedown = false;
            fireMouseEvent(MouseEvent3D.MOUSE_UP, mouseX, mouseY, e.ctrlKey, e.shiftKey);
        }

        private function onMouseOut(e:MouseEvent):void
        {
        	if (e.eventPhase != EventPhase.AT_TARGET)
        		return;
        	fireMouseEvent(MouseEvent3D.MOUSE_OUT, mouseX, mouseY, e.ctrlKey, e.shiftKey);
        }
        
        private function onMouseOver(e:MouseEvent):void
        {
        	if (e.eventPhase != EventPhase.AT_TARGET)
        		return;
            fireMouseEvent(MouseEvent3D.MOUSE_OVER, mouseX, mouseY, e.ctrlKey, e.shiftKey);
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
                    event.object = target;
                    event.material = mouseMaterial = targetMaterial;
                    dispatchMouseEvent(event);
                    bubbleMouseEvent(event);
                    buttonMode = target.useHandCursor;
                }
                mouseObject = target;
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
        
        use namespace arcane;
                
        arcane function dispatchMouseEvent(event:MouseEvent3D):void
        {
            if (!hasEventListener(event.type))
                return;

            dispatchEvent(event);
        }
		
	}
}