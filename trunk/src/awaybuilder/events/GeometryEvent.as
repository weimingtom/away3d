package awaybuilder.events
{
	import flash.events.Event;
	
	import awaybuilder.vo.SceneGeometryVO;
	
	
	
	public class GeometryEvent extends Event
	{
		static public const DOWN : String = "GeometryInteractionEvent.DOWN" ;
		static public const MOVE : String = "GeometryInteractionEvent.MOVE" ;
		static public const OUT : String = "GeometryInteractionEvent.OUT" ;
		static public const OVER : String = "GeometryInteractionEvent.OVER" ;
		static public const UP : String = "GeometryInteractionEvent.UP" ;
		
		// getters and setters
		private var _geometry : SceneGeometryVO ;
								public function GeometryEvent ( type : String , bubbles : Boolean = true , cancelable : Boolean = false )
		{
			super ( type , bubbles , cancelable ) ;
		}
		
		
		
		/////////////////////////
		// GETTERS AND SETTERS //
		/////////////////////////
		
		
		
		public function set geometry ( value : SceneGeometryVO ) : void
		{
			this._geometry = value ;
		}
		
		
		
		public function get geometry ( ) : SceneGeometryVO
		{
			return this._geometry ;
		}
	}
}