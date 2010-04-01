package away3dlite.materials
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * Base particle material class.
	 */
	public class ParticleMaterial
	{
		public var bitmapData:BitmapData;
		public var rect:Rectangle;

		private var _currentFrame:int;
		private var _totalFrames:int;

		public function get width():Number
		{
			return rect.width;
		}

		public function get height():Number
		{
			return rect.width;
		}

		/**
		 * Creates a new <code>ParticleMaterial</code> object.
		 */
		public function ParticleMaterial(bitmapData:BitmapData, width:Number = NaN, height:Number = NaN, totalFrames:int = 1)
		{
			rect = new Rectangle(0, 0, width || bitmapData.width, height || bitmapData.height);
			_totalFrames = totalFrames;

			this.bitmapData = bitmapData;

			currentFrame = 0;
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
			return new ParticleMaterial(bitmapData, width, height, _totalFrames);
		}
	}
}