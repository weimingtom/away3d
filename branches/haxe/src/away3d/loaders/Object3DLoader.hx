package away3d.loaders;

import flash.utils.getTimer;
import away3d.loaders.data.ContainerData;
import away3d.containers.ObjectContainer3D;
import flash.events.ProgressEvent;
import flash.events.EventDispatcher;
import away3d.loaders.data.MaterialData;
import away3d.loaders.utils.MaterialLibrary;
import flash.utils.Dictionary;
import flash.events.Event;
import away3d.events.LoaderEvent;
import away3d.core.utils.IClonable;
import flash.events.IOErrorEvent;
import away3d.core.base.Object3D;
import away3d.core.base.Mesh;
import away3d.events.ParserEvent;
import away3d.core.utils.Init;
import away3d.loaders.utils.TextureLoader;
import flash.display.Sprite;
import flash.display.Loader;
import flash.net.URLLoader;
import away3d.loaders.utils.TextureLoadQueue;
import flash.net.URLRequest;


/**
 * Dispatched when the 3d object loader completes a file load successfully.
 * 
 * @eventType away3d.events.LoaderEvent
 */
// [Event(name="loadSuccess", type="away3d.events.LoaderEvent")]

/**
 * Dispatched when the 3d object loader fails to load a file.
 * 
 * @eventType away3d.events.LoaderEvent
 */
// [Event(name="loadError", type="away3d.events.LoaderEvent")]

// use namespace arcane;

/**
 * Abstract loader class used as a placeholder for loading 3d content
 */
class Object3DLoader extends ObjectContainer3D  {
	public var handle(getHandle, null) : Object3D;
	
	private var _broadcaster:Sprite;
	private var Parser:Class;
	public var parser:AbstractParser;
	private var _parseStart:Int;
	private var _parseTime:Int;
	private var _object:Object3D;
	private var _result:Object3D;
	private var _urlloader:URLLoader;
	private var _child:Object3D;
	private var _materialData:MaterialData;
	private var _loadQueue:TextureLoadQueue;
	private var _loadsuccess:LoaderEvent;
	private var _loaderror:LoaderEvent;
	private var _zipsourcesloaded:LoaderEvent;
	/**
	 * Constant value string representing the geometry loading mode of the 3d object loader.
	 */
	public static inline var LOADING_GEOMETRY:String = "loading_geometry";
	/**
	 * Constant value string representing the geometry parsing mode of the 3d object loader.
	 */
	public static inline var PARSING_GEOMETRY:String = "parsing_geometry";
	/**
	 * Constant value string representing the texture loading mode of the 3d object loader.
	 */
	public static inline var LOADING_TEXTURES:String = "loading_textures";
	/**
	 * Constant value string representing a completed loader mode.
	 */
	public static inline var COMPLETE:String = "complete";
	/**
	 * Constant value string representing a problem loader mode.
	 */
	public static inline var ERROR:String = "error";
	/**
	 * Returns the current loading mode of the 3d object loader.
	 */
	public var mode:String;
	/**
	 * Returns the the data container being used by the loaded file.
	 */
	public var containerData:ContainerData;
	/**
	 * Returns the filepath to the directory where any required texture files are located.
	 */
	public var texturePath:String;
	/**
	 * Returns the url string of the file being loaded.
	 */
	public var url:String;
	/**
	 * Defines a timeout period for file parsing (in milliseconds).
	 */
	public var parseTimeout:Int;
	

	/** @private */
	public static function loadGeometry(url:String, Parser:Class, binary:Bool, init:Dynamic):Object3DLoader {
		
		var ini:Init = Init.parse(init);
		var loaderClass:Class = cast(ini.getObject("loader"), Class);
		if (loaderClass == null)  {
			loaderClass = CubeLoader;
		};
		var loader:Object3DLoader = Type.createInstance(loaderClass, []);
		loader.startLoadingGeometry(url, Parser, binary);
		return loader;
	}

	/** @private */
	public static function parseGeometry(data:Dynamic, Parser:Class, init:Dynamic):Object3DLoader {
		
		var ini:Init = Init.parse(init);
		var loaderClass:Class = cast(ini.getObject("loader"), Class);
		if (loaderClass == null)  {
			loaderClass = CubeLoader;
		};
		var loader:Object3DLoader = Type.createInstance(loaderClass, []);
		loader.startParsingGeometry(data, Parser);
		return loader;
	}

	private function registerURL(object:Object3D):Void {
		
		if (Std.is(object, ObjectContainer3D)) {
			for (__i in 0...(cast(object, ObjectContainer3D)).children.length) {
				_child = (cast(object, ObjectContainer3D)).children[__i];

				if (_child != null) {
					registerURL(_child);
				}
			}

		} else if (Std.is(object, Mesh)) {
			(cast(object, Mesh)).url = url;
		}
	}

	private function startLoadingGeometry(url:String, Parser:Class, binary:Bool):Void {
		
		mode = LOADING_GEOMETRY;
		this.Parser = Parser;
		this.url = url;
		_urlloader = new URLLoader();
		_urlloader.dataFormat = binary ? URLLoaderDataFormat.BINARY : URLLoaderDataFormat.TEXT;
		_urlloader.addEventListener(IOErrorEvent.IO_ERROR, onGeometryError);
		_urlloader.addEventListener(ProgressEvent.PROGRESS, onGeometryProgress);
		_urlloader.addEventListener(Event.COMPLETE, onGeometryComplete);
		_urlloader.load(new URLRequest(url));
	}

	private function startParsingGeometry(data:Dynamic, Parser:Class):Void {
		
		_broadcaster.addEventListener(Event.ENTER_FRAME, update);
		mode = PARSING_GEOMETRY;
		_parseStart = flash.Lib.getTimer();
		this.Parser = Parser;
		this.parser = Type.createInstance(Parser, []);
		parser.addEventListener(ParserEvent.PARSE_SUCCESS, onParserComplete, false, 0, true);
		parser.addEventListener(ParserEvent.PARSE_ERROR, onParserError, false, 0, true);
		parser.addEventListener(ParserEvent.PARSE_PROGRESS, onParserProgress, false, 0, true);
		parser.parseNext();
	}

	private function startLoadingTextures():Void {
		
		mode = LOADING_TEXTURES;
		_loadQueue = new TextureLoadQueue();
		var __keys:Iterator<Dynamic> = untyped (__keys__(materialLibrary)).iterator();
		for (__key in __keys) {
			_materialData = materialLibrary[untyped __key];

			if (_materialData != null) {
				if (_materialData.materialType == MaterialData.TEXTURE_MATERIAL && _materialData.material == null) {
					var req:URLRequest = new URLRequest(materialLibrary.texturePath + _materialData.textureFileName);
					var loader:TextureLoader = new TextureLoader();
					_loadQueue.addItem(loader, req);
				}
			}
		}

		_loadQueue.addEventListener(IOErrorEvent.IO_ERROR, onTextureError);
		_loadQueue.addEventListener(ProgressEvent.PROGRESS, onTextureProgress);
		_loadQueue.addEventListener(Event.COMPLETE, onTextureComplete);
		_loadQueue.start();
	}

	private function update(event:Event):Void {
		
		parser.parseNext();
	}

	private function notifySuccess(event:Event):Void {
		
		mode = COMPLETE;
		ini.addForCheck();
		_result = _object;
		_result.transform.multiply(_result.transform, transform);
		_result.name = name;
		_result.ownCanvas = ownCanvas;
		_result.filters = filters;
		_result.visible = visible;
		_result.mouseEnabled = mouseEnabled;
		_result.useHandCursor = useHandCursor;
		_result.alpha = alpha;
		_result.pushback = pushback;
		_result.pushfront = pushfront;
		_result.pivotPoint = pivotPoint;
		_result.extra = (Std.is(extra, IClonable)) ? (cast(extra, IClonable)).clone() : extra;
		if (parent != null) {
			_result.parent = parent;
			parent = null;
		}
		//register url with hierarchy
		registerURL(_result);
		//dispatch event
		if (_loadsuccess == null) {
			_loadsuccess = new LoaderEvent(LoaderEvent.LOAD_SUCCESS, this);
		}
		dispatchEvent(_loadsuccess);
	}

	private function notifyError(event:Event):Void {
		
		mode = ERROR;
		//dispatch event
		if (_loaderror == null) {
			_loaderror = new LoaderEvent(LoaderEvent.LOAD_ERROR, this);
		}
		dispatchEvent(_loaderror);
	}

	private function notifyProgress(event:Event):Void {
		
	}

	/**
	 * Automatically fired on an geometry error event.
	 * 
	 * @see away3d.loaders.utils.TextureLoadQueue
	 */
	private function onGeometryError(event:IOErrorEvent):Void {
		
		notifyError(event);
	}

	/**
	 * Automatically fired on a geometry progress event
	 */
	private function onGeometryProgress(event:ProgressEvent):Void {
		
		notifyProgress(event);
		dispatchEvent(event);
	}

	/**
	 * Automatically fired on a geometry complete event
	 */
	private function onGeometryComplete(event:Event):Void {
		
		startParsingGeometry(_urlloader.data, Parser);
	}

	/**
	 * Automatically fired on an parser error event.
	 * 
	 * @see away3d.loaders.utils.TextureLoadQueue
	 */
	private function onParserError(event:ParserEvent):Void {
		
		_broadcaster.removeEventListener(Event.ENTER_FRAME, update);
		notifyError(event);
	}

	/**
	 * Automatically fired on a parser progress event
	 */
	private function onParserProgress(event:ParserEvent):Void {
		
		notifyProgress(event);
		_parseTime = flash.Lib.getTimer() - _parseStart;
		if (_parseTime < parseTimeout) {
			parser.parseNext();
		} else {
			dispatchEvent(event);
			_parseStart = flash.Lib.getTimer();
		}
	}

	/**
	 * Automatically fired on a parser complete event
	 */
	private function onParserComplete(event:ParserEvent):Void {
		
		_broadcaster.removeEventListener(Event.ENTER_FRAME, update);
		_object = event.result;
		materialLibrary = _object.materialLibrary;
		if ((materialLibrary != null) && materialLibrary.autoLoadTextures && materialLibrary.loadRequired) {
			texturePath = materialLibrary.texturePath;
			startLoadingTextures();
		} else {
			notifySuccess(event);
		}
	}

	/**
	 * Automatically fired on an texture error event.
	 * 
	 * @see away3d.loaders.utils.TextureLoadQueue
	 */
	private function onTextureError(event:IOErrorEvent):Void {
		
		notifyError(event);
	}

	/**
	 * Automatically fired on a texture progress event
	 */
	private function onTextureProgress(event:ProgressEvent):Void {
		
		notifyProgress(event);
		dispatchEvent(event);
	}

	/**
	 * Automatically fired on a texture complete event
	 */
	private function onTextureComplete(event:Event):Void {
		
		materialLibrary.texturesLoaded(_loadQueue);
		notifySuccess(event);
	}

	/**
	 * Returns a 3d object relating to the currently visible model.
	 * While a file is being loaded, this takes the form of the 3d object loader placeholder.
	 * The default placeholder is <code>CubeLoader</code>
	 * 
	 * Once the file has been loaded and is ready to view, the <code>handle</code> returns the 
	 * parsed 3d object file and the placeholder object is swapped in the scenegraph tree.
	 * 
	 * @see	away3d.loaders.CubeLoader
	 */
	public function getHandle():Object3D {
		
		return (_result != null) ? _result : this;
	}

	/**
	 * Creates a new <code>Object3DLoader</code> object.
	 * Not intended for direct use, use the static <code>parse</code> or <code>load</code> methods found on the file loader classes.
	 * 
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(?init:Dynamic=null) {
		this._broadcaster = new Sprite();
		
		
		super(init);
		parseTimeout = Std.int(ini.getNumber("parseTimeout", 40000));
		ini.removeFromCheck();
	}

	/**
	 * Default method for adding a loadsuccess event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnSuccess(listener:Dynamic):Void {
		
		addEventListener(LoaderEvent.LOAD_SUCCESS, listener, false, 0, true);
	}

	/**
	 * Default method for removing a loadsuccess event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnSuccess(listener:Dynamic):Void {
		
		removeEventListener(LoaderEvent.LOAD_SUCCESS, listener, false);
	}

	/**
	 * Default method for adding a loaderror event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnError(listener:Dynamic):Void {
		
		addEventListener(LoaderEvent.LOAD_ERROR, listener, false, 0, true);
	}

	/**
	 * Default method for removing a loaderror event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnError(listener:Dynamic):Void {
		
		removeEventListener(LoaderEvent.LOAD_ERROR, listener, false);
	}

}

