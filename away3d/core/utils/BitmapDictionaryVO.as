package away3d.core.utils
{
	import flash.display.BitmapData;
	
	public class BitmapDictionaryVO
	{
		public var bitmap:BitmapData;
		public var dirty:Boolean;
		
		public function BitmapDictionaryVO(width:Number, height:Number)
		{
			bitmap = new BitmapData(width, height, true, 0x00000000);
		}
		
		public function clear():void
		{
			bitmap.fillRect(bitmap.rect, 0x00000000);
	        dirty = true;
		}
		
		public function reset(width:Number, height:Number):void
		{
			bitmap.dispose();
			bitmap = new BitmapData(width, height, true, 0x00000000);
			dirty = false;
		}
	}
}