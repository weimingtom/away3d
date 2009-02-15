package away3d.containers;

import flash.display.Sprite;
import away3d.events.ViewEvent;
import flash.events.EventDispatcher;
import away3d.core.math.Matrix3D;
import away3d.core.traverse.ProjectionTraverser;
import flash.utils.Dictionary;
import away3d.core.utils.Init;
import flash.events.Event;
import away3d.core.traverse.LightTraverser;
import away3d.core.utils.Debug;
import away3d.core.base.Object3D;
import away3d.core.traverse.TickTraverser;
import away3d.core.traverse.SessionTraverser;
import away3d.core.base.Mesh;
import away3d.core.traverse.Traverser;


// use namespace arcane;

/**
 * The root container of all 3d objects in a single scene
 */
class Scene3D extends ObjectContainer3D  {
	public var sceneTransform(getSceneTransform, null) : Matrix3D;
	
	private var _view:View3D;
	private var _currentView:View3D;
	private var _mesh:Mesh;
	private var _time:Int;
	private var _autoUpdate:Bool;
	private var _projtraverser:ProjectionTraverser;
	private var _sessiontraverser:SessionTraverser;
	private var _lighttraverser:LightTraverser;
	public var viewDictionary:Dictionary;
	/**
	 * Traverser object for all custom <code>tick()</code> methods
	 * 
	 * @see away3d.core.base.Object3D#tick()
	 */
	public var tickTraverser:TickTraverser;
	/**
	 * Library of updated 3d objects in the scene.
	 */
	public var updatedObjects:Dictionary;
	/**
	 * Library of updated sessions in the scene.
	 */
	public var updatedSessions:Dictionary;
	/**
	 * Library of  all meshes in the scene.
	 */
	public var meshes:Dictionary;
	/**
	 * Defines whether scene events are automatically triggered by the view, or manually by <code>updateScene()</code>
	 */
	public var autoUpdate:Bool;
	/**
	 * Interface for physics (not implemented)
	 */
	public var physics:IPhysicsScene;
	

	/** @private */
	public function internalRemoveView(view:View3D):Void {
		
		view.removeEventListener(ViewEvent.UPDATE_SCENE, onUpdate);
	}

	/** @private */
	public function internalAddView(view:View3D):Void {
		
		view.addEventListener(ViewEvent.UPDATE_SCENE, onUpdate);
	}

	private function onUpdate(event:ViewEvent):Void {
		
		if (autoUpdate) {
			if ((_currentView != null) && _currentView != event.view) {
				Debug.warning("Multiple views detected! Should consider switching to manual update");
			}
			_currentView = event.view;
			update();
		}
	}

	/**
	 * @inheritDoc
	 */
	public override function getSceneTransform():Matrix3D {
		
		if (_transformDirty) {
			_sceneTransformDirty = true;
		}
		if (_sceneTransformDirty) {
			notifySceneTransformChange();
		}
		return transform;
	}

	/**
	 * Creates a new <code>Scene3D</code> object
	 * 
	 * @param	...initarray		An array of 3d objects to be added as children of the scene on instatiation. Can contain an initialisation object
	 */
	public function new(?initarray:Array<Dynamic>) {
		if (initarray == null) initarray = new Array<Dynamic>();
		this._projtraverser = new ProjectionTraverser();
		this._sessiontraverser = new SessionTraverser();
		this._lighttraverser = new LightTraverser();
		this.viewDictionary = new Dictionary();
		this.tickTraverser = new TickTraverser();
		
		
		var init:Dynamic;
		var childarray:Array<Dynamic> = [];
		for (__i in 0...initarray.length) {
			var object:Dynamic = initarray[__i];

			if (Std.is(object, Object3D)) {
				childarray.push(object);
			} else {
				init = object;
			}
		}

		//force ownCanvas and ownLights
		if ((init != null)) {
			init.ownCanvas = true;
			init.ownLights = true;
		} else {
			init = {ownCanvas:true, ownLights:true};
		}
		super(init);
		autoUpdate = ini.getBoolean("autoUpdate", true);
		var ph:Dynamic = ini.getObject("physics");
		if (Std.is(ph, IPhysicsScene)) {
			physics = cast(ph, IPhysicsScene);
		}
		if (Std.is(ph, Bool)) {
			if (ph == true) {
				// new RobPhysicsEngine();
				physics = null;
			}
		}
		if (Std.is(ph, Dynamic)) {
			// new RobPhysicsEngine(ph); // ph - init object
			physics = null;
		}
		for (__i in 0...childarray.length) {
			var child:Object3D = childarray[__i];

			addChild(child);
		}

	}

	/**
	 * Calling manually will update scene specific variables
	 */
	public function update():Void {
		//clear updated objects
		
		updatedObjects = new Dictionary();
		//clear updated sessions
		updatedSessions = new Dictionary();
		//traverse lights
		traverse(_lighttraverser);
		//execute projection traverser on each view
		var __keys:Iterator<Dynamic> = untyped (__keys__(viewDictionary)).iterator();
		for (__key in __keys) {
			_view = viewDictionary[cast __key];

			_view.camera.update();
			//clear meshes
			meshes = new Dictionary();
			//clear blockers
			_view.blockers = new Dictionary();
			_view.drawPrimitiveStore.blockerDictionary = new Dictionary();
			//clear camera view transforms
			_view.cameraVarsStore.reset();
			//clear blockers
			_view.blockerarray.clip = _view.screenClipping;
			//traverse scene
			_projtraverser.view = _view;
			traverse(_projtraverser);
			_time = flash.Lib.getTimer();
			//update materials in meshes
			var __keys:Iterator<Dynamic> = untyped (__keys__(meshes)).iterator();
			for (__key in __keys) {
				_mesh = meshes[cast __key];

				_mesh.updateMaterials(_mesh, _view);
				//update geometry materials
				_mesh.geometry.updateMaterials(_mesh, _view);
				//update elements
				_mesh.geometry.updateElements(_time);
			}

		}

		//traverse sessions
		traverse(_sessiontraverser);
	}

	/**
	 * Calling manually will update 3d objects that execute updates on their <code>tick()</code> methods.
	 * Uses the <code>TickTraverser</code> to traverse all tick methods in the scene.
	 * 
	 * @see	away3d.core.base.Object3D#tick()
	 * @see	away3d.core.traverse.TickTraverser
	 */
	public function updateTime(?time:Int=-1):Void {
		//set current time
		
		if (time == -1) {
			time = flash.Lib.getTimer();
		}
		//traverser scene ticks
		tickTraverser.now = time;
		traverse(tickTraverser);
		if (physics != null) {
			physics.updateTime(time);
		}
	}

}

