package away3dlite.core.clip
{
	import away3dlite.arcane;
	import away3dlite.containers.*;
	import away3dlite.core.base.*;
	import away3dlite.events.*;

	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;

	/**
	 * Dispatched when the clipping properties of a clipping object update.
	 *
	 * @eventType away3dlite.events.ClipEvent
	 *
	 * @see #maxX
	 * @see #minX
	 * @see #maxY
	 * @see #minY
	 * @see #maxZ
	 * @see #minZ
	 */
	[Event(name="clippingUpdated", type="away3dlite.events.ClippingEvent")]

	/**
	 * Dispatched when the clipping properties of a screenClipping object update.
	 *
	 * @eventType away3dlite.events.ClipEvent
	 *
	 * @see #maxX
	 * @see #minX
	 * @see #maxY
	 * @see #minY
	 * @see #maxZ
	 * @see #minZ
	 */
	[Event(name="screenUpdated", type="away3dlite.events.ClippingEvent")]

	use namespace arcane;

	/**
	 * Base clipping class for no clipping.
	 */
	public class Clipping extends EventDispatcher
	{
		/** @private */
		protected var _isDestroyed:Boolean;

		/** @private */
		arcane function setView(view:View3D):void
		{
			_view = view;
		}

		/** @private */
		arcane function collectParticles(particles:Array):Array
		{
			var _particles:Array = [];
			var i:int = 0;
			for each (var _particle:IRenderable in particles)
			{
				if (!_particle.isClip)
				{
					var _projectedPosition:Vector3D = _particle.transformPosition;
					var _x:int = int(_projectedPosition.x);
					var _y:int = int(_projectedPosition.y);
					var _z:int = int(_particle.screenZ);

					if (_x > _minX && _x < _maxX && _y > _minY && _y < _maxY && _z > _minZ && _z < _maxZ)
						_particles[int(i++)] = _particle;
				}
			}
			return _particles;
		}

		/** @private */
		arcane function collectFaces(mesh:Mesh, faces:Vector.<Face>):void
		{
			_faces = mesh._faces;
			_screenVertices = mesh._screenVertices;

			for each (_face in _faces)
				if (_face.length == 4)
				{
					if (mesh.bothsides || _screenVertices[_face.x0] * (_screenVertices[_face.y2] - _screenVertices[_face.y1]) + _screenVertices[_face.x1] * (_screenVertices[_face.y0] - _screenVertices[_face.y2]) + _screenVertices[_face.x2] * (_screenVertices[_face.y1] - _screenVertices[_face.y0]) > 0 || _screenVertices[_face.x0] * (_screenVertices[_face.y3] - _screenVertices[_face.y2]) + _screenVertices[_face.x2] * (_screenVertices[_face.y0] - _screenVertices[_face.y3]) + _screenVertices[_face.x3] * (_screenVertices[_face.y2] - _screenVertices[_face.y0]) > 0)
						faces[faces.length] = _face;
				}
				else
				{
					if (mesh.bothsides || _screenVertices[_face.x0] * (_screenVertices[_face.y2] - _screenVertices[_face.y1]) + _screenVertices[_face.x1] * (_screenVertices[_face.y0] - _screenVertices[_face.y2]) + _screenVertices[_face.x2] * (_screenVertices[_face.y1] - _screenVertices[_face.y0]) > 0)
						faces[faces.length] = _face;
				}
		}

		/** @private */
		arcane function screen(container:Sprite, _loaderWidth:int, _loaderHeight:int):Clipping
		{
			if (!_clippingClone)
			{
				_clippingClone = clone();
				_clippingClone.addEventListener(ClippingEvent.SCREEN_UPDATED, onScreenUpdate);
			}

			_stage = container.stage;

			if (!_stage)
				return _clippingClone;

			if (_stage.scaleMode == StageScaleMode.NO_SCALE)
			{
				_stageWidth = _stage.stageWidth;
				_stageHeight = _stage.stageHeight;
			}
			else if (_stage.scaleMode == StageScaleMode.EXACT_FIT)
			{
				_stageWidth = _loaderWidth;
				_stageHeight = _loaderHeight;
			}
			else if (_stage.scaleMode == StageScaleMode.SHOW_ALL)
			{
				if (_stage.stageWidth / _loaderWidth < _stage.stageHeight / _loaderHeight)
				{
					_stageWidth = _loaderWidth;
					_stageHeight = _stage.stageHeight * _stageWidth / _stage.stageWidth;
				}
				else
				{
					_stageHeight = _loaderHeight;
					_stageWidth = _stage.stageWidth * _stageHeight / _stage.stageHeight;
				}
			}
			else if (_stage.scaleMode == StageScaleMode.NO_BORDER)
			{
				if (_stage.stageWidth / _loaderWidth > _stage.stageHeight / _loaderHeight)
				{
					_stageWidth = _loaderWidth;
					_stageHeight = _stage.stageHeight * _stageWidth / _stage.stageWidth;
				}
				else
				{
					_stageHeight = _loaderHeight;
					_stageWidth = _stage.stageWidth * _stageHeight / _stage.stageHeight;
				}
			}

			if (_stage.align == StageAlign.TOP_LEFT)
			{

				_localPointTL.x = 0;
				_localPointTL.y = 0;

				_localPointBR.x = _stageWidth;
				_localPointBR.y = _stageHeight;

			}
			else if (_stage.align == StageAlign.TOP_RIGHT)
			{

				_localPointTL.x = _loaderWidth - _stageWidth;
				_localPointTL.y = 0;

				_localPointBR.x = _loaderWidth;
				_localPointBR.y = _stageHeight;

			}
			else if (_stage.align == StageAlign.BOTTOM_LEFT)
			{

				_localPointTL.x = 0;
				_localPointTL.y = _loaderHeight - _stageHeight;

				_localPointBR.x = _stageWidth;
				_localPointBR.y = _loaderHeight;

			}
			else if (_stage.align == StageAlign.BOTTOM_RIGHT)
			{

				_localPointTL.x = _loaderWidth - _stageWidth;
				_localPointTL.y = _loaderHeight - _stageHeight;

				_localPointBR.x = _loaderWidth;
				_localPointBR.y = _loaderHeight;

			}
			else if (_stage.align == StageAlign.TOP)
			{

				_localPointTL.x = _loaderWidth / 2 - _stageWidth / 2;
				_localPointTL.y = 0;

				_localPointBR.x = _loaderWidth / 2 + _stageWidth / 2;
				_localPointBR.y = _stageHeight;

			}
			else if (_stage.align == StageAlign.BOTTOM)
			{

				_localPointTL.x = _loaderWidth / 2 - _stageWidth / 2;
				_localPointTL.y = _loaderHeight - _stageHeight;

				_localPointBR.x = _loaderWidth / 2 + _stageWidth / 2;
				_localPointBR.y = _loaderHeight;

			}
			else if (_stage.align == StageAlign.LEFT)
			{

				_localPointTL.x = 0;
				_localPointTL.y = _loaderHeight / 2 - _stageHeight / 2;

				_localPointBR.x = _stageWidth;
				_localPointBR.y = _loaderHeight / 2 + _stageHeight / 2;

			}
			else if (_stage.align == StageAlign.RIGHT)
			{

				_localPointTL.x = _loaderWidth - _stageWidth;
				_localPointTL.y = _loaderHeight / 2 - _stageHeight / 2;

				_localPointBR.x = _loaderWidth;
				_localPointBR.y = _loaderHeight / 2 + _stageHeight / 2;

			}
			else
			{

				_localPointTL.x = _loaderWidth / 2 - _stageWidth / 2;
				_localPointTL.y = _loaderHeight / 2 - _stageHeight / 2;

				_localPointBR.x = _loaderWidth / 2 + _stageWidth / 2;
				_localPointBR.y = _loaderHeight / 2 + _stageHeight / 2;
			}

			_globalPointTL = container.globalToLocal(_localPointTL);
			_globalPointBR = container.globalToLocal(_localPointBR);

			_miX = _globalPointTL.x;
			_miY = _globalPointTL.y;
			_maX = _globalPointBR.x;
			_maY = _globalPointBR.y;

			if (_minX > _miX)
				_clippingClone.minX = _minX;
			else
				_clippingClone.minX = _miX;

			if (_maxX < _maX)
				_clippingClone.maxX = _maxX;
			else
				_clippingClone.maxX = _maX;

			if (_minY > _miY)
				_clippingClone.minY = _minY;
			else
				_clippingClone.minY = _miY;

			if (_maxY < _maY)
				_clippingClone.maxY = _maxY;
			else
				_clippingClone.maxY = _maY;

			_clippingClone.minZ = _minZ;
			_clippingClone.maxZ = _maxZ;

			return _clippingClone;
		}

		private var _clippingClone:Clipping;
		private var _stage:Stage;
		private var _stageWidth:int;
		private var _stageHeight:int;
		private var _localPointTL:Point = new Point(0, 0);
		private var _localPointBR:Point = new Point(0, 0);
		private var _globalPointTL:Point = new Point(0, 0);
		private var _globalPointBR:Point = new Point(0, 0);
		private var _miX:int;
		private var _miY:int;
		private var _maX:int;
		private var _maY:int;
		private var _clippingupdated:ClippingEvent;
		private var _screenupdated:ClippingEvent;

		protected var _view:View3D;
		protected var _face:Face;
		protected var _faces:Vector.<Face>;
		protected var _screenVertices:Vector.<Number>;
		protected var _uvtData:Vector.<Number>;
		protected var _index:int;
		protected var _indexX:int;
		protected var _indexY:int;
		protected var _indexZ:int;
		protected var _screenVerticesCull:Vector.<int> = new Vector.<int>();
		protected var _cullCount:int;
		protected var _cullTotal:int;
		protected var _minX:int = -100000;
		protected var _minY:int = -100000;
		protected var _minZ:int = -100000;
		protected var _maxX:int = 100000;
		protected var _maxY:int = 100000;
		protected var _maxZ:int = 100000;

		private function onScreenUpdate(event:ClippingEvent):void
		{
			notifyScreenUpdate();
		}

		private function notifyClippingUpdate():void
		{
			if (!hasEventListener(ClippingEvent.CLIPPING_UPDATED))
				return;

			if (_clippingupdated == null)
				_clippingupdated = new ClippingEvent(ClippingEvent.CLIPPING_UPDATED, this);

			dispatchEvent(_clippingupdated);
		}

		private function notifyScreenUpdate():void
		{
			if (!hasEventListener(ClippingEvent.SCREEN_UPDATED))
				return;

			if (_screenupdated == null)
				_screenupdated = new ClippingEvent(ClippingEvent.SCREEN_UPDATED, this);

			dispatchEvent(_screenupdated);
		}

		/**
		 * Minimum allowed x value for primitives.
		 */
		public function get minX():int
		{
			return _minX;
		}

		public function set minX(value:int):void
		{
			if (_minX == int(value))
				return;

			_minX = int(value);

			notifyClippingUpdate();
		}

		/**
		 * Maximum allowed x value for primitives
		 */
		public function get maxX():int
		{
			return _maxX;
		}

		public function set maxX(value:int):void
		{
			if (_maxX == int(value))
				return;

			_maxX = int(value);

			notifyClippingUpdate();
		}

		/**
		 * Minimum allowed y value for primitives
		 */
		public function get minY():int
		{
			return _minY;
		}

		public function set minY(value:int):void
		{
			if (_minY == int(value))
				return;

			_minY = int(value);

			notifyClippingUpdate();
		}

		/**
		 * Maximum allowed y value for primitives
		 */
		public function get maxY():int
		{
			return _maxY;
		}

		public function set maxY(value:int):void
		{
			if (_maxY == int(value))
				return;

			_maxY = int(value);

			notifyClippingUpdate();
		}

		/**
		 * Minimum allowed z value for primitives
		 */
		public function get minZ():int
		{
			return _minZ;
		}

		public function set minZ(value:int):void
		{
			if (_minZ == int(value))
				return;

			_minZ = int(value);

			notifyClippingUpdate();
		}

		/**
		 * Maximum allowed z value for primitives
		 */
		public function get maxZ():int
		{
			return _maxZ;
		}

		public function set maxZ(value:int):void
		{
			if (_maxZ == int(value))
				return;

			_maxZ = int(value);

			notifyClippingUpdate();
		}

		/**
		 * Creates a new <code>Clipping</code> object.
		 *
		 * @param minX	Minimum allowed x value for primitives.
		 * @param maxX	Maximum allowed x value for primitives.
		 * @param minY	Minimum allowed y value for primitives.
		 * @param maxY	Maximum allowed y value for primitives.
		 * @param minZ	Minimum allowed z value for primitives.
		 * @param maxZ	Maximum allowed z value for primitives.
		 */
		public function Clipping(minX:int = -10000, maxX:int = 10000, minY:int = -10000, maxY:int = 10000, minZ:int = -10000, maxZ:int = 10000)
		{
			super();

			_minX = minX;
			_maxX = maxX;
			_minY = minY;
			_maxY = maxY;
			_minZ = minZ;
			_maxZ = maxZ;
		}

		/**
		 * Duplicates the clipping object's properties to another <code>Clipping</code> object
		 *
		 * @param	object	[optional]	The new object instance into which all properties are copied. The default is <code>Clipping</code>.
		 * @return						The new object instance with duplicated properties applied.
		 */
		public function clone(object:Clipping = null):Clipping
		{
			var clipping:Clipping = object || new Clipping();

			clipping.minX = minX;
			clipping.minY = minY;
			clipping.minZ = minZ;
			clipping.maxX = maxX;
			clipping.maxY = maxY;
			clipping.maxZ = maxZ;

			return clipping;
		}

		/**
		 * Used to trace the values of a clipping object.
		 *
		 * @return		A string representation of the clipping object.
		 */
		public override function toString():String
		{
			return "{minX:" + minX + " maxX:" + maxX + " minY:" + minY + " maxY:" + maxY + " minZ:" + minZ + " maxZ:" + maxZ + "}";
		}

		public function get destroyed():Boolean
		{
			return _isDestroyed;
		}

		public function destroy():void
		{
			_isDestroyed = true;

			_clippingClone = null;

			_clippingupdated = null;
			_screenupdated = null;

			_view = null;
			_face = null;
			_faces = null;
			_screenVertices = null;
			_uvtData = null;
			_screenVerticesCull = null;
		}
	}
}