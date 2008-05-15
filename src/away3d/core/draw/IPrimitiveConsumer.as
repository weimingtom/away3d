package away3d.core.draw
{
    import away3d.core.draw.*;

    /** Interface for containers capable of drawing primitives */
    public interface IPrimitiveConsumer
    {
        function primitive(pri:DrawPrimitive):void;
    }
}
