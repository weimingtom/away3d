package away3d.core.render
{
    import away3d.core.proto.*;
    import away3d.core.draw.*;

    public interface IPrimitiveConsumer
    {
        function primitive(tri:DrawPrimitive):void;
    }
}
