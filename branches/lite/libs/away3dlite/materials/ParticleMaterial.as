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
		
		private var _currentFrame:int = 1;
		private var _totalFrames:int = 1;
		private var _rect:Rectangle;
		private var _point:Point = new Point();
		
		public function get width():Number
		{
			return _rect.width;
		}
		
		public function get height():Number
		{
			return _rect.width;
		}

		/**
		 * Creates a new <code>ParticleMaterial</code> object.
		 */
		public function ParticleMaterial(__bitmapData:BitmapData, width:Number = NaN, height:Number = NaN, totalFrames:int=1)
		{
			_bitmapData = __bitmapData;
			_rect = new Rectangle(0, 0, width || _bitmapData.width, height || _bitmapData.height);
			_totalFrames = totalFrames;
			
			this.bitmapData = new BitmapData(width, height, true, 0x00000000);
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
			_currentFrame = value;
			update();
		}
		
		public function update():void
		{
			// seek
			_rect.x = _currentFrame * _rect.width;
			
			bitmapData.lock();
			bitmapData.fillRect(bitmapData.rect, 0x00000000);
			bitmapData.copyPixels(_bitmapData, _rect, _point, null, null, true);
			bitmapData.unlock();
		}
	}
}