package away3d.loaders.data
{
	import away3d.core.math.Matrix3D;
	import away3d.core.math.Number3D;
	/**
	 * Data class for 3d object containers.
	 */
	public class ContainerData extends ObjectData
	{
		/**
		 * An array containing the child 3d objects of the container.
		 */
		public var children:Array = [];
	}
}