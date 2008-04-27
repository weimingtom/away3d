package away3d.core.light
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;

    /** Interface for objects that provide lighting to the scene */
    public interface ILightProvider
    {
        function light(consumer:ILightConsumer):void;
    }
}
