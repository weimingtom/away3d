package away3d.animators;

import away3d.containers.Scene3D;


class TimeBase  {
	public var time(getTime, null) : Float;
	public var fps(getFps, setFps) : Float;
	
	private var _fps:Float;
	private var _time:Float;
	private var _frameval:Float;
	private var _scene:Scene3D;
	

	private function getTime():Float {
		
		var now:Int = _scene.tickTraverser.now;
		if (now != _time) {
			_frameval = (now - _time) * fps / 1000;
		}
		_time = now;
		return _frameval;
	}

	/**
	 * Creates a new <code>TimeBase</code> object.
	 *
	 * @param	scene				The scene 
	 * @param	fpsrate				The frame per second rate
	 * 
	 */
	public function new(scene:Scene3D, fpsrate:Float) {
		this._time = 1;
		
		
		fps = fpsrate;
		_scene = scene;
		scene.updateTime();
	}

	/**
	 * Set the fps rate set for this class.
	 */
	public function setFps(value:Float):Float {
		
		_fps = (value > 0) ? value : _fps;
		return value;
	}

	/**
	 * Returns  the fps rate set for this class.
	 * 
	 * @return	The fps rate set for this class.
	 */
	public function getFps():Float {
		
		return _fps;
	}

	/**
	 * Returns the value passed at a the actual fps rate set for this class.
	 * 
	 * @param	value		The number to be interpreted at the fps rate set for this class
	 * 
	 * @return	A Number, the value passed at a the actual fps rate set for this class
	 */
	public function timeVal(value:Float):Float {
		
		return value * ((value / fps) * time);
	}

}

