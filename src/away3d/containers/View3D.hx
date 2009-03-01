package away3d.containers;

import away3d.haxeutils.Error;
import away3d.core.utils.ValueObject;
import away3d.materials.IMaterial;
import away3d.core.utils.CameraVarsStore;
import flash.events.EventDispatcher;
import away3d.core.draw.DrawFog;
import away3d.core.project.ConvexBlockProjector;
import flash.display.BitmapData;
import flash.utils.Dictionary;
import flash.events.Event;
import away3d.core.render.BasicRenderer;
import away3d.cameras.Camera3D;
import flash.display.Stage;
import away3d.events.ClippingEvent;
import away3d.core.render.SpriteRenderSession;
import flash.events.MouseEvent;
import away3d.core.utils.DrawPrimitiveStore;
import away3d.core.project.MeshProjector;
import flash.geom.Point;
import away3d.core.render.IRenderer;
import away3d.core.draw.IPrimitiveConsumer;
import away3d.core.draw.ScreenVertex;
import away3d.core.clip.Clipping;
import away3d.core.base.Object3D;
import away3d.core.project.DofSpriteProjector;
import away3d.core.render.BitmapRenderSession;
import away3d.materials.BitmapMaterialContainer;
import away3d.events.CameraEvent;
import flash.display.BlendMode;
import away3d.core.clip.RectangleClipping;
import away3d.core.utils.Init;
import flash.display.DisplayObject;
import away3d.core.render.AbstractRenderSession;
import away3d.events.Object3DEvent;
import away3d.core.draw.DrawDisplayObject;
import flash.display.Sprite;
import away3d.core.stats.Stats;
import away3d.blockers.ConvexBlock;
import away3d.events.ViewEvent;
import away3d.materials.IUVMaterial;
import flash.display.StageScaleMode;
import away3d.core.draw.DrawTriangle;
import away3d.core.draw.DrawPrimitive;
import away3d.core.base.UV;
import away3d.core.project.ObjectContainerProjector;
import away3d.core.project.MovieClipSpriteProjector;
import away3d.core.math.Matrix3D;
import away3d.core.traverse.PrimitiveTraverser;
import away3d.core.project.DirSpriteProjector;
import away3d.events.MouseEvent3D;
import away3d.core.project.SpriteProjector;
import away3d.core.block.BlockerArray;
import away3d.events.SessionEvent;
import flash.display.LoaderInfo;
import away3d.core.traverse.Traverser;


/**
 * Dispatched when a user moves the cursor while it is over a 3d object
 * 
 * @eventType away3d.events.MouseEvent3D
 */
// [Event(name="mouseMove", type="away3d.events.MouseEvent3D")]

/**
 * Dispatched when a user presses the let hand mouse button while the cursor is over a 3d object
 * 
 * @eventType away3d.events.MouseEvent3D
 */
// [Event(name="mouseDown", type="away3d.events.MouseEvent3D")]

/**
 * Dispatched when a user releases the let hand mouse button while the cursor is over a 3d object
 * 
 * @eventType away3d.events.MouseEvent3D
 */
// [Event(name="mouseUp", type="away3d.events.MouseEvent3D")]

/**
 * Dispatched when a user moves the cursor over a 3d object
 * 
 * @eventType away3d.events.MouseEvent3D
 */
// [Event(name="mouseOver", type="away3d.events.MouseEvent3D")]

/**
 * Dispatched when a user moves the cursor away from a 3d object
 * 
 * @eventType away3d.events.MouseEvent3D
 */
// [Event(name="mouseOut", type="away3d.events.MouseEvent3D")]

// use namespace arcane;

/**
 * Sprite container used for storing camera, scene, session, renderer and clip references, and resolving mouse events
 */
class View3D extends Sprite  {
	public var renderer(getRenderer, setRenderer) : IRenderer;
	public var updated(getUpdated, null) : Bool;
	public var clipping(getClipping, setClipping) : Clipping;
	public var camera(getCamera, setCamera) : Camera3D;
	public var scene(getScene, setScene) : Scene3D;
	public var session(getSession, setSession) : AbstractRenderSession;
	public var screenClipping(getScreenClipping, null) : Clipping;
	public var drawPrimitiveStore(getDrawPrimitiveStore, null) : DrawPrimitiveStore;
	public var cameraVarsStore(getCameraVarsStore, null) : CameraVarsStore;
	
	/** @private */
	public var _screenClipping:Clipping;
	/** @private */
	public var _interactiveLayer:Sprite;
	/** @private */
	public var _convexBlockProjector:ConvexBlockProjector;
	/** @private */
	public var _dirSpriteProjector:DirSpriteProjector;
	/** @private */
	public var _dofSpriteProjector:DofSpriteProjector;
	/** @private */
	public var _meshProjector:MeshProjector;
	/** @private */
	public var _movieClipSpriteProjector:MovieClipSpriteProjector;
	/** @private */
	public var _objectContainerProjector:ObjectContainerProjector;
	/** @private */
	public var _spriteProjector:SpriteProjector;
	private var _loaderWidth:Float;
	private var _loaderHeight:Float;
	private var _loaderDirty:Bool;
	private var _screenClippingDirty:Bool;
	private var _viewZero:Point;
	private var _x:Float;
	private var _y:Float;
	private var _stageWidth:Float;
	private var _stageHeight:Float;
	private var _drawPrimitiveStore:DrawPrimitiveStore;
	private var _cameraVarsStore:CameraVarsStore;
	private var _scene:Scene3D;
	private var _session:AbstractRenderSession;
	private var _clipping:Clipping;
	private var _camera:Camera3D;
	private var _renderer:IRenderer;
	private var _ini:Init;
	private var _mousedown:Bool;
	private var _lastmove_mouseX:Float;
	private var _lastmove_mouseY:Float;
	private var _internalsession:AbstractRenderSession;
	private var _updatescene:ViewEvent;
	private var _renderComplete:ViewEvent;
	private var _updated:Bool;
	private var _cleared:Bool;
	private var _blocker:ConvexBlock;
	private var _pritraverser:PrimitiveTraverser;
	private var _ddo:DrawDisplayObject;
	private var _container:DisplayObject;
	private var _hitPointX:Float;
	private var _hitPointY:Float;
	private var _sc:ScreenVertex;
	private var _consumer:IPrimitiveConsumer;
	private var screenX:Float;
	private var screenY:Float;
	private var screenZ:Float;
	private var element:Dynamic;
	private var drawpri:DrawPrimitive;
	private var material:IUVMaterial;
	private var object:Object3D;
	private var uv:UV;
	private var sceneX:Float;
	private var sceneY:Float;
	private var sceneZ:Float;
	private var primitive:DrawPrimitive;
	private var inv:Matrix3D;
	private var persp:Float;
	private var _mouseIsOverView:Bool;
	public var viewTimer:Int;
	/**
	 * A background sprite positioned under the rendered scene.
	 */
	public var background:Sprite;
	/**
	 * A container for 2D overlays positioned over the rendered scene.
	 */
	public var hud:Sprite;
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
	 * Defines whether the view always redraws on a render, or just redraws what 3d objects change. Defaults to false.
	 * 
	 * @see #render()
	 */
	public var forceUpdate:Bool;
	public var blockerarray:BlockerArray;
	public var blockers:Dictionary;
	

	/** @private */
	public function dispatchMouseEvent(event:MouseEvent3D):Void {
		
		if (!hasEventListener(event.type)) {
			return;
		}
		dispatchEvent(event);
	}

	private function checkSession(session:AbstractRenderSession):Void {
		
		if (Std.is(session, BitmapRenderSession)) {
			_container = session.getContainer(this);
			_hitPointX += _container.x;
			_hitPointY += _container.y;
		}
		if (session.getContainer(this).hitTestPoint(_hitPointX, _hitPointY)) {
			for (__i in 0...session.getConsumer(this).list().length) {
				primitive = session.getConsumer(this).list()[__i];

				if (primitive != null) {
					checkPrimitive(primitive);
				}
			}

			for (__i in 0...session.sessions.length) {
				session = session.sessions[__i];

				if (session != null) {
					checkSession(session);
				}
			}

		}
		if (Std.is(session, BitmapRenderSession)) {
			_container = session.getContainer(this);
			_hitPointX -= _container.x;
			_hitPointY -= _container.y;
		}
	}

	private function checkPrimitive(pri:DrawPrimitive):Void {
		
		if (Std.is(pri, DrawFog)) {
			return;
		}
		if (pri.source == null || !pri.source._mouseEnabled) {
			return;
		}
		if (pri.minX > screenX) {
			return;
		}
		if (pri.maxX < screenX) {
			return;
		}
		if (pri.minY > screenY) {
			return;
		}
		if (pri.maxY < screenY) {
			return;
		}
		if (Std.is(pri, DrawDisplayObject) && !(cast(pri, DrawDisplayObject)).displayobject.hitTestPoint(_hitPointX, _hitPointY, true)) {
			return;
		}
		if (pri.contains(screenX, screenY)) {
			var z:Float = pri.getZ(screenX, screenY);
			if (z < screenZ) {
				if (Std.is(pri, DrawTriangle)) {
					var tri:DrawTriangle = cast(pri, DrawTriangle);
					var testuv:UV = tri.getUV(screenX, screenY);
					if (Std.is(tri.material, IUVMaterial)) {
						var testmaterial:IUVMaterial = (cast(tri.material, IUVMaterial));
						//return if material pixel is transparent
						if (!(Std.is(tri.material, BitmapMaterialContainer)) && (testmaterial.getPixel32(testuv.u, testuv.v) >> 24) == 0) {
							return;
						}
						uv = testuv;
						material = testmaterial;
					}
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
				// TODO face or segment
				element = null;
			}
		}
	}

	private function notifySceneUpdate():Void {
		//dispatch event
		
		if (_updatescene == null) {
			_updatescene = new ViewEvent(ViewEvent.UPDATE_SCENE, this);
		}
		dispatchEvent(_updatescene);
	}

	private function notifyRenderComplete():Void {
		//dispatch event
		
		if (_renderComplete == null) {
			_renderComplete = new ViewEvent(ViewEvent.RENDER_COMPLETE, this);
		}
		dispatchEvent(_renderComplete);
	}

	private function createStatsMenu(event:Event):Void {
		
		statsPanel = new Stats(this, flash.Lib.current.stage.frameRate);
		statsOpen = false;
		flash.Lib.current.stage.addEventListener(Event.RESIZE, onStageResized);
	}

	private function onStageResized(event:Event):Void {
		
		_screenClippingDirty = true;
	}

	private function onSessionUpdate(event:SessionEvent):Void {
		
		if (Std.is(event.target, BitmapRenderSession)) {
			_scene.updatedSessions[untyped event.target] = event.target;
		}
	}

	private function onCameraTransformChange(e:Object3DEvent):Void {
		
		_updated = true;
	}

	private function onCameraUpdated(e:CameraEvent):Void {
		
		_updated = true;
	}

	private function onClippingUpdated(e:ClippingEvent):Void {
		
		_updated = true;
	}

	private function onSessionChange(e:Object3DEvent):Void {
		
		_session.sessions = [e.object.session];
	}

	private function onMouseDown(e:MouseEvent):Void {
		
		_mousedown = true;
		fireMouseEvent(MouseEvent3D.MOUSE_DOWN, mouseX, mouseY, e.ctrlKey, e.shiftKey);
	}

	private function onMouseUp(e:MouseEvent):Void {
		
		_mousedown = false;
		fireMouseEvent(MouseEvent3D.MOUSE_UP, mouseX, mouseY, e.ctrlKey, e.shiftKey);
	}

	private function onRollOut(e:MouseEvent):Void {
		
		_mouseIsOverView = false;
		fireMouseEvent(MouseEvent3D.MOUSE_OUT, mouseX, mouseY, e.ctrlKey, e.shiftKey);
	}

	private function onRollOver(e:MouseEvent):Void {
		
		_mouseIsOverView = true;
		fireMouseEvent(MouseEvent3D.MOUSE_OVER, mouseX, mouseY, e.ctrlKey, e.shiftKey);
	}

	private function bubbleMouseEvent(event:MouseEvent3D):Array<Dynamic> {
		
		var tar:Object3D = event.object;
		var tarArray:Array<Dynamic> = [];
		while (tar != null) {
			tarArray.unshift(tar);
			tar.dispatchMouseEvent(event);
			tar = tar.parent;
		}

		return tarArray;
	}

	private function traverseRollEvent(event:MouseEvent3D, array:Array<Dynamic>):Void {
		
		for (__i in 0...array.length) {
			var tar:Object3D = array[__i];

			if (tar != null) {
				tar.dispatchMouseEvent(event);
			}
		}

	}

	/**
	 * Renderer object used to traverse the scenegraph and output the drawing primitives required to render the scene to the view.
	 */
	public function getRenderer():IRenderer {
		
		return _renderer;
	}

	public function setRenderer(val:IRenderer):IRenderer {
		
		if (_renderer == val) {
			return val;
		}
		_renderer = val;
		_updated = true;
		if (_renderer == null) {
			throw new Error("View cannot have renderer set to null");
		}
		return val;
	}

	/**
	 * Flag used to determine if the camera has updated the view.
	 * 
	 * @see #camera
	 */
	public function getUpdated():Bool {
		
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
	public function getClipping():Clipping {
		
		return _clipping;
	}

	public function setClipping(val:Clipping):Clipping {
		
		if (_clipping == val) {
			return val;
		}
		if ((_clipping != null)) {
			_clipping.removeOnClippingUpdate(onClippingUpdated);
		}
		_clipping = val;
		_clipping.view = this;
		if ((_clipping != null)) {
			_clipping.addOnClippingUpdate(onClippingUpdated);
		} else {
			throw new Error("View cannot have clip set to null");
		}
		_updated = true;
		_screenClippingDirty = true;
		return val;
	}

	/**
	 * Camera used when rendering.
	 * 
	 * @see #render()
	 */
	public function getCamera():Camera3D {
		
		return _camera;
	}

	public function setCamera(val:Camera3D):Camera3D {
		
		if (_camera == val) {
			return val;
		}
		if ((_camera != null)) {
			_camera.removeOnSceneTransformChange(onCameraTransformChange);
			_camera.removeOnCameraUpdate(onCameraUpdated);
		}
		_camera = val;
		_camera.view = this;
		_updated = true;
		if ((_camera != null)) {
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
	public function getScene():Scene3D {
		
		return _scene;
	}

	public function setScene(val:Scene3D):Scene3D {
		
		if (_scene == val) {
			return val;
		}
		if ((_scene != null)) {
			_scene.internalRemoveView(this);
			_scene.viewDictionary[untyped this] = null;
			_scene.removeOnSessionChange(onSessionChange);
			if ((_session != null)) {
				_session.internalRemoveSceneSession(_scene.ownSession);
			}
		}
		_scene = val;
		_updated = true;
		if ((_scene != null)) {
			_scene.internalAddView(this);
			_scene.addOnSessionChange(onSessionChange);
			_scene.viewDictionary[untyped this] = this;
			if ((_session != null)) {
				_session.internalAddSceneSession(_scene.ownSession);
			}
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
	public function getSession():AbstractRenderSession {
		
		return _session;
	}

	public function setSession(val:AbstractRenderSession):AbstractRenderSession {
		
		if (_session == val) {
			return val;
		}
		if ((_session != null)) {
			_session.removeOnSessionUpdate(onSessionUpdate);
			if ((_scene != null)) {
				_session.internalRemoveSceneSession(_scene.ownSession);
			}
		}
		_session = val;
		_updated = true;
		if ((_session != null)) {
			_session.addOnSessionUpdate(onSessionUpdate);
			if ((_scene != null)) {
				_session.internalAddSceneSession(_scene.ownSession);
			}
		} else {
			throw new Error("View cannot have session set to null");
		}
		//clear children
		while ((numChildren > 0)) {
			removeChildAt(0);
		}

		//add children
		addChild(background);
		addChild(_session.getContainer(this));
		addChild(_interactiveLayer);
		addChild(hud);
		return val;
	}

	public function getScreenClipping():Clipping {
		
		if (_screenClippingDirty) {
			_screenClippingDirty = false;
			return _screenClipping = _clipping.screen(this, _loaderWidth, _loaderHeight);
		}
		return _screenClipping;
	}

	public function getDrawPrimitiveStore():DrawPrimitiveStore {
		
		return _drawPrimitiveStore;
	}

	public function getCameraVarsStore():CameraVarsStore {
		
		return _cameraVarsStore;
	}

	/**
	 * Creates a new <code>View3D</code> object.
	 * 
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(?init:Dynamic=null) {
		// autogenerated
		super();
		this._interactiveLayer = new Sprite();
		this._convexBlockProjector = new ConvexBlockProjector();
		this._dirSpriteProjector = new DirSpriteProjector();
		this._dofSpriteProjector = new DofSpriteProjector();
		this._meshProjector = new MeshProjector();
		this._movieClipSpriteProjector = new MovieClipSpriteProjector();
		this._objectContainerProjector = new ObjectContainerProjector();
		this._spriteProjector = new SpriteProjector();
		this._viewZero = new Point();
		this._drawPrimitiveStore = new DrawPrimitiveStore();
		this._cameraVarsStore = new CameraVarsStore();
		this._pritraverser = new PrimitiveTraverser();
		this._ddo = new DrawDisplayObject();
		this._sc = new ScreenVertex();
		this.screenZ = Math.POSITIVE_INFINITY;
		this.inv = new Matrix3D();
		this.background = new Sprite();
		this.hud = new Sprite();
		this.blockerarray = new BlockerArray();
		
		
		_ini = cast(Init.parse(init), Init);
		var stats:Bool = _ini.getBoolean("stats", true);
		var iniObject:Dynamic = _ini.getObject("session");
		if (iniObject != null) {
			session = cast(iniObject, AbstractRenderSession);
		}
		if (session == null)  {
			session = new SpriteRenderSession();
		};
		scene = _ini.getObjectOrInit("scene", Scene3D);
		if (scene == null)  {
			scene = new Scene3D();
		};
		camera = _ini.getObjectOrInit("camera", Camera3D);
		if (camera == null)  {
			camera = new Camera3D({x:0, y:0, z:-1000, lookat:"center"});
		};
		renderer = _ini.getObject("renderer");
		if (renderer == null)  {
			renderer = new BasicRenderer();
		};
		clipping = _ini.getObject("clipping", Clipping);
		if (clipping == null)  {
			clipping = new RectangleClipping();
		};
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
		addEventListener(MouseEvent.ROLL_OUT, onRollOut);
		addEventListener(MouseEvent.ROLL_OVER, onRollOver);
		//setup stats panel creation
		if (stats) {
			addEventListener(Event.ADDED_TO_STAGE, createStatsMenu);
		}
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
	public function fireMouseEvent(type:String, x:Float, y:Float, ?ctrlKey:Bool=false, ?shiftKey:Bool=false):Void {
		
		findHit(_internalsession, x, y);
		var event:MouseEvent3D = getMouseEvent(type);
		var outArray:Array<Dynamic> = [];
		var overArray:Array<Dynamic> = [];
		event.ctrlKey = ctrlKey;
		event.shiftKey = shiftKey;
		if (type != MouseEvent3D.MOUSE_OUT && type != MouseEvent3D.MOUSE_OVER) {
			dispatchMouseEvent(event);
			bubbleMouseEvent(event);
		}
		//catch mouseOver/mouseOut rollOver/rollOut object3d events
		if (mouseObject != object || mouseMaterial != material) {
			if (mouseObject != null) {
				event = getMouseEvent(MouseEvent3D.MOUSE_OUT);
				event.object = mouseObject;
				event.material = mouseMaterial;
				event.ctrlKey = ctrlKey;
				event.shiftKey = shiftKey;
				dispatchMouseEvent(event);
				outArray = bubbleMouseEvent(event);
				buttonMode = false;
			}
			if (object != null) {
				event = getMouseEvent(MouseEvent3D.MOUSE_OVER);
				event.ctrlKey = ctrlKey;
				event.shiftKey = shiftKey;
				dispatchMouseEvent(event);
				overArray = bubbleMouseEvent(event);
				buttonMode = object.useHandCursor;
			}
			if (mouseObject != object) {
				var i:Int = 0;
				while ((outArray[i] != null) && outArray[i] == overArray[i]) {
					i++;
				}

				if (mouseObject != null) {
					event = getMouseEvent(MouseEvent3D.ROLL_OUT);
					event.object = mouseObject;
					event.material = mouseMaterial;
					event.ctrlKey = ctrlKey;
					event.shiftKey = shiftKey;
					traverseRollEvent(event, outArray.slice(i));
				}
				if (object != null) {
					event = getMouseEvent(MouseEvent3D.ROLL_OVER);
					event.ctrlKey = ctrlKey;
					event.shiftKey = shiftKey;
					traverseRollEvent(event, overArray.slice(i));
				}
			}
			mouseObject = object;
			mouseMaterial = material;
		}
	}

	/** 
	 * Finds the object that is rendered under a certain view coordinate. Used for mouse click events.
	 */
	public function findHit(session:AbstractRenderSession, x:Float, y:Float):Void {
		
		screenX = x;
		screenY = y;
		screenZ = Math.POSITIVE_INFINITY;
		material = null;
		object = null;
		if (session == null || !_mouseIsOverView) {
			return;
		}
		_hitPointX = flash.Lib.current.stage.mouseX;
		_hitPointY = flash.Lib.current.stage.mouseY;
		if (Std.is(this.session, BitmapRenderSession)) {
			_container = this.session.getContainer(this);
			_hitPointX += _container.x;
			_hitPointY += _container.y;
		}
		checkSession(session);
	}

	/**
	 * Returns a 3d mouse event object populated with the properties from the hit point.
	 */
	public function getMouseEvent(type:String):MouseEvent3D {
		
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
	public function getContainer():DisplayObject {
		
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
	public function getBitmapData():BitmapData {
		
		if (Std.is(_session, BitmapRenderSession)) {
			return (cast(_session, BitmapRenderSession)).getBitmapData(this);
		} else {
			throw new Error("incorrect session object - require BitmapRenderSession");
		}
		
		// autogenerated
		return null;
	}

	public function updateScreenClipping():Void {
		//check for loaderInfo update
		
		try {
			_loaderWidth = loaderInfo.width;
			_loaderHeight = loaderInfo.height;
			if (_loaderDirty) {
				_loaderDirty = false;
				_screenClippingDirty = true;
			}
		} catch (error:Dynamic) {
			_loaderDirty = true;
			_loaderWidth = flash.Lib.current.stage.stageWidth;
			_loaderHeight = flash.Lib.current.stage.stageHeight;
		}

		//check for global view movement
		_viewZero.x = 0;
		_viewZero.y = 0;
		_viewZero = localToGlobal(_viewZero);
		if (_x != _viewZero.x || _y != _viewZero.y || flash.Lib.current.stage.scaleMode != StageScaleMode.NO_SCALE && (_stageWidth != flash.Lib.current.stage.stageWidth || _stageHeight != flash.Lib.current.stage.stageHeight)) {
			_x = _viewZero.x;
			_y = _viewZero.y;
			_stageWidth = flash.Lib.current.stage.stageWidth;
			_stageHeight = flash.Lib.current.stage.stageHeight;
			_screenClippingDirty = true;
		}
	}

	/**
	 * Clears previously rendered view from all render sessions.
	 * 
	 * @see #session
	 */
	public function clear():Void {
		
		_updated = true;
		if ((_internalsession != null)) {
			session.clear(this);
		}
	}

	/**
	 * Renders a snapshot of the view to the render session's view container.
	 * 
	 * @see #session
	 */
	public function render():Void {
		
		viewTimer = flash.Lib.getTimer();
		//update scene
		notifySceneUpdate();
		//update session
		if (_internalsession != _session) {
			_internalsession = _session;
		}
		//update renderer
		if (_session.renderer != cast(_renderer, IPrimitiveConsumer)) {
			_session.renderer = cast(_renderer, IPrimitiveConsumer);
		}
		//clear session
		_session.clear(this);
		//clear drawprimitives
		_drawPrimitiveStore.reset();
		//draw scene into view session
		if (_session.updated) {
			if (Std.is(_scene.ownSession, SpriteRenderSession)) {
				(cast(_scene.ownSession, SpriteRenderSession)).cacheAsBitmap = true;
			}
			_ddo.view = this;
			_ddo.displayobject = _scene.session.getContainer(this);
			_ddo.session = _session;
			_ddo.screenvertex = _sc;
			_ddo.calc();
			_consumer = _session.getConsumer(this);
			_consumer.primitive(_ddo);
		}
		//traverse blockers
		var __keys:Iterator<Dynamic> = untyped (__keys__(blockers)).iterator();
		for (__key in __keys) {
			_blocker = blockers[untyped __key];

			if (_blocker != null) {
				_convexBlockProjector.blockers(_blocker, cameraVarsStore.viewTransformDictionary[untyped _blocker], blockerarray);
			}
		}

		//traverse primitives
		_scene.traverse(_pritraverser);
		//render scene
		_session.render(this);
		_updated = false;
		//dispatch stats
		if (statsOpen) {
			statsPanel.updateStats(_session.getTotalFaces(this), camera);
		}
		//debug check
		Init.checkUnusedArguments();
		//check for mouse interaction
		fireMouseMoveEvent();
		//notify render complete
		notifyRenderComplete();
	}

	/**
	 * Defines a source url string that can be accessed though a View Source option in the right-click menu.
	 * 
	 * Requires the stats panel to be enabled.
	 * 
	 * @param	url		The url to the source files.
	 */
	public function addSourceURL(url:String):Void {
		
		sourceURL = url;
		if ((statsPanel != null)) {
			statsPanel.addSourceURL(url);
		}
	}

	/**
	 * Manually fires a mouseMove3D event.
	 */
	public function fireMouseMoveEvent(?force:Bool=false):Void {
		
		if (!_mouseIsOverView) {
			return;
		}
		if (!(mouseZeroMove || force)) {
			if ((mouseX == _lastmove_mouseX) && (mouseY == _lastmove_mouseY)) {
				return;
			}
		}
		fireMouseEvent(MouseEvent3D.MOUSE_MOVE, mouseX, mouseY);
		_lastmove_mouseX = mouseX;
		_lastmove_mouseY = mouseY;
	}

	/**
	 * Default method for adding a mouseMove3d event listener.
	 * 
	 * @param	listener		The listener function.
	 */
	public function addOnMouseMove(listener:Dynamic):Void {
		
		addEventListener(MouseEvent3D.MOUSE_MOVE, listener, false, 0, false);
	}

	/**
	 * Default method for removing a mouseMove3D event listener.
	 * 
	 * @param	listener		The listener function.
	 */
	public function removeOnMouseMove(listener:Dynamic):Void {
		
		removeEventListener(MouseEvent3D.MOUSE_MOVE, listener, false);
	}

	/**
	 * Default method for adding a mouseDown3d event listener.
	 * 
	 * @param	listener		The listener function.
	 */
	public function addOnMouseDown(listener:Dynamic):Void {
		
		addEventListener(MouseEvent3D.MOUSE_DOWN, listener, false, 0, false);
	}

	/**
	 * Default method for removing a mouseDown3d event listener.
	 * 
	 * @param	listener		The listener function.
	 */
	public function removeOnMouseDown(listener:Dynamic):Void {
		
		removeEventListener(MouseEvent3D.MOUSE_DOWN, listener, false);
	}

	/**
	 * Default method for adding a mouseUp3d event listener.
	 * 
	 * @param	listener		The listener function.
	 */
	public function addOnMouseUp(listener:Dynamic):Void {
		
		addEventListener(MouseEvent3D.MOUSE_UP, listener, false, 0, false);
	}

	/**
	 * Default method for removing a 3d mouseUp event listener.
	 * 
	 * @param	listener		The listener function.
	 */
	public function removeOnMouseUp(listener:Dynamic):Void {
		
		removeEventListener(MouseEvent3D.MOUSE_UP, listener, false);
	}

	/**
	 * Default method for adding a 3d mouseOver event listener.
	 * 
	 * @param	listener		The listener function.
	 */
	public function addOnMouseOver(listener:Dynamic):Void {
		
		addEventListener(MouseEvent3D.MOUSE_OVER, listener, false, 0, false);
	}

	/**
	 * Default method for removing a 3d mouseOver event listener.
	 * 
	 * @param	listener		The listener function.
	 */
	public function removeOnMouseOver(listener:Dynamic):Void {
		
		removeEventListener(MouseEvent3D.MOUSE_OVER, listener, false);
	}

	/**
	 * Default method for adding a 3d mouseOut event listener.
	 * 
	 * @param	listener		The listener function.
	 */
	public function addOnMouseOut(listener:Dynamic):Void {
		
		addEventListener(MouseEvent3D.MOUSE_OUT, listener, false, 0, false);
	}

	/**
	 * Default method for removing a 3d mouseOut event listener.
	 * 
	 * @param	listener		The listener function.
	 */
	public function removeOnMouseOut(listener:Dynamic):Void {
		
		removeEventListener(MouseEvent3D.MOUSE_OUT, listener, false);
	}

}

