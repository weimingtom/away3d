package away3d.materials;

import away3d.haxeutils.Error;
import flash.events.Event;
import flash.utils.getTimer;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.display.MovieClip;
import flash.geom.Matrix;
import away3d.core.utils.Init;
import flash.display.Sprite;


// use namespace arcane;

/**
 * Bitmap material that allows fast rendering of animations by caching bitmapdata objects for each frame.
 * Not suitable for use with long animations, where the initialisation time will be lengthy and the memory footprint large.
 * If interactive movieclip properties are required, please refer to MovieMaterial.
 */
class AnimatedBitmapMaterial extends TransformBitmapMaterial, implements ITriangleMaterial, implements IUVMaterial {
	public var index(getIndex, setIndex) : Int;
	
	private var _broadcaster:Sprite;
	private var _playing:Bool;
	private var _index:Int;
	private var _cache:Array<Dynamic>;
	/**
	 * Indicates whether the animation will loop.
	 */
	public var loop:Bool;
	/**
	 * Indicates whether the animation will start playing on initialisation.
	 * If false, only the first frame is displayed.
	 */
	public var autoplay:Bool;
	

	private function update(?event:Event=null):Void {
		//increment _index
		
		if (_index < _cache.length - 1) {
			_index++;
		} else if (loop) {
			_index = 0;
		}
		_renderBitmap = _bitmap = _cache[_index];
		_bitmapDirty = true;
	}

	/**
	 * Creates a new <code>AnimatedBitmapMaterial</code> object.
	 *
	 * @param	movie				The movieclip to be bitmap cached for use in the material.
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(movie:MovieClip, ?init:Dynamic=null) {
		this._broadcaster = new Sprite();
		
		
		setMovie(movie);
		super(_cache[_index], init);
		loop = ini.getBoolean("loop", true);
		autoplay = ini.getBoolean("autoplay", true);
		_index = ini.getInt("_index", 0, {min:0, max:movie.totalFrames - 1});
		//add event listener
		if (autoplay) {
			play();
		}
		//trigger first frame
		if (loop || autoplay) {
			update();
		} else {
			_renderBitmap = _bitmap = _cache[_index];
		}
	}

	/**
	 * Resumes playback of the animation
	 */
	public function play():Void {
		
		if (!_playing) {
			_playing = true;
			_broadcaster.addEventListener(Event.ENTER_FRAME, update);
		}
	}

	/**
	 * Halts playback of the animation
	 */
	public function stop():Void {
		
		if (_playing) {
			_playing = false;
			_broadcaster.removeEventListener(Event.ENTER_FRAME, update);
		}
	}

	/**
	 * Resets the movieclip used by the material.
	 * 
	 * @param	movie	The movieclip to be bitmap cached for use in the material.
	 */
	public function setMovie(movie:MovieClip):Void {
		
		_cache = new Array<Dynamic>();
		var i:Int;
		var rect:Rectangle;
		var minX:Float = 100000;
		var minY:Float = 100000;
		var maxX:Float = -100000;
		var maxY:Float = -100000;
		i = movie.totalFrames;
		while ((i-- > 0)) {
			movie.gotoAndStop(i);
			rect = movie.getBounds(movie);
			if (minX > rect.left) {
				minX = rect.left;
			}
			if (minY > rect.top) {
				minY = rect.top;
			}
			if (maxX < rect.right) {
				maxX = rect.right;
			}
			if (maxY < rect.bottom) {
				maxY = rect.bottom;
			}
		}

		//draw the cached bitmaps
		var W:Int = Std.int(maxX - minX);
		var H:Int = Std.int(maxY - minY);
		var mat:Matrix = new Matrix(1, 0, 0, 1, -minX, -minY);
		var tmp_bmd:BitmapData;
		var timer:Int = flash.Lib.getTimer();
		i = 1;
		while (i < movie.totalFrames + 1) {
			movie.gotoAndStop(i);
			tmp_bmd = new BitmapData(W, H, true, 0x00FFFFFF);
			tmp_bmd.draw(movie, mat, null, null, tmp_bmd.rect, true);
			_cache.push(tmp_bmd);
			//error timeout for time over 2 seconds
			if (flash.Lib.getTimer() - timer > 2000) {
				throw new Error("AnimatedBitmapMaterial contains too many frames. MovieMaterial should be used instead.");
			}
			
			// update loop variables
			i++;
		}

	}

	/**
	 * Resets the cached bitmapData objects making up the animation with a pre-defined array.
	 */
	public function setFrames(sources:Array<Dynamic>):Void {
		
		var i:Int;
		if (_cache.length > 0) {
			i = 0;
			while (i < _cache.length) {
				_cache[i].dispose();
				
				// update loop variables
				++i;
			}

		}
		_cache = [];
		if (_index > sources.length - 1) {
			_index = sources.length - 1;
		}
		i = 0;
		while (i < sources.length) {
			_cache.push(sources[i]);
			
			// update loop variables
			++i;
		}

		_renderBitmap = _bitmap = _cache[_index];
	}

	/**
	 * Manually sets the frame index of the animation.
	 */
	public function setIndex(f:Int):Int {
		
		_index = (f < 0) ? 0 : (f > _cache.length - 1) ? _cache.length - 1 : f;
		_renderBitmap = _bitmap = _cache[_index];
		return f;
	}

	/**
	 * returns the frame index of the animation.
	 */
	public function getIndex():Int {
		
		return _index;
	}

	/**
	 * Manually clears all frames of the animation.
	 * a new series of bitmapdatas will be required using the setFrames handler.
	 */
	public function clear():Void {
		
		stop();
		if (_cache.length > 0) {
			var i:Int = 0;
			while (i < _cache.length) {
				_cache[i].dispose();
				
				// update loop variables
				++i;
			}

		}
		_cache = [];
	}

}

