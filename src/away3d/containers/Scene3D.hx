package away3d.containers;

import flash.display.Sprite;
import away3d.events.ViewEvent;
import flash.events.EventDispatcher;
import away3d.core.math.Matrix3D;
import away3d.core.traverse.ProjectionTraverser;
import away3d.haxeutils.HashMap;
import away3d.core.utils.Init;
import flash.events.Event;
import away3d.core.traverse.LightTraverser;
import away3d.core.utils.Debug;
import away3d.core.base.Object3D;
import away3d.core.traverse.TickTraverser;
import away3d.core.traverse.SessionTraverser;
import away3d.core.base.Mesh;
import away3d.core.render.AbstractRenderSession;
import away3d.core.traverse.Traverser;
import away3d.blockers.ConvexBlock;
import away3d.core.block.ConvexBlocker;

// use namespace arcane;

/**
 * The root container of all 3d objects in a single scene
 */
class Scene3D extends ObjectContainer3D  {
	
	private var _view:View3D;
	private var _currentView:View3D;
	private var _mesh:Mesh;
	private var _time:Int;
	private var _autoUpdate:Bool;
	private var _projtraverser:ProjectionTraverser;
	private var _sessiontraverser:SessionTraverser;
	private var _lighttraverser:LightTraverser;
	public var viewArray:Array<View3D>;
	/**
	 * Traverser object for all custom <code>tick()</code> methods
	 * 
	 * @see away3d.core.base.Object3D#tick()
	 */
	public var tickTraverser:TickTraverser;
	/**
	 * Library of updated 3d objects in the scene.
	 */
	public var updatedObjects:Array<Object3D>;
	/**
	 * Library of updated sessions in the scene.
	 */
	public var updatedSessions:Array<AbstractRenderSession>;
	/**
	 * Library of  all meshes in the scene.
	 */
	public var meshes:Array<Mesh>;
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
		this.viewArray = new Array<View3D>();
		this.tickTraverser = new TickTraverser();
		
		
		var init:Dynamic = null;
		var childarray:Array<Object3D> = [];
		for (__i in 0...initarray.length) {
			var object:Dynamic = initarray[__i];

			if (object != null) {
				if (Std.is(object, Object3D)) {
					childarray.push(object);
				} else {
					init = object;
				}
			}
		}

		//force ownCanvas and ownLights
		if ((init != null)) {
			init.ownCanvas = true;
			init.ownLights = true;
		} else {
			init = {ownCanvas:true, ownLights:true};
		}
		super([init]);
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

			if (child != null) {
				addChild(child);
			}
		}

	}

	/**
	 * Calling manually will update scene specific variables
	 */
	public function update():Void {
		//clear updated objects
		
		updatedObjects = new Array<Object3D>();
		//clear updated sessions
		updatedSessions = new Array<AbstractRenderSession>();
		//traverse lights
		traverse(_lighttraverser);
		//execute projection traverser on each view
		for (_view in viewArray) {

			if (_view != null) {
				_view.camera.update();
				//clear meshes
				meshes = new Array<Mesh>();
				//clear blockers
				_view.blockers = new Array<ConvexBlock>();
				_view.drawPrimitiveStore.blockerDictionary = new HashMap<Object3D, ConvexBlocker>();
				//clear camera view transforms
				_view.cameraVarsStore.reset();
				//clear blockers
				_view.blockerarray.clip = _view.screenClipping;
				//traverse scene
				_projtraverser.view = _view;
				traverse(_projtraverser);
				_time = flash.Lib.getTimer();
				//update materials in meshes
				for (_mesh in meshes) {
					if (_mesh != null) {
						_mesh.updateMaterials(_mesh, _view);
						//update geometry materials
						_mesh.geometry.updateMaterials(_mesh, _view);
						//update elements
						_mesh.geometry.updateElements(_time);
					}
				}

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

