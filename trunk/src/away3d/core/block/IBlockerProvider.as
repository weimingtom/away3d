package away3d.core.block
{

    /** Interface for objects that provide blockers instances for rendering occlusion culling */
    public interface IBlockerProvider
    {
        function blockers(consumer:IBlockerConsumer):void;
    }
}
