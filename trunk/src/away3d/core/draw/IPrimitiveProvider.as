package away3d.core.draw
{
    import away3d.core.draw.*;
    import away3d.core.render.*;

    /** Interface for objects that provide drawing primitives to the rendering process */
    public interface IPrimitiveProvider
    {
        function primitives(consumer:IPrimitiveConsumer, session:AbstractRenderSession):void;
    }
}
