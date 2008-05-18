package away3d.core.light
{

    /** Interface for containers capable of storing lighting info */
    public interface ILightConsumer
    {
        function ambientLight(ambient:AmbientLight):void;
        function directionalLight(directional:DirectionalLight):void;
        function pointLight(point:PointLight):void;
    }
}
