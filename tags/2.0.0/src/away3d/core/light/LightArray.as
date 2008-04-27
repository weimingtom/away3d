package away3d.core.light
{
    import away3d.core.*;
    import away3d.core.base.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    
    import flash.geom.*;

    /** Array of light sources */
    public class LightArray implements ILightConsumer
    {
        public var ambients:Array;
        public var directionals:Array;
        public var points:Array;
		public var numLights:int;
		
        public function ambientLight(ambient:AmbientLightSource):void
        {
            ambients.push(ambient);
            numLights++;
        }

        public function directionalLight(directional:DirectionalLightSource):void
        {
            directionals.push(directional);
            numLights++;
        }
		
        public function pointLight(point:PointLightSource):void
        {
            points.push(point);
            numLights++;
        }
        
        public function clear():void
        {
        	ambients = [];
	        directionals = [];
	        points = [];
	        numLights = 0;
        }
    }
}

