package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import flash.geom.*;
    import flash.display.*;

    public interface IPrimitiveProvider
    {
        function primitives(projection:Projection, consumer:IPrimitiveConsumer):void;
    }
}
