package away3d.core.graphs
{
	public interface ITreeNode
	{
		function get leftChild() : ITreeNode;
		function get rightChild() : ITreeNode;
		function get parent() : ITreeNode;
	}
}