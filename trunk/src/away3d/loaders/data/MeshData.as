package away3d.loaders.data
{
	import flash.utils.*;
	
	/**
	 * Data class for the mesh data of a 3d object
	 */
	public class MeshData extends ObjectData
	{
		/**
		 * Array of vertex objects.
		 *
		 * @see away3d.core.base.Vertex
		 */
		public var vertices:Array = [];
		
		/**
		 * Array of uv objects.
		 *
		 * see@ away3d.core.base.UV
		 */
		public var uvs:Array = [];
		
		/**
		 * Array of face data objects.
		 *
		 * @see away3d.loaders.data.FaceData
		 */
		public var faces:Array = [];
		
		/**
		* Optional assigned materials to the mesh.
		*/
		public var materials:Array = [];
		
		/**
		 * Colada animation
		 */
		public var bothsides:Boolean;
        public var skinVertices:Array = new Array();
        public var skinControllers:Array = new Array();
	}
}