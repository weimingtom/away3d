package away3d.core.block
{
    import away3d.core.proto.*;
    import away3d.core.draw.*;

    public interface IBlockerConsumer
    {
        function blocker(block:Blocker):void;
    }
}
