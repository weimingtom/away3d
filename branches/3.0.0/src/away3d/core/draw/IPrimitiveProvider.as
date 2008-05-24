package away3d.core.draw
{
    import away3d.core.draw.*;
    import away3d.core.render.*;

    /**
    * Interface for objects that provide drawing primitives to the rendering process
    */
    public interface IPrimitiveProvider
    {
    	/**
    	 * Called from the <code>PrimitiveTraverser</code> when passing <code>DrawPrimitive</code> objects to the primitive consumer object
    	 * 
    	 * @param	consumer	The consumer instance
    	 * @param	session		The render session of the 3d object
    	 * 
    	 * @see	away3d.core.traverse.PrimitiveTraverser
    	 * @see	away3d.core.draw.DrawPrimitive
    	 */
        function primitives(consumer:IPrimitiveConsumer, session:AbstractRenderSession):void;
    }
}
