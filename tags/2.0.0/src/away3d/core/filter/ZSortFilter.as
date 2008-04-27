package away3d.core.filter
{
	import away3d.cameras.*;
    import away3d.containers.*;
    import away3d.core.*;
    import away3d.core.base.*
    import away3d.core.draw.*;
    import away3d.core.render.*;

    import flash.display.*;

    /** Filter that sorts drawing primitives by z coordinate */
    public class ZSortFilter implements IPrimitiveFilter
    {
        public function filter(primitives:Array, scene:Scene3D, camera:Camera3D, clip:Clipping):Array
        {
            primitives.sortOn("screenZ", Array.DESCENDING | Array.NUMERIC);
            return primitives;
        }

        public function toString():String
        {
            return "ZSort";
        }
    }
}
