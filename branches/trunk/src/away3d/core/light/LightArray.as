package away3d.core.light
{

    /**
    * Array for storing light primitives.
    */
    public class LightArray implements ILightConsumer
    {
    	/**
    	 * The ambient light primitives stored in the consumer.
    	 */
        public var ambients:Array;
        
    	/**
    	 * The directional light primitives stored in the consumer.
    	 */
        public var directionals:Array;
        
    	/**
    	 * The point light primitives stored in the consumer.
    	 */
        public var points:Array;
        
    	/**
    	 * The total number of light primitives stored in the consumer.
    	 */
		public var numLights:int;
        
		/**
		 * @inheritDoc
		 */
        public function ambientLight(ambient:AmbientLight):void
        {
            ambients.push(ambient);
            numLights++;
        }
        
		/**
		 * @inheritDoc
		 */
        public function directionalLight(directional:DirectionalLight):void
        {
            directionals.push(directional);
            numLights++;
        }
        
		/**
		 * @inheritDoc
		 */
        public function pointLight(point:PointLight):void
        {
            points.push(point);
            numLights++;
        }
        
        /**
        * Clears all light primitives from the consumer.
        */
        public function clear():void
        {
        	ambients = [];
	        directionals = [];
	        points = [];
	        numLights = 0;
        }
    }
}

