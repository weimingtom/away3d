package away3d.core.filter
{
	import away3d.cameras.*;
    import away3d.containers.*;
    import away3d.core.render.*;

    /** Interface for filters that work on primitive arrays */
    public interface IPrimitiveFilter
    {
        function filter(primitives:Array, scene:Scene3D, camera:Camera3D, clip:Clipping):Array;
    }
}
