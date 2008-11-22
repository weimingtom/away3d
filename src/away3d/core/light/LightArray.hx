package away3d.core.light;


    /**
    * Array for storing light primitives.
    */
    class LightArray implements ILightConsumer {
    	public var ambients(getAmbients, null) : Array<Dynamic>
        ;
    	public var directionals(getDirectionals, null) : Array<Dynamic>
        ;
    	public var numLights(getNumLights, null) : Int
		;
    	public var points(getPoints, null) : Array<Dynamic>
        ;
    	
    	var _ambients:Array<Dynamic>;
    	var _directionals:Array<Dynamic>;
    	var _points:Array<Dynamic>;
    	var _numLights:Int;
    	
    	/**
    	 * The ambient light primitives stored in the consumer.
    	 */
        public function getAmbients():Array<Dynamic>
        {
        	return _ambients;
        }
        
    	/**
    	 * The directional light primitives stored in the consumer.
    	 */
        public function getDirectionals():Array<Dynamic>
        {
        	return _directionals;
        }
        
    	/**
    	 * The point light primitives stored in the consumer.
    	 */
        public function getPoints():Array<Dynamic>
        {
        	return _points;
        }
        
    	/**
    	 * The total number of light primitives stored in the consumer.
    	 */
		public function getNumLights():Int
		{
			return _numLights;
		}
        
		/**
		 * @inheritDoc
		 */
        public function ambientLight(ambient:AmbientLight):Void
        {
            _ambients.push(ambient);
            _numLights++;
        }
        
		/**
		 * @inheritDoc
		 */
        public function directionalLight(directional:DirectionalLight):Void
        {
            _directionals.push(directional);
            _numLights++;
        }
        
		/**
		 * @inheritDoc
		 */
        public function pointLight(point:PointLight):Void
        {
            _points.push(point);
            _numLights++;
        }
        
        /**
        * Clears all light primitives from the consumer.
        */
        public function clear():Void
        {
        	_ambients = [];
	        _directionals = [];
	        _points = [];
	        _numLights = 0;
        }
    }
