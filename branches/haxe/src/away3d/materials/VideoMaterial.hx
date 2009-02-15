package away3d.materials;

import away3d.haxeutils.Error;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.AsyncErrorEvent;
import flash.events.IOErrorEvent;
import flash.events.NetStatusEvent;
import flash.events.SecurityErrorEvent;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.media.SoundTransform;
import fl.video.VideoEvent;
import away3d.core.utils.Init;


// use namespace arcane;

class VideoMaterial extends MovieMaterial  {
	public var time(getTime, null) : Float;
	public var pan(null, setPan) : Float;
	public var volume(null, setVolume) : Float;
	public var file(getFile, setFile) : String;
	public var netStream(getNetStream, setNetStream) : NetStream;
	public var loop(getLoop, setLoop) : Bool;
	public var video(getVideo, setVideo) : Video;
	
	private var _file:String;
	private var _netStream:NetStream;
	private var _video:Video;
	private var _loop:Bool;
	private var _lockW:Float;
	private var _lockH:Float;
	/**
	 * Defines the NetConnection we'll use
	 */
	public var nc:NetConnection;
	/**
	 * Defines the path to the rtmp stream used for rendering the material
	 */
	public var rtmp:String;
	/**
	 * A Sprite we can return to the MovieMaterial
	 */
	public var sprite:Sprite;
	

	private function initStream():Void {
		
		if (rtmp == "") {
			try {
				nc = new NetConnection();
				nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
				nc.connect(null);
				_netStream = new NetStream();
				this._netStream = _netStream;
				// Setup stream. Remember that the FLV must be in the same security sandbox as the SWF.
				_netStream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false, 0, true);
				_netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, ayncErrorHandler, false, 0, true);
				_netStream.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
				_netStream.play(file);
				// ignore metadata
				var anyObject:Dynamic = new Dynamic();
				anyObject.onCuePoint = metaDataHandler;
				anyObject.onMetaData = metaDataHandler;
				_netStream.client = anyObject;
				// Setup video object
				_video = new Video();
				_video.smoothing = true;
				_video.attachNetStream(_netStream);
				sprite.addChild(_video);
				// update the material dimensions
				this.movie = sprite;
				updateDimensions();
			} catch (e:Error) {
				showError("an error has occured with the flv stream:" + e.message);
			}

		} else {
		}
	}

	private function playStream():Void {
		
		_netStream = new NetStream();
		_netStream = _netStream;
		_netStream.checkPolicyFile = true;
		_netStream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false, 0, true);
		_netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, ayncErrorHandler, false, 0, true);
		_netStream.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
		play();
		var anyObject:Dynamic = {};
		anyObject.onMetaData = metaDataHandler;
		_netStream.client = anyObject;
		if (video == null) {
			video = new Video();
			video.smoothing = true;
			sprite.addChild(video);
		}
		video.attachNetStream(_netStream);
	}

	/**
	 * We must update the material
	 */
	private function updateDimensions():Void {
		
		_lockW = ini.getNumber("lockW", movie.width);
		_lockH = ini.getNumber("lockH", movie.height);
		_bitmap = new BitmapData();
	}

	// Event handling
	private function ayncErrorHandler(event:AsyncErrorEvent):Void {
		// Must be present to prevent errors, but won't do anything
		
	}

	private function metaDataHandler(?oData:Dynamic=null):Void {
		// Offers info such as oData.duration, oData.width, oData.height, oData.framerate and more (if encoded into the FLV)
		
		this.dispatchEvent(new VideoEvent());
	}

	private function ioErrorHandler(e:IOErrorEvent):Void {
		
		showError("An IOerror occured: " + e.text);
	}

	private function securityErrorHandler(e:SecurityErrorEvent):Void {
		
		showError("A security error occured: " + e.text + " Remember that the FLV must be in the same security sandbox as your SWF.");
	}

	private function showError(txt:String, ?e:NetStatusEvent=null):Void {
		
		sprite.graphics.beginFill(0x333333);
		sprite.graphics.drawRect(0, 0, 400, 300);
		sprite.graphics.endFill();
		// Error text formatting
		var style:StyleSheet = new StyleSheet();
		var styleObj:Dynamic = new Dynamic();
		styleObj.fontSize = 24;
		styleObj.fontWeight = "bold";
		styleObj.color = "#FF0000";
		style.setStyle("p", styleObj);
		// make textfield
		var text:TextField = new TextField();
		text.width = 400;
		text.multiline = true;
		text.wordWrap = true;
		text.styleSheet = style;
		text.text = "<p>" + txt + "</p>";
		sprite.addChild(text);
		updateDimensions();
	}

	private function netStatusHandler(e:NetStatusEvent):Void {
		
		switch (e.info.code) {
			case "NetStream.Play.Stop" :
				this.dispatchEvent(new VideoEvent());
				if (loop) {
					_netStream.play(file);
				}
			case "NetStream.Play.Play" :
				this.dispatchEvent(new VideoEvent());
			case "NetStream.Play.StreamNotFound" :
				showError("The file " + file + "was not found", e);
			case "NetConnection.Connect.Success" :
				playStream();
			

		}
	}

	/**
	 * Plays the NetStream object. The material plays the NetStream object by default at init. Use this handler only if you pause the NetStream object;
	 */
	public function play():Void {
		
		_netStream.play(file);
	}

	/**
	 * Pauses the NetStream object
	 */
	public function pause():Void {
		
		_netStream.pause();
	}

	/**
	 * Seeks to a given time in the file, specified in seconds, with a precision of three decimal places (milliseconds).
	 * For a progressive download, you can seek only to a keyframe, so a seek takes you to the time of the first keyframe after the specified time. (When streaming, a seek always goes to the precise specified time even if the source FLV file doesn't have a keyframe there.) 
	 * @param	val		Number: the playheadtime
	 */
	public function seek(val:Float):Void {
		
		pause();
		_netStream.seek(val);
		_netStream.resume();
	}

	/**
	 * Returns the actual time of the netStream
	 */
	public function getTime():Float {
		
		return _netStream.time;
	}

	/**
	 * Closes the NetStream object
	 */
	public function close():Void {
		
		_netStream.close();
	}

	/**
	 * The sound pan
	 * @param	val		Number: the sound pan, a value from -1 to 1. Default is 0;
	 */
	public function setPan(val:Float):Float {
		
		var transform:SoundTransform = _netStream.soundTransform;
		transform.pan = val;
		_netStream.soundTransform = transform;
		return val;
	}

	/**
	 * The sound volume
	 * @param	val		Number: the sound volume, a value from 0 to 1. Default is 0;
	 */
	public function setVolume(val:Float):Float {
		
		var transform:SoundTransform = _netStream.soundTransform;
		transform.volume = val;
		_netStream.soundTransform = transform;
		return val;
	}

	/**
	 * The FLV url used for rendering the material
	 */
	public function getFile():String {
		
		return _file;
	}

	public function setFile(file:String):String {
		
		_file = file;
		initStream();
		return file;
	}

	/**
	 * The NetStream object used by the class
	 */
	public function getNetStream():NetStream {
		
		return _netStream;
	}

	public function setNetStream(ns:NetStream):NetStream {
		
		_netStream = ns;
		return ns;
	}

	/**
	 * Defines if the FLV will loop
	 */
	public function getLoop():Bool {
		
		return _loop;
	}

	public function setLoop(b:Bool):Bool {
		
		_loop = b;
		return b;
	}

	/**
	 * The Video Object
	 */
	public function getVideo():Video {
		
		return _video;
	}

	public function setVideo(newvideo:Video):Video {
		
		sprite.removeChild(_video);
		_video = null;
		_video = newvideo;
		_video.smoothing = true;
		sprite.addChild(_video);
		_video.attachNetStream(_netStream);
		return newvideo;
	}

	/**
	 * Creates a new <code>VideoMaterial</code> object.
	 * Pass file:"somevideo.flv" in the initobject or set the file to start playing a video.
	 * Be aware that FLV files must be located in the same domain as the SWF or you will get security errors.
	 * NOTE: rtmp is not yet supported
	 * 
	 * @param	file				The url to the FLV file.
	 * @param	init	[optional]	An initialisation object for specifying default instance properties. loop:Boolean, file:String, rtmp:String.
	 */
	public function new(?init:Dynamic=null) {
		
		
		ini = Init.parse(init);
		loop = ini.getBoolean("loop", false);
		file = ini.getString("file", "");
		rtmp = ini.getString("rtmp", "");
		sprite = new Sprite();
		super(sprite, ini);
		if (file != "") {
			initStream();
		}
	}

}

