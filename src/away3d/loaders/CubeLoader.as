package away3d.loaders
{
    import away3d.core.utils.*;
    import away3d.events.ParserEvent;
    import away3d.materials.*;
    import away3d.primitives.*;
    
    import flash.display.*;
    import flash.events.*;
    import flash.text.*;
 
	/**
	 * Default loader class used as a placeholder for loading 3d content
	 */
    public class CubeLoader extends Object3DLoader
    {
        private var side:MovieClip;
        private var info:TextField;
        private var tf:TextFormat;
        private var geometryTitle:String;
		private var textureTitle:String;
		private var parsingTitle:String;
        
		/**
		 * Creates a new <code>CubeLoader</code> object.
		 * 
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function CubeLoader(init:Object = null) 
        {
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
            
            var size:Number = ini.getNumber("loadersize", 200);
            geometryTitle = ini.getString("geometrytitle", "Loading Geometry...");
            textureTitle = ini.getString("texturetitle", "Loading Texture...");
            parsingTitle = ini.getString("parsingtitle", "Parsing Geometry...");

            addChild(new Cube({material:new MovieMaterial(side, {transparent:true, smooth:true}), width:size, height:size, depth:size}));
        }
		
		/**
		 * Listener function for an error event.
		 */
        protected override function notifyError():void 
        {
        	super.notifyError();
        	
        	//write message
        	if (mode == LOADING_GEOMETRY)
        		info.text = geometryTitle + "\n" + IOErrorText;
        	else if (mode == PARSING_GEOMETRY)
        		info.text = parsingTitle + "\n" + parser;
        	else if (mode == LOADING_TEXTURES)
        		info.text = textureTitle + "\n" + IOErrorText;
        	
        	info.setTextFormat(tf);
        	
        	//draw background
            var graphics:Graphics = side.graphics;
            graphics.beginFill(0xFF0000);
            graphics.drawRect(0, 0, 200, 200);
            graphics.endFill();
        }
		
		/**
		 * Listener function for a progress event.
		 */
        protected override function notifyProgress():void 
        {
        	super.notifyProgress();
        	
        	//write message
        	if (mode == LOADING_GEOMETRY)
        		info.text = geometryTitle + "\n" + bytesLoaded + " of " + bytesTotal + " bytes";
        	else if (mode == PARSING_GEOMETRY)
        		info.text = parsingTitle + "\n" + parser.parsedChunks + " of " + parser.totalChunks + " chunks";
        	else if (mode == LOADING_TEXTURES)
        		info.text = textureTitle + "\n" + bytesLoaded + " of " + bytesTotal + " bytes";
        	
            info.setTextFormat(tf);
            
            //draw background
            if (mode == LOADING_GEOMETRY || mode == LOADING_TEXTURES) {
	            var graphics:Graphics = side.graphics;
	            graphics.lineStyle(1, 0x808080);
	            graphics.drawCircle(100, 100, 100*bytesLoaded/bytesTotal);
	        }
        }
    }
}