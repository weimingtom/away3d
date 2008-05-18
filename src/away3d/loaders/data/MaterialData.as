package away3d.loaders.data
{
	import away3d.materials.ITriangleMaterial;
	
	import flash.display.BitmapData;
	
	/**
	 * Data class for the material data of a face.
	 * 
	 * @see away3d.loaders.data.FaceData
	 */
	public class MaterialData
	{
		/**
		 * String representing a texture material.
		 */
		public static const TEXTURE_MATERIAL:String = "textureMaterial";
		
		/**
		 * String representing a shaded material.
		 */
		public static const SHADING_MATERIAL:String = "shadingMaterial";
		
		/**
		 * String representing a wireframe material.
		 */
		public static const WIREFRAME_MATERIAL:String = "wireframeMaterial";
		
		/**
		 * The name of the material used as a unique reference.
		 */
		public var name:String;
		
		/**
		 * Optional ambient color of the material.
		 */
		public var ambientColor:int;
		
		/**
		 * Optional diffuse color of the material.
		 */
		public var diffuseColor:int;
		
		/**
		 * Optional specular color of the material.
		 */
		public var specularColor:int;
		
		/**
		 * Reference to the filename of the texture image.
		 */
		public var textureFileName:String;
		
		/**
		 * Reference to the bitmapData object of the texture image.
		 */
		public var textureBitmap:BitmapData;
		
		/**
		 * Reference to the material object of the resulting material.
		 */
		public var material:ITriangleMaterial;
		
		/**
		 * String representing the material type.
		 */
		public var materialType:String = WIREFRAME_MATERIAL;
		
		/**
		 * Array of indexes representing the faces that use the material.
		 */
		public var faces:Array = [];
	}
}