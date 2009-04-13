package away3d.core.base;

import away3d.core.base.Geometry;
import away3d.core.base.Vertex;
import flash.events.EventDispatcher;


/**
 * Holds information about the current state of animation to transition into another animation.
 */
class AnimationTransition  {
	public var interpolate(getInterpolate, null) : Float;
	public var transitionValue(getTransitionValue, setTransitionValue) : Float;
	
	private var _steps:Float;
	private var _transitionvalue:Float;
	private var _geom:Geometry;
	private var _interpolate:Float;
	private var _refFrame:Array<Vertex>;
	

	public function new(geo:Geometry) {
		this._steps = .1;
		this._transitionvalue = 10;
		
		
		_interpolate = 1;
		_geom = geo;
		setRef();
	}

	private function setRef():Void {
		
		_refFrame = [];
		var i:Int = 0;
		while (i < _geom.vertices.length) {
			_refFrame.push(new Vertex(_geom.vertices[i].x, _geom.vertices[i].y, _geom.vertices[i].z));
			
			// update loop variables
			++i;
		}

	}

	private function updateRef():Void {
		var i:Int = 0;
		while (i < _refFrame.length) {
			_refFrame[i].x = _geom.vertices[i].x;
			_refFrame[i].y = _geom.vertices[i].y;
			_refFrame[i].z = _geom.vertices[i].z;
			
			// update loop variables
			++i;
		}

	}

	public function update():Void {
		
		if (_interpolate < 1) {
			var inv:Float = 1 - _interpolate;
			var i:Int = 0;
			while (i < _refFrame.length) {
				_geom.vertices[i].x = (_refFrame[i].x * inv) + (_geom.vertices[i].x * _interpolate);
				_geom.vertices[i].y = (_refFrame[i].y * inv) + (_geom.vertices[i].y * _interpolate);
				_geom.vertices[i].z = (_refFrame[i].z * inv) + (_geom.vertices[i].z * _interpolate);
				
				// update loop variables
				++i;
			}

			_interpolate += _steps;
		}
	}

	public function reset():Void {
		
		updateRef();
		_interpolate = _steps;
	}

	public function getInterpolate():Float {
		
		return _interpolate;
	}

	public function setTransitionValue(val:Float):Float {
		
		_transitionvalue = (val < 1) ? 1 : val;
		_steps = 1 / val;
		return val;
	}

	public function getTransitionValue():Float {
		
		return _transitionvalue;
	}

}

