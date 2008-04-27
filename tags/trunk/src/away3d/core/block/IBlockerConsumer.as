package away3d.core.block
{

    /** Interface for containers capable of storing blockers */
    public interface IBlockerConsumer
    {
        function blocker(block:Blocker):void;
    }
}
