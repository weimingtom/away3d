package away3d.core.light
{
	import away3d.containers.View3D;
	
    /**
    * Interface for objects that provide lighting to the scene
    */
    public interface ILightProvider
    {
    	/**
    	 * Called from the <code>PrimitiveTraverser</code> when passing <code>LightPrimitive</code> objects to the light consumer object
    	 * 
    	 * @see		away3d.core.traverse.PrimitiveTraverser
    	 * @see		away3d.core.light.LightPrimitive
    	 * @see		away3d.core.light.ILightConsumer
    	 */
        function light():void;
    }
}
