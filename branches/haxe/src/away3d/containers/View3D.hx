package away3d.containers;

	import away3d.arcane;
	import away3d.cameras.*;
	import away3d.core.base.*;
	import away3d.core.block.BlockerArray;
	import away3d.core.clip.*;
	import away3d.core.draw.*;
	import away3d.core.math.Matrix3D;
	import away3d.core.render.*;
	import away3d.core.stats.*;
	import away3d.core.traverse.*;
	import away3d.core.utils.*;
	import away3d.events.*;
	import away3d.materials.*;
	
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	use namespace arcane;
	
	 /**
	 * Dispatched when a user moves the cursor while it is over a 3d object
	 * 
	 * @eventType away3d.events.MouseEvent3D
	 */
	/*[Event(name="mouseMove",type="away3d.events.MouseEvent3D")]*/
    			
	 /**
	 * Dispatched when a user presses the let hand mouse button while the cursor is over a 3d object
	 * 
	 * @eventType away3d.events.MouseEvent3D
	 */
	/*[Event(name="mouseDown",type="away3d.events.MouseEvent3D")]*/
    			
	 /**
	 * Dispatched when a user releases the let hand mouse button while the cursor is over a 3d object
	 * 
	 * @eventType away3d.events.MouseEvent3D
	 */
	/*[Event(name="mouseUp",type="away3d.events.MouseEvent3D")]*/
    			
	 /**
	 * Dispatched when a user moves the cursor over a 3d object
	 * 
	 * @eventType away3d.events.MouseEvent3D
	 */
	/*[Event(name="mouseOver",type="away3d.events.MouseEvent3D")]*/
    			
	 /**
	 * Dispatched when a user moves the cursor away from a 3d object
	 * 
	 * @eventType away3d.events.MouseEvent3D
	 */
	/*[Event(name="mouseOut",type="away3d.events.MouseEvent3D")]*/
	
	/**
	 * Sprite container used for storing camera, scene, session, renderer and clip references, and resolving mouse events
	 */
	class View3D extends Sprite {
		public var camera(getCamera, setCamera) : Camera3D;
		public var renderer(getRenderer, setRenderer) : IRenderer;
		public var scene(getScene, setScene) : Scene3D;
		public var session(getSession, setSession) : AbstractRenderSession;
		public var updated(getUpdated, null) : Bool
        ;
		/** @private */
		
		/** @private */
		arcane var _interactiveLayer:Sprite ;
		/** @private */
        arcane function dispatchMouseEvent(event:MouseEvent3D):Void
        {
            if (!hasEventListener(event.type))
                return;

            dispatchEvent(event);
        }
        var _scene:Scene3D;
		var _session:AbstractRenderSession;
		var _camera:Camera3D;
		var _renderer:IRenderer;
        var _defaultclip:Clipping ;
		var _ini:Init;
		var _mousedown:Bool;
        var _lastmove_mouseX:Float;
        var _lastmove_mouseY:Float;
		var _oldclip:Clipping;
		var _internalsession:AbstractRenderSession;
		var _updatescene:ViewEvent;
		var _updated:Bool;
		var _cleared:Bool;
		var _pritraverser:PrimitiveTraverser ;
		var _ddo:DrawDisplayObject ;
        var _container:DisplayObject;
        var _hitPointX:Float;
        var _hitPointY:Float;
        var _sc:ScreenVertex ;
        var _consumer:IPrimitiveConsumer;
        var screenX:Float;
        var screenY:Float;
        var screenZ:Int ;
        var element:Dynamic;
        var drawpri:DrawPrimitive;
        var material:IUVMaterial;
        var object:Object3D;
        var uv:UV;
        var sceneX:Float;
        var sceneY:Float;
        var sceneZ:Float;
        var primitive:DrawPrimitive;
        var inv:Matrix3D ;
        var persp:Float;
        
        function checkSession(session:AbstractRenderSession):Void
        {
        	
        	if (Std.is( session, BitmapRenderSession)) {
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
	        
        	if (Std.is( session, BitmapRenderSession)) {
        		_container = session.getContainer(this);
        		_hitPointX -= _container.x;
        		_hitPointY -= _container.y;
        	}
        	
        }
        
        function checkPrimitive(pri:DrawPrimitive):Void
        {
        	if (Std.is( pri, DrawFog))
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
            
            if (pri.contains(screenX, screenY))
            {
                var z:Int = pri.getZ(screenX, screenY);
                if (z < screenZ)
                {
                    if (Std.is( pri, DrawTriangle))
                    {
                        var tri:DrawTriangle = cast( pri, DrawTriangle);
                        var testuv:UV = tri.getUV(screenX, screenY);
                        if (Std.is( tri.material, IUVMaterial)) {
                            var testmaterial:IUVMaterial = (cast( tri.material, IUVMaterial));
                            //return if material pixel is transparent
                            if (!(Std.is( tri.material, BitmapMaterialContainer)) && !(testmaterial.getPixel32(testuv.u, testuv.v) >> 24))
                                return;
                            uv = testuv;
                        }
                        material = testmaterial;
                    } else {
                        uv = null;
                    }
                    screenZ = z;
                    persp = camera.zoom / (1 + screenZ / camera.focus);
                    inv = camera.invView;
					
                    sceneX = screenX / persp * inv.sxx + screenY / persp * inv.sxy + screenZ * inv.sxz + inv.tx;
                    sceneY = screenX / persp * inv.syx + screenY / persp * inv.syy + screenZ * inv.syz + inv.ty;
                    sceneZ = screenX / persp * inv.szx + screenY / persp * inv.szy + screenZ * inv.szz + inv.tz;

                    drawpri = pri;
                    object = pri.source;
                    element = null; // TODO face or segment

                }
            }
        }
        
		function notifySceneUpdate():Void
		{
			//dispatch event
			if (!_updatescene)
				_updatescene = new ViewEvent(ViewEvent.UPDATE_SCENE, this);
				
			dispatchEvent(_updatescene);
		}
		
		function createStatsMenu(event:Event):Void
		{
			statsPanel = new Stats(this, stage.frameRate); 
			statsOpen = false;
		}
		
		function onSessionUpdate(event:SessionEvent):Void
		{
			if (Std.is( event.target, BitmapRenderSession))
				_scene.updatedSessions[event.target] = event.target;
		}
		
		function onCameraTransformChange(e:Object3DEvent):Void
		{
			_updated = true;
		}
		
		function onCameraUpdated(e:CameraEvent):Void
		{
			_updated = true;
		}
		
		function onSessionChange(e:Object3DEvent):Void
		{
			_session.sessions = [e.object.session];
		}
		
        function onMouseDown(e:MouseEvent):Void
        {
            _mousedown = true;
            fireMouseEvent(MouseEvent3D.MOUSE_DOWN, mouseX, mouseY, e.ctrlKey, e.shiftKey);
        }

        function onMouseUp(e:MouseEvent):Void
        {
            _mousedown = false;
            fireMouseEvent(MouseEvent3D.MOUSE_UP, mouseX, mouseY, e.ctrlKey, e.shiftKey);
        }

        function onMouseOut(e:MouseEvent):Void
        {
        	//if (e.eventPhase != EventPhase.AT_TARGET)
        	//	return;
        	fireMouseEvent(MouseEvent3D.MOUSE_OUT, mouseX, mouseY, e.ctrlKey, e.shiftKey);
        }
        
        function onMouseOver(e:MouseEvent):Void
        {
        	//if (e.eventPhase != EventPhase.AT_TARGET)
        	//	return;
            fireMouseEvent(MouseEvent3D.MOUSE_OVER, mouseX, mouseY, e.ctrlKey, e.shiftKey);
        }
        
        function bubbleMouseEvent(event:MouseEvent3D):Void
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
        public var background:Sprite ;
        
        /**
        * A container for 2D overlays positioned over the rendered scene.
        */
        public var hud:Sprite ;
		
        /**
        * Enables/Disables stats panel.
        * 
        * @see away3d.core.stats.Stats
        */
        public var stats:Bool;
        
        /**
        * Keeps track of whether the stats panel is currently open.
        * 
        * @see away3d.core.stats.Stats
        */
        
        public var statsOpen:Bool;
        
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
        public var mouseZeroMove:Bool;

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
        public var forceUpdate:Bool;
      
        public var blockerarray:BlockerArray ;
        /**
        * Clipping area used when rendering.
        * 
        * If null, the visible edges of the screen are located with the <code>Clipping.screen()</code> method.
        * 
        * @see #render()
        * @see away3d.core.render.Clipping.scene()
        */
        public var clip:Clipping;
        
        /**
        * Renderer object used to traverse the scenegraph and output the drawing primitives required to render the scene to the view.
        */
        public function getRenderer():IRenderer{
        	return _renderer;
        }
    	
        public function setRenderer(val:IRenderer):IRenderer{
        	if (_renderer == val)
        		return;
        	
        	_renderer = val;
        	
			_updated = true;
			
        	if (!_renderer)
        		throw new Error("View cannot have renderer set to null");
        	return val;
        }
		
		/**
		* Flag used to determine if the camera has updated the view.
        * 
        * @see #camera
        */
        public function getUpdated():Bool
        {
        	return _updated;
        }
        
        /**
        * Camera used when rendering.
        * 
        * @see #render()
        */
        public function getCamera():Camera3D{
        	return _camera;
        }
    	
        public function setCamera(val:Camera3D):Camera3D{
        	if (_camera == val)
        		return;
        	
        	if (_camera) {
        		_camera.removeOnSceneTransformChange(onCameraTransformChange);
        		_camera.removeOnCameraUpdate(onCameraUpdated);
        	}
        	
        	_camera = val;
        	
        	if (_camera) {
        		_camera.addOnSceneTransformChange(onCameraTransformChange);
        		_camera.addOnCameraUpdate(onCameraUpdated);
        	} else {
        		throw new Error("View cannot have camera set to null");
        	}
        	return val;
        }
        
		/**
		* Scene used when rendering.
        * 
        * @see render()
        */
        public function getScene():Scene3D{
        	return _scene;
        }
    	
        public function setScene(val:Scene3D):Scene3D{
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
        	return val;
        }
        
        /**
        * Session object used to draw all drawing primitives returned from the renderer to the view container.
        * 
        * @see #renderer
        * @see #getContainer()
        */
        public function getSession():AbstractRenderSession{
        	return _session;
        }
    	
        public function setSession(val:AbstractRenderSession):AbstractRenderSession{
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
        	return val;
        }
        
		/**
		 * Creates a new <code>View3D</code> object.
		 * 
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
		public function new(?init:Dynamic = null)
		{
			
			_interactiveLayer = new Sprite();
			_defaultclip = new Clipping();
			_pritraverser = new PrimitiveTraverser();
			_ddo = new DrawDisplayObject();
			_sc = new ScreenVertex();
			screenZ = Infinity;
			inv = new Matrix3D();
			background = new Sprite();
			hud = new Sprite();
			blockerarray = new BlockerArray();
			_ini = cast( Init.parse(init), Init);
			
            var stats:Bool = _ini.getBoolean("stats", true);
			session = cast( _ini.getObject("session"), AbstractRenderSession) || new SpriteRenderSession();
            scene = cast( _ini.getObjectOrInit("scene", Scene3D), Scene3D) || new Scene3D();
            camera = cast( _ini.getObjectOrInit("camera", Camera3D), Camera3D) || new Camera3D({x:0, y:0, z:1000, lookat:"center"});
			renderer = cast( _ini.getObject("renderer"), IRenderer) || new BasicRenderer();
			clip = cast( _ini.getObject("clip", Clipping), Clipping);
			x = _ini.getNumber("x", 0);
			y = _ini.getNumber("y", 0);
			forceUpdate = _ini.getBoolean("forceUpdate", false);
			mouseZeroMove = _ini.getBoolean("mouseZeroMove", false);
			
			//setup blendmode for hidden interactive layer
            _interactiveLayer.blendMode = BlendMode.ALPHA;
            
            //setup view property on traverser
            _pritraverser.view = this;
            
            //setup events on view
            addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
            addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			
			//setup default clip value
            if (!clip)
            	clip = _defaultclip;
            
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
        public function fireMouseEvent(type:String, x:Float, y:Float, ?ctrlKey:Bool = false, ?shiftKey:Bool = false):Void
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
        public function findHit(session:AbstractRenderSession, x:Float, y:Float):Void
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
            
        	if (Std.is( this.session, BitmapRenderSession)) {
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
			if (Std.is( _session, BitmapRenderSession))
				return (cast( _session, BitmapRenderSession)).getBitmapData(this);
			else
				throw new Error("incorrect session object - require BitmapRenderSession");	
		}
		
        /**
        * Clears previously rendered view from all render sessions.
        * 
        * @see #session
        */
        public function clear():Void
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
        public function render():Void
        {
        	//update session
        	if (_session != _internalsession)
        		_internalsession = session;
        	
        	//update renderer
        	if (_session.renderer != cast( _renderer, IPrimitiveConsumer))
        		_session.renderer = cast( _renderer, IPrimitiveConsumer);
        	
            //update scene
            notifySceneUpdate();
        	
        	_oldclip = clip;
            
            //if clip set to default, determine screen clipping
			if (clip == _defaultclip)
            	clip = _defaultclip.screen(this);
	        
            //clear session
            _session.clear(this);
            
            //draw scene into view session
            if (_session.updated) {
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
            
			//revert clip value
			clip = _oldclip;
        	
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
		public function addSourceURL(url:String):Void
		{
			sourceURL = url;
			if (statsPanel)
				statsPanel.addSourceURL(url);
		}

        /**
        * Manually fires a mouseMove3D event.
        */
        public function fireMouseMoveEvent(?force:Bool = false):Void
        {
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
        public function addOnMouseMove(listener:Dynamic):Void
        {
            addEventListener(MouseEvent3D.MOUSE_MOVE, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a mouseMove3D event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function removeOnMouseMove(listener:Dynamic):Void
        {
            removeEventListener(MouseEvent3D.MOUSE_MOVE, listener, false);
        }
		
		/**
		 * Default method for adding a mouseDown3d event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function addOnMouseDown(listener:Dynamic):Void
        {
            addEventListener(MouseEvent3D.MOUSE_DOWN, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a mouseDown3d event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function removeOnMouseDown(listener:Dynamic):Void
        {
            removeEventListener(MouseEvent3D.MOUSE_DOWN, listener, false);
        }
		
		/**
		 * Default method for adding a mouseUp3d event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function addOnMouseUp(listener:Dynamic):Void
        {
            addEventListener(MouseEvent3D.MOUSE_UP, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a 3d mouseUp event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function removeOnMouseUp(listener:Dynamic):Void
        {
            removeEventListener(MouseEvent3D.MOUSE_UP, listener, false);
        }
		
		/**
		 * Default method for adding a 3d mouseOver event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function addOnMouseOver(listener:Dynamic):Void
        {
            addEventListener(MouseEvent3D.MOUSE_OVER, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a 3d mouseOver event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function removeOnMouseOver(listener:Dynamic):Void
        {
            removeEventListener(MouseEvent3D.MOUSE_OVER, listener, false);
        }
		
		/**
		 * Default method for adding a 3d mouseOut event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function addOnMouseOut(listener:Dynamic):Void
        {
            addEventListener(MouseEvent3D.MOUSE_OUT, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a 3d mouseOut event listener.
		 * 
		 * @param	listener		The listener function.
		 */
        public function removeOnMouseOut(listener:Dynamic):Void
        {
            removeEventListener(MouseEvent3D.MOUSE_OUT, listener, false);
        }		
	}
