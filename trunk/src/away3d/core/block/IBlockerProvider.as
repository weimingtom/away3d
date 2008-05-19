package away3d.core.block
{

    /**
    * Interface for objects that provide blocker instances for occlusion culling in the renderer.
    */
    public interface IBlockerProvider
    {
    	/**
    	 * Called from the <code>BlockerTraverser</code> when passing <code>Blocker/code> objects to the blocker consumer object
    	 * 
    	 * @param	consumer	The consumer instance
    	 * @param	session		The render session of the 3d object
    	 * 
    	 * @see		away3d.core.traverse.BlockerTraverser
    	 * @see		away3d.core.block.Blocker
    	 */
        function blockers(consumer:IBlockerConsumer):void;
    }
}
