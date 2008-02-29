package away3d.loaders.data
{
	import away3d.core.material.ITriangleMaterial;
	
	import flash.display.BitmapData;
	
	public class MaterialData
	{
		public static const TEXTURE_MATERIAL:String = "textureMaterial";
		public static const SHADING_MATERIAL:String = "shadingMaterial";
		public static const WIREFRAME_MATERIAL:String = "wireframeMaterial";
		
		public var name:String;
		
		public var ambientColor:int;
		public var diffuseColor:int;
		public var specularColor:int;
		public var textureFileName:String;
		public var textureBitmap:BitmapData;
		
		public var material:ITriangleMaterial;
		
		public var materialType:String = WIREFRAME_MATERIAL;
		
		public var faces:Array = [];
	}
}