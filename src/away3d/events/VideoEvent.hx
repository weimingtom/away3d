package away3d.events;

import flash.events.Event;
import flash.net.NetStream;


/**
 * Passed as a parameter when a material event occurs
 */
class VideoEvent extends Event  {
	
	/**
	 * Dispatched when the video starts playing (NetStream.Play.Start)
	 */
	public static inline var PLAY:String = "onPlay";
	/**
	 * Dispatched when the video stops playing (NetStream.Play.Start)
	 */
	public static inline var STOP:String = "onStop";
	/**
	 * Dispatched when the metadata is downloaded
	 */
	public static inline var METADATA:String = "onMetadata";
	/**
	 * A reference to the NetStream that is relevant to the event.
	 */
	public var stream:NetStream;
	/**
	 * A reference to the FLV that is relevant to the event.
	 */
	public var file:String;
	/**
	 * A reference to the related object (for metadata)
	 */
	public var object:Dynamic;
	

	/**
	 * Creates a new <code>VideoEvent</code> object.
	 * 
	 * @param	type		The type of the event. Possible values are: <code>VideoEvent.START, VideoEvent.STOP and VideoEvent.METADATA</code>.
	 * @param	stream		A reference to the NetStream that is relevant to the event.
	 * @param	file		A reference to the file that is playing on the stream.
	 * @param	stream		A reference to an object passed from the event dispatcher (used for passing the MetaData)
	 */
	public function new(type:String, stream:NetStream, file:String, ?object:Dynamic=null) {
		
		
		super(type);
		this.stream = stream;
		this.file = file;
		this.object = object;
	}

	/**
	 * Creates a copy of the VideoEvent object and sets the value of each property to match that of the original.
	 */
	public override function clone():Event {
		
		return new VideoEvent();
	}

}

