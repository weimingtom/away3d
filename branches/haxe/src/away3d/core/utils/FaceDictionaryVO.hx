package away3d.core.utils;

import flash.display.BitmapData;


class FaceDictionaryVO  {
	
	public var bitmap:BitmapData;
	public var dirty:Bool;
	

	public function new(?width:Float=0, ?height:Float=0) {
		
		
		if ((width > 0) && (height > 0)) {
			bitmap = new BitmapData();
		}
	}

	public function clear():Void {
		
		if ((bitmap != null)) {
			bitmap.fillRect(bitmap.rect, 0x00000000);
		}
		dirty = true;
	}

	public function reset(width:Float, height:Float):Void {
		
		if ((bitmap != null)) {
			bitmap.dispose();
		}
		bitmap = new BitmapData();
		dirty = true;
	}

}

