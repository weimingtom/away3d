package away3d.haxeutils {
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	public class TimerUtils extends Sprite {
		
	
		private var timeStart:Dictionary;
		private var timeEnd:Dictionary;
		private var nPasses:Dictionary;
		private var timerText:TextField;
		
		private static var instance:TimerUtils;
		
		public function TimerUtils() {
					
			// Create a text field						
			timerText = new TextField();
			timerText.autoSize = TextFieldAutoSize.LEFT;
			addChild(timerText);
			timerText.text = "";

			timeStart = new Dictionary();
			timeEnd = new Dictionary();
			nPasses = new Dictionary();
		}
	
		public static function getInstance():TimerUtils {
			if (instance == null) {
				instance = new TimerUtils();
			}
			return instance;
		}	
		
	
		public function tickStart(id:String):void {
			timeStart[id] = getTimer();
		}
		
		public function tickEnd(id:String):void {
			if (timeStart[id] != null) {
				var timePassed:int = getTimer() - timeStart[id];
				var cumulativeTime:int = 0;
				var iter:int = 0;
				if (timeEnd[id] != null) {
					cumulativeTime = timeEnd[id];
					iter = nPasses[id];
				}
				
				timeEnd[id] = timePassed + cumulativeTime;
				nPasses[id] = iter + 1;
				
			}
		}
		
		public function display():void {
			var text:String = "";
			for (var key:String in timeEnd) {
				text = text + key + " ----> " + timeEnd[key] + " / " + nPasses[key] + "\n"; 
			}
			
			timerText.text = text;
		}


	}
}