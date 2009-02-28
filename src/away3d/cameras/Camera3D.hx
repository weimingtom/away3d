package away3d.cameras;

import away3d.events.CameraEvent;
import flash.display.Sprite;
import away3d.core.utils.ValueObject;
import away3d.core.utils.DofCache;
import away3d.core.utils.CameraVarsStore;
import away3d.cameras.lenses.ZoomFocusLens;
import away3d.core.math.Number3D;
import flash.events.EventDispatcher;
import away3d.core.math.Matrix3D;
import away3d.core.base.Vertex;
import away3d.core.utils.DrawPrimitiveStore;
import away3d.containers.View3D;
import flash.utils.Dictionary;
import away3d.core.utils.Init;
import flash.events.Event;
import away3d.core.clip.Clipping;
import away3d.core.draw.ScreenVertex;
import away3d.core.base.Object3D;
import away3d.cameras.lenses.ILens;
import away3d.cameras.lenses.AbstractLens;


/**
 * Dispatched when the focus or zoom properties of a camera update.
 * 
 * @eventType away3d.events.CameraEvent
 * 
 * @see #focus
 * @see #zoom
 */
// [Event(name="cameraUpdated", type="away3d.events.CameraEvent")]

/**
 * Basic camera used to resolve a view.
 * 
 * @see	away3d.containers.View3D
 */
class Camera3D extends Object3D  {
	public var aperture(getAperture, setAperture) : Float;
	public var dof(getDof, setDof) : Bool;
	public var focus(getFocus, setFocus) : Float;
	public var zoom(getZoom, setZoom) : Float;
	public var lens(getLens, setLens) : ILens;
	public var fov(getFov, setFov) : Float;
	public var view(getView, setView) : View3D;
	public var viewMatrix(getViewMatrix, null) : Matrix3D;
	
	private var _fovDirty:Bool;
	private var _zoomDirty:Bool;
	private var _aperture:Float;
	private var _dof:Bool;
	private var _flipY:Matrix3D;
	private var _focus:Float;
	private var _zoom:Float;
	private var _lens:ILens;
	private var _fov:Float;
	private var _clipping:Clipping;
	private var _clipTop:Float;
	private var _clipBottom:Float;
	private var _clipLeft:Float;
	private var _clipRight:Float;
	private var _viewMatrix:Matrix3D;
	private var _view:View3D;
	private var _drawPrimitiveStore:DrawPrimitiveStore;
	private var _cameraVarsStore:CameraVarsStore;
	private var _vt:Matrix3D;
	private var _cameraupdated:CameraEvent;
	private var _x:Float;
	private var _y:Float;
	private var _z:Float;
	private var _sz:Float;
	private var _persp:Float;
	private static inline var toRADIANS:Float = Math.PI / 180;
	private static inline var toDEGREES:Float = 180 / Math.PI;
	public var invViewMatrix:Matrix3D;
	public var fixedZoom:Bool;
	/**
	 * Used in <code>DofSprite2D</code>.
	 * 
	 * @see	away3d.sprites.DofSprite2D
	 */
	public var maxblur:Float;
	/**
	 * Used in <code>DofSprite2D</code>.
	 * 
	 * @see	away3d.sprites.DofSprite2D
	 */
	public var doflevels:Float;
	

	private function notifyCameraUpdate():Void {
		
		if (!hasEventListener(CameraEvent.CAMERA_UPDATED)) {
			return;
		}
		if (_cameraupdated == null) {
			_cameraupdated = new CameraEvent(CameraEvent.CAMERA_UPDATED, this);
		}
		dispatchEvent(_cameraupdated);
	}

	/**
	 * Used in <code>DofSprite2D</code>.
	 * 
	 * @see	away3d.sprites.DofSprite2D
	 */
	public function getAperture():Float {
		
		return _aperture;
	}

	public function setAperture(value:Float):Float {
		
		_aperture = value;
		DofCache.aperture = _aperture;
		return value;
	}

	/**
	 * Used in <code>DofSprite2D</code>.
	 * 
	 * @see	away3d.sprites.DofSprite2D
	 */
	public function getDof():Bool {
		
		return _dof;
	}

	public function setDof(value:Bool):Bool {
		
		_dof = value;
		if (_dof) {
			enableDof();
		} else {
			disableDof();
		}
		return value;
	}

	/**
	 * A divisor value for the perspective depth of the view.
	 */
	public function getFocus():Float {
		
		return _focus;
	}

	public function setFocus(value:Float):Float {
		
		_focus = value;
		DofCache.focus = _focus;
		notifyCameraUpdate();
		return value;
	}

	/**
	 * Provides an overall scale value to the view
	 */
	public function getZoom():Float {
		
		return _zoom;
	}

	public function setZoom(value:Float):Float {
		
		if (_zoom == value) {
			return value;
		}
		_zoom = value;
		_zoomDirty = false;
		_fovDirty = true;
		notifyCameraUpdate();
		return value;
	}

	/**
	 * Defines a lens object used in vertex projection
	 */
	public function getLens():ILens {
		
		return _lens;
	}

	public function setLens(value:ILens):ILens {
		
		if (_lens == value) {
			return value;
		}
		_lens = value;
		notifyCameraUpdate();
		return value;
	}

	/**
	 * Defines the field of view of the camera in a vertical direction.
	 */
	public function getFov():Float {
		
		return _fov;
	}

	public function setFov(value:Float):Float {
		
		if (_fov == value) {
			return value;
		}
		_fov = value;
		_fovDirty = false;
		_zoomDirty = true;
		notifyCameraUpdate();
		return value;
	}

	public function getView():View3D {
		
		return _view;
	}

	public function setView(val:View3D):View3D {
		
		if (_view == val) {
			return val;
		}
		_view = val;
		_drawPrimitiveStore = val.drawPrimitiveStore;
		_cameraVarsStore = val.cameraVarsStore;
		return val;
	}

	/**
	 * Returns the transformation matrix used to resolve the scene to the view.
	 * Used in the <code>ProjectionTraverser</code> class
	 * 
	 * @see	away3d.core.traverse.ProjectionTraverser
	 */
	public function getViewMatrix():Matrix3D {
		
		invViewMatrix.multiply(sceneTransform, _flipY);
		_viewMatrix.inverse(invViewMatrix);
		return _viewMatrix;
	}

	/**
	 * Creates a new <code>Camera3D</code> object.
	 * 
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(?init:Dynamic=null) {
		this._aperture = 22;
		this._dof = false;
		this._flipY = new Matrix3D();
		this._zoom = 10;
		this._fov = 0;
		this._viewMatrix = new Matrix3D();
		this.invViewMatrix = new Matrix3D();
		this.maxblur = 150;
		this.doflevels = 16;
		
		
		super(init);
		fov = ini.getNumber("fov", _fov);
		focus = ini.getNumber("focus", 100);
		zoom = ini.getNumber("zoom", _zoom);
		fixedZoom = ini.getBoolean("fixedZoom", true);
		lens = cast(ini.getObject("lens", AbstractLens), ILens);
		if (lens == null)  {
			lens = new ZoomFocusLens();
		};
		aperture = ini.getNumber("aperture", 22);
		maxblur = ini.getNumber("maxblur", 150);
		doflevels = ini.getNumber("doflevels", 16);
		dof = ini.getBoolean("dof", false);
		var lookat:Number3D = ini.getPosition("lookat");
		_flipY.syy = -1;
		if ((lookat != null)) {
			lookAt(lookat);
		}
	}

	/**
	 * Used in <code>DofSprite2D</code>.
	 * 
	 * @see	away3d.sprites.DofSprite2D
	 */
	public function enableDof():Void {
		
		DofCache.doflevels = doflevels;
		DofCache.aperture = aperture;
		DofCache.maxblur = maxblur;
		DofCache.focus = focus;
		DofCache.resetDof(true);
	}

	/**
	 * Used in <code>DofSprite2D</code>
	 * 
	 * @see	away3d.sprites.DofSprite2D
	 */
	public function disableDof():Void {
		
		DofCache.resetDof(false);
	}

	/**
	 * Returns a <code>ScreenVertex</code> object describing the resolved x and y position of the given <code>Vertex</code> object.
	 * 
	 * @param	object	The local object for the Vertex. If none exists, use the <code>Scene3D</code> object.
	 * @param	vertex	The vertex to be resolved.
	 * 
	 * @see	away3d.containers.Scene3D
	 */
	public function screen(object:Object3D, ?vertex:Vertex=null):ScreenVertex {
		
		if (vertex == null) {
			vertex = object.center;
		}
		_cameraVarsStore.createViewTransform(object).multiply(viewMatrix, object.sceneTransform);
		_drawPrimitiveStore.createVertexDictionary(object);
		return lens.project(_cameraVarsStore.viewTransformDictionary[untyped object], vertex);
	}

	/**
	 * Updates the transformation matrix used to resolve the scene to the view.
	 * Used in the <code>BasicRender</code> class
	 * 
	 * @see	away3d.core.render.BasicRender
	 */
	public function update():Void {
		
		_view.updateScreenClipping();
		_clipping = _view.screenClipping;
		if (_clipTop != _clipping.maxY || _clipBottom != _clipping.minY || _clipLeft != _clipping.minX || _clipRight != _clipping.maxX) {
			if (!_fovDirty && !_zoomDirty) {
				if (fixedZoom) {
					_fovDirty = true;
				} else {
					_zoomDirty = true;
				}
			}
			_clipTop = _clipping.maxY;
			_clipBottom = _clipping.minY;
			_clipLeft = _clipping.minX;
			_clipRight = _clipping.maxX;
		}
		lens.setView(_view);
		if (_fovDirty) {
			_fovDirty = false;
			_fov = lens.getFOV();
		}
		if (_zoomDirty) {
			_zoomDirty = false;
			_zoom = lens.getZoom();
		}
	}

	/**
	 * Rotates the camera in its vertical plane.
	 * 
	 * Tilting the camera results in a motion similar to someone nodding their head "yes".
	 * 
	 * @param	angle	Angle to tilt the camera.
	 */
	public function tilt(angle:Float):Void {
		
		super.pitch(angle);
	}

	/**
	 * Rotates the camera in its horizontal plane.
	 * 
	 * Panning the camera results in a motion similar to someone shaking their head "no".
	 * 
	 * @param	angle	Angle to pan the camera.
	 */
	public function pan(angle:Float):Void {
		
		super.yaw(angle);
	}

	/**
	 * Duplicates the camera's properties to another <code>Camera3D</code> object.
	 * 
	 * @param	object	[optional]	The new object instance into which all properties are copied.
	 * @return						The new object instance with duplicated properties applied.
	 */
	public override function clone(?object:Object3D=null):Object3D {
		
		var camera:Camera3D = (cast(object, Camera3D));
		if (camera == null)  {
			camera = new Camera3D();
		};
		super.clone(camera);
		camera.zoom = zoom;
		camera.focus = focus;
		camera.lens = lens;
		return camera;
	}

	public function unproject(mX:Float, mY:Float):Number3D {
		
		var persp:Float = (focus * zoom) / focus;
		var vector:Number3D = new Number3D(mX / persp, -mY / persp, focus);
		transform.multiplyVector3x3(vector);
		return vector;
	}

	/**
	 * Default method for adding a cameraUpdated event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnCameraUpdate(listener:Dynamic):Void {
		
		addEventListener(CameraEvent.CAMERA_UPDATED, listener, false, 0, false);
	}

	/**
	 * Default method for removing a cameraUpdated event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnCameraUpdate(listener:Dynamic):Void {
		
		removeEventListener(CameraEvent.CAMERA_UPDATED, listener, false);
	}

}

