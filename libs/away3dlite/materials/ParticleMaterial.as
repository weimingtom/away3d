package away3dlite.materials
{
	import flash.display.*;
	import flash.geom.Rectangle;

	/**
	 * Base particle material class.
	 */
	public class ParticleMaterial
	{
		/** @private */
		protected var _isDestroyed:Boolean;

		private var _bitmapData:BitmapData;

		public function get bitmapData():BitmapData
		{
			return _bitmapData;
		}

		public function set bitmapData(value:BitmapData):void
		{
			_bitmapData = value;
			rect = new Rectangle(0, 0, width || _bitmapData.width, height || _bitmapData.height);
			currentFrame = 0;
			
			isDirty = true;
		}

		public var isDirty:Boolean;
		public var rect:Rectangle;

		private var _currentFrame:int;
		private var _totalFrames:int;

		public function get width():Number
		{
			return rect.width;
		}

		public function get height():Number
		{
			return rect.height;
		}
		
		/**
		 * Creates a new <code>ParticleMaterial</code> object.
		 */
		public function ParticleMaterial(bitmapData:BitmapData, width:Number = NaN, height:Number = NaN, totalFrames:int = 1)
		{
			_bitmapData = bitmapData;
			rect = new Rectangle(0, 0, width || _bitmapData.width, height || _bitmapData.height);
			
			_totalFrames = totalFrames;
			currentFrame = 0;
			
			isDirty = true;
		}

		public function updateAnimation():void
		{
			nextFrame();
		}
		
		public function nextFrame():void
		{
			_currentFrame++;

			if (_currentFrame >= _totalFrames)
				_currentFrame = 0;

			updateFrame();
		}

		public function get currentFrame():int
		{
			return _currentFrame;
		}

		public function set currentFrame(value:int):void
		{
			if (_currentFrame == value)
				return;

			_currentFrame = value;
			updateFrame();
		}

		private function updateFrame():void
		{
			rect.x = _currentFrame * rect.width;
		}

		public function clone():ParticleMaterial
		{
			return new ParticleMaterial(_bitmapData, width, height, _totalFrames);
		}

		public function get destroyed():Boolean
		{
			return _isDestroyed;
		}

		public function destroy():void
		{
			_isDestroyed = true;

			bitmapData = null;
			rect = null;
		}
	}
}