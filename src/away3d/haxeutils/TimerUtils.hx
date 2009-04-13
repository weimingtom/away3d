package away3d.haxeutils;

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

class TimerUtils extends Sprite {
	
	
	private var timeStart:Hash<Int>;
	private var cumulativeTimes:Hash<Int>;
	private var nPasses:Hash<Int>;
	private var timerText:TextField;
	
	
	private static var instance:TimerUtils = null;
	
	private function new() {
		super();
				
		// Create a text field						
		timerText = new TextField();
		timerText.autoSize = TextFieldAutoSize.LEFT;
		addChild(timerText);
		timerText.text = "";

		timeStart = new Hash<Int>();
		cumulativeTimes = new Hash<Int>();
		nPasses = new Hash<Int>();
	}

	public static function getInstance():TimerUtils {
		if (instance == null) {
			instance = new TimerUtils();
		}
		return instance;
	}	
	

	public function tickStart(id:String):Void {
		timeStart.set(id, flash.Lib.getTimer());
	}
	
	public function tickEnd(id:String):Void {
		if (timeStart.get(id) != null) {
			var timePassed:Int = flash.Lib.getTimer() - timeStart.get(id);
			var cumulativeTime:Int = 0;
			var iter:Int = 0;
			if (cumulativeTimes.get(id) != null) {
				cumulativeTime = cumulativeTimes.get(id);
				iter = nPasses.get(id);
			}
			
			cumulativeTimes.set(id, timePassed + cumulativeTime);
			nPasses.set(id, iter + 1);
			
		}
	}
	
	public function display():Void {
		var text:String = "";
		for (key in cumulativeTimes.keys()) {
			text = text + key + " ----> " + cumulativeTimes.get(key) + " / " + nPasses.get(key) + "\n"; 
		}
		
		timerText.text = text;
	}

}





