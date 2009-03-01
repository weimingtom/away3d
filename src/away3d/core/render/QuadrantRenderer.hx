package away3d.core.render;

import away3d.containers.Scene3D;
import away3d.containers.ObjectContainer3D;
import flash.events.EventDispatcher;
import away3d.containers.View3D;
import away3d.core.filter.IPrimitiveQuadrantFilter;
import away3d.cameras.Camera3D;
import away3d.core.draw.IPrimitiveConsumer;
import away3d.core.clip.Clipping;
import away3d.core.base.Object3D;
import away3d.core.draw.PrimitiveQuadrantTreeNode;
import flash.display.Sprite;
import away3d.core.draw.DrawPrimitive;


/** Renderer that uses quadrant tree for storing and operating drawing primitives. Quadrant tree speeds up all proximity based calculations. */
class QuadrantRenderer implements IPrimitiveConsumer, implements IRenderer {
	public var filters(getFilters, setFilters) : Array<Dynamic>;
	
	private var _qdrntfilters:Array<Dynamic>;
	private var _root:PrimitiveQuadrantTreeNode;
	private var _center:Array<Dynamic>;
	private var _result:Array<Dynamic>;
	private var _except:Object3D;
	private var _minX:Float;
	private var _minY:Float;
	private var _maxX:Float;
	private var _maxY:Float;
	private var _child:DrawPrimitive;
	private var _children:Array<Dynamic>;
	private var i:Int;
	private var _primitives:Array<Dynamic>;
	private var _clippedPrimitives:Array<Dynamic>;
	private var _view:View3D;
	private var _scene:Scene3D;
	private var _camera:Camera3D;
	private var _screenClipping:Clipping;
	private var _blockers:Array<Dynamic>;
	private var _filter:IPrimitiveQuadrantFilter;
	

	private function getList(node:PrimitiveQuadrantTreeNode):Void {
		
		if (node.onlysourceFlag && _except == node.onlysource) {
			return;
		}
		if (_minX < node.xdiv) {
			if (node.lefttopFlag && _minY < node.ydiv) {
				getList(node.lefttop);
			}
			if (node.leftbottomFlag && _maxY > node.ydiv) {
				getList(node.leftbottom);
			}
		}
		if (_maxX > node.xdiv) {
			if (node.righttopFlag && _minY < node.ydiv) {
				getList(node.righttop);
			}
			if (node.rightbottomFlag && _maxY > node.ydiv) {
				getList(node.rightbottom);
			}
		}
		_children = node.center;
		if (_children != null) {
			i = _children.length;
			while ((i-- > 0)) {
				_child = _children[i];
				if ((_except == null || _child.source != _except) && _child.maxX > _minX && _child.minX < _maxX && _child.maxY > _minY && _child.minY < _maxY) {
					_result.push(_child);
				}
			}

		}
	}

	private function getParent(?node:PrimitiveQuadrantTreeNode=null):Void {
		
		node = node.parent;
		if (node == null || (node.onlysourceFlag && _except == node.onlysource)) {
			return;
		}
		_children = node.center;
		if (_children != null) {
			i = _children.length;
			while ((i-- > 0)) {
				_child = _children[i];
				if ((_except == null || _child.source != _except) && _child.maxX > _minX && _child.minX < _maxX && _child.maxY > _minY && _child.minY < _maxY) {
					_result.push(_child);
				}
			}

		}
		getParent(node);
	}

	/**
	 * Defines the array of filters to be used on the drawing primitives.
	 */
	public function getFilters():Array<Dynamic> {
		
		return _qdrntfilters;
	}

	public function setFilters(val:Array<Dynamic>):Array<Dynamic> {
		
		_qdrntfilters = val;
		return val;
	}

	/**
	 * Creates a new <code>QuadrantRenderer</code> object.
	 *
	 * @param	filters	[optional]	An array of filters to use on projected drawing primitives before rendering them to screen.
	 */
	public function new(?filters:Array<Dynamic>) {
		if (filters == null) filters = new Array<Dynamic>();
		
		
		_qdrntfilters = filters;
	}

	/**
	 * @inheritDoc
	 */
	public function primitive(pri:DrawPrimitive):Bool {
		
		if (!_screenClipping.checkPrimitive(pri)) {
			return false;
		}
		_root.push(pri);
		return true;
	}

	/**
	 * removes a drawing primitive from the quadrant tree.
	 * 
	 * @param	pri	The drawing primitive to remove.
	 */
	public function remove(pri:DrawPrimitive):Void {
		
		_center = pri.quadrant.center;
		_center.splice(untyped _center.indexOf(pri), 1);
	}

	/**
	 * Returns an array containing all primiives overlapping the specifed primitive's quadrant.
	 * 
	 * @param	pri					The drawing primitive to check.
	 * @param	ex		[optional]	Excludes primitives that are children of the 3d object.
	 * @return						An array of drawing primitives.
	 */
	public function get(pri:DrawPrimitive, ?ex:Object3D=null):Array<Dynamic> {
		
		_result = [];
		_minX = pri.minX;
		_minY = pri.minY;
		_maxX = pri.maxX;
		_maxY = pri.maxY;
		_except = ex;
		getList(pri.quadrant);
		getParent(pri.quadrant);
		return _result;
	}

	/**
	 * A list of primitives that have been clipped.
	 * 
	 * @return	An array containing the primitives to be rendered.
	 */
	public function list():Array<Dynamic> {
		
		_result = [];
		_minX = -1000000;
		_minY = -1000000;
		_maxX = 1000000;
		_maxY = 1000000;
		_except = null;
		getList(_root);
		return _result;
	}

	public function clear(view:View3D):Void {
		
		_primitives = [];
		_scene = view.scene;
		_camera = view.camera;
		_screenClipping = view.screenClipping;
		if (_root == null) {
			_root = new PrimitiveQuadrantTreeNode((_screenClipping.minX + _screenClipping.maxX) / 2, (_screenClipping.minY + _screenClipping.maxY) / 2, _screenClipping.maxX - _screenClipping.minX, _screenClipping.maxY - _screenClipping.minY, 0);
		} else {
			_root.reset((_screenClipping.minX + _screenClipping.maxX) / 2, (_screenClipping.minY + _screenClipping.maxY) / 2, _screenClipping.maxX - _screenClipping.minX, _screenClipping.maxY - _screenClipping.minY);
		}
	}

	public function render(view:View3D):Void {
		//filter primitives array
		
		for (__i in 0..._qdrntfilters.length) {
			_filter = _qdrntfilters[__i];

			if (_filter != null) {
				_filter.filter(this, _scene, _camera, _screenClipping);
			}
		}

		// render all primitives
		_root.render(-Math.POSITIVE_INFINITY);
	}

	/**
	 * @inheritDoc
	 */
	public function toString():String {
		
		return "Quadrant [" + _qdrntfilters.join("+") + "]";
	}

	public function clone():IPrimitiveConsumer {
		
		var renderer:QuadrantRenderer = new QuadrantRenderer();
		renderer.filters = filters;
		return renderer;
	}

}

