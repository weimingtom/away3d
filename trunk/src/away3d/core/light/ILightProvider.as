package away3d.core.light
{

    /** Interface for objects that provide lighting to the scene */
    public interface ILightProvider
    {
        function light(consumer:ILightConsumer):void;
    }
}
