package awaybuilder.utils
{
	import awaybuilder.CoordinateSystem;
	
	
		public class ConvertCoordinates
	{
		public function ConvertCoordinates ( )
		{
		}
		
		
		
		////////////////////////////////////////////////////////////////////////////////
		//
		// Public Methods
		//
		////////////////////////////////////////////////////////////////////////////////
		
		
		
		public static function groupPositionX ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.AFTER_EFFECTS :
				case CoordinateSystem.MAYA :
				case CoordinateSystem.NATIVE :
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function groupPositionY ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.AFTER_EFFECTS :
				case CoordinateSystem.MAYA :
				case CoordinateSystem.NATIVE :
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function groupPositionZ ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.MAYA :
				{
					return n * -1 ;
				}
				case CoordinateSystem.AFTER_EFFECTS :
				case CoordinateSystem.NATIVE :
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function positionX ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.AFTER_EFFECTS :
				case CoordinateSystem.MAYA :
				case CoordinateSystem.NATIVE :
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function positionY ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.AFTER_EFFECTS :
				{
					return -n ;
				}
				case CoordinateSystem.MAYA :
				case CoordinateSystem.NATIVE :
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function positionZ ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.MAYA :
				{
					return n * -1 ;
				}
				case CoordinateSystem.AFTER_EFFECTS :
				case CoordinateSystem.NATIVE :
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function scale ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.AFTER_EFFECTS :
				{
					return n / 100 ;
				}
				case CoordinateSystem.MAYA :
				case CoordinateSystem.NATIVE :
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function groupRotationX ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.AFTER_EFFECTS :
				case CoordinateSystem.MAYA :
				case CoordinateSystem.NATIVE :
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function groupRotationY ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.MAYA :
				{
					return n * -1 ;
				}
				case CoordinateSystem.AFTER_EFFECTS :
				case CoordinateSystem.NATIVE :
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function groupRotationZ ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.AFTER_EFFECTS :
				case CoordinateSystem.MAYA :
				case CoordinateSystem.NATIVE :
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function meshRotationX ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.AFTER_EFFECTS :
				case CoordinateSystem.MAYA :
				{
					return n + 90 ;
				}
				case CoordinateSystem.NATIVE :
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function meshRotationY ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.MAYA :
				{
					return n * -1 ;
				}
				case CoordinateSystem.AFTER_EFFECTS :
				case CoordinateSystem.NATIVE :
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function meshRotationZ ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.AFTER_EFFECTS :
				case CoordinateSystem.MAYA :
				case CoordinateSystem.NATIVE :
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function colladaRotationX ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.MAYA :
				{
					return n + 90 ;
				}
				case CoordinateSystem.AFTER_EFFECTS :
				case CoordinateSystem.NATIVE :
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function colladaRotationY ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.MAYA :
				{
					return n * -1 ;
				}
				case CoordinateSystem.AFTER_EFFECTS :
				case CoordinateSystem.NATIVE :
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function colladaRotationZ ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.AFTER_EFFECTS :
				case CoordinateSystem.MAYA :
				case CoordinateSystem.NATIVE :
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function cameraPositionX ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.AFTER_EFFECTS :
				case CoordinateSystem.MAYA :
				case CoordinateSystem.NATIVE :
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function cameraPositionY ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.AFTER_EFFECTS :
				case CoordinateSystem.MAYA :
				case CoordinateSystem.NATIVE :
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function cameraPositionZ ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.MAYA :
				{
					return n * -1 ;
				}
				case CoordinateSystem.AFTER_EFFECTS :
				case CoordinateSystem.NATIVE :
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function cameraRotationX ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.AFTER_EFFECTS :
				case CoordinateSystem.MAYA :
				case CoordinateSystem.NATIVE :
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function cameraRotationY ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.MAYA :
				{
					return n * -1 ;
				}
				case CoordinateSystem.AFTER_EFFECTS :
				case CoordinateSystem.NATIVE :
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function cameraRotationZ ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.AFTER_EFFECTS :
				{
					return n * -1 ;
				}
				case CoordinateSystem.MAYA :
				case CoordinateSystem.NATIVE :
				default :
				{
					return n ;
				}
			}
		}
	}
}