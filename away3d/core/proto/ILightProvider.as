package away3d.core.proto
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.render.*;
    import flash.geom.*;
    import flash.display.*;

    /** Interface for objects that provide lighting to the scene */
    public interface ILightProvider
    {
        function light(projection:Projection, consumer:ILightConsumer):void;
    }
}
