package away3d.loaders.data
{
	public class MeshData
	{
		public var name:String;
		public var vertices:Array = [];
		public var uvs:Array = [];
		public var faces:Array = [];
		
		/**
		* Assigns a materials to the mesh, if one has been assigned in the
		* 3d authoring application.
		*/		
		public var materials:Array = [];
		
		// currently there is support for only one material per mesh
		public function get material():MeshMaterialData
		{
			if (materials.length > 0)
				return (materials[0] as MeshMaterialData);
			
			return null;
		}
	}
}