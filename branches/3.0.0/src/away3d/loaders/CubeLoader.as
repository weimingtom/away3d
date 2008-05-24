package away3d.loaders
{
    import away3d.materials.*;
    import away3d.core.utils.*;
    import away3d.primitives.*;

    import flash.display.MovieClip;
    import flash.display.Graphics;
    import flash.text.TextField;
    import flash.events.ProgressEvent;
    import flash.events.IOErrorEvent;
 
	/**
	 * Default loader class used as a placeholder for loading 3d content
	 */
    public class CubeLoader extends Object3DLoader
    {
        private var side:MovieClip;
        private var info:TextField;
        private var geometryTitle:String;
		private var textureTitle:String;
        
		/**
		 * Creates a new <code>CubeLoader</code> object.
		 * Not intended for direct use, use the static <code>parse</code> or <code>load</code> methods found on the file loader classes.
		 * 
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function CubeLoader(init:Object = null) 
        {
            super(init);

            side = new MovieClip();
            var graphics:Graphics = side.graphics;
            graphics.lineStyle(1, 0xFFFFFF);
            graphics.drawCircle(50, 50, 50);
            info = new TextField();
            info.wordWrap = true;
            side.addChild(info);
            
            var size:Number = ini.getNumber("loadersize", 200);
            geometryTitle = ini.getString("geometrytitle", "Loading Geometry...");
            textureTitle = ini.getString("texturetitle", "Loading Texture...");

            addChild(new Cube({material:new MovieMaterial(side, {transparent:true, smooth:true}), width:size, height:size, depth:size}));
        }
		
		/**
		 * Listener function for an error event.
		 */
        protected override function onError(event:IOErrorEvent):void 
        {
            super.onError(event);
            info.text = ((mode == LOADING_GEOMETRY)? geometryTitle : textureTitle) + "\n" + event.text;
            var graphics:Graphics = side.graphics;
            graphics.beginFill(0xFF0000);
            graphics.drawRect(0, 0, 100, 100);
            graphics.endFill();
        }
		
		/**
		 * Listener function for a progress event.
		 */
        protected override function onProgress(event:ProgressEvent):void 
        {
            info.text = ((mode == LOADING_GEOMETRY)? geometryTitle : textureTitle) + "\n" + event.bytesLoaded + " of\n" + event.bytesTotal + " bytes";
            var graphics:Graphics = side.graphics;
            graphics.lineStyle(1, 0x808080);
            graphics.drawCircle(50, 50, 50*event.bytesLoaded/event.bytesTotal);
        }
    }
}