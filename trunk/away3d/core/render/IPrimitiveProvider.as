package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.scene.*;
    
    import flash.display.*;
    import flash.geom.*;

    /** Interface for objects that provide drawing primitives to the rendering process */
    public interface IPrimitiveProvider
    {
        function primitives(projection:Projection, consumer:IPrimitiveConsumer, session:RenderSession):void;
    }
}
