package away3d.haxeutils;

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.utils.Dictionary;

class TimerUtils extends Sprite {
	
	
	private var timeStart:Dictionary;
	private var cumulativeTimes:Dictionary;
	private var nPasses:Dictionary;
	private var timerText:TextField;
	
	
	private static var instance:TimerUtils = null;
	
	private function new() {
		super();
				
		// Create a text field						
		timerText = new TextField();
		timerText.autoSize = TextFieldAutoSize.LEFT;
		addChild(timerText);
		timerText.text = "";

		timeStart = new Dictionary();
		cumulativeTimes = new Dictionary();
		nPasses = new Dictionary();
	}

	public static function getInstance():TimerUtils {
		if (instance == null) {
			instance = new TimerUtils();
		}
		return instance;
	}	
	

	public function tickStart(id:String):Void {
		timeStart[untyped id] = flash.Lib.getTimer();
	}
	
	public function tickEnd(id:String):Void {
		if (timeStart[untyped id] != null) {
			var timePassed:Int = flash.Lib.getTimer() - timeStart[untyped id];
			var cumulativeTime:Int = 0;
			var iter:Int = 0;
			if (cumulativeTimes[untyped id] != null) {
				cumulativeTime = cumulativeTimes[untyped id];
				iter = nPasses[untyped id];
			}
			
			cumulativeTimes[untyped id] = timePassed + cumulativeTime;
			nPasses[untyped id] = iter + 1;
			
		}
	}
	
	public function display():Void {
		var text:String = "";
		var __keys:Iterator<Dynamic> = untyped (__keys__(cumulativeTimes)).iterator();
		for (key in __keys) {
			text = text + key + " ----> " + cumulativeTimes[untyped key] + " / " + nPasses[untyped key] + "\n"; 
		}
		
		timerText.text = text;
	}

}





