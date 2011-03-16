package away3dlite.animators
{
	import away3dlite.animators.frames.Frame;
	import away3dlite.arcane;
	import away3dlite.core.*;
	import away3dlite.core.base.*;

	import flash.utils.Dictionary;

	use namespace arcane;

	/**
	 * Animates a series of <code>Frame</code> objects in sequence in a mesh.
	 */
	public class MovieMesh extends Mesh implements IDestroyable
	{
		/*
		 * Three kinds of animation sequences:
		 *  [1] Normal (sequential, just playing)
		 *  [2] Loop   (a loop)
		 *  [3] Stop   (stopped, not animating)
		 */
		public static const ANIM_NORMAL:int = 1;
		public static const ANIM_LOOP:int = 2;
		public static const ANIM_STOP:int = 4;
		private var _totalFrames:int = 0;

		public function get totalFrames():int
		{
			return _totalFrames;
		}

		//Keep track of the current frame number and animation
		private var _currentFrame:int = 0;
		private var _addFrame:int;
		private var _interp:Number = 0;
		private var _begin:int;
		private var _end:int;
		private var _type:int;

		public function get status():int
		{
			return _type;
		}

		private var _ctime:int = 0;

		public function get currentTime():Number
		{
			return _ctime;
		}

		private var _otime:int;

		public function set prevTime(value:int):void
		{
			_otime = value;
		}

		private var _labels:Dictionary = new Dictionary(true);
		private var _currentLabel:String;

		public function seek(ctime:int, otime:int):void
		{
			var cframe:Frame;
			var nframe:Frame;
			var i:int = _vertices.length;

			_ctime = ctime;

			cframe = frames[_currentFrame];
			nframe = frames[(_currentFrame + 1) % _totalFrames];

			// TODO : optimize
			var _cframe_vertices:Vector.<Number> = cframe.vertices;
			var _nframe_vertices:Vector.<Number> = nframe.vertices;

			if (visible)
				while (i--)
					_vertices[int(i)] = _cframe_vertices[int(i)] + _interp * (_nframe_vertices[int(i)] - _cframe_vertices[int(i)]);

			if (_type != ANIM_STOP)
			{
				_interp += fps * (ctime - otime) / 1000;

				if (_interp > 1)
				{
					_addFrame = int(_interp);

					if ((_type == ANIM_LOOP || _type == ANIM_NORMAL) && _currentFrame + _addFrame >= _end)
						keyframe = _begin + _currentFrame + _addFrame - _end;
					else
						keyframe += _addFrame;

					_interp -= _addFrame;
				}
			}
			_otime = ctime;

			if (visible && _scene)
				_scene.isDirty = true;
		}

		/**
		 * Number of animation frames to display per second
		 */
		public var fps:int = 30;

		/**
		 * The array of frames that make up the animation sequence.
		 */
		public var frames:Vector.<Frame> = new Vector.<Frame>();

		/**
		 * Creates a new <code>MovieMesh</code> object that provides a "keyframe animation"/"vertex animation"/"mesh deformation" framework for subclass loaders.
		 */
		public function MovieMesh()
		{
			super();
		}

		/**
		 * Adds a new frame to the animation timeline.
		 */
		public function addFrame(frame:Frame):void
		{
			var _name:String = frame.name.replace(/[0-9]/g, "");

			if (!_labels[_name])
				_labels[_name] = new FrameData(_totalFrames, _totalFrames);
			else
				++FrameData(_labels[_name]).end;

			frames.push(frame);

			_totalFrames++;
		}

		/**
		 * Begins a looping sequence in the animation.
		 *
		 * @param begin		The starting frame position.
		 * @param end		The ending frame position.
		 */
		public function loop(begin:int, end:int):void
		{
			if (_totalFrames > 0)
			{
				_begin = (begin % _totalFrames);
				_end = (end % _totalFrames);
			}
			else
			{
				_begin = begin;
				_end = end;
			}

			keyframe = begin;
			_type = ANIM_LOOP;
		}

		/**
		 * Plays a pre-defined labelled sequence of animation frames.
		 */
		public function gotoAndPlay(label:String):void
		{
			if (!_labels)
				return;

			_currentLabel = label;

			var _frameData:FrameData = _labels[label] as FrameData;
			if (_frameData)
			{
				loop(_frameData.begin, _frameData.end);
			}
			else
			{
				var _begin:int = 0;
				var _end:int = 0;

				for each (_frameData in _labels)
				{
					_begin = (_frameData.begin < _begin) ? _frameData.begin : _begin;
					_end = (_frameData.end > _end) ? _frameData.end : _end;

					loop(_begin, _end);
				}
			}

			_type = ANIM_NORMAL;
		}

		public function play():void
		{
			_type = ANIM_NORMAL;
		}

		/**
		 * Stops the animation.
		 */
		public function stop():void
		{
			_type = ANIM_STOP;
		}

		/**
		 * Defines the current keyframe.
		 */
		public function get keyframe():int
		{
			return _currentFrame;
		}

		public function set keyframe(i:int):void
		{
			_currentFrame = i % _totalFrames;
		}

		public override function clone(object:Object3D = null):Object3D
		{
			var mesh:MovieMesh = (object as MovieMesh) || new MovieMesh();
			super.clone(mesh);

			mesh._totalFrames = _totalFrames;
			mesh.fps = fps;
			mesh.frames = frames.concat();

			mesh._currentLabel = _currentLabel;
			mesh._begin = _begin;
			mesh._end = _end;
			mesh._type = _type;

			for (var i:* in _labels)
				mesh._labels[i] = _labels[i];

			return mesh;
		}

		override public function destroy():void
		{
			if (_isDestroyed)
				return;

			stop();

			_labels = null;
			frames = null;

			super.destroy();
		}
	}
}

internal class FrameData
{
	public var begin:int;
	public var end:int;

	public function FrameData(begin:int, end:int)
	{
		this.begin = begin;
		this.end = end;
	}
}