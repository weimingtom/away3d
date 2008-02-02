package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;

    import flash.display.*;

    /** Filter that sorts drawing primitives by z coordinate */
    public class ZSortFilter implements IPrimitiveFilter
    {
        public function filter(primitives:Array, scene:Scene3D, camera:Camera3D, container:Sprite, clip:Clipping):Array
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
