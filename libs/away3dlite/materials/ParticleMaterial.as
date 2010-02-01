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
		private var _bitmapData:BitmapData;
		public var bitmapData:BitmapData;
		
		private var _currentFrame:int;
		private var _totalFrames:int;
		public var rect:Rectangle;
		private var _point:Point = new Point();
		
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
		public function ParticleMaterial(bitmapData:BitmapData, width:Number = NaN, height:Number = NaN, totalFrames:int=1)
		{
			_bitmapData = bitmapData;
			rect = new Rectangle(0, 0, width || _bitmapData.width, height || _bitmapData.height);
			_totalFrames = totalFrames;
			
			this.bitmapData = bitmapData;//new BitmapData(width, height, true, 0x00000000);
			
			currentFrame = 0;
		}
		
		public function nextFrame():void
		{
			if (_currentFrame+1 >= _totalFrames)
			{
				_currentFrame = 1;
			}else{
				_currentFrame++;
			}
			
			update();
		}
		
		public function set currentFrame(value:int):void
		{
			if(_currentFrame == value)
				return;
			
			_currentFrame = value;
			update();
		}
		
		public function update():void
		{
			// seek
			rect.x = _currentFrame * rect.width;
			
			/*
			bitmapData.lock();
			bitmapData.fillRect(bitmapData.rect, 0x00000000);
			bitmapData.copyPixels(_bitmapData, rect, _point, null, null, true);
			bitmapData.unlock();
			*/
		}
	}
}