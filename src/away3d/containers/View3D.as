package away3d.containers
{
	import away3d.arcane;
	import away3d.cameras.*;
	import away3d.core.base.*;
	import away3d.core.block.*;
	import away3d.core.clip.*;
	import away3d.core.draw.*;
	import away3d.core.math.Matrix3D;
	import away3d.core.project.*;
	import away3d.core.render.*;
	import away3d.core.stats.*;
	import away3d.core.traverse.*;
	import away3d.core.utils.*;
	import away3d.events.*;
	import away3d.materials.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.getTimer;
	
	use namespace arcane;
	
	 /**
	 * Dispatched when a user moves the cursor while it is over a 3d object
	 * 
	 * @eventType away3d.events.MouseEvent3D
	 */
	[Event(name="mouseMove",type="away3d.events.MouseEvent3D")]
    			
	 /**
	 * Dispatched when a user presses the let hand mouse button while the cursor is over a 3d object
	 * 
	 * @eventType away3d.events.MouseEvent3D
	 */
	[Event(name="mouseDown",type="away3d.events.MouseEvent3D")]
    			
	 /**
	 * Dispatched when a user releases the let hand mouse button while the cursor is over a 3d object
	 * 
	 * @eventType away3d.events.MouseEvent3D
	 */
	[Event(name="mouseUp",type="away3d.events.MouseEvent3D")]
    			
	 /**
	 * Dispatched when a user moves the cursor over a 3d object
	 * 
	 * @eventType away3d.events.MouseEvent3D
	 */
	[Event(name="mouseOver",type="away3d.events.MouseEvent3D")]
    			
	 /**
	 * Dispatched when a user moves the cursor away from a 3d object
	 * 
	 * @eventType away3d.events.MouseEvent3D
	 */
	[Event(name="mouseOut",type="away3d.events.MouseEvent3D")]
	
	/**
	 * Sprite container used for storing camera, scene, session, renderer and clip references, and resolving mouse events
	 */
	public class View3D extends Sprite
	{
		/** @private */
		arcane var _screenClip:Clipping;
		/** @private */
		arcane var _interactiveLayer:Sprite = new Sprite();
		/** @private */
		arcane var _convexBlockProjector:ConvexBlockProjector = new ConvexBlockProjector();
		/** @private */
    	arcane var _dirSpriteProjector:DirSpriteProjector = new DirSpriteProjector();
    	/** @private */
    	arcane var _dofSpriteProjector:DofSpriteProjector = new DofSpriteProjector();
    	/** @private */
    	arcane var _meshProjector:MeshProjector = new MeshProjector();
    	/** @private */
    	arcane var _movieClipSpriteProjector:MovieClipSpriteProjector = new MovieClipSpriteProjector();
    	/** @private */
    	arcane var _objectContainerProjector:ObjectContainerProjector = new ObjectContainerProjector();
    	/** @private */
    	arcane var _spriteProjector:SpriteProjector = new SpriteProjector();
		/** @private */
        arcane function dispatchMouseEvent(event:MouseEvent3D):void
        {
            if (!hasEventListener(event.type))
                return;

            dispatchEvent(event);
        }
		
		private var _screenClipDirty:Boolean;
		private var _viewZero:Point = new Point();
		private var _x:Number;
		private var _y:Number;
		private var _stageWidth:Number;
		private var _stageHeight:Number;
		private var _drawPrimitiveStore:DrawPrimitiveStore = new DrawPrimitiveStore();
		private var _cameraVarsStore:CameraVarsStore = new CameraVarsStore();
        private var _scene:Scene3D;
		private var _session:AbstractRenderSession;
		private var _clipping:Clipping;
		private var _camera:Camera3D;
		private var _renderer:IRenderer;
		private var _ini:Init;
		private var _mousedown:Boolean;
        private var _lastmove_mouseX:Number;
        private var _lastmove_mouseY:Number;
		private var _internalsession:AbstractRenderSession;
		private var _updatescene:ViewEvent;
		private var _updated:Boolean;
		private var _cleared:Boolean;
		private var _pritraverser:PrimitiveTraverser = new PrimitiveTraverser();
		private var _ddo:DrawDisplayObject = new DrawDisplayObject();
        private var _container:DisplayObject;
        private var _hitPointX:Number;
        private var _hitPointY:Number;
        private var _sc:ScreenVertex = new ScreenVertex();
        private var _consumer:IPrimitiveConsumer;
        private var screenX:Number;
        private var screenY:Number;
        private var screenZ:Number = Infinity;
        private var element:Object;
        private var drawpri:DrawPrimitive;
        private var material:IUVMaterial;
        private var object:Object3D;
        private var uv:UV;
        private var sceneX:Number;
        private var sceneY:Number;
        private var sceneZ:Number;
        private var primitive:DrawPrimitive;
        private var inv:Matrix3D = new Matrix3D();
        private var persp:Number;
        private var _mouseIsOverView:Boolean;
        
        private function checkSession(session:AbstractRenderSession):void
        {
        	
        	if (session is BitmapRenderSession) {
        		_container = session.getContainer(this);
        		_hitPointX += _container.x;
        		_hitPointY += _container.y;
        	}
        	
        	if (session.getContainer(this).hitTestPoint(_hitPointX, _hitPointY)) {
	        	for each (primitive in session.getConsumer(this).list())
	               checkPrimitive(primitive);
	        	for each (session in session.sessions)
	        		checkSession(session);
	        }
	        
        	if (session is BitmapRenderSession) {
        		_container = session.getContainer(this);
        		_hitPointX -= _container.x;
        		_hitPointY -= _container.y;
        	}
        	
        }
        
        private function checkPrimitive(pri:DrawPrimitive):void
        {
        	if (pri is DrawFog)
        		return;
        	
            if (!pri.source || !pri.source._mouseEnabled)
                return;
            
            if (pri.minX > screenX)
                return;
            if (pri.maxX < screenX)
                return;
            if (pri.minY > screenY)
                return;
            if (pri.maxY < screenY)
                return;
            
            if (pri is DrawDisplayObject && !(pri as DrawDisplayObject).displayobject.hitTestPoint(_hitPointX, _hitPointY, true))
            	return;
            
            if (pri.contains(screenX, screenY))
            {
                var z:Number = pri.getZ(screenX, screenY);
                if (z < screenZ)
                {
                    if (pri is DrawTriangle)
                    {
                        var tri:DrawTriangle = pri as DrawTriangle;
                        var testuv:UV = tri.getUV(screenX, screenY);
                        if (tri.material is IUVMaterial) {
                            var testmaterial:IUVMaterial = (tri.material as IUVMaterial);
                            //return if material pixel is transparent
                            if (!(tri.material is BitmapMaterialContainer) && !(testmaterial.getPixel32(testuv.u, testuv.v) >> 24))
                                return;
                            uv = testuv;
                        }
                        material = testmaterial;
                    } else {
                        uv = null;
                    }
                    screenZ = z;
                    persp = camera.zoom / (1 + screenZ / camera.focus);
                    inv = camera.invViewMatrix;
					
                    sceneX = screenX / persp * inv.sxx + screenY / persp * inv.sxy + screenZ * inv.sxz + inv.tx;
                    sceneY = screenX / persp * inv.syx + screenY / persp * inv.syy + screenZ * inv.syz + inv.ty;
                    sceneZ = screenX / persp * inv.szx + screenY / persp * inv.szy + screenZ * inv.szz + inv.tz;

                    drawpri = pri;
                    object = pri.source;
                    element = null; // TODO face or segment

                }
            }
        }
        
		private function notifySceneUpdate():void
		{
			//dispatch event
			if (!_updatescene)
				_updatescene = new ViewEvent(ViewEvent.UPDATE_SCENE, this);
				
			dispatchEvent(_updatescene);
		}
		
		private function createStatsMenu(event:Event):void
		{
			statsPanel = new Stats(this, stage.frameRate); 
			statsOpen = false;
			
			stage.addEventListener(Event.RESIZE, onStageResized);
		}
		
		private function onStageResized(event:Event):void
		{
			_screenClipDirty = true;
		}
		
		private function onSessionUpdate(event:SessionEvent):void
		{
			if (event.target is BitmapRenderSession)
				_scene.updatedSessions[event.target] = event.target;
		}
		
		private function onCameraTransformChange(e:Object3DEvent):void
		{
			_updated = true;
		}
		
		private function onCameraUpdated(e:CameraEvent):void
		{
			_updated = true;
		}
		
		private function onClippingUpdated(e:ClippingEvent):void
		{
			_updated = true;
		}
		
		private function onSessionChange(e:Object3DEvent):void
		{
			_session.sessions = [e.object.session];
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
        	//if (e.eventPhase != EventPhase.AT_TARGET)
        	//	return;
        	
        	_mouseIsOverView = false;
        	
        	fireMouseEvent(MouseEvent3D.MOUSE_OUT, mouseX, mouseY, e.ctrlKey, e.shiftKey);
        	
			if (mouseObject != null)
			{
				var event:MouseEvent3D = getMouseEvent(MouseEvent3D.MOUSE_OUT);
				event.object = mouseObject;
				event.material = mouseMaterial;
				dispatchMouseEvent(event);
				bubbleMouseEvent(event);
				mouseObject = null;
				buttonMode = false;
			}
        }
        
        private function onMouseOver(e:MouseEvent):void
        {
        	//if (e.eventPhase != EventPhase.AT_TARGET)
        	//	return;
        	
        	_mouseIsOverView = true;
        	
            fireMouseEvent(MouseEvent3D.MOUSE_OVER, mouseX, mouseY, e.ctrlKey, e.shiftKey);
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
        
        public var viewTimer:int;
        
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
        * Defines whether the view always redraws on a render, or just redraws what 3d objects change. Defaults to true.
        * 
        * @see #render()
        */
        public var forceUpdate:Boolean;
      
        public var blockerarray:BlockerArray = new BlockerArray();
        
        /**
        * Renderer object used to traverse the scenegraph and output the drawing primitives required to render the scene to the view.
        */
        public function get renderer():IRenderer
        {
        	return _renderer;
        }
    	
        public function set renderer(val:IRenderer):void
        {
        	if (_renderer == val)
        		return;
        	
        	_renderer = val;
        	
			_updated = true;
			
        	if (!_renderer)
        		throw new Error("View cannot have renderer set to null");
        }
		
		/**
		* Flag used to determine if the camera has updated the view.
        * 
        * @see #camera
        */
        public function get updated():Boolean
        {
        	return _updated;
        }
        
        /**
        * Clipping area used when rendering.
        * 
        * If null, the visible edges of the screen are located with the <code>Clipping.screen()</code> method.
        * 
        * @see #render()
        * @see away3d.core.render.Clipping.scene()
        */
        public function get clipping():Clipping
        {
        	return _clipping;
        }
    	
        public function set clipping(val:Clipping):void
        {
        	if (_clipping == val)
        		return;
        	
        	if (_clipping) {
        		_clipping.removeOnClippingUpdate(onClippingUpdated);
        		_clipping.internalRemoveView(this);
        	}
        		
        	_clipping = val;
        	
        	if (_clipping) {
        		_clipping.addOnClippingUpdate(onClippingUpdated);
        		_clipping.internalAddView(this);
        	} else {
        		throw new Error("View cannot have clip set to null");
        	}
        	
        	_updated = true;
        	_screenClipDirty = true;
        }
        
        /**
        * Camera used when rendering.
        * 
        * @see #render()
        */
        public function get camera():Camera3D
        {
        	return _camera;
        }
    	
        public function set camera(val:Camera3D):void
        {
        	if (_camera == val)
        		return;
        	
        	if (_camera) {
        		_camera.view = null;
        		_camera.removeOnSceneTransformChange(onCameraTransformChange);
        		_camera.removeOnCameraUpdate(onCameraUpdated);
        	}
        	
        	_camera = val;
        	_camera.view = this;
        	
        	_updated = true;
        	
        	if (_camera) {
        		_camera.addOnSceneTransformChange(onCameraTransformChange);
        		_camera.addOnCameraUpdate(onCameraUpdated);
        	} else {
        		throw new Error("View cannot have camera set to null");
        	}
        }
        
		/**
		* Scene used when rendering.
        * 
        * @see render()
        */
        public function get scene():Scene3D
        {
        	return _scene;
        }
    	
        public function set scene(val:Scene3D):void
        {
        	if (_scene == val)
        		return;
        	
        	if (_scene) {
        		_scene.internalRemoveView(this);
        		delete _scene.viewDictionary[this];
        		_scene.removeOnSessionChange(onSessionChange);
        		if (_session)
        			_session.internalRemoveSceneSession(_scene.ownSession);
	        }
        	
        	_scene = val;
        	
			_updated = true;
			
        	if (_scene) {
        		_scene.internalAddView(this);
        		_scene.addOnSessionChange(onSessionChange);
        		_scene.viewDictionary[this] = this;
        		if (_session)
        			_session.internalAddSceneSession(_scene.ownSession);
        	} else {
        		throw new Error("View cannot have scene set to null");
        	}
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
        	if (_session == val)
        		return;
        	
        	if (_session) {
        		_session.removeOnSessionUpdate(onSessionUpdate);
	        	if (_scene)
	        		_session.internalRemoveSceneSession(_scene.ownSession);
        	}
        	
        	_session = val;
        	
			_updated = true;
			
        	if (_session) {
        		_session.addOnSessionUpdate(onSessionUpdate);
	        	if (_scene)
	        		_session.internalAddSceneSession(_scene.ownSession);
        	} else {
        		throw new Error("View cannot have session set to null");
        	}
        	
        	//clear children
        	while (numChildren)
        		removeChildAt(0);
        	
        	//add children
        	addChild(background);
            addChild(_session.getContainer(this));
            addChild(_interactiveLayer);
            addChild(hud);
        }
        
        public function get screenClip():Clipping
        {
        	if (_screenClipDirty) {
        		_screenClipDirty = false;
        		return _screenClip = _clipping.screen(this);
        	}
        	
        	return _screenClip;
        }
        
        public function get drawPrimitiveStore():DrawPrimitiveStore
        {
        	return _drawPrimitiveStore;
        }
        
        public function get cameraVarsStore():CameraVarsStore
        {
        	return _cameraVarsStore;
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
			session = _ini.getObject("session") as AbstractRenderSession || new SpriteRenderSession();
            scene = _ini.getObjectOrInit("scene", Scene3D) as Scene3D || new Scene3D();
            camera = _ini.getObjectOrInit("camera", Camera3D) as Camera3D || new Camera3D({x:0, y:0, z:-1000, lookat:"center"});
			renderer = _ini.getObject("renderer") as IRenderer || new BasicRenderer();
			clipping = _ini.getObject("clipping", Clipping) as Clipping || new RectangleClipping();
			x = _ini.getNumber("x", 0);
			y = _ini.getNumber("y", 0);
			forceUpdate = _ini.getBoolean("forceUpdate", false);
			mouseZeroMove = _ini.getBoolean("mouseZeroMove", false);
			
			//setup blendmode for hidden interactive layer
            _interactiveLayer.blendMode = BlendMode.ALPHA;
            
            //setup the view property on child classes
            _convexBlockProjector.view = this;
			_dirSpriteProjector.view = this;
			_dofSpriteProjector.view = this;
			_meshProjector.view = this;
			_movieClipSpriteProjector.view = this;
			_objectContainerProjector.view = this;
			_spriteProjector.view = this;
			_drawPrimitiveStore.view = this;
			_cameraVarsStore.view = this;
            _pritraverser.view = this;
            
            //setup events on view
            addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
            addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
            
            //setup stats panel creation
            if (stats)
				addEventListener(Event.ADDED_TO_STAGE, createStatsMenu);			
		}
        
        /**
        * Collects all information from the given type of 3d mouse event into a <code>MouseEvent3D</code> object that can be accessed from the <code>getMouseEvent()<code> method.
        * 
        * @param	type					The type of 3d mouse event being triggered - can be MOUSE_UP, MOUSE_DOWN, MOUSE_OVER, MOUSE_OUT, and MOUSE_MOVE.
        * @param	x						The x coordinate being used for the 3d mouse event.
        * @param	y						The y coordinate being used for the 3d mouse event.
        * @param	ctrlKey		[optional]	The ctrl key value being used for the 3d mouse event.
        * @param	shiftKey	[optional]	The shift key value being used for the 3d mouse event.
        * 
        * @see #getMouseEvent()
        * @see away3d.events.MouseEvent3D
        */
        public function fireMouseEvent(type:String, x:Number, y:Number, ctrlKey:Boolean = false, shiftKey:Boolean = false):void
        {
        	findHit(_internalsession, x, y);
        	
            var event:MouseEvent3D = getMouseEvent(type);
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
                    event = getMouseEvent(MouseEvent3D.MOUSE_OUT);
                    event.object = mouseObject;
                    event.material = mouseMaterial;
                    dispatchMouseEvent(event);
                    bubbleMouseEvent(event);
                    mouseObject = null;
                    buttonMode = false;
                }
                if (target != null && mouseObject == null) {
                    event = getMouseEvent(MouseEvent3D.MOUSE_OVER);
                    event.object = target;
                    event.material = mouseMaterial = targetMaterial;
                    dispatchMouseEvent(event);
                    bubbleMouseEvent(event);
                    buttonMode = target.useHandCursor;
                }
                mouseObject = target;
            }
            
        }
        
	    /** 
	    * Finds the object that is rendered under a certain view coordinate. Used for mouse click events.
	    */
        public function findHit(session:AbstractRenderSession, x:Number, y:Number):void
        {
        	if (!session)
        		return;
        	
            screenX = x;
            screenY = y;
            screenZ = Infinity;
            material = null;
            object = null;
            
            _hitPointX = stage.mouseX;
            _hitPointY = stage.mouseY;
            
        	if (this.session is BitmapRenderSession) {
        		_container = this.session.getContainer(this);
        		_hitPointX += _container.x;
        		_hitPointY += _container.y;
        	}
        	
            checkSession(session);
        }
        
        /**
        * Returns a 3d mouse event object populated with the properties from the hit point.
        */
        public function getMouseEvent(type:String):MouseEvent3D
        {
            var event:MouseEvent3D = new MouseEvent3D(type);
            event.screenX = screenX;
            event.screenY = screenY;
            event.screenZ = screenZ;
            event.sceneX = sceneX;
            event.sceneY = sceneY;
            event.sceneZ = sceneZ;
            event.view = this;
            event.drawpri = drawpri;
            event.material = material;
            event.element = element;
            event.object = object;
            event.uv = uv;

            return event;
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
		
		public function updateScreenClip():void
		{
			//check for global view movement
        	_viewZero.x = 0;
        	_viewZero.y = 0;
        	localToGlobal(_viewZero);
			if (_x != _viewZero.x || _y != _viewZero.y || stage.scaleMode != StageScaleMode.NO_SCALE && (_stageWidth != stage.stageWidth || _stageHeight != stage.stageHeight)) {
        		_x = _viewZero.x;
        		_y = _viewZero.y;
        		_stageWidth = stage.stageWidth;
        		_stageHeight = stage.stageHeight;
        		_screenClipDirty = true;
   			}
		}
        /**
        * Clears previously rendered view from all render sessions.
        * 
        * @see #session
        */
        public function clear():void
        {
        	_updated = true;
        	
        	if (_internalsession)
        		session.clear(this);
        }
        
        /**
        * Renders a snapshot of the view to the render session's view container.
        * 
        * @see #session
        */
        public function render():void
        {
        	viewTimer = getTimer();
        	
            //update scene
            notifySceneUpdate();
            
        	//update session
        	if (_session != _internalsession)
        		_internalsession = session;
        	
        	//update renderer
        	if (_session.renderer != _renderer as IPrimitiveConsumer)
        		_session.renderer = _renderer as IPrimitiveConsumer;
	        
            //clear session
            _session.clear(this);
			
        	//clear drawprimitives
        	_drawPrimitiveStore.reset();
            
            //draw scene into view session
            if (_session.updated) {
            	if (_scene.ownSession is SpriteRenderSession)
					(_scene.ownSession as SpriteRenderSession).cacheAsBitmap = true;
            	_ddo.view = this;
	        	_ddo.displayobject = _scene.session.getContainer(this);
	        	_ddo.session = _session;
	        	_ddo.screenvertex = _sc;
	        	_ddo.calc();
	        	_consumer = _session.getConsumer(this);
	         	_consumer.primitive(_ddo);
            }
            
            //traverse scene
            _scene.traverse(_pritraverser);
            
            //render scene
            _session.render(this);
        	
        	_updated = false;
			
			//dispatch stats
            if (statsOpen)
            	statsPanel.updateStats(_session.getTotalFaces(this), camera);
        	
        	//debug check
            Init.checkUnusedArguments();
			
			//check for mouse interaction
            fireMouseMoveEvent();
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
        	if(!_mouseIsOverView)
        		return;
        	
            if (!(mouseZeroMove || force))
                if ((mouseX == _lastmove_mouseX) && (mouseY == _lastmove_mouseY))
                    return;

            fireMouseEvent(MouseEvent3D.MOUSE_MOVE, mouseX, mouseY);

             _lastmove_mouseX = mouseX;
             _lastmove_mouseY = mouseY;
        }
		
		/**
		 * Default method for adding a mouseMove3d event listener.
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
		 * Default method for adding a mouseDown3d event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function addOnMouseDown(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_DOWN, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a mouseDown3d event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function removeOnMouseDown(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_DOWN, listener, false);
        }
		
		/**
		 * Default method for adding a mouseUp3d event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function addOnMouseUp(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_UP, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a 3d mouseUp event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function removeOnMouseUp(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_UP, listener, false);
        }
		
		/**
		 * Default method for adding a 3d mouseOver event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function addOnMouseOver(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_OVER, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a 3d mouseOver event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function removeOnMouseOver(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_OVER, listener, false);
        }
		
		/**
		 * Default method for adding a 3d mouseOut event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function addOnMouseOut(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_OUT, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a 3d mouseOut event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function removeOnMouseOut(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_OUT, listener, false);
        }		
	}
}