package away3d.core.draw
{
    import away3d.core.draw.*;

    /**
    * Interface for containers capable of drawing primitives
    */
    public interface IPrimitiveConsumer
    {
    	/**
    	 * Adds a drawing primitive to the primitive consumer
    	 *
		 * @param	pri		The drawing primitive to add.
		 */
        function primitive(pri:DrawPrimitive):void;
    }
}
