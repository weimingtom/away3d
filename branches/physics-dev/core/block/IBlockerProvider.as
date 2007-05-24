package away3d.core.block
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import flash.geom.*;
    import flash.display.*;

    public interface IBlockerProvider
    {
        function blockers(projection:Projection, consumer:IBlockerConsumer):void;
    }
}
