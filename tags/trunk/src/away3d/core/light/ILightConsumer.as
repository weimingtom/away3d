package away3d.core.light
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.base.*
    
    import flash.display.*;
    import flash.geom.*;

    /** Interface for containers capable of storing lighting info */
    public interface ILightConsumer
    {
        function ambientLight(ambient:AmbientLightSource):void;
        function directionalLight(directional:DirectionalLightSource):void;
        function pointLight(point:PointLightSource):void;
    }
}
