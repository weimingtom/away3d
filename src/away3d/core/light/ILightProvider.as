package away3d.core.light
{
    /**
    * Interface for objects that provide lighting to the scene
    */
    public interface ILightProvider
    {
    	/**
    	 * Called from the <code>PrimitiveTraverser</code> when passing <code>LightPrimitive</code> objects to the light consumer object
    	 * 
    	 * @param	consumer	The consumer instance
    	 * @param	session		The render session of the 3d object
    	 * 
    	 * @see		away3d.core.traverse.PrimitiveTraverser
    	 * @see		away3d.core.light.LightPrimitive
    	 * @see		away3d.core.light.ILightConsumer
    	 */
        function light(consumer:ILightConsumer):void;
    }
}
