package away3d.core.block
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import flash.geom.*;
    import flash.display.*;

    /** Interface for objects that provide blockers instances for rendering occlusion culling */
    public interface IBlockerProvider
    {
        function blockers(consumer:IBlockerConsumer):void;
    }
}
