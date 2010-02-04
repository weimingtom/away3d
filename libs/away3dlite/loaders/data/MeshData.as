package away3dlite.loaders.data
{
	/**
	 * Data class for the mesh data of a 3d object
	 */
	public class MeshData extends ObjectData
	{
		public var material:MaterialData;
		/**
		 * Defines the geometry used by the mesh instance
		 */
		public var geometry:GeometryData;
		 
		/**
		 *
		 */
		public var skeleton:String;

		/**
		 * Copy the mesh data into another <code>MeshData</code> object.
		 */
		public override function copyTo(dst:ObjectData):void
		{
			super.copyTo(dst as ObjectData);
			
			(dst as MeshData).material = material;
			(dst as MeshData).geometry = geometry;
			(dst as MeshData).skeleton = skeleton;
		}
	}
}