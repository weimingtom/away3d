package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import flash.geom.*;
    import flash.display.*;

    public interface IPrimitiveVolumeBlockFilter
    {
        function filter(blocklist:PrimitiveVolumeBlockList, scene:Scene3D, camera:Camera3D, container:Sprite, clip:Clipping):void;
    }
}
