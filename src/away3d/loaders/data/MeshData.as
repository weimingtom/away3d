package away3d.loaders.data
{
	import flash.geom.Matrix;
	
	public class MeshData extends ObjectData
	{
		public var vertices:Array = [];
		public var uvs:Array = [];
		public var faces:Array = [];
		
		/**
		* Assigns materials to the mesh, if one has been assigned in the
		* 3d authoring application.
		*/		
		public var materials:Array = [];
	}
}