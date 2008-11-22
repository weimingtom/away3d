package away3d.core.utils;

	import flash.display.BitmapData;
	
	class FaceDictionaryVO
	 {
		
		public var bitmap:BitmapData;
		public var dirty:Bool;
		
		public function new(?width:Int = 0, ?height:Int = 0)
		{
			if (width && height)
				bitmap = new BitmapData(width, height, true, 0x00000000);
		}
		
		public function clear():Void
		{
			if (bitmap)
				bitmap.fillRect(bitmap.rect, 0x00000000);
	        dirty = true;
		}
		
		public function reset(width:Float, height:Float):Void
		{
			if (bitmap)
				bitmap.dispose();
			bitmap = new BitmapData(width, height, true, 0x00000000);
			dirty = true;
		}
	}
