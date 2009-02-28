package away3d.core.render;

import away3d.containers.Scene3D;
import away3d.containers.ObjectContainer3D;
import flash.events.EventDispatcher;
import away3d.containers.View3D;
import away3d.core.filter.ZSortFilter;
import away3d.cameras.Camera3D;
import away3d.core.draw.IPrimitiveConsumer;
import away3d.core.clip.Clipping;
import away3d.core.filter.IPrimitiveFilter;
import flash.display.Sprite;
import away3d.core.draw.DrawPrimitive;
import away3d.core.block.Blocker;


/** 
 * Default renderer for a view.
 * Contains the main render loop for rendering a scene to a view,
 * which resolves the projection, culls any drawing primitives that are occluded or outside the viewport,
 * and then z-sorts and renders them to screen.
 */
class BasicRenderer implements IRenderer, implements IPrimitiveConsumer {
	public var filters(getFilters, setFilters) : Array<Dynamic>;
	
	private var _filters:Array<Dynamic>;
	private var _primitive:DrawPrimitive;
	private var _primitives:Array<Dynamic>;
	private var _view:View3D;
	private var _scene:Scene3D;
	private var _camera:Camera3D;
	private var _screenClipping:Clipping;
	private var _blockers:Array<Dynamic>;
	private var _filter:IPrimitiveFilter;
	private var _blocker:Blocker;
	

	/**
	 * Defines the array of filters to be used on the drawing primitives.
	 */
	public function getFilters():Array<Dynamic> {
		
		return _filters.slice(0, _filters.length - 1);
	}

	public function setFilters(val:Array<Dynamic>):Array<Dynamic> {
		
		_filters = val;
		_filters.push(new ZSortFilter());
		return val;
	}

	/**
	 * Creates a new <code>BasicRenderer</code> object.
	 *
	 * @param	filters	[optional]	An array of filters to use on projected drawing primitives before rendering them to screen.
	 */
	public function new(?filters:Array<Dynamic>) {
		if (filters == null) filters = new Array<Dynamic>();
		this._primitives = [];
		this._blockers = [];
		
		
		_filters = filters;
		_filters.push(new ZSortFilter());
	}

	/**
	 * @inheritDoc
	 */
	public function primitive(pri:DrawPrimitive):Bool {
		
		if (!_screenClipping.checkPrimitive(pri)) {
			return false;
		}
		for (__i in 0..._blockers.length) {
			_blocker = _blockers[__i];

			if (_blocker != null) {
				if (_blocker.screenZ > pri.minZ) {
					continue;
				}
				if (_blocker.block(pri)) {
					return false;
				}
			}
		}

		_primitives.push(pri);
		return true;
	}

	/**
	 * A list of primitives that have been clipped and blocked.
	 * 
	 * @return	An array containing the primitives to be rendered.
	 */
	public function list():Array<Dynamic> {
		
		return _primitives;
	}

	public function clear(view:View3D):Void {
		
		_primitives = [];
		_scene = view.scene;
		_camera = view.camera;
		_screenClipping = view.screenClipping;
		_blockers = view.blockerarray.list();
	}

	public function render(view:View3D):Void {
		//filter primitives array
		
		for (__i in 0..._filters.length) {
			_filter = _filters[__i];

			if (_filter != null) {
				_primitives = _filter.filter(_primitives, _scene, _camera, _screenClipping);
			}
		}

		// render all primitives
		for (__i in 0..._primitives.length) {
			_primitive = _primitives[__i];

			if (_primitive != null) {
				_primitive.render();
			}
		}

	}

	/**
	 * @inheritDoc
	 */
	public function toString():String {
		
		return "Basic [" + _filters.join("+") + "]";
	}

	public function clone():IPrimitiveConsumer {
		
		var renderer:BasicRenderer = new BasicRenderer();
		renderer.filters = filters;
		return renderer;
	}

}

