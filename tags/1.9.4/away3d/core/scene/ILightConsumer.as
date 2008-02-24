package away3d.core.scene
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    
    import flash.display.*;
    import flash.geom.*;

    /** Interface for containers capable of storing lighting info */
    public interface ILightConsumer
    {
        function ambientLight(color:int, ambient:Number):void;
        function directedLight(direction:Number3D, color:int, diffuse:Number):void;
        function pointLight(source:Matrix3D, light:Light3D, color:int, ambient:Number, diffuse:Number, specular:Number):void;
    }
}
