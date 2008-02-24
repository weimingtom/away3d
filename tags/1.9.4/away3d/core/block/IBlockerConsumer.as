package away3d.core.block
{
    import away3d.core.scene.*;
    import away3d.core.draw.*;

    /** Interface for containers capable of storing blockers */
    public interface IBlockerConsumer
    {
        function blocker(block:Blocker):void;
    }
}
