package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;
    import flash.geom.*;
    import flash.display.*;

    /** Interface for filters that work on primitive quadrant trees */
    public interface IPrimitiveQuadrantFilter
    {
        function filter(pritree:PrimitiveQuadrantTree, scene:Scene3D, camera:Camera3D, container:Sprite, clip:Clipping):void;
    }
}
