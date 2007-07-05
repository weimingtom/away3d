package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;
    import flash.geom.*;
    import flash.display.*;

    /** Interface for filters that work on primitive volume blocks */
    public interface IPrimitiveVolumeBlockFilter
    {
        function filter(blocklist:PrimitiveVolumeBlockList, scene:Scene3D, camera:Camera3D, container:Sprite, clip:Clipping):void;
    }
}
