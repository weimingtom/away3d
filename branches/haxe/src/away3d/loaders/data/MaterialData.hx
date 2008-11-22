package away3d.loaders.data;

	import away3d.core.base.*;
	import away3d.materials.*;
	
	import flash.display.BitmapData;
	
	/**
	 * Data class for the material data of a face.
	 * 
	 * @see away3d.loaders.data.FaceData
	 */
	class MaterialData
	 {
		public var material(getMaterial, setMaterial) : IMaterial;
		public function new() {
		materialType = WIREFRAME_MATERIAL;
		elements = [];
		}
		
		var _material:IMaterial;
		var _element:Element;
		
		/**
		 * String representing a texture material.
		 */
		inline public static var TEXTURE_MATERIAL:String = "textureMaterial";
		
		/**
		 * String representing a shaded material.
		 */
		inline public static var SHADING_MATERIAL:String = "shadingMaterial";
		
		/**
		 * String representing a color material.
		 */
		inline public static var COLOR_MATERIAL:String = "colorMaterial";
		
		/**
		 * String representing a wireframe material.
		 */
		inline public static var WIREFRAME_MATERIAL:String = "wireframeMaterial";
		
		/**
		 * The name of the material used as a unique reference.
		 */
		public var name:String;
		
		/**
		 * Optional ambient color of the material.
		 */
		public var ambientColor:UInt;
		
		/**
		 * Optional diffuse color of the material.
		 */
		public var diffuseColor:UInt;
		
		/**
		 * Optional specular color of the material.
		 */
		public var specularColor:UInt;
		
		/**
		 * Optional shininess of the material.
		 */
		public var shininess:Float;
		
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
		public function getMaterial():IMaterial{
        	return _material;
        }
		
		public function setMaterial(val:IMaterial):IMaterial{
        	if (_material == val)
                return;
            
            _material = val;
            
            if (Std.is( _material, IUVMaterial))
            	textureBitmap = (cast( _material, IUVMaterial)).bitmap;
            
            if(Std.is( _material, ITriangleMaterial))
            	for each(_element in elements)
            		(cast( _element, Face)).material = cast( _material, ITriangleMaterial);		
			else if(Std.is( _material, ISegmentMaterial))
            	for each(_element in elements)
            		(cast( _element, Segment)).material = cast( _material, ISegmentMaterial);
        	return val;
        }
        		
		/**
		 * String representing the material type.
		 */
		public var materialType:String ;
		
		/**
		 * Array of indexes representing the elements that use the material.
		 */
		public var elements:Array<Dynamic> ;
	}
