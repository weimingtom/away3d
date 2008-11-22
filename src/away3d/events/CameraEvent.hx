package away3d.events;

	import away3d.cameras.*;
	
	import flash.events.Event;
    
    /**
    * Passed as a parameter when a session event occurs
    */
    class CameraEvent extends Event {
    	/**
    	 * Defines the value of the type property of a cameraUpdated event object.
    	 */
    	
    	/**
    	 * Defines the value of the type property of a cameraUpdated event object.
    	 */
    	inline public static var CAMERA_UPDATED:String = "cameraUpdated";
    	
    	/**
    	 * A reference to the session object that is relevant to the event.
    	 */
        public var camera:Camera3D;
		
		/**
		 * Creates a new <code>FaceEvent</code> object.
		 * 
		 * @param	type	The type of the event. Possible values are: <code>FaceEvent.UPDATED</code></code>.
		 * @param	camera	A reference to the camera object that is relevant to the event.
		 */
        public function new(type:String, camera:Camera3D)
        {
            super(type);
            this.camera = camera;
        }
		
		/**
		 * Creates a copy of the FaceEvent object and sets the value of each property to match that of the original.
		 */
        public override function clone():Event
        {
            return new CameraEvent(type, camera);
        }
    }
