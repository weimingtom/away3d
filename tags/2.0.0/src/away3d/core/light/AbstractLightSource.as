package away3d.core.light
{	
	import flash.display.*;

    /** Abstract light source */
    public class AbstractLightSource
    {
 
        public var red:Number;
        public var green:Number;
        public var blue:Number;
        
        public var ambient:Number;
        public var diffuse:Number;
        public var specular:Number;
        
        public var ambientBitmap:BitmapData;
        public var diffuseBitmap:BitmapData;
        public var ambientDiffuseBitmap:BitmapData;
    	public var specularBitmap:BitmapData;
	}
}