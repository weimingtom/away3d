package away3d.core.light
{

    /** Interface for containers capable of storing lighting info */
    public interface ILightConsumer
    {
        function ambientLight(ambient:AmbientLightSource):void;
        function directionalLight(directional:DirectionalLightSource):void;
        function pointLight(point:PointLightSource):void;
    }
}
