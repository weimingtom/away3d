package away3d.core.proto
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import flash.geom.*;
    import flash.display.*;

    public interface ILightSource
    {
        function light(position:Matrix3D, consumer:ILightConsumer, transform:Matrix3D):void;
    }
}
