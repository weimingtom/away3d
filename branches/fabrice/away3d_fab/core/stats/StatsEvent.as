package away3d.core.stats
{
	import flash.events.Event;
	import away3d.core.scene.Camera3D;

	public class StatsEvent extends Event
	{
		public static var RENDER:String = "render";
		
		
		public var totalfaces:Number;
		public var camera:Camera3D;
		
		public function StatsEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false){
			super(type, bubbles, cancelable);
		}
	}
}