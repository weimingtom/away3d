package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import flash.geom.*;
    import flash.display.*;

    public interface IPrimitiveFilter
    {
        function filter(primitives:Array, scene:Scene3D, camera:Camera3D, container:Sprite, clip:Clipping):Array;
    }
}
