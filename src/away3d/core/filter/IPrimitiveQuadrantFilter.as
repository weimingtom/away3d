package away3d.core.filter
{
	import away3d.cameras.*;
    import away3d.containers.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;

    /** Interface for filters that work on primitive quadrant trees */
    public interface IPrimitiveQuadrantFilter
    {
        function filter(pritree:PrimitiveQuadrantTree, scene:Scene3D, camera:Camera3D, clip:Clipping):void;
    }
}
