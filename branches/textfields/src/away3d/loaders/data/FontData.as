package away3d.loaders.data
{
	import flash.utils.Dictionary;
	
	public class FontData
	{
		protected var _glyfs:Dictionary = new Dictionary();
		protected var _dims:Dictionary = new Dictionary();
		protected var _initialized:Boolean = false;
		
		public function FontData()
		{
			
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