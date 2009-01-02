package away3d.loaders.data
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	public class FontData extends EventDispatcher
	{
		protected var _glyfs:Dictionary;
		protected var _dims:Dictionary;
		protected var _initialized:Boolean;
		
		public function FontData()
		{
			_glyfs = new Dictionary();
			_dims = new Dictionary();
			
			_glyfs['nochar'] = [['M', 0, 0], ['L', 50, 0], ['L', 50, 50], ['L', 0, 50], ['L', 0, 0]];
			_dims['nochar'] = [60, 60];
		}
		
		public function reportChanges():void
		{
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get glyfs():Dictionary
		{
			if(!_initialized)
				initialize();
				
			return _glyfs;
		}
		
		public function get dims():Dictionary
		{
			if(!_initialized)
				initialize();
				
			return _dims;
		}
		
		public function initialize():void
		{
			//Must be overriden by a particular font class.
		}
	}
}