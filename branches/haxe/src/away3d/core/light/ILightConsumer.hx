package away3d.core.light;


    /**
    * Interface for containers capable of storing lighting info
    */
    interface ILightConsumer
    {
    	function ambients():Array<Dynamic>;
    	function directionals():Array<Dynamic>;
    	function points():Array<Dynamic>;
    	function numLights():Int;
    	
    	/**
    	 * Adds an ambient light primitive to the light consumer.
    	 *
		 * @param	ambient			The light primitive to add.
		 */
        function ambientLight(ambient:AmbientLight):Void;
        
    	/**
    	 * Adds an directional light primitive to the light consumer.
    	 *
		 * @param	directional		The light primitive to add.
		 */
        function directionalLight(directional:DirectionalLight):Void;
        
    	/**
    	 * Adds an point light primitive to the light consumer.
    	 *
		 * @param	point			The light primitive to add.
		 */
        function pointLight(point:PointLight):Void;
        
        function clear():Void;
    }
