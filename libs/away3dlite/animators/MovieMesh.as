package away3dlite.animators
{
	import away3dlite.animators.frames.Frame;
	import away3dlite.arcane;
	import away3dlite.core.*;
	import away3dlite.core.base.*;
	
	import flash.events.*;
	import flash.utils.*;

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
		private var framesLength:int = 0;

		//Keep track of the current frame number and animation
		private var _currentFrame:int = 0;
		private var _addFrame:int;
		private var _interp:Number = 0;
		private var _begin:int;
		private var _end:int;
		private var _type:int;
		private var _ctime:Number = 0;
		private var _otime:Number = 0;

		private var _labels:Dictionary = new Dictionary(true);
		private var _currentLabel:String;
		
		public var isPlaying:Boolean;
		public var isParentControl:Boolean;
		
		private function onEnterFrame(event:Event = null):void
		{
			seek(_ctime = getTimer(), _otime);
		}
		
		public function seek(ctime:Number, otime:Number):void
		{
			isPlaying = true;
			
			var cframe:Frame;
			var nframe:Frame;
			var i:int = _vertices.length;

			cframe = frames[_currentFrame];
			nframe = frames[(_currentFrame + 1) % framesLength];

			// TODO : optimize
			var _cframe_vertices:Vector.<Number> = cframe.vertices;
			var _nframe_vertices:Vector.<Number> = nframe.vertices;

			if(visible)
			while (i--)
				_vertices[i] = _cframe_vertices[i] + _interp * (_nframe_vertices[i] - _cframe_vertices[i]);

			if (_type != ANIM_STOP)
			{
				_interp += fps * (ctime - otime) / 1000;

				if (_interp > 1)
				{
					_addFrame = int(_interp);

					if (_type == ANIM_LOOP || _type == ANIM_NORMAL && _currentFrame + _addFrame >= _end)
						keyframe = _begin + _currentFrame + _addFrame - _end;
					else
						keyframe += _addFrame;

					_interp -= _addFrame;
				}
			}
			_otime = ctime;
			
			transfromDirty = true;
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
			var _name:String = frame.name.slice(0, frame.name.length - 3);

			if (!_labels[_name])
				_labels[_name] = {begin: framesLength, end: framesLength};
			else
				++_labels[_name].end;

			frames.push(frame);

			framesLength++;
		}

		/**
		 * Begins a looping sequence in the animation.
		 *
		 * @param begin		The starting frame position.
		 * @param end		The ending frame position.
		 */
		public function loop(begin:int, end:int):void
		{
			if (framesLength > 0)
			{
				_begin = (begin % framesLength);
				_end = (end % framesLength);
			}
			else
			{
				_begin = begin;
				_end = end;
			}

			keyframe = begin;
			_type = ANIM_LOOP;

			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			if(!isParentControl)
				addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		/**
		 * Plays a pre-defined labelled sequence of animation frames.
		 */
		public function play(label:String = "frame"):void
		{
			if (!_labels)
				return;

			if (_currentLabel != label)
			{
				_currentLabel = label;

				if (_labels[label])
				{
					loop(_labels[label].begin, _labels[label].end);
				}
				else
				{
					var _begin:int = 0;
					var _end:int = 0;

					for (var i:Object in _labels)
					{
						_begin = (_labels[i].begin < _begin) ? _labels[i].begin : _begin;
						_end = (_labels[i].end > _end) ? _labels[i].end : _end;

						loop(_begin, _end);
					}
				}
			}
			
			_type = ANIM_NORMAL;

			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			if(!isParentControl)
				addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		/**
		 * Stops the animation.
		 */
		public function stop():void
		{
			_type = ANIM_STOP;

			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
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
			_currentFrame = i % framesLength;
		}
		
		public override function clone(object:Object3D = null):Object3D
		{
			var mesh:MovieMesh = (object as MovieMesh) || new MovieMesh();
			super.clone(mesh);
			
			mesh.framesLength = framesLength;
			mesh.fps = fps;
			mesh.frames = frames.concat();
			mesh.isParentControl = isParentControl;
			
			return mesh;
		}
		
		override public function get destroyed():Boolean
		{
			return _isDestroyed;
		}

		override public function destroy():void
		{
			if (_isDestroyed)
				return;

			_isDestroyed = true;

			stop();

			_labels = null;
			frames = null;
		}
	}
}