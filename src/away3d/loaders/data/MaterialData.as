package away3d.loaders.data
{
	import away3d.core.base.*;
	import away3d.materials.*;
	
	import flash.display.BitmapData;
	
	/**
	 * Data class for the material data of a face.
	 * 
	 * @see away3d.loaders.data.FaceData
	 */
	public class MaterialData
	{
		private var _material:ITriangleMaterial;
		private var _face:Face;
		
		/**
		 * String representing a texture material.
		 */
		public static const TEXTURE_MATERIAL:String = "textureMaterial";
		
		/**
		 * String representing a shaded material.
		 */
		public static const SHADING_MATERIAL:String = "shadingMaterial";
		
		/**
		 * String representing a color material.
		 */
		public static const COLOR_MATERIAL:String = "colorMaterial";
		
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
		 * defines the material object of the resulting material.
		 */
		public function get material():ITriangleMaterial
        {
        	return _material;
        }
		
		public function set material(val:ITriangleMaterial):void
        {
        	if (_material == val)
                return;
            
            _material = val;
            
            if(_material is IUVMaterial)
            	textureBitmap = (_material as IUVMaterial).bitmap;
            
            for each(_face in faces)
            	_face.material = _material;
        }
        		
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