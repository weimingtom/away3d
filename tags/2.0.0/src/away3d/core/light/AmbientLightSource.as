package away3d.core.light
{
	import away3d.lights.*;
	
	import flash.display.*;

    /** Point light source */
    public class AmbientLightSource extends AbstractLightSource
    {
        public var light:AmbientLight3D;
        
        public function updateAmbientBitmap(ambient:Number):void
        {
        	this.ambient = ambient;
        	ambientBitmap = new BitmapData(256, 256, false, int(ambient*red << 16) | int(ambient*green << 8) | int(ambient*blue));
        	ambientBitmap.lock();
        }
    }
}

