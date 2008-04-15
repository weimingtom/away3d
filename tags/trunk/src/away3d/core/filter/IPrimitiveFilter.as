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

    /** Interface for filters that work on primitive arrays */
    public interface IPrimitiveFilter
    {
        function filter(primitives:Array, scene:Scene3D, camera:Camera3D, clip:Clipping):Array;
    }
}
