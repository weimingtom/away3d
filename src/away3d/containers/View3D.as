package away3d.containers
{
	import away3d.cameras.*;
	import away3d.core.*;
	import away3d.core.base.*;
	import away3d.core.clip.*;
	import away3d.core.render.*;
	import away3d.core.stats.*;
	import away3d.core.utils.*;
	import away3d.events.*;
	import away3d.materials.*;
	
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.events.MouseEvent;
	
	 /**
	 * Dispatched when a user moves the cursor while it is over a 3d object
	 * 
	 * @eventType away3d.events.MouseEvent3D
	 */
	[Event(name="mouseMove3D",type="away3d.events.MouseEvent3D")]
    			
	 /**
	 * Dispatched when a user presses the let hand mouse button while the cursor is over a 3d object
	 * 
	 * @eventType away3d.events.MouseEvent3D
	 */
	[Event(name="mouseDown3D",type="away3d.events.MouseEvent3D")]
    			
	 /**
	 * Dispatched when a user releases the let hand mouse button while the cursor is over a 3d object
	 * 
	 * @eventType away3d.events.MouseEvent3D
	 */
	[Event(name="mouseUp3D",type="away3d.events.MouseEvent3D")]
    			
	 /**
	 * Dispatched when a user moves the cursor over a 3d object
	 * 
	 * @eventType away3d.events.MouseEvent3D
	 */
	[Event(name="mouseOver3D",type="away3d.events.MouseEvent3D")]
    			
	 /**
	 * Dispatched when a user moves the cursor away from a 3d object
	 * 
	 * @eventType away3d.events.MouseEvent3D
	 */
	[Event(name="mouseOut3D",type="away3d.events.MouseEvent3D")]
	
	/**
	 * Sprite container used for storing camera, scene, session, renderer and clip references, and resolving mouse events
	 */
	public class View3D extends Sprite
	{
		use namespace arcane;
		
		arcane var _interactiveLayer:Sprite = new Sprite();
		
        arcane function dispatchMouseEvent(event:MouseEvent3D):void
        {
            if (!hasEventListener(event.type))
                return;

            dispatchEvent(event);
        }
        		
		private var _session:AbstractRenderSession;
		private var _renderer:IRenderer;
        private var _defaultclip:Clipping = new Clipping();
		private var _ini:Init;
		private var _mousedown:Boolean;
        private var _lastmove_mouseX:Number;
        private var _lastmove_mouseY:Number;
		private var _oldclip:Clipping;
		
		private function createStatsMenu(event:Event):void
		{
			statsPanel = new Stats(this, stage.frameRate); 
			statsOpen = false;
		}
		
        private function onMouseDown(e:MouseEvent):void
        {
            _mousedown = true;
            fireMouseEvent(MouseEvent3D.MOUSE_DOWN, mouseX, mouseY, e.ctrlKey, e.shiftKey);
        }

        private function onMouseUp(e:MouseEvent):void
        {
            _mousedown = false;
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
        
        private function fireMouseEvent(type:String, x:Number, y:Number, ctrlKey:Boolean = false, shiftKey:Boolean = false):void
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
        
        private function bubbleMouseEvent(event:MouseEvent3D):void
        {
            var tar:Object3D = event.object;
            while (tar != null)
            {
                if (tar.dispatchMouseEvent(event))
                    break;
                tar = tar.parent;
            }       
        }
        
        /**
        * A background sprite positioned under the rendered scene.
        */
        public var background:Sprite = new Sprite();
        
        /**
        * A container for 2D overlays positioned over the rendered scene.
        */
        public var hud:Sprite = new Sprite();
		
        /**
        * Enables/Disables stats panel.
        * 
        * @see away3d.core.stats.Stats
        */
        public var stats:Boolean;
        
        /**
        * Keeps track of whether the stats panel is currently open.
        * 
        * @see away3d.core.stats.Stats
        */
        
        public var statsOpen:Boolean;
        
        /**
        * Object instance of the stats panel.
        * 
        * @see away3d.core.stats.Stats
        */
        public var statsPanel:Stats;
                
		/**
		 * Optional string for storing source url.
		 */
		public var sourceURL:String;
                
		/**
		 * temporary store for rendered primitives.
		 */
        public var primitives:Array;

        /**
        * Forces mousemove events to fire even when cursor is static.
        */
        public var mouseZeroMove:Boolean;

        /**
        * Current object under the mouse.
        */
        public var mouseObject:Object3D;
        
        /**
        * Current material under the mouse.
        */
        public var mouseMaterial:IUVMaterial;

		/**
		* Scene used when rendering.
        * 
        * @see render()
        */
        public var scene:Scene3D;
        
        /**
        * Camera used when rendering.
        * 
        * @see render()
        */
        public var camera:Camera3D;
        
        /**
        * Clipping area used when rendering.
        * 
        * If null, the visible edges of the screen are located with the <code>Clipping.screen()</code> method.
        * 
        * @see render()
        * @see away3d.core.render.Clipping.scene()
        */
        public var clip:Clipping;
        

        /**
        * Traverser used to find the current object under the mouse.
        * 
        * @see fireMouseEvent
        */
        public var findhit:FindHit;
        
        /**
        * Renderer object used to traverse the scenegraph and output the drawing primitives required to render the scene to the view.
        */
        public function get renderer():IRenderer
        {
        	return _renderer;
        }
        
        public function set renderer(val:IRenderer):void
        {
        	_renderer = val;
        	_renderer.session = _session;
        }
        
        /**
        * Session object used to draw all drawing primitives returned from the renderer to the view container.
        * 
        * @see #renderer
        * @see #getContainer()
        */
        public function get session():AbstractRenderSession
        {
        	return _session;
        }
    	
        public function set session(val:AbstractRenderSession):void
        {
        	_session = val;
        	_renderer.session = _session;
        	
        	//clear children
        	while (numChildren)
        		removeChildAt(0);
        	
        	//add children
        	addChild(background);
            addChild(_session.getContainer(this));
            addChild(_interactiveLayer);
            addChild(hud);
        }
        
		/**
		 * Creates a new <code>View3D</code> object.
		 * 
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
		public function View3D(init:Object = null)
		{
			_ini = Init.parse(init) as Init;
			
            var stats:Boolean = _ini.getBoolean("stats", true);
            scene = _ini.getObjectOrInit("scene", Scene3D) as Scene3D || new Scene3D();
            camera = _ini.getObjectOrInit("camera", Camera3D) as Camera3D || new Camera3D({x:0, y:0, z:1000, lookat:"center"});
			_renderer = _ini.getObject("renderer") as IRenderer || new BasicRenderer();
			session = _ini.getObject("session") as AbstractRenderSession || new SpriteRenderSession();
			clip = _ini.getObject("clip", Clipping) as Clipping;
			x = _ini.getNumber("x", 0);
			y = _ini.getNumber("y", 0);
			
            _interactiveLayer.blendMode = BlendMode.ALPHA;
            
            addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
            addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			
            if (!clip)
            	clip = _defaultclip;
            
            if (stats)
				addEventListener(Event.ADDED_TO_STAGE, createStatsMenu);			
		}
		
        /**
        * Clears previuosly rendered view from the session.
        * 
        * @see session
        */
        public function clear():void
        {
        	_oldclip = clip;
            
            //if clip set to default, determine screen clipping
			if (clip == _defaultclip)
            	clip = _defaultclip.screen(this);
        	
        	//setup view in session
        	_session.view = this;
        	
        	_session.clear();
        }
		
        /**
        * Returns the <code>DisplayObject</code> container of the rendered scene.
        * 
        * @return	The <code>DisplayObject</code> containing the output from the render session of the view.
        * 
        * @see #session
        * @see away3d.core.render.BitmapRenderSession
        * @see away3d.core.render.SpriteRenderSession
        */
		public function getContainer():DisplayObject
		{
			return _session.getContainer(this);
		}
		
        /**
        * Returns the <code>bitmapData</code> of the rendered scene.
        * 
        * <code>session</code> is required to be an instance of <code>BitmapRenderSession</code>, otherwise an error is thrown.
        * 
        * @throws	Error	incorrect session object - require BitmapRenderSession.
        * @return	The rendered view image.
        * 
        * @see #session
        * @see away3d.core.render.BitmapRenderSession
        */
		public function getBitmapData():BitmapData
		{
			if (_session is BitmapRenderSession)
				return (_session as BitmapRenderSession).getBitmapData(this);
			else
				throw new Error("incorrect session object - require BitmapRenderSession");	
		}
				
        /**
        * Renders a snapshot of the view to the render session's view container.
        * 
        * @see #session
        */
        public function render():void
        {
            clear();
            
            primitives = _renderer.render(this);
			
			flush();
        	
            Init.checkUnusedArguments();

            fireMouseMoveEvent();
        }
		
		/**
		 * Completes the rendering of a view by flushing the session
		 * 
		 * @see #session
		 */
        public function flush():void
        {
        	_session.flush();
        	
        	clip = _oldclip;
        }
        
		/**
		 * Defines a source url string that can be accessed though a View Source option in the right-click menu.
		 * 
		 * Requires the stats panel to be enabled.
		 * 
		 * @param	url		The url to the source files.
		 */
		public function addSourceURL(url:String):void
		{
			sourceURL = url;
			if (statsPanel)
				statsPanel.addSourceURL(url);
		}

        /**
        * Manually fires a mouseMove3D event.
        */
        public function fireMouseMoveEvent(force:Boolean = false):void
        {
            if (!(mouseZeroMove || force))
                if ((mouseX == _lastmove_mouseX) && (mouseY == _lastmove_mouseY))
                    return;

            fireMouseEvent(MouseEvent3D.MOUSE_MOVE, mouseX, mouseY);

             _lastmove_mouseX = mouseX;
             _lastmove_mouseY = mouseY;
        }
		
		/**
		 * Default method for adding a mouseMove3D event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function addOnMouseMove(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_MOVE, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a mouseMove3D event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function removeOnMouseMove(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_MOVE, listener, false);
        }
		
		/**
		 * Default method for adding a mouseDown3D event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function addOnMouseDown(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_DOWN, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a mouseDown3D event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function removeOnMouseDown(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_DOWN, listener, false);
        }
		
		/**
		 * Default method for adding a mouseUp3D event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function addOnMouseUp(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_UP, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a mouseUp3D event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function removeOnMouseUp(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_UP, listener, false);
        }
		
		/**
		 * Default method for adding a mouseOver3D event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function addOnMouseOver(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_OVER, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a mouseOver3D event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function removeOnMouseOver(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_OVER, listener, false);
        }
		
		/**
		 * Default method for adding a mouseOut3D event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function addOnMouseOut(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_OUT, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a mouseOut3D event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function removeOnMouseOut(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_OUT, listener, false);
        }		
	}
}