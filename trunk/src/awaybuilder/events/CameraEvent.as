package awaybuilder.events{	import awaybuilder.vo.SceneCameraVO;	
	
	import flash.events.Event;				public class CameraEvent extends Event	{		static public const ANIMATION_START : String = "CameraEvent.ANIMATION_START" ;		static public const ANIMATION_COMPLETE : String = "CameraEvent.ANIMATION_COMPLETE" ;				// getters and setters		private var _targetCamera : SceneCameraVO ;
		
		
		public function CameraEvent ( type : String , bubbles : Boolean = true , cancelable : Boolean = false )		{			super ( type , bubbles , cancelable ) ;		}								/////////////////////////		// GETTERS AND SETTERS //		/////////////////////////								public function set targetCamera ( value : SceneCameraVO ) : void		{			this._targetCamera = value ;		}								public function get targetCamera ( ) : SceneCameraVO		{			return this._targetCamera ;		}	}}