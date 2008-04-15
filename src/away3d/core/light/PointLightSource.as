package away3d.core.light
{
	import away3d.core.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.math.*;
	import away3d.lights.*;
	
	import flash.geom.*;

    /** Point light source */
    public class PointLightSource extends AbstractLightSource
    {
        public var x:Number;
        public var y:Number;
        public var z:Number;
        
        public var light:PointLight3D;
    }
}

