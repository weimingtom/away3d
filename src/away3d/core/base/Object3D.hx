package away3d.core.base;

import away3d.haxeutils.Error;
import away3d.haxeutils.BlendModeUtils;
import flash.events.EventDispatcher;
import away3d.containers.Scene3D;
import away3d.containers.ObjectContainer3D;
import away3d.primitives.WireSphere;
import away3d.loaders.utils.MaterialLibrary;
import flash.events.Event;
import away3d.loaders.utils.GeometryLibrary;
import away3d.core.render.SpriteRenderSession;
import away3d.core.light.ILightConsumer;
import away3d.core.utils.IClonable;
import away3d.primitives.AbstractWirePrimitive;
import away3d.core.draw.IPrimitiveConsumer;
import away3d.core.render.BitmapRenderSession;
import away3d.loaders.utils.AnimationLibrary;
import flash.display.BlendMode;
import away3d.core.utils.Init;
import away3d.core.utils.Debug;
import away3d.core.render.AbstractRenderSession;
import away3d.events.Object3DEvent;
import away3d.core.math.Quaternion;
import away3d.core.light.LightArray;
import away3d.core.math.Number3D;
import away3d.core.math.Matrix3D;
import away3d.primitives.WireCube;
import away3d.events.MouseEvent3D;
import away3d.events.SessionEvent;
import away3d.core.traverse.Traverser;


/**
 * Dispatched when the local transform matrix of the 3d object changes.
 * 
 * @eventType away3d.events.Object3DEvent
 * @see	#transform
 */
// [Event(name="transformChanged", type="away3d.events.Object3DEvent")]

/**
 * Dispatched when the scene transform matrix of the 3d object changes.
 * 
 * @eventType away3d.events.Object3DEvent
 * @see	#sceneTransform
 */
// [Event(name="scenetransformChanged", type="away3d.events.Object3DEvent")]

/**
 * Dispatched when the parent scene of the 3d object changes.
 * 
 * @eventType away3d.events.Object3DEvent
 * @see	#scene
 */
// [Event(name="sceneChanged", type="away3d.events.Object3DEvent")]

/**
 * Dispatched when the render session property of the 3d object changes.
 * 
 * @eventType away3d.events.Object3DEvent
 * @see	#session
 */
// [Event(name="sessionChanged", type="away3d.events.Object3DEvent")]

/**
 * Dispatched when the render session property of the 3d object updates its contents.
 * 
 * @eventType away3d.events.Object3DEvent
 * @see	#session
 */
// [Event(name="sessionUpdated", type="away3d.events.Object3DEvent")]

/**
 * Dispatched when the bounding dimensions of the 3d object changes.
 * 
 * @eventType away3d.events.Object3DEvent
 * @see	#minX
 * @see	#maxX
 * @see	#minY
 * @see	#maxY
 * @see	#minZ
 * @see	#maxZ
 */
// [Event(name="dimensionsChanged", type="away3d.events.Object3DEvent")]

/**
 * Dispatched when a user moves the cursor while it is over the 3d object.
 * 
 * @eventType away3d.events.MouseEvent3D
 */
// [Event(name="mouseMove", type="away3d.events.MouseEvent3D")]

/**
 * Dispatched when a user presses the left hand mouse button while the cursor is over the 3d object.
 * 
 * @eventType away3d.events.MouseEvent3D
 */
// [Event(name="mouseDown", type="away3d.events.MouseEvent3D")]

/**
 * Dispatched when a user releases the left hand mouse button while the cursor is over the 3d object.
 * 
 * @eventType away3d.events.MouseEvent3D
 */
// [Event(name="mouseUp", type="away3d.events.MouseEvent3D")]

/**
 * Dispatched when a user moves the cursor over the 3d object.
 * 
 * @eventType away3d.events.MouseEvent3D
 */
// [Event(name="mouseOver", type="away3d.events.MouseEvent3D")]

/**
 * Dispatched when a user moves the cursor away from the 3d object.
 * 
 * @eventType away3d.events.MouseEvent3D
 */
// [Event(name="mouseOut", type="away3d.events.MouseEvent3D")]

/**
 * Dispatched when a user rolls over the 3d object.
 * 
 * @eventType away3d.events.MouseEvent3D
 */
// [Event(name="rollOver", type="away3d.events.MouseEvent3D")]

/**
 * Dispatched when a user rolls out of the 3d object.
 * 
 * @eventType away3d.events.MouseEvent3D
 */
// [Event(name="rollOut", type="away3d.events.MouseEvent3D")]

// use namespace arcane;

/**
 * Base class for all 3d objects.
 */
class Object3D extends EventDispatcher, implements IClonable {
	public var lookingAtTarget(getLookingAtTarget, null) : Number3D;
	public var parentmaxX(getParentmaxX, null) : Float;
	public var parentminX(getParentminX, null) : Float;
	public var parentmaxY(getParentmaxY, null) : Float;
	public var parentminY(getParentminY, null) : Float;
	public var parentmaxZ(getParentmaxZ, null) : Float;
	public var parentminZ(getParentminZ, null) : Float;
	public var parentBoundingRadius(getParentBoundingRadius, null) : Float;
	public var debugBoundingBox(getDebugBoundingBox, null) : WireCube;
	public var debugBoundingSphere(getDebugBoundingSphere, null) : WireSphere;
	public var session(getSession, null) : AbstractRenderSession;
	public var boundingRadius(getBoundingRadius, null) : Float;
	public var maxX(getMaxX, null) : Float;
	public var minX(getMinX, null) : Float;
	public var maxY(getMaxY, null) : Float;
	public var minY(getMinY, null) : Float;
	public var maxZ(getMaxZ, null) : Float;
	public var minZ(getMinZ, null) : Float;
	public var objectWidth(getObjectWidth, null) : Float;
	public var objectHeight(getObjectHeight, null) : Float;
	public var objectDepth(getObjectDepth, null) : Float;
	public var visible(getVisible, setVisible) : Bool;
	public var ownCanvas(getOwnCanvas, setOwnCanvas) : Bool;
	public var renderer(getRenderer, setRenderer) : IPrimitiveConsumer;
	public var filters(getFilters, setFilters) : Array<Dynamic>;
	public var alpha(getAlpha, setAlpha) : Float;
	public var blendMode(getBlendMode, setBlendMode) : BlendMode;
	public var ownSession(getOwnSession, setOwnSession) : AbstractRenderSession;
	public var x(getX, setX) : Float;
	public var y(getY, setY) : Float;
	public var z(getZ, setZ) : Float;
	public var rotationX(getRotationX, setRotationX) : Float;
	public var rotationY(getRotationY, setRotationY) : Float;
	public var rotationZ(getRotationZ, setRotationZ) : Float;
	public var scaleX(getScaleX, setScaleX) : Float;
	public var scaleY(getScaleY, setScaleY) : Float;
	public var scaleZ(getScaleZ, setScaleZ) : Float;
	public var position(getPosition, setPosition) : Number3D;
	public var eulers(getEulers, setEulers) : Number3D;
	public var transform(getTransform, setTransform) : Matrix3D;
	public var parent(getParent, setParent) : ObjectContainer3D;
	public var sceneTransform(getSceneTransform, null) : Matrix3D;
	public var ownLights(getOwnLights, setOwnLights) : Bool;
	public var pivotPoint(getPivotPoint, setPivotPoint) : Number3D;
	public var lightarray(getLightarray, null) : ILightConsumer;
	public var scenePosition(getScenePosition, null) : Number3D;
	public var scene(getScene, null) : Scene3D;
	public var pivotZero(getPivotZero, null) : Bool;
	public var scenePivotPoint(getScenePivotPoint, null) : Number3D;
	
	/** @private */
	public var _mouseEnabled:Bool;
	/** @private */
	public var _transformDirty:Bool;
	/** @private */
	public var _transform:Matrix3D;
	/** @private */
	public var _sceneTransformDirty:Bool;
	/** @private */
	public var _sceneTransform:Matrix3D;
	/** @private */
	public var _localTransformDirty:Bool;
	/** @private */
	public var _dimensionsDirty:Bool;
	/** @private */
	public var _boundingRadius:Float;
	/** @private */
	public var _boundingScale:Float;
	/** @private */
	public var _maxX:Float;
	/** @private */
	public var _minX:Float;
	/** @private */
	public var _maxY:Float;
	/** @private */
	public var _minY:Float;
	/** @private */
	public var _maxZ:Float;
	/** @private */
	public var _minZ:Float;
	/** @private */
	public var _lookingAtTarget:Number3D;
	private static var toDEGREES:Float = 180 / Math.PI;
	private static var toRADIANS:Float = Math.PI / 180;
	private var _eulers:Number3D;
	private var _rotationDirty:Bool;
	public var _sessionDirty:Bool;
	public var _objectDirty:Bool;
	public var _rotationX:Float;
	public var _rotationY:Float;
	public var _rotationZ:Float;
	public var _scaleX:Float;
	public var _scaleY:Float;
	public var _scaleZ:Float;
	private var _pivotPoint:Number3D;
	private var _scenePivotPoint:Number3D;
	private var _parentradius:Number3D;
	public var _scene:Scene3D;
	private var _oldscene:Scene3D;
	private var _parent:ObjectContainer3D;
	private var _quaternion:Quaternion;
	private var _rot:Number3D;
	private var _sca:Number3D;
	private var _pivotZero:Bool;
	private var _vector:Number3D;
	private var _m:Matrix3D;
	private var _xAxis:Number3D;
	private var _yAxis:Number3D;
	private var _zAxis:Number3D;
	private var _parentupdated:Object3DEvent;
	private var _transformchanged:Object3DEvent;
	private var _scenetransformchanged:Object3DEvent;
	private var _scenechanged:Object3DEvent;
	private var _sessionchanged:Object3DEvent;
	private var _sessionupdated:Object3DEvent;
	private var _dimensionschanged:Object3DEvent;
	private var _dispatchedDimensionsChange:Bool;
	public var _session:AbstractRenderSession;
	private var _ownSession:AbstractRenderSession;
	private var _ownCanvas:Bool;
	private var _filters:Array<Dynamic>;
	private var _alpha:Float;
	private var _blendMode:BlendMode;
	private var _renderer:IPrimitiveConsumer;
	private var _ownLights:Bool;
	private var _lightsDirty:Bool;
	private var _lightarray:ILightConsumer;
	private var _debugBoundingSphere:WireSphere;
	private var _debugBoundingBox:WireCube;
	private var _visible:Bool;
	/**
	 * Instance of the Init object used to hold and parse default property values
	 * specified by the initialiser object in the 3d object constructor.
	 */
	private var ini:Init;
	/**
	 * Elements use their furthest point from the camera when z-sorting
	 */
	public var pushback:Bool;
	/**
	 * Elements use their nearest point to the camera when z-sorting
	 */
	public var pushfront:Bool;
	/**
	 * Returns the inverse of sceneTransform.
	 * 
	 * @see #sceneTransform
	 */
	public var inverseSceneTransform:Matrix3D;
	/**
	 * An optional name string for the 3d object.
	 * 
	 * Can be used to access specific 3d object in a scene by calling the <code>getChildByName</code> method on the parent <code>ObjectContainer3D</code>.
	 * 
	 * @see away3d.containers.ObjectContainer3D#getChildByName()
	 */
	public var name:String;
	/**
	 * An optional untyped object that can contain used-defined properties
	 */
	public var extra:Dynamic;
	/**
	 * Defines whether mouse events are received on the 3d object
	 */
	public var mouseEnabled:Bool;
	/**
	 * Defines whether a hand cursor is displayed when the mouse rolls over the 3d object.
	 */
	public var useHandCursor:Bool;
	/**
	 * Reference container for all materials used in the container. Populated in <code>Collada</code> and <code>Max3DS</code> importers.
	 * 
	 * @see away3d.loaders.Collada
	 * @see away3d.loaders.Max3DS
	 */
	public var materialLibrary:MaterialLibrary;
	/**
	 * Reference container for all animations used in the container. Populated in <code>Collada</code> and <code>Max3DS</code> importers.
	 * 
	 * @see away3d.loaders.Collada
	 * @see away3d.loaders.Max3DS
	 */
	public var animationLibrary:AnimationLibrary;
	/**
	 * Reference container for all geometries used in the container. Populated in <code>Collada</code> and <code>Max3DS</code> importers.
	 * 
	 * @see away3d.loaders.Collada
	 * @see away3d.loaders.Max3DS
	 */
	public var geometryLibrary:GeometryLibrary;
	/**
	 * Indicates whether a debug bounding box should be rendered around the 3d object.
	 */
	public var debugbb:Bool;
	/**
	 * Indicates whether a debug bounding sphere should be rendered around the 3d object.
	 */
	public var debugbs:Bool;
	public var center:Vertex;
	public var projectorType:String;
	

	/** @private */
	public function getLookingAtTarget():Number3D {
		
		return _lookingAtTarget;
	}

	/** @private */
	public function getParentmaxX():Float {
		
		return boundingRadius * _boundingScale + _transform.tx;
	}

	/** @private */
	public function getParentminX():Float {
		
		return -boundingRadius * _boundingScale + _transform.tx;
	}

	/** @private */
	public function getParentmaxY():Float {
		
		return boundingRadius * _boundingScale + _transform.ty;
	}

	/** @private */
	public function getParentminY():Float {
		
		return -boundingRadius * _boundingScale + _transform.ty;
	}

	/** @private */
	public function getParentmaxZ():Float {
		
		return boundingRadius * _boundingScale + _transform.tz;
	}

	/** @private */
	public function getParentminZ():Float {
		
		return -boundingRadius * _boundingScale + _transform.tz;
	}

	/** @private */
	public function getParentBoundingRadius():Float {
		
		return boundingRadius * _boundingScale;
	}

	/** @private */
	public function notifyParentUpdate():Void {
		
		if (_ownCanvas && (_parent != null)) {
			_parent._sessionDirty = true;
		}
		if (!hasEventListener(Object3DEvent.PARENT_UPDATED)) {
			return;
		}
		if (_parentupdated == null) {
			_parentupdated = new Object3DEvent(Object3DEvent.PARENT_UPDATED, this);
		}
		dispatchEvent(_parentupdated);
	}

	/** @private */
	public function notifyTransformChange():Void {
		
		_localTransformDirty = false;
		if (!hasEventListener(Object3DEvent.TRANSFORM_CHANGED)) {
			return;
		}
		if (_transformchanged == null) {
			_transformchanged = new Object3DEvent(Object3DEvent.TRANSFORM_CHANGED, this);
		}
		dispatchEvent(_transformchanged);
	}

	/** @private */
	public function notifySceneTransformChange():Void {
		
		_sceneTransformDirty = false;
		_objectDirty = true;
		if (!hasEventListener(Object3DEvent.SCENETRANSFORM_CHANGED)) {
			return;
		}
		if (_scenetransformchanged == null) {
			_scenetransformchanged = new Object3DEvent(Object3DEvent.SCENETRANSFORM_CHANGED, this);
		}
		dispatchEvent(_scenetransformchanged);
	}

	/** @private */
	public function notifySceneChange():Void {
		
		_sceneTransformDirty = true;
		if (!hasEventListener(Object3DEvent.SCENE_CHANGED)) {
			return;
		}
		if (_scenechanged == null) {
			_scenechanged = new Object3DEvent(Object3DEvent.SCENE_CHANGED, this);
		}
		dispatchEvent(_scenechanged);
	}

	/** @private */
	public function notifySessionChange():Void {
		
		changeSession();
		if (!hasEventListener(Object3DEvent.SESSION_CHANGED)) {
			return;
		}
		if (_sessionchanged == null) {
			_sessionchanged = new Object3DEvent(Object3DEvent.SESSION_CHANGED, this);
		}
		dispatchEvent(_sessionchanged);
	}

	/** @private */
	public function notifySessionUpdate():Void {
		
		if ((_scene != null)) {
			_scene.updatedSessions[untyped _session] = _session;
		}
		if (!hasEventListener(Object3DEvent.SESSION_UPDATED)) {
			return;
		}
		if (_sessionupdated == null) {
			_sessionupdated = new Object3DEvent(Object3DEvent.SESSION_UPDATED, this);
		}
		dispatchEvent(_sessionupdated);
	}

	/** @private */
	public function notifyDimensionsChange():Void {
		
		_dimensionsDirty = true;
		if (_dispatchedDimensionsChange || !hasEventListener(Object3DEvent.DIMENSIONS_CHANGED)) {
			return;
		}
		if (_dimensionschanged == null) {
			_dimensionschanged = new Object3DEvent(Object3DEvent.DIMENSIONS_CHANGED, this);
		}
		dispatchEvent(_dimensionschanged);
		_dispatchedDimensionsChange = true;
	}

	/** @private */
	public function dispatchMouseEvent(event:MouseEvent3D):Bool {
		
		if (!hasEventListener(event.type)) {
			return false;
		}
		dispatchEvent(event);
		return true;
	}

	private function onSessionUpdate(event:SessionEvent):Void {
		
		if (Std.is(event.target, BitmapRenderSession)) {
			_scene.updatedSessions[untyped event.target] = event.target;
		}
	}

	private function updateSceneTransform():Void {
		
		_sceneTransform.multiply(_parent.sceneTransform, transform);
		if (!_pivotZero) {
			_scenePivotPoint.rotate(_pivotPoint, _sceneTransform);
			_sceneTransform.tx -= _scenePivotPoint.x;
			_sceneTransform.ty -= _scenePivotPoint.y;
			_sceneTransform.tz -= _scenePivotPoint.z;
		}
		//calulate the inverse transform of the scene (used for lights and bones)
		inverseSceneTransform.inverse(_sceneTransform);
		notifySceneTransformChange();
	}

	private function updateRotation():Void {
		
		_rot.matrix2euler(_transform, _scaleX, _scaleY, _scaleZ);
		_rotationX = _rot.x;
		_rotationY = _rot.y;
		_rotationZ = _rot.z;
		_rotationDirty = false;
	}

	private function onParentUpdate(event:Object3DEvent):Void {
		
		_sessionDirty = true;
		dispatchEvent(event);
	}

	private function onParentSessionChange(event:Object3DEvent):Void {
		
		if ((_ownSession != null) && (event.object.parent != null)) {
			event.object.parent.session.removeChildSession(_ownSession);
		}
		if ((_ownSession != null) && (_parent.session != null)) {
			_parent.session.addChildSession(_ownSession);
		}
		if (_ownSession == null && _session != _parent.session) {
			changeSession();
			dispatchEvent(event);
		}
	}

	private function onParentSceneChange(event:Object3DEvent):Void {
		
		if (_scene == _parent.scene) {
			return;
		}
		_scene = _parent.scene;
		notifySceneChange();
	}

	private function onParentTransformChange(event:Object3DEvent):Void {
		
		_sceneTransformDirty = true;
	}

	private function updateLights():Void {
		
		if (!_ownLights) {
			_lightarray = parent.lightarray;
		} else {
			_lightarray = new LightArray();
		}
		_lightsDirty = false;
	}

	private function changeSession():Void {
		
		if ((_ownSession != null)) {
			_session = _ownSession;
		} else if ((_parent != null)) {
			_session = _parent.session;
		} else {
			_session = null;
		}
		_sessionDirty = true;
	}

	private function updateTransform():Void {
		
		if (_rotationDirty) {
			updateRotation();
		}
		// Swapped
		_quaternion.euler2quaternion(_rotationY, _rotationZ, -_rotationX);
		_transform.quaternion2matrix(_quaternion);
		_transform.scale(_transform, _scaleX, _scaleY, _scaleZ);
		_transformDirty = false;
		_sceneTransformDirty = true;
		_localTransformDirty = true;
	}

	private function updateDimensions():Void {
		
		_dimensionsDirty = false;
		_dispatchedDimensionsChange = false;
		if (debugbb) {
			if (_debugBoundingBox == null) {
				_debugBoundingBox = new WireCube({material:"#333333"});
			}
			if ((_boundingRadius > 0)) {
				_debugBoundingBox.visible = true;
				_debugBoundingBox.v000.setValue(_minX, _minY, _minZ);
				_debugBoundingBox.v100.setValue(_maxX, _minY, _minZ);
				_debugBoundingBox.v010.setValue(_minX, _maxY, _minZ);
				_debugBoundingBox.v110.setValue(_maxX, _maxY, _minZ);
				_debugBoundingBox.v001.setValue(_minX, _minY, _maxZ);
				_debugBoundingBox.v101.setValue(_maxX, _minY, _maxZ);
				_debugBoundingBox.v011.setValue(_minX, _maxY, _maxZ);
				_debugBoundingBox.v111.setValue(_maxX, _maxY, _maxZ);
			} else {
				debugBoundingBox.visible = false;
			}
		}
		if (debugbs) {
			if (_debugBoundingSphere == null) {
				_debugBoundingSphere = new WireSphere({material:"#cyan", segmentsW:16, segmentsH:12});
			}
			if ((_boundingRadius > 0)) {
				_debugBoundingSphere.visible = true;
				_debugBoundingSphere.radius = _boundingRadius;
				_debugBoundingSphere.updateObject();
				_debugBoundingSphere.applyPosition(-_pivotPoint.x, -_pivotPoint.y, -_pivotPoint.z);
			} else {
				debugBoundingSphere.visible = false;
			}
		}
	}

	public function getDebugBoundingBox():WireCube {
		
		if (_dimensionsDirty || _debugBoundingBox == null) {
			updateDimensions();
		}
		return _debugBoundingBox;
	}

	public function getDebugBoundingSphere():WireSphere {
		
		if (_dimensionsDirty || _debugBoundingSphere == null) {
			updateDimensions();
		}
		return _debugBoundingSphere;
	}

	/**
	 * The render session used by the 3d object
	 */
	public function getSession():AbstractRenderSession {
		
		return _session;
	}

	/**
	 * Returns the bounding radius of the 3d object
	 */
	public function getBoundingRadius():Float {
		
		if (_dimensionsDirty) {
			updateDimensions();
		}
		return _boundingRadius;
	}

	/**
	 * Returns the maximum x value of the 3d object
	 * 
	 * @see	#x
	 */
	public function getMaxX():Float {
		
		if (_dimensionsDirty) {
			updateDimensions();
		}
		return _maxX;
	}

	/**
	 * Returns the minimum x value of the 3d object
	 * 
	 * @see	#x
	 */
	public function getMinX():Float {
		
		if (_dimensionsDirty) {
			updateDimensions();
		}
		return _minX;
	}

	/**
	 * Returns the maximum y value of the 3d object
	 * 
	 * @see	#y
	 */
	public function getMaxY():Float {
		
		if (_dimensionsDirty) {
			updateDimensions();
		}
		return _maxY;
	}

	/**
	 * Returns the minimum y value of the 3d object
	 * 
	 * @see	#y
	 */
	public function getMinY():Float {
		
		if (_dimensionsDirty) {
			updateDimensions();
		}
		return _minY;
	}

	/**
	 * Returns the maximum z value of the 3d object
	 * 
	 * @see	#z
	 */
	public function getMaxZ():Float {
		
		if (_dimensionsDirty) {
			updateDimensions();
		}
		return _maxZ;
	}

	/**
	 * Returns the minimum z value of the 3d object
	 * 
	 * @see	#z
	 */
	public function getMinZ():Float {
		
		if (_dimensionsDirty) {
			updateDimensions();
		}
		return _minZ;
	}

	/**
	 * Boundary width of the 3d object
	 * 
	 *@return	The width of the object
	 */
	public function getObjectWidth():Float {
		
		if (_dimensionsDirty) {
			updateDimensions();
		}
		return _maxX - _minX;
	}

	/**
	 * Boundary height of the 3d object
	 * 
	 *@return	The height of the mesh
	 */
	public function getObjectHeight():Float {
		
		if (_dimensionsDirty) {
			updateDimensions();
		}
		return _maxY - _minY;
	}

	/**
	 * Boundary depth of the 3d object
	 * 
	 *@return	The depth of the mesh
	 */
	public function getObjectDepth():Float {
		
		if (_dimensionsDirty) {
			updateDimensions();
		}
		return _maxZ - _minZ;
	}

	/**
	 * Defines whether the 3d object is visible in the scene
	 */
	public function getVisible():Bool {
		
		return _visible;
	}

	public function setVisible(val:Bool):Bool {
		
		if (_visible == val) {
			return val;
		}
		_visible = val;
		_sessionDirty = true;
		notifyParentUpdate();
		return val;
	}

	/**
	 * Defines whether the contents of the 3d object are rendered using it's own render session
	 */
	public function getOwnCanvas():Bool {
		
		return _ownCanvas;
	}

	public function setOwnCanvas(val:Bool):Bool {
		
		if (_ownCanvas == val) {
			return val;
		}
		if (val) {
			ownSession = new SpriteRenderSession();
		} else if (Std.is(this, Scene3D)) {
			throw new Error("Scene cannot have ownCanvas set to false");
		} else {
			ownSession = null;
		}
		return val;
	}

	/**
	 * An optional renderer object that can be used to render the contents of the object.
	 * 
	 * Requires <code>ownCanvas</code> to be set to true.
	 * 
	 * @see #ownCanvas
	 */
	public function getRenderer():IPrimitiveConsumer {
		
		return _renderer;
	}

	public function setRenderer(val:IPrimitiveConsumer):IPrimitiveConsumer {
		
		if (_renderer == val) {
			return val;
		}
		_renderer = val;
		if ((_ownSession != null)) {
			_ownSession.renderer = _renderer;
		}
		_sessionDirty = true;
		return val;
	}

	/**
	 * An optional array of filters that can be applied to the 3d object.
	 * 
	 * Requires <code>ownCanvas</code> to be set to true.
	 * 
	 * @see #ownCanvas
	 */
	public function getFilters():Array<Dynamic> {
		
		return _filters;
	}

	public function setFilters(val:Array<Dynamic>):Array<Dynamic> {
		
		if (_filters == val) {
			return val;
		}
		_filters = val;
		if ((_ownSession != null)) {
			_ownSession.filters = _filters;
		}
		return val;
	}

	/**
	 * An optional alpha value that can be applied to the 3d object.
	 * 
	 * Requires <code>ownCanvas</code> to be set to true.
	 * 
	 * @see #ownCanvas
	 */
	public function getAlpha():Float {
		
		return _alpha;
	}

	public function setAlpha(val:Float):Float {
		
		if (_alpha == val) {
			return val;
		}
		_alpha = val;
		if ((_ownSession != null)) {
			_ownSession.alpha = _alpha;
		}
		return val;
	}

	/**
	 * An optional blend mode that can be applied to the 3d object.
	 * 
	 * Requires <code>ownCanvas</code> to be set to true.
	 * 
	 * @see #ownCanvas
	 */
	public function getBlendMode():BlendMode {
		
		return _blendMode;
	}

	public function setBlendMode(val:BlendMode):BlendMode {
		
		if (_blendMode == val) {
			return val;
		}
		_blendMode = val;
		if ((_ownSession != null)) {
			_ownSession.blendMode = _blendMode;
		}
		return val;
	}

	/**
	 * Defines a unique render session for the 3d object.
	 */
	public function getOwnSession():AbstractRenderSession {
		
		return _ownSession;
	}

	public function setOwnSession(val:AbstractRenderSession):AbstractRenderSession {
		
		if (_ownSession == val) {
			return val;
		}
		if ((_ownSession != null)) {
			if ((_parent != null) && (_parent.session != null)) {
				_parent.session.removeChildSession(_ownSession);
			}
			//reset old session children
			_ownSession.clearChildSessions();
			_ownSession.renderer = null;
			_ownSession.internalRemoveOwnSession(this);
			_ownSession.removeOnSessionUpdate(onSessionUpdate);
		} else if ((_parent != null) && (_parent.session != null)) {
			_parent.session.internalRemoveOwnSession(this);
		}
		//set new session
		_ownSession = val;
		if ((_ownSession != null)) {
			if ((_parent != null) && (_parent.session != null)) {
				_parent.session.addChildSession(_ownSession);
			}
			//reset new session children and session properties
			_ownSession.clearChildSessions();
			_ownSession.renderer = _renderer;
			_ownSession.filters = _filters;
			_ownSession.alpha = _alpha;
			_ownSession.blendMode = _blendMode;
			_ownSession.internalAddOwnSession(this);
			_ownSession.addOnSessionUpdate(onSessionUpdate);
		} else if (Std.is(this, Scene3D)) {
			throw new Error("Scene cannot have ownSession set to null");
		} else if ((_parent != null) && (_parent.session != null)) {
			_parent.session.internalAddOwnSession(this);
		}
		//update ownCanvas property
		if ((_ownSession != null)) {
			_ownCanvas = true;
		} else {
			_ownCanvas = false;
		}
		notifySessionChange();
		return val;
	}

	/**
	 * Defines the x coordinate of the 3d object relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
	 */
	public function getX():Float {
		
		return _transform.tx;
	}

	public function setX(value:Float):Float {
		
		if (Math.isNaN(value)) {
			throw new Error("isNaN(x)");
		}
		if (_transform.tx == value) {
			return value;
		}
		if (value == Math.POSITIVE_INFINITY) {
			Debug.warning("x == Infinity");
		}
		if (value == -Math.POSITIVE_INFINITY) {
			Debug.warning("x == -Infinity");
		}
		_transform.tx = value;
		_sceneTransformDirty = true;
		_localTransformDirty = true;
		return value;
	}

	/**
	 * Defines the y coordinate of the 3d object relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
	 */
	public function getY():Float {
		
		return _transform.ty;
	}

	public function setY(value:Float):Float {
		
		if (Math.isNaN(value)) {
			throw new Error("isNaN(y)");
		}
		if (_transform.ty == value) {
			return value;
		}
		if (value == Math.POSITIVE_INFINITY) {
			Debug.warning("y == Infinity");
		}
		if (value == -Math.POSITIVE_INFINITY) {
			Debug.warning("y == -Infinity");
		}
		_transform.ty = value;
		_sceneTransformDirty = true;
		_localTransformDirty = true;
		return value;
	}

	/**
	 * Defines the z coordinate of the 3d object relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
	 */
	public function getZ():Float {
		
		return _transform.tz;
	}

	public function setZ(value:Float):Float {
		
		if (Math.isNaN(value)) {
			throw new Error("isNaN(z)");
		}
		if (_transform.tz == value) {
			return value;
		}
		if (value == Math.POSITIVE_INFINITY) {
			Debug.warning("z == Infinity");
		}
		if (value == -Math.POSITIVE_INFINITY) {
			Debug.warning("z == -Infinity");
		}
		_transform.tz = value;
		_sceneTransformDirty = true;
		_localTransformDirty = true;
		return value;
	}

	/**
	 * Defines the euler angle of rotation of the 3d object around the x-axis, relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
	 */
	public function getRotationX():Float {
		
		if (_rotationDirty) {
			updateRotation();
		}
		return _rotationX * toDEGREES;
	}

	public function setRotationX(rot:Float):Float {
		
		if (rotationX == rot) {
			return rot;
		}
		_rotationX = rot * toRADIANS;
		_transformDirty = true;
		return rot;
	}

	/**
	 * Defines the euler angle of rotation of the 3d object around the y-axis, relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
	 */
	public function getRotationY():Float {
		
		if (_rotationDirty) {
			updateRotation();
		}
		return _rotationY * toDEGREES;
	}

	public function setRotationY(rot:Float):Float {
		
		if (rotationY == rot) {
			return rot;
		}
		_rotationY = rot * toRADIANS;
		_transformDirty = true;
		return rot;
	}

	/**
	 * Defines the euler angle of rotation of the 3d object around the z-axis, relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
	 */
	public function getRotationZ():Float {
		
		if (_rotationDirty) {
			updateRotation();
		}
		return _rotationZ * toDEGREES;
	}

	public function setRotationZ(rot:Float):Float {
		
		if (rotationZ == rot) {
			return rot;
		}
		_rotationZ = rot * toRADIANS;
		_transformDirty = true;
		return rot;
	}

	/**
	 * Defines the scale of the 3d object along the x-axis, relative to local coordinates.
	 */
	public function getScaleX():Float {
		
		return _scaleX;
	}

	public function setScaleX(scale:Float):Float {
		
		if (_scaleX == scale) {
			return scale;
		}
		_scaleX = scale;
		_transformDirty = true;
		_dimensionsDirty = true;
		return scale;
	}

	/**
	 * Defines the scale of the 3d object along the y-axis, relative to local coordinates.
	 */
	public function getScaleY():Float {
		
		return _scaleY;
	}

	public function setScaleY(scale:Float):Float {
		
		if (_scaleY == scale) {
			return scale;
		}
		_scaleY = scale;
		_transformDirty = true;
		_dimensionsDirty = true;
		return scale;
	}

	/**
	 * Defines the scale of the 3d object along the z-axis, relative to local coordinates.
	 */
	public function getScaleZ():Float {
		
		return _scaleZ;
	}

	public function setScaleZ(scale:Float):Float {
		
		if (_scaleZ == scale) {
			return scale;
		}
		_scaleZ = scale;
		_transformDirty = true;
		_dimensionsDirty = true;
		return scale;
	}

	/**
	 * Defines the position of the 3d object, relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
	 */
	public function getPosition():Number3D {
		
		return transform.position;
	}

	public function setPosition(value:Number3D):Number3D {
		
		_transform.tx = value.x;
		_transform.ty = value.y;
		_transform.tz = value.z;
		_sceneTransformDirty = true;
		_localTransformDirty = true;
		return value;
	}

	/**
	 * Defines the rotation of the 3d object as a <code>Number3D</code> object containing euler angles for rotation around x, y and z axis.
	 */
	public function getEulers():Number3D {
		
		if (_rotationDirty) {
			updateRotation();
		}
		_eulers.x = _rotationX * toDEGREES;
		_eulers.y = _rotationY * toDEGREES;
		_eulers.z = _rotationZ * toDEGREES;
		return _eulers;
	}

	public function setEulers(value:Number3D):Number3D {
		
		_rotationX = value.x * toRADIANS;
		_rotationY = value.y * toRADIANS;
		_rotationZ = value.z * toRADIANS;
		_transformDirty = true;
		return value;
	}

	/**
	 * Defines the transformation of the 3d object, relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
	 */
	public function getTransform():Matrix3D {
		
		if (_transformDirty) {
			updateTransform();
		}
		return _transform;
	}

	public function setTransform(value:Matrix3D):Matrix3D {
		
		if (_transform.compare(value)) {
			return value;
		}
		_transform.clone(value);
		_transformDirty = false;
		_rotationDirty = true;
		_sceneTransformDirty = true;
		_localTransformDirty = true;
		_sca.matrix2scale(_transform);
		if (_scaleX != _sca.x || _scaleY != _sca.y || _scaleZ != _sca.z) {
			_scaleX = _sca.x;
			_scaleY = _sca.y;
			_scaleZ = _sca.z;
			_dimensionsDirty = true;
		}
		return value;
	}

	/**
	 * Defines the parent of the 3d object.
	 */
	public function getParent():ObjectContainer3D {
		
		return _parent;
	}

	public function setParent(value:ObjectContainer3D):ObjectContainer3D {
		
		if (Std.is(this, Scene3D)) {
			throw new Error("Scene cannot be parented");
		}
		if (value == _parent) {
			return value;
		}
		_oldscene = _scene;
		if (_parent != null) {
			_parent.removeOnParentUpdate(onParentUpdate);
			_parent.removeOnSessionChange(onParentSessionChange);
			_parent.removeOnSceneChange(onParentSceneChange);
			_parent.removeOnSceneTransformChange(onParentTransformChange);
			_parent.internalRemoveChild(this);
			if ((_ownSession != null) && (_parent.session != null)) {
				_parent.session.removeChildSession(_ownSession);
			}
		}
		_parent = value;
		_scene = (_parent != null) ? _parent.scene : null;
		if (_parent != null) {
			_parent.internalAddChild(this);
			_parent.addOnParentUpdate(onParentUpdate);
			_parent.addOnSessionChange(onParentSessionChange);
			_parent.addOnSceneChange(onParentSceneChange);
			_parent.addOnSceneTransformChange(onParentTransformChange);
			if ((_ownSession != null) && (_parent.session != null)) {
				_parent.session.addChildSession(_ownSession);
			}
		}
		if (_scene != _oldscene) {
			notifySceneChange();
		}
		if (_ownSession == null && (_parent == null || _session != _parent.session)) {
			notifySessionChange();
		}
		_sceneTransformDirty = true;
		_localTransformDirty = true;
		return value;
	}

	/**
	 * Returns the transformation of the 3d object, relative to the global coordinates of the <code>Scene3D</code> object.
	 */
	public function getSceneTransform():Matrix3D {
		//for camera transforms
		
		if (_scene == null || _scene == this) {
			if (_transformDirty) {
				_sceneTransformDirty = true;
			}
			if (_sceneTransformDirty) {
				notifySceneTransformChange();
			}
			return transform;
		}
		if (_transformDirty) {
			updateTransform();
		}
		if (_sceneTransformDirty) {
			updateSceneTransform();
		}
		if (_localTransformDirty) {
			notifyTransformChange();
		}
		return _sceneTransform;
	}

	/**
	 * Defines whether the children of the container are rendered using it's own lights.
	 */
	public function getOwnLights():Bool {
		
		return _ownLights;
	}

	public function setOwnLights(val:Bool):Bool {
		
		_ownLights = val;
		_lightsDirty = true;
		return val;
	}

	/**
	 * Defines the local point around which the object rotates.
	 * 
	 * @param	pivotPoint		The Number 3D for the new pivot point
	 */
	public function getPivotPoint():Number3D {
		
		return _pivotPoint;
	}

	public function setPivotPoint(pivot:Number3D):Number3D {
		
		_pivotPoint.clone(pivot);
		_pivotZero = (_pivotPoint.x == 0 && _pivotPoint.y == 0 && _pivotPoint.z == 0);
		_sceneTransformDirty = true;
		_dimensionsDirty = true;
		notifyParentUpdate();
		return pivot;
	}

	/**
	 * returns the array of lights contained inside the container.
	 */
	public function getLightarray():ILightConsumer {
		
		if (_lightsDirty) {
			updateLights();
		}
		return _lightarray;
	}

	/**
	 * Returns the position of the 3d object, relative to the global coordinates of the <code>Scene3D</code> object.
	 */
	public function getScenePosition():Number3D {
		
		return sceneTransform.position;
	}

	/**
	 * Returns the parent scene of the 3d object
	 */
	public function getScene():Scene3D {
		
		return _scene;
	}

	public function getPivotZero():Bool {
		
		return _pivotZero;
	}

	public function getScenePivotPoint():Number3D {
		
		if (_sceneTransformDirty) {
			updateSceneTransform();
		}
		return _scenePivotPoint;
	}

	/**
	 * @private
	 */
	public function new(?init:Dynamic=null):Void {
		// autogenerated
		super();
		this._mouseEnabled = true;
		this._transform = new Matrix3D();
		this._sceneTransform = new Matrix3D();
		this._dimensionsDirty = false;
		this._boundingRadius = 0;
		this._boundingScale = 1;
		this._maxX = 0;
		this._minX = 0;
		this._maxY = 0;
		this._minY = 0;
		this._maxZ = 0;
		this._minZ = 0;
		this._lookingAtTarget = new Number3D();
		this._eulers = new Number3D();
		this._rotationX = 0;
		this._rotationY = 0;
		this._rotationZ = 0;
		this._scaleX = 1;
		this._scaleY = 1;
		this._scaleZ = 1;
		this._pivotPoint = new Number3D();
		this._scenePivotPoint = new Number3D();
		this._parentradius = new Number3D();
		this._quaternion = new Quaternion();
		this._rot = new Number3D();
		this._sca = new Number3D();
		this._vector = new Number3D();
		this._m = new Matrix3D();
		this._xAxis = new Number3D();
		this._yAxis = new Number3D();
		this._zAxis = new Number3D();
		this.inverseSceneTransform = new Matrix3D();
		this.mouseEnabled = true;
		this.useHandCursor = false;
		this.center = new Vertex();
		
		
		ini = Init.parse(init);
		name = ini.getString("name", name);
		ownSession = cast(ini.getObject("ownSession", AbstractRenderSession), AbstractRenderSession);
		ownCanvas = ini.getBoolean("ownCanvas", ownCanvas);
		ownLights = ini.getBoolean("ownLights", false);
		visible = ini.getBoolean("visible", true);
		mouseEnabled = ini.getBoolean("mouseEnabled", mouseEnabled);
		useHandCursor = ini.getBoolean("useHandCursor", useHandCursor);
		renderer = cast(ini.getObject("renderer", IPrimitiveConsumer), IPrimitiveConsumer);
		filters = ini.getArray("filters");
		alpha = ini.getNumber("alpha", 1);
		var blendModeString:String = ini.getString("blendMode", BlendModeUtils.NORMAL);
		blendMode = BlendModeUtils.toHaxe(blendModeString);
		debugbb = ini.getBoolean("debugbb", false);
		debugbs = ini.getBoolean("debugbs", false);
		pushback = ini.getBoolean("pushback", false);
		pushfront = ini.getBoolean("pushfront", false);
		x = ini.getNumber("x", 0);
		y = ini.getNumber("y", 0);
		z = ini.getNumber("z", 0);
		rotationX = ini.getNumber("rotationX", 0);
		rotationY = ini.getNumber("rotationY", 0);
		rotationZ = ini.getNumber("rotationZ", 0);
		pivotPoint = ini.getNumber3D("pivotPoint");
		if (pivotPoint == null)  {
			pivotPoint = new Number3D();
		};
		extra = ini.getObject("extra");
		if (Std.is(this, Scene3D)) {
			_scene = cast(this, Scene3D);
		} else {
			parent = cast(ini.getObject3D("parent"), ObjectContainer3D);
		}
		/*
		 var scaling:Number = init.getNumber("scale", 1);
		 scaleX(init.getNumber("scaleX", 1) * scaling);
		 scaleY(init.getNumber("scaleY", 1) * scaling);
		 scaleZ(init.getNumber("scaleZ", 1) * scaling);
		 */
		
	}

	public function updateObject():Void {
		
		if (_objectDirty) {
			_scene.updatedObjects[untyped this] = this;
			_objectDirty = false;
			_sessionDirty = true;
		}
	}

	public function updateSession():Void {
		
		if (_sessionDirty) {
			notifySessionUpdate();
			_sessionDirty = false;
		}
	}

	/**
	 * Scales the contents of the 3d object.
	 * 
	 * @param	scale	The scaling value
	 */
	public function scale(scale:Float):Void {
		
		_scaleX = _scaleY = _scaleZ = scale;
		_transformDirty = true;
		_dimensionsDirty = true;
	}

	/**
	 * Calulates the absolute distance between the local 3d object position and the position of the given 3d object
	 * 
	 * @param	obj		The 3d object to use for calulating the distance
	 * @return			The scalar distance between objects
	 * 
	 * @see	#position
	 */
	public function distanceTo(obj:Object3D):Float {
		
		var m1:Matrix3D = _scene == this ? transform : sceneTransform;
		var m2:Matrix3D = obj.scene == obj ? obj.transform : obj.sceneTransform;
		var dx:Float = m1.tx - m2.tx;
		var dy:Float = m1.ty - m2.ty;
		var dz:Float = m1.tz - m2.tz;
		return Math.sqrt(dx * dx + dy * dy + dz * dz);
	}

	/**
	 * Used when traversing the scenegraph
	 * 
	 * @param	tranverser		The traverser object
	 * 
	 * @see	away3d.core.traverse.BlockerTraverser
	 * @see	away3d.core.traverse.PrimitiveTraverser
	 * @see	away3d.core.traverse.ProjectionTraverser
	 * @see	away3d.core.traverse.TickTraverser
	 */
	public function traverse(traverser:Traverser):Void {
		
		if (traverser.match(this)) {
			traverser.enter(this);
			traverser.apply(this);
			traverser.leave(this);
		}
	}

	/**
	 * Moves the 3d object forwards along it's local z axis
	 * 
	 * @param	distance	The length of the movement
	 */
	public function moveForward(distance:Float):Void {
		
		translate(Number3D.FORWARD, distance);
	}

	/**
	 * Moves the 3d object backwards along it's local z axis
	 * 
	 * @param	distance	The length of the movement
	 */
	public function moveBackward(distance:Float):Void {
		
		translate(Number3D.BACKWARD, distance);
	}

	/**
	 * Moves the 3d object backwards along it's local x axis
	 * 
	 * @param	distance	The length of the movement
	 */
	public function moveLeft(distance:Float):Void {
		
		translate(Number3D.LEFT, distance);
	}

	/**
	 * Moves the 3d object forwards along it's local x axis
	 * 
	 * @param	distance	The length of the movement
	 */
	public function moveRight(distance:Float):Void {
		
		translate(Number3D.RIGHT, distance);
	}

	/**
	 * Moves the 3d object forwards along it's local y axis
	 * 
	 * @param	distance	The length of the movement
	 */
	public function moveUp(distance:Float):Void {
		
		translate(Number3D.UP, distance);
	}

	/**
	 * Moves the 3d object backwards along it's local y axis
	 * 
	 * @param	distance	The length of the movement
	 */
	public function moveDown(distance:Float):Void {
		
		translate(Number3D.DOWN, distance);
	}

	/**
	 * Moves the 3d object directly to a point in space
	 * 
	 * @param	dx		The amount of movement along the local x axis.
	 * @param	dy		The amount of movement along the local y axis.
	 * @param	dz		The amount of movement along the local z axis.
	 */
	public function moveTo(dx:Float, dy:Float, dz:Float):Void {
		
		if (_transform.tx == dx && _transform.ty == dy && _transform.tz == dz) {
			return;
		}
		_transform.tx = dx;
		_transform.ty = dy;
		_transform.tz = dz;
		_localTransformDirty = true;
		_sceneTransformDirty = true;
	}

	/**
	 * Moves the local point around which the object rotates.
	 * 
	 * @param	dx		The amount of movement along the local x axis.
	 * @param	dy		The amount of movement along the local y axis.
	 * @param	dz		The amount of movement along the local z axis.
	 */
	public function movePivot(dx:Float, dy:Float, dz:Float):Void {
		
		_pivotPoint.x = dx;
		_pivotPoint.y = dy;
		_pivotPoint.z = dz;
		_pivotZero = (dx == 0 && dy == 0 && dz == 0);
		_sceneTransformDirty = true;
		_dimensionsDirty = true;
		notifyParentUpdate();
	}

	/**
	 * Moves the 3d object along a vector by a defined length
	 * 
	 * @param	axis		The vector defining the axis of movement
	 * @param	distance	The length of the movement
	 */
	public function translate(axis:Number3D, distance:Float):Void {
		
		axis.normalize();
		_vector.rotate(axis, transform);
		x += distance * _vector.x;
		y += distance * _vector.y;
		z += distance * _vector.z;
	}

	/**
	 * Rotates the 3d object around it's local x-axis
	 * 
	 * @param	angle		The amount of rotation in degrees
	 */
	public function pitch(angle:Float):Void {
		
		rotate(Number3D.RIGHT, angle);
	}

	/**
	 * Rotates the 3d object around it's local y-axis
	 * 
	 * @param	angle		The amount of rotation in degrees
	 */
	public function yaw(angle:Float):Void {
		
		rotate(Number3D.UP, angle);
	}

	/**
	 * Rotates the 3d object around it's local z-axis
	 * 
	 * @param	angle		The amount of rotation in degrees
	 */
	public function roll(angle:Float):Void {
		
		rotate(Number3D.FORWARD, angle);
	}

	/**
	 * Rotates the 3d object directly to a euler angle
	 * 
	 * @param	ax		The angle in degrees of the rotation around the x axis.
	 * @param	ay		The angle in degrees of the rotation around the y axis.
	 * @param	az		The angle in degrees of the rotation around the z axis.
	 */
	public function rotateTo(ax:Float, ay:Float, az:Float):Void {
		
		_rotationX = -ax * toRADIANS;
		_rotationY = -ay * toRADIANS;
		_rotationZ = -az * toRADIANS;
		_rotationDirty = false;
		_transformDirty = true;
	}

	/**
	 * Rotates the 3d object around an axis by a defined angle
	 * 
	 * @param	axis		The vector defining the axis of rotation
	 * @param	angle		The amount of rotation in degrees
	 */
	public function rotate(axis:Number3D, angle:Float):Void {
		
		axis.normalize();
		_m.rotationMatrix(axis.x, axis.y, axis.z, angle * toRADIANS);
		_transform.multiply3x3(transform, _m);
		_rotationDirty = true;
		_sceneTransformDirty = true;
		_localTransformDirty = true;
	}

	/**
	 * Rotates the 3d object around to face a point defined relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
	 * 
	 * @param	target		The vector defining the point to be looked at
	 * @param	upAxis		An optional vector used to define the desired up orientation of the 3d object after rotation has occurred
	 */
	public function lookAt(target:Number3D, ?upAxis:Number3D=null):Void {
		
		_lookingAtTarget = target;
		_zAxis.sub(target, position);
		_zAxis.normalize();
		if (_zAxis.modulo > 0.1 && (_zAxis.x != _transform.sxz || _zAxis.y != _transform.syz || _zAxis.z != _transform.szz)) {
			_xAxis.cross(_zAxis, (upAxis != null) ? upAxis : Number3D.UP);
			if (_xAxis.modulo2 == 0) {
				_xAxis.cross(_zAxis, Number3D.BACKWARD);
			}
			_xAxis.normalize();
			_yAxis.cross(_zAxis, _xAxis);
			_yAxis.normalize();
			_transform.sxx = _xAxis.x * _scaleX;
			_transform.syx = _xAxis.y * _scaleX;
			_transform.szx = _xAxis.z * _scaleX;
			_transform.sxy = -_yAxis.x * _scaleY;
			_transform.syy = -_yAxis.y * _scaleY;
			_transform.szy = -_yAxis.z * _scaleY;
			_transform.sxz = _zAxis.x * _scaleZ;
			_transform.syz = _zAxis.y * _scaleZ;
			_transform.szz = _zAxis.z * _scaleZ;
			_transformDirty = false;
			_rotationDirty = true;
			_sceneTransformDirty = true;
			_localTransformDirty = true;
		} else {
		}
	}

	/**
	 * Apply the local rotations to the object without altering the apperance of child objects
	 */
	public function applyRotations():Void {
		
		throw new Error("Not implemented in Object3D - Use Mesh or ObjectContainer3D");
	}

	/**
	 * Apply the given position to the object without altering the apperance of child objects
	 */
	public function applyPosition(dx:Float, dy:Float, dz:Float):Void {
		
		throw new Error("Not implemented in Object3D - Use Mesh or ObjectContainer3D");
	}

	/**
	 * Used to trace the values of a 3d object.
	 * 
	 * @return A string representation of the 3d object.
	 */
	public override function toString():String {
		
		return ((name != null) ? name : "$") + ': x:' + Math.round(x) + ' y:' + Math.round(y) + ' z:' + Math.round(z);
	}

	/**
	 * Called by the <code>TickTraverser</code>.
	 * 
	 * Can be overridden to provide updates to the 3d object based on individual render calls from the renderer.
	 * 
	 * @param	time		The absolute time at the start of the render cycle
	 * 
	 * @see away3d.core.traverse.TickTraverser
	 */
	public function tick(time:Int):Void {
		
	}

	/**
	 * Duplicates the 3d object's properties to another <code>Object3D</code> object
	 * 
	 * @param	object	[optional]	The new object instance into which all properties are copied
	 * @return						The new object instance with duplicated properties applied
	 */
	public function clone(?object:Object3D=null):Object3D {
		
		var object3D:Object3D = object;
		if (object3D == null)  {
			object3D = new Object3D();
		};
		object3D.transform = transform;
		object3D.name = name;
		object3D.ownCanvas = _ownCanvas;
		object3D.renderer = _renderer;
		object3D.filters = _filters.concat([]);
		object3D.alpha = _alpha;
		object3D.visible = visible;
		object3D.mouseEnabled = mouseEnabled;
		object3D.useHandCursor = useHandCursor;
		object3D.pushback = pushback;
		object3D.pushfront = pushfront;
		object3D.pivotPoint = pivotPoint;
		object3D.projectorType = projectorType;
		object3D.extra = (Std.is(extra, IClonable)) ? (cast(extra, IClonable)).clone() : extra;
		return object3D;
	}

	/**
	 * Default method for adding a parentupdated event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnParentUpdate(listener:Dynamic):Void {
		
		addEventListener(Object3DEvent.PARENT_UPDATED, listener, false, 0, true);
	}

	/**
	 * Default method for removing a parentupdated event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnParentUpdate(listener:Dynamic):Void {
		
		removeEventListener(Object3DEvent.PARENT_UPDATED, listener, false);
	}

	/**
	 * Default method for adding a transformchanged event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnTransformChange(listener:Dynamic):Void {
		
		addEventListener(Object3DEvent.TRANSFORM_CHANGED, listener, false, 0, true);
	}

	/**
	 * Default method for removing a transformchanged event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnTransformChange(listener:Dynamic):Void {
		
		removeEventListener(Object3DEvent.TRANSFORM_CHANGED, listener, false);
	}

	/**
	 * Default method for adding a scenetransformchanged event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnSceneTransformChange(listener:Dynamic):Void {
		
		addEventListener(Object3DEvent.SCENETRANSFORM_CHANGED, listener, false, 0, true);
	}

	/**
	 * Default method for removing a scenetransformchanged event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnSceneTransformChange(listener:Dynamic):Void {
		
		removeEventListener(Object3DEvent.SCENETRANSFORM_CHANGED, listener, false);
	}

	/**
	 * Default method for adding a scenechanged event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnSceneChange(listener:Dynamic):Void {
		
		addEventListener(Object3DEvent.SCENE_CHANGED, listener, false, 0, true);
	}

	/**
	 * Default method for removing a scenechanged event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnSceneChange(listener:Dynamic):Void {
		
		removeEventListener(Object3DEvent.SCENE_CHANGED, listener, false);
	}

	/**
	 * Default method for adding a sessionchanged event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnSessionChange(listener:Dynamic):Void {
		
		addEventListener(Object3DEvent.SESSION_CHANGED, listener, false, 0, true);
	}

	/**
	 * Default method for removing a sessionchanged event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnSessionChange(listener:Dynamic):Void {
		
		removeEventListener(Object3DEvent.SESSION_CHANGED, listener, false);
	}

	/**
	 * Default method for adding a dimensionschanged event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnDimensionsChange(listener:Dynamic):Void {
		
		addEventListener(Object3DEvent.DIMENSIONS_CHANGED, listener, false, 0, true);
	}

	/**
	 * Default method for removing a dimensionschanged event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnDimensionsChange(listener:Dynamic):Void {
		
		removeEventListener(Object3DEvent.DIMENSIONS_CHANGED, listener, false);
	}

	/**
	 * Default method for adding a mouseMove3D event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnMouseMove(listener:Dynamic):Void {
		
		addEventListener(MouseEvent3D.MOUSE_MOVE, listener, false, 0, false);
	}

	/**
	 * Default method for removing a mouseMove3D event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnMouseMove(listener:Dynamic):Void {
		
		removeEventListener(MouseEvent3D.MOUSE_MOVE, listener, false);
	}

	/**
	 * Default method for adding a mouseDown3D event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnMouseDown(listener:Dynamic):Void {
		
		addEventListener(MouseEvent3D.MOUSE_DOWN, listener, false, 0, false);
	}

	/**
	 * Default method for removing a mouseDown3D event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnMouseDown(listener:Dynamic):Void {
		
		removeEventListener(MouseEvent3D.MOUSE_DOWN, listener, false);
	}

	/**
	 * Default method for adding a mouseUp3D event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnMouseUp(listener:Dynamic):Void {
		
		addEventListener(MouseEvent3D.MOUSE_UP, listener, false, 0, false);
	}

	/**
	 * Default method for removing a mouseUp3D event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnMouseUp(listener:Dynamic):Void {
		
		removeEventListener(MouseEvent3D.MOUSE_UP, listener, false);
	}

	/**
	 * Default method for adding a mouseOver3D event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnMouseOver(listener:Dynamic):Void {
		
		addEventListener(MouseEvent3D.MOUSE_OVER, listener, false, 0, false);
	}

	/**
	 * Default method for removing a mouseOver3D event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnMouseOver(listener:Dynamic):Void {
		
		removeEventListener(MouseEvent3D.MOUSE_OVER, listener, false);
	}

	/**
	 * Default method for adding a mouseOut3D event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnMouseOut(listener:Dynamic):Void {
		
		addEventListener(MouseEvent3D.MOUSE_OUT, listener, false, 0, false);
	}

	/**
	 * Default method for removing a mouseOut3D event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnMouseOut(listener:Dynamic):Void {
		
		removeEventListener(MouseEvent3D.MOUSE_OUT, listener, false);
	}

	/**
	 * Default method for adding a rollOver3D event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnRollOver(listener:Dynamic):Void {
		
		addEventListener(MouseEvent3D.ROLL_OVER, listener, false, 0, false);
	}

	/**
	 * Default method for removing a rollOver3D event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnRollOver(listener:Dynamic):Void {
		
		removeEventListener(MouseEvent3D.ROLL_OVER, listener, false);
	}

	/**
	 * Default method for adding a rollOut3D event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnRollOut(listener:Dynamic):Void {
		
		addEventListener(MouseEvent3D.ROLL_OUT, listener, false, 0, false);
	}

	/**
	 * Default method for removing a rollOut3D event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnRollOut(listener:Dynamic):Void {
		
		removeEventListener(MouseEvent3D.ROLL_OUT, listener, false);
	}

}

