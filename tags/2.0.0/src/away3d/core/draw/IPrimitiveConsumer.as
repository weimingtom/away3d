package away3d.core.draw
{
    import away3d.core.draw.*;
    import away3d.core.base.*

    /** Interface for containers capable of drawing primitives */
    public interface IPrimitiveConsumer
    {
        function primitive(pri:DrawPrimitive):void;
    }
}
