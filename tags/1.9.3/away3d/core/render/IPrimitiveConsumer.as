package away3d.core.render
{
    import away3d.core.draw.*;
    import away3d.core.scene.*;

    /** Interface for containers capable of drawing primitives */
    public interface IPrimitiveConsumer
    {
        function primitive(pri:DrawPrimitive):void;
    }
}
