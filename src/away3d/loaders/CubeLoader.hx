package away3d.loaders;

import away3d.events.ParserEvent;
import flash.events.ProgressEvent;
import flash.events.Event;
import flash.display.MovieClip;
import flash.events.IOErrorEvent;
import away3d.core.utils.Init;
import flash.text.TextField;
import away3d.primitives.Cube;
import away3d.materials.MovieMaterial;
import flash.text.TextFormat;
import flash.display.Graphics;


/**
 * Default loader class used as a placeholder for loading 3d content
 */
class CubeLoader extends Object3DLoader  {
	
	private var side:MovieClip;
	private var info:TextField;
	private var tf:TextFormat;
	private var geometryTitle:String;
	private var textureTitle:String;
	private var parsingTitle:String;
	

	/**
	 * Creates a new <code>CubeLoader</code> object.
	 * Not intended for direct use, use the static <code>parse</code> or <code>load</code> methods found on the file loader classes.
	 * 
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(?init:Dynamic=null) {
		
		
		super(init);
		side = new MovieClip();
		var graphics:Graphics = side.graphics;
		graphics.lineStyle(1, 0xFFFFFF);
		graphics.drawCircle(100, 100, 100);
		info = new TextField();
		info.width = 200;
		info.height = 200;
		tf = new TextFormat();
		tf.size = 24;
		tf.color = 0x00FFFF;
		tf.bold = true;
		info.wordWrap = true;
		side.addChild(info);
		var size:Float = ini.getNumber("loadersize", 200);
		geometryTitle = ini.getString("geometrytitle", "Loading Geometry...");
		textureTitle = ini.getString("texturetitle", "Loading Texture...");
		parsingTitle = ini.getString("parsingtitle", "Parsing Geometry...");
		addChild(new Cube({material:new MovieMaterial(side, {transparent:true, smooth:true}), width:size, height:size, depth:size}));
	}

	/**
	 * Listener function for an error event.
	 */
	private override function notifyError(event:Event):Void {
		//write message
		
		if (mode == LOADING_GEOMETRY) {
			info.text = geometryTitle + "\n" + (cast(event, IOErrorEvent)).text;
		} else if (mode == PARSING_GEOMETRY) {
			info.text = parsingTitle + "\n" + (cast(event, ParserEvent)).parser;
		} else if (mode == LOADING_TEXTURES) {
			info.text = textureTitle + "\n" + (cast(event, IOErrorEvent)).text;
		}
		info.setTextFormat(tf);
		//draw background
		var graphics:Graphics = side.graphics;
		graphics.beginFill(0xFF0000);
		graphics.drawRect(0, 0, 200, 200);
		graphics.endFill();
		super.notifyError(event);
	}

	/**
	 * Listener function for a progress event.
	 */
	private override function notifyProgress(event:Event):Void {
		
		super.notifyProgress(event);
		//write message
		if (mode == LOADING_GEOMETRY) {
			info.text = geometryTitle + "\n" + (cast(event, ProgressEvent)).bytesLoaded + " of " + (cast(event, ProgressEvent)).bytesTotal + " bytes";
		} else if (mode == PARSING_GEOMETRY) {
			info.text = parsingTitle + "\n" + (cast(event, ParserEvent)).parser.parsedChunks + " of " + (cast(event, ParserEvent)).parser.totalChunks + " chunks";
		} else if (mode == LOADING_TEXTURES) {
			info.text = textureTitle + "\n" + (cast(event, ProgressEvent)).bytesLoaded + " of " + (cast(event, ProgressEvent)).bytesTotal + " bytes";
		}
		info.setTextFormat(tf);
		//draw background
		if (mode == LOADING_GEOMETRY || mode == LOADING_TEXTURES) {
			var graphics:Graphics = side.graphics;
			graphics.lineStyle(1, 0x808080);
			graphics.drawCircle(100, 100, 100 * (cast(event, ProgressEvent)).bytesLoaded / (cast(event, ProgressEvent)).bytesTotal);
		}
	}

}

