package away3d.core.light
{

    /** Array of light sources */
    public class LightArray implements ILightConsumer
    {
        public var ambients:Array;
        public var directionals:Array;
        public var points:Array;
		public var numLights:int;
		
        public function ambientLight(ambient:AmbientLight):void
        {
            ambients.push(ambient);
            numLights++;
        }

        public function directionalLight(directional:DirectionalLight):void
        {
            directionals.push(directional);
            numLights++;
        }
		
        public function pointLight(point:PointLight):void
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

