package away3d.core.filter
{
	import away3d.cameras.*;
    import away3d.containers.*;
    import away3d.core.*;
    import away3d.core.base.*
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import flash.geom.*;
    import flash.display.*;

    /** Interface for filters that work on primitive volume blocks */
    public interface IPrimitiveVolumeBlockFilter
    {
        function filter(blocklist:PrimitiveVolumeBlockList, scene:Scene3D, camera:Camera3D, container:Sprite, clip:Clipping):void;
    }
}
